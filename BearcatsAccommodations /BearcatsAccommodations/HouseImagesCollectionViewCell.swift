//
//  HouseImagesCollectionViewCell.swift
//  BearcatsAccommodations
//
//  Created by Prashanthi Rayala  on 11/08/2023.
//

import UIKit

class HouseImagesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var houseIV: UIImageView!
    func updateAppearance(isCentered: Bool) {
           UIView.animate(withDuration: 0.3) {
               if isCentered {
                  
                   self.contentView.alpha = 1.0
                   self.transform = CGAffineTransform.identity
               } else {
                  
                   self.contentView.alpha = 0.5
                   self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
               }
           }
       }}
