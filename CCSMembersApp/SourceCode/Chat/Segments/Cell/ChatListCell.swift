//
//  ChatListCell.swift
//  CCSMembersApp
//
//  Created by Divvyesh on 26/06/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChatListCell: UITableViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblMsgUnreadCount: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(data: JSON) {
        self.lblName.text = data["username"].stringValue
//        self.lblMessage.text = data["username"].stringValue
    }
}
