//
//  RestClient.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 24/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import Foundation

class TwitchAPIClient {
 
    class func getDataFromURL(url: NSURL, completion:(NSArray?, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        
            if let errorOcurred = error {
                completion(nil, errorOcurred)
            } else {
                
                let json = JSON(data: data!)
                
                var games: [TTGame] = []
                
                for (_, gameInfo):(String, JSON) in json["top"] {
                    
                    let id = gameInfo["game"]["_id"]
                    let name = gameInfo["game"]["name"]
                    let viewers = gameInfo["viewers"]
                    let image = gameInfo["game"]["box"]["medium"]
                    
                    let imageUrl: NSURL = NSURL(string: image.stringValue)!
                                        
                    let gameInfo = TTGame(id: id.numberValue, name: name.stringValue, viewers: viewers.numberValue, imageUrl: imageUrl)
                    
                    games.append(gameInfo)
                    
                }
                
                completion(games, nil)
            }
            
        })
        
        dataTask.resume()
    }
    
}