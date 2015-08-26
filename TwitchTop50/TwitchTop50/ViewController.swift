//
//  ViewController.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 24/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var games: [TTGame] = []
    
    var imageCache: NSCache = NSCache()
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl.addTarget(self, action: "handlePullToRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        self.loadGamesData()
    }
    
    // MARK: UITableView methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TTGameCell = self.tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath) as! TTGameCell
        
        return self.configureCell(cell, atIndexPath: indexPath)
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    // MARK: Rest integration
    
    func loadGamesData() {
        let twitchURL: NSURL = NSURL(string: "https://api.twitch.tv/kraken/games/top?limit=50&offset=50")!
        
        TwitchAPIClient.getDataFromURL(twitchURL,
            completion: { (games: NSArray?, error: NSError?) -> Void in
                
                if let _ = error {
                    return
                }
                
                self.games = games as! [TTGame]
                                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                })
                
        })
    }
    
    // MARK: UITableView cell configuration
    
    func configureCell(cell: TTGameCell, atIndexPath indexPath: NSIndexPath) -> TTGameCell {
        
        let row = indexPath.row
        let gameInfo: TTGame = self.games[row]
        
        cell.nameLabel?.text = gameInfo.name
        cell.viewersLabel?.text = "Viewers: \(gameInfo.viewers!)"
        
        var image: UIImage? = imageCache.objectForKey(gameInfo.id!) as? UIImage
        
        if image != nil {
            cell.gameImage?.image = image
        } else {
            cell.gameImage?.image = UIImage(imageLiteral: "empty_image")
            
            let request: NSURLRequest = NSURLRequest(URL: gameInfo.imageUrl!)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                
                if error != nil {
                    return
                }
                
                image = UIImage(data: data!)
                
                self.imageCache.setObject(image!, forKey: gameInfo.id!)
                
                if self.tableView.cellForRowAtIndexPath(indexPath) != nil {
                    cell.gameImage?.image = image
                    cell.setNeedsLayout()
                }
                
            })
        }
        
        return cell
    }
    
    func handlePullToRefresh(refreshControl: UIRefreshControl) {
        self.refreshControl.beginRefreshing()
        
        self.loadGamesData()
    }
}

