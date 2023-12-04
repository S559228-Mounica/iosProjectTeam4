//
//  HouseTableViewCell.swift
//  BearcatsAccommodations
//
//  Created by Mounica Seelam on 11/05/2023.
//

import UIKit

class HouseTableViewCell: UITableViewCell {

    @IBOutlet weak var houseIV: UIImageView!
    
    @IBOutlet weak var cityLbl: UILabel!
    
    @IBOutlet weak var addressLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
