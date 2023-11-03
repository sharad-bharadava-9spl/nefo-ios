//
//  MainCell.swift
//  CCSMembersApp
//
//  Created by Jaimin Patel on 6/7/19.
//  Copyright © 2019 Jaimin Patel. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class clubCell:UITableViewCell{
    @IBOutlet weak var lblClubName: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var delteBtn: UIButton!
    @IBOutlet weak var banndImg: UIImageView!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var viewNotificationCount: UIView!
    @IBOutlet weak var btnNotification: UIButton!
    @IBOutlet weak var lblNotificationCount: UILabel!
    @IBOutlet weak var btnBarcode: UIButton!
    @IBOutlet weak var viewBarcode: UIView!
}

class slidemenucell:UITableViewCell{
    @IBOutlet weak var lblSwitchName: UILabel!
    @IBOutlet weak var imgHeigt: NSLayoutConstraint!
    @IBOutlet weak var imgbgView: UIView!
    @IBOutlet weak var lblView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var manageAccountView: UIView!
    @IBOutlet weak var accountImg: UIImageView!
    @IBOutlet weak var accountlbl: UILabel!
    @IBOutlet weak var switchAccountView: UIView!
    
    override func prepareForReuse() {
        accountImg.image=nil
        accountlbl.text=nil
        imgView.image=nil
        lblName.text=nil
      //  lblSwitchName.text=nil
        
    }
}

class categoryCell:UICollectionViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UILabel!
}

class homeCell:UICollectionViewCell,UITextFieldDelegate,gramEuro{
    var delegateGrm:gramEuro?
    
    @IBOutlet weak var btnExttrior: UIButton!
    @IBOutlet weak var btnSativa: UIButton!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var txtEuros: UITextField!
    @IBOutlet weak var txtGram: UITextField!
    @IBOutlet weak var plusAdd: UIButton!
    @IBOutlet weak var minusDelete: UIButton!
    @IBOutlet weak var lbladdMinusValue: UILabel!
    @IBOutlet weak var addminusStackView: UIStackView!
    @IBOutlet weak var gramStckView: UIStackView!
    @IBOutlet weak var imgBGView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnPlush: UIButton!
    @IBOutlet weak var btnInformation: UIButton!
    @IBOutlet weak var btnMedicalInformation: UIButton!
    @IBOutlet weak var mainStackView: UIView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewMoreInfo: UIView!
    @IBOutlet weak var lblMoreInfo: UILabel!
    @IBOutlet weak var btnMoreInfo: UIButton!
    @IBOutlet weak var btnActionViewMore: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtEuros.delegate=self
        self.txtGram.delegate=self
        
        btnInformation.setTitle("", for: .normal)
//        btnInformation.setImage(UIImage(named: "info_new"), for: .normal)
        btnMoreInfo.setTitle("", for: .normal)
        btnActionViewMore.setTitle("", for: .normal)
        lblMoreInfo.text = "More_Info".localized
    }
    override func layoutSubviews() {
            super.layoutSubviews()
        self.imageHeight.constant = self.imgView.frame.size.width
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.imageHeight.constant = self.imgView.frame.size.width
//    }
    
    //Constraints Setting Outlet
    @IBOutlet weak var imageHeight: NSLayoutConstraint! //70
    @IBOutlet weak var satvanaHeight: NSLayoutConstraint!//17
    @IBOutlet weak var detailHeight: NSLayoutConstraint!//17
   
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!//H=36
    
    @IBOutlet weak var extratriorWidth: NSLayoutConstraint!//65
    @IBOutlet weak var sativaWidth: NSLayoutConstraint!//50
    @IBOutlet weak var btnInfoMedicineHeight: NSLayoutConstraint!//25
    @IBOutlet weak var plushBtnHeight: NSLayoutConstraint!//H17 W17

    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let price=JSON(self.lblPrice.text!).doubleValue
        if textField == self.txtEuros{
            if string.count == 0{
                let euroString:String=JSON(self.txtEuros.text!).stringValue
                let Euro=Double(euroString.dropLast())
                if let euroVal = Euro{
                    self.txtGram.text="\(Double(round(100*(euroVal/price))/100))"
                    delegateGrm?.selectedGrm?(sender: textField.tag, txtEuro: "\(euroVal)", txtGrm: self.txtGram.text!)
                } else{
                    self.txtGram.text=""
                    self.txtGram.placeholder="Gr"
                    delegateGrm?.selectedGrm?(sender: textField.tag, txtEuro: "", txtGrm: self.txtGram.text!)
                }
            } else{
                let Euro=JSON(self.txtEuros.text!+string).doubleValue
                self.txtGram.text="\(Double(round(100*(Euro/price))/100))"
                delegateGrm?.selectedGrm?(sender: textField.tag, txtEuro: "\(Euro)", txtGrm: self.txtGram.text!)
            }
        } else{
            if string.count == 0{
                let euroString:String=JSON(self.txtGram.text!).stringValue
                let Grm=Double(euroString.dropLast())
                if let grmVal = Grm{
                    self.txtEuros.text="\(Double(round(100*(grmVal*price))/100))"
                    delegateGrm?.selectedGrm?(sender: textField.tag, txtEuro: self.txtEuros.text!, txtGrm: "\(grmVal)")
                } else{
                    self.txtEuros.text=""
                    self.txtEuros.placeholder="Euros"
                    delegateGrm?.selectedGrm?(sender: textField.tag, txtEuro: self.txtEuros.text!, txtGrm: "")
                }
            } else{
                let Grm=JSON(self.txtGram.text!+string).doubleValue
                self.txtEuros.text="\(Double(round(100*(Grm*price))/100))"
                delegateGrm?.selectedGrm?(sender: textField.tag, txtEuro: self.txtEuros.text!, txtGrm: "\(Grm)")
            }
        }
        return true
    }
}

