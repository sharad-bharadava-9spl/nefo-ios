//
//  NoDataVC.swift
//

import UIKit

class NoDataVC: UIView {
    
    //MARK:- Variable Declaration
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var conCenterPoint: NSLayoutConstraint!
    
    /*
    override func awakeFromNib() {
        self.lblTitle.setLineSpacing(lineSpacing: 5)
    }*/
    var msg : String! {
        didSet{
            self.lblTitle.text = msg
            //self.lblTitle.setLineSpacing(lineSpacing: 8.0)
        }
    }
    
    var desc : String! {
        didSet{
            self.lblDescription.text = desc
        }
    }
}
