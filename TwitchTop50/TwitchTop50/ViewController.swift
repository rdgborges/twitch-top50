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
    
    var games: [String] = []
    var imageUrls: [String] = []
    var ids: [NSNumber] = []
    
    var imageCache: NSCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.loadGamesData()
    }
    
    // MARK: UITableView methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.games.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let row = indexPath.row
        
        let id = self.ids[row]
        let name = self.games[row]
        let imageUrl = self.imageUrls[row]
        
        cell.textLabel?.text = name
        
        var gameBox: UIImage? = imageCache.objectForKey(id) as? UIImage
        
        if gameBox != nil {
            cell.imageView?.image = gameBox
        } else {
            cell.imageView?.image = UIImage(imageLiteral: "empty_image")

            let url: NSURL = NSURL(string: imageUrl)!
            
            RestClient.getDataFromURL(url,
                completion: { (data: NSData?, error: NSError?) -> Void in
                    
                    if let _ = error {
                        return
                    }
                    
                    gameBox = UIImage(data: data!)
                    
                    self.imageCache.setObject(gameBox!, forKey: id)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView!.image = gameBox
                            cellToUpdate.setNeedsLayout()
                        }
                    })
                    
            })
        
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        print("You selected cell #\(indexPath.row)!")
    }
    
    
    // MARK: Rest integration
    
    func loadGamesData() {
        let twitchURL: NSURL = NSURL(string: "https://api.twitch.tv/kraken/games/top?limit=50&offset=50")!
        
        RestClient.getDataFromURL(twitchURL,
            completion: { (data: NSData?, error: NSError?) -> Void in
                
                if let _ = error {
                    return
                }
                
                let json = JSON(data: data!)
                
                self.games = []
                
                for (_, gameInfo):(String, JSON) in json["top"] {
                    
                    let id = gameInfo["game"]["_id"]
                    let name = gameInfo["game"]["name"]
                    let imageUrl = gameInfo["game"]["box"]["medium"]
                    
                    self.ids.append(id.numberValue)
                    self.games.append(name.stringValue)
                    self.imageUrls.append(imageUrl.stringValue)
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
                
        })
    }
    
}

