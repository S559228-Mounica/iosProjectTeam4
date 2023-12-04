//
//  senderTableViewCell.swift
//  BearcatsAccommodations
//
//  Created by Mounica Seelam on 11/10/2023.
//

import UIKit

class senderTableViewCell: UITableViewCell {
    
    
    @IBOutlet var contantView: UIView!
    
    @IBOutlet var audioLbl: UILabel!
    @IBOutlet var audioBGView: UIView!
    @IBOutlet var audioIconView: UIView!
      
    @IBOutlet var messageView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var timeLbl: UILabel!
    
    var chat: Chat?{
        didSet {
            
            self.configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell() -> Void {
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contantView.backgroundColor = .clear
        
        messageView.layer.cornerRadius = 12
        messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        messageView.backgroundColor = .systemYellow
        
        audioBGView.layer.cornerRadius = 12
        audioBGView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        audioBGView.backgroundColor = .systemYellow
        
        audioIconView.layer.cornerRadius = audioIconView.frame.size.height / 2
        
        if chat?.type == 1 {
            
            audioBGView.isHidden = true
            messageView.isHidden = false
            
            messageLabel.text = chat?.message ?? ""
            
            let date_str = chat?.date ?? ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            
            let date = dateFormatter.date(from: date_str)
            dateFormatter.dateFormat = "hh:mm a"
            
            timeLbl.text = dateFormatter.string(from: date ?? Date())
        }
        
        if chat?.type == 4 {
            
            let text = chat?.message ?? ""
            audioLbl.text = text
            
            messageView.isHidden = true
            audioBGView.isHidden = false
        }
    }
}
