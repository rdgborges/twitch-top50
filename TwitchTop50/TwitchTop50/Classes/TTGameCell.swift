//
//  TTGameCell.swift
//  TwitchTop50
//
//  Created by Rodrigo Soares on 26/08/15.
//  Copyright © 2015 Rodrigo Borges. All rights reserved.
//

import UIKit

class TTGameCell: UITableViewCell {

    @IBOutlet var gameImage: UIImageView!

    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var viewersLabel: UILabel!
    
    func setGame(gameInfo: TTGame, imageCache: NSCache) {
        
        nameLabel?.text = gameInfo.name
        viewersLabel?.text = "Viewers: \(gameInfo.viewers!)"
        gameImage?.image = UIImage(data: NSData(contentsOfURL: gameInfo.imageUrl!)!)
        
        let image: UIImage? = imageCache.objectForKey(gameInfo.id!) as? UIImage
        
        if image != nil {
            gameImage?.image = image
        } else {
            gameImage?.image = UIImage(imageLiteral: "empty_image")
        
            let imageData: NSData = NSData(contentsOfURL: gameInfo.imageUrl!)!
            
            imageCache.setObject(image!, forKey: gameInfo.id!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.gameImage?.image = UIImage(data: imageData)
                    self.setNeedsLayout()
            })

            
            /*TwitchAPIClient.getDataFromURL(url,
            completion: { (data: NSData?, error: NSError?) -> Void in
            
            if let _ = error {
            return
            }
            
            gameBox = UIImage(data: data!)
            
            self.imageCache.setObject(gameBox!, forKey: gameInfo.id!)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
            cellToUpdate.imageView!.image = gameBox
            cellToUpdate.setNeedsLayout()
            }
            })
            
            })*/
            
        }
    }
    
}