class productSelection:UICollectionViewCell{
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var btnProductView: UIView!
    @IBOutlet weak var img: UIImageView!
    
    override func prepareForReuse() {
        btnProduct.setImage(nil, for: .normal)
        lblProductName.text=nil
        
       
    }
}


class viewCartCell:UITableViewCell{
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var lblRemoveOutlet: UILabel!
    @IBOutlet weak var lblDiscountPercentage: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var btnPlushQty: UIButton!
    @IBOutlet weak var lblQtyPlusMinus: UILabel!
    @IBOutlet weak var btnMinusQty: UIButton!
    @IBOutlet weak var qtyView: UIView!
    @IBOutlet weak var gramStackView: UIView!
    //  @IBOutlet weak var gramStackView: UIStackView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnEditEuro: UIButton!
    @IBOutlet weak var btnEditGrm: UIButton!
    @IBOutlet weak var btnEditQTY: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    @IBOutlet weak var imgProduct: UIImageView!
    //@IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var txtEuro: UITextField!
    @IBOutlet weak var txtGrm: UITextField!
    @IBOutlet weak var removeView: UIView!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    // Manage Height && Width iPhone 5s
    //tblHeight::195
    @IBOutlet weak var imgHeight: NSLayoutConstraint!//116
    @IBOutlet weak var sativaHeight: NSLayoutConstraint!//20
    @IBOutlet weak var sativaWidth: NSLayoutConstraint!//60
    @IBOutlet weak var exttriorWidth: NSLayoutConstraint!//70
//    @IBOutlet weak var stackViewWidth: NSLayoutConstraint!//100
//    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!//25
//    @IBOutlet weak var btnEditHeight: NSLayoutConstraint!//30
}

class notificationCell:UITableViewCell{
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblNotificationDate: UILabel!
    @IBOutlet weak var btnTraceOutlet: UIButton!
    @IBOutlet weak var imgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgBottomHeight: NSLayoutConstraint!
}

class donationCell:UITableViewCell{
    @IBOutlet weak var lblDonationAdded: UILabel!
    @IBOutlet weak var lblNewCreditOutlet: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDonationID: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblDateTime: UILabel!
    //@IBOutlet weak var lblOldCredit: UILabel!
    @IBOutlet weak var lblNewCredit: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
}

class dispanseHistoryCell:UITableViewCell{
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblItems: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var btnDidselect: UIButton!
    @IBOutlet weak var lblOrderIDOutlet: UILabel!
    @IBOutlet weak var lblItemsOutlet: UILabel!
    @IBOutlet weak var lblTotalPriceOutlet: UILabel!
    @IBOutlet weak var btnCancelOutlet: UIButton!
    @IBOutlet weak var hightCancelBtn: NSLayoutConstraint!
    @IBOutlet weak var bottomCancelBtn: NSLayoutConstraint!
    @IBOutlet weak var lblTimes: UILabel!
}

class calenderYearCell:UITableViewCell{
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var btnYear: UIButton!
}

class ChatCell:UITableViewCell{
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
}

class chattingCell:UITableViewCell{
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainDateHeight: NSLayoutConstraint!
    @IBOutlet weak var lblMainDate: UILabel!
    @IBOutlet weak var mainCellView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    // @IBOutlet weak var bubbleView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for view in self.mainCellView.subviews {
            view.removeFromSuperview()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class adminSetting:UITableViewCell{
    @IBOutlet weak var lblSettingName: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
}

class adminSettingAddMacAddress:UITableViewCell,UITextFieldDelegate,setting{
    var delegateSetting:setting?
    @IBOutlet weak var txtMacAddress: UITextField!
    @IBOutlet weak var lblVerify: UILabel!
    @IBOutlet weak var lblVerifyHeight: NSLayoutConstraint!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnTrace: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.txtMacAddress.delegate=self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("tag is")
        if(string.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            if ((textField.text?.count)! >= 1  && string.count == 0){
                let strVal:String=JSON(self.txtMacAddress.text!).stringValue
                delegateSetting?.deleteMacText?(sender:self.txtMacAddress.tag,txtMac:String(strVal.dropLast()))
            } else{
                return false
            }
        } else{
            delegateSetting?.deleteMacText?(sender:self.txtMacAddress.tag,txtMac:JSON(self.txtMacAddress.text!).stringValue+string)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class DispenseDetaiCell:UITableViewCell{
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var lblExtraPriceCount: UILabel!
    @IBOutlet weak var lblExtraPrice: UILabel!
   // @IBOutlet weak var lblProductDescription: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
}

class MainMenuCell:UICollectionViewCell{
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var lblMenuName: UILabel!
    @IBOutlet weak var imgMenu: UIImageView!
}

class ProfileSetupGuardianCell:UITableViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblHash: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVoluntary: UILabel!
}

class ProfileSetupPreferencesCell:UITableViewCell{
    @IBOutlet weak var lblPreferenceName: UILabel!
}

class LanguageSelectionCell:UITableViewCell{
    @IBOutlet weak var lblLanguageName: UILabel!
    @IBOutlet weak var btnSelectionOption: UIButton!
}




class notificationCellNew:UITableViewCell{
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var viewImg: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblNotificationDate: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnColor: UIButton!
}
