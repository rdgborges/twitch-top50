//
//  RestClient.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 24/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import Foundation

class RestClient {
 
    class func getDataFromURL(url: NSURL, completion:(NSData?, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
        
            if let errorOcurred = error {
                completion(nil, errorOcurred)
            } else {
                completion(data, nil)
            }
            
        })
        
        dataTask.resume()
    }
    
}