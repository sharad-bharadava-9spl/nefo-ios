//
//  RegionNameTableViewCell.swift
//  CCSMembersApp
//
//  Created by Parth Makwana on 06/10/23.
//  Copyright © 2023 Jaimin Patel. All rights reserved.
//

import UIKit

class RegionNameTableViewCell: UITableViewCell {

    @IBOutlet weak var lblRegionName: UILabel!
    @IBOutlet weak var btnRegionName: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
