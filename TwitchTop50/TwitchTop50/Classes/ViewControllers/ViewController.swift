//
//  ViewController.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 24/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import UIKit

import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Games UITableView
    @IBOutlet var tableView: UITableView!
    
    // Cache for game images
    var imageCache: NSCache = NSCache()
    
    // Pull to refresh control
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    // CoreData context for saving and fetching games
    var managedObjectContext: NSManagedObjectContext?
    
    // FetchedResultsController for fetching games and feed table view
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: Game.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "viewers", ascending: false)]
        fetchRequest.fetchLimit = 50
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addTarget(self, action: "handlePullToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.startGamesLoading()
        
        self.fetchResults()
    }
    
    // MARK: UI manipulation
    
    // Callback for pull to refresh action
    func handlePullToRefresh(refreshControl: UIRefreshControl) {
        self.startGamesLoading()
    }
    
    // Starts loading of data
    func startGamesLoading() {
        self.refreshControl.beginRefreshing()
        self.loadGamesData()
    }
    
    // Shows connection error UIAlertController
    func showConnectionErrorAlertController() {
        dispatch_async(dispatch_get_main_queue()) {
            
            let alert = UIAlertController(title: NSLocalizedString("Twitch Top 50", comment: ""), message: NSLocalizedString("Ocorreu um problema ao tentar baixar a lista de jogos :(", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    // MARK: UITableView Data Source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ = self.fetchedResultsController.sections {
            let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TTGameCell = self.tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath) as! TTGameCell
        
        return self.configureCell(cell, atIndexPath: indexPath)
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    // MARK: UITableView cell configuration
    
    func configureCell(cell: TTGameCell, atIndexPath indexPath: NSIndexPath) -> TTGameCell {
        
        let gameInfo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Game
        
        cell.nameLabel?.text = gameInfo.name
        cell.viewersLabel?.text = String(format: NSLocalizedString("Visualizações: %ld", comment: ""), arguments: [gameInfo.viewers!.integerValue]);
        
        var image: UIImage? = imageCache.objectForKey(gameInfo.id!) as? UIImage
        
        if image != nil {
            cell.gameImage?.image = image
        } else {
            cell.gameImage?.image = UIImage(imageLiteral: "empty_image")
            
            let request: NSURLRequest = NSURLRequest(URL: NSURL(string: gameInfo.imageUrl!)!)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                
                if error != nil {
                    return
                }
                
                image = UIImage(data: data!)
                
                if let _ = image {
                    if let _ = gameInfo.id {
                        self.imageCache.setObject(image!, forKey: gameInfo.id!)
                    }
                }
                
                if self.tableView.cellForRowAtIndexPath(indexPath) != nil {
                    cell.gameImage?.image = image
                    cell.setNeedsLayout()
                }
                
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    // MARK: Twitch API integration
    
    // Method for downloading games and save to CoreData
    func loadGamesData() {
        let twitchURL: NSURL = NSURL(string: "https://api.twitch.tv/kraken/games/top?limit=50&offset=50")!
        
        TTAPIClient.getDataFromURL(twitchURL,
            completion: { (games: [TTGame], error: NSError?) -> Void in
                
                self.refreshControl.endRefreshing()
                
                if let _ = error {
                    self.showConnectionErrorAlertController()
                    return
                }
                
                self.reloadData(games)
                
        })
    }
    
    // MARK: Methods for handling CoreData
    
    // Method that creates/updates NSManagedObjets for Games
    func saveGameInfo(gameInfo: TTGame) {
        
        let fetchRequest = NSFetchRequest(entityName: Game.entityName)
        fetchRequest.predicate = NSPredicate(format: "id = %@", gameInfo.id)
        
        var fetchResults = []
        
        do {
            try fetchResults = (self.managedObjectContext?.executeFetchRequest(fetchRequest))!
        } catch is ErrorType {
        }
        
        var gameObject: Game
        
        if fetchResults.count > 0 {
            gameObject = fetchResults[0] as! Game
        } else {
            gameObject = NSEntityDescription.insertNewObjectForEntityForName(Game.entityName, inManagedObjectContext: self.managedObjectContext!) as! Game
        }
        
        gameObject.id = gameInfo.id
        gameObject.name = gameInfo.name
        gameObject.viewers = gameInfo.viewers
        gameObject.imageUrl = gameInfo.imageUrl
        
    }
    
    // Method that deletes all Game NSManagedObjets
    func deleteGames() {
        let fetchRequest = NSFetchRequest(entityName: Game.entityName)
        
        var fetchResults = []
        
        do {
            try fetchResults = (self.managedObjectContext?.executeFetchRequest(fetchRequest))!
        } catch is ErrorType {
        }
        
        for var i = 0; i<fetchResults.count; i++ {
            let game: Game = fetchResults.objectAtIndex(i) as! Game
            
            self.managedObjectContext?.deleteObject(game)
        }
        
        self.saveContext()
        
    }
    
    // Deletes application data and reloads with new data
    func reloadData(games: [TTGame]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.imageCache.removeAllObjects()

            self.deleteGames()
            
            for gameInfo in games {
                self.saveGameInfo(gameInfo)
            }
            
            self.saveContext()
        }
    }
    
    // Saves CoreData context
    func saveContext() {
        do {
            try self.managedObjectContext!.save()
        } catch is ErrorType {
        } catch {
        }
    }
    
    // MARK: NSFetchedResultsController methods
    
    func fetchResults() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch is ErrorType {
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject object: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            
            if let _ = newIndexPath {
                self.tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
            
        case .Update:
            
            if let _ = indexPath {
                self.tableView!.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
            
        case .Move:
            
            if let _ = indexPath {
                self.tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
            
            if let _ = newIndexPath {
                self.tableView!.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
            
        case .Delete:

            if let _ = indexPath {
                self.tableView!.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
            
        }
    }
    
}

