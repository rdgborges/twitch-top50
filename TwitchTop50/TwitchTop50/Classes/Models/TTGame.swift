//
//  TTGame.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 25/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import Foundation

class TTGame : NSObject {

    var id: NSNumber
    var name: String
    var viewers: NSNumber
    var imageUrl: String
    
    init(id: NSNumber, name: String, viewers: NSNumber, imageUrl: String) {
        self.id = id
        self.name = name
        self.viewers = viewers
        self.imageUrl = imageUrl
    }
}

