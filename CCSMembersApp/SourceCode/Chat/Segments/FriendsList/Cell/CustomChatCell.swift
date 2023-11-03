//
//  FriendRequestCell.swift
//  CCSMembersApp
//
//  Created by mac-18 on 29/12/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
class CustomChatCell: UITableViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgBtn1: UIImageView!
    @IBOutlet weak var imgBtn2: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setupData(data: JSON) {
        self.lblName.text = "@\(data["username"].stringValue)"
//        self.lblMessage.text = data["username"].stringValue
    }
}
