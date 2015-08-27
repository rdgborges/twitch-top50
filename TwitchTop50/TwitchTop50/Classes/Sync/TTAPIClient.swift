//
//  RestClient.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 24/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import Foundation

class TTAPIClient {
 
    class func getDataFromURL(url: NSURL, completion:(NSArray?, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        
            if let errorOcurred = error {
                completion(nil, errorOcurred)
            } else {
                
                let json = JSON(data: data!)
                
                var games: [TTGame] = []
                
                for (_, gameInfo):(String, JSON) in json["top"] {
                    games.append(self.convertToGame(gameInfo))
                }
                
                completion(games, nil)
            }
            
        })
        
        dataTask.resume()
    }
    
    class func convertToGame(json: JSON) -> TTGame {
        let id = json["game"]["_id"]
        let name = json["game"]["name"]
        let viewers = json["viewers"]
        let image = json["game"]["box"]["medium"]
        
        let imageUrl: NSURL = NSURL(string: image.stringValue)!
        
        return TTGame(id: id.numberValue, name: name.stringValue, viewers: viewers.numberValue, imageUrl: imageUrl)
    }
    
}