//
//  RestClient.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 24/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import Foundation

class TTAPIClient {
 
    // Fetch data from Twitch
    class func getDataFromURL(url: NSURL, completion:([TTGame], NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let errorOcurred = error {
                completion([], errorOcurred)
            } else {
                let json = JSON(data: data!)
        
                completion(self.convertToGame(json), nil)
            }
            
        })
        
        dataTask.resume()
    }
    
    // Convert JSON to Array of TTGame
    class func convertToGame(json: JSON) -> [TTGame] {
        
        var games: [TTGame] = []
        
        for (_, gameInfo):(String, JSON) in json["top"] {
            
            let id = gameInfo["game"]["_id"]
            let name = gameInfo["game"]["name"]
            let viewers = gameInfo["viewers"]
            let image = gameInfo["game"]["box"]["medium"]
            
            let game: TTGame = TTGame(id: id.numberValue, name: name.stringValue, viewers: viewers.numberValue, imageUrl: image.stringValue)
            
            games.append(game)
        }
    
        return games
    }
    
}