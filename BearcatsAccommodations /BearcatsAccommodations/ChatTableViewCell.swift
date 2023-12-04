//
//  ChatTableViewCell.swift
//  BearcatsAccommodations
//
//  Created by Aashritha Dodda on 11/12/2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var nameBtn: UIButton!
    
    @IBOutlet weak var nameLBL: UILabel!
    
    @IBOutlet weak var msgLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
