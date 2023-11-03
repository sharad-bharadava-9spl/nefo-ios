//
//  HistoryTblCellTableViewCell.swift
//  CCSMembersApp
//
//  Created by Apple on 22/07/22.
//  Copyright © 2022 Jaimin Patel. All rights reserved.
//

import UIKit

class HistoryTblCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomBoder: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var total: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
