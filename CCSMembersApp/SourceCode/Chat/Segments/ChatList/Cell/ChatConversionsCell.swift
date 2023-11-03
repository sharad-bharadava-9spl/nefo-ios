//
//  ChatConversionsCell.swift
//  CCSMembersApp
//
//  Created by Divvyesh on 04/07/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit

class ChatConversionsCell: UITableViewCell {

    //Date
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var cnstViewDateHeight: NSLayoutConstraint!
    @IBOutlet weak var lblDate: UILabel!
    
    //Sender
    @IBOutlet weak var viewSender: UIView!
    @IBOutlet weak var lblSenderMessage: UILabel!
    @IBOutlet weak var lblSenderMessageTime: UILabel!
    
    //Receiver
    @IBOutlet weak var viewReceiver: UIView!
    @IBOutlet weak var lblReceiverMessage: UILabel!
    @IBOutlet weak var lblReceiverMessageTime: UILabel!
    
    //Set Date is show or not according to Time difference
    var isAvailableNewDate = true {
        didSet {
            self.viewDate.isHidden = !isAvailableNewDate
            self.cnstViewDateHeight.constant = isAvailableNewDate ? 50 : 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewSender.layer.cornerRadius = 20
        self.viewSender.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]
        self.viewReceiver.layer.cornerRadius = 20
        self.viewReceiver.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
