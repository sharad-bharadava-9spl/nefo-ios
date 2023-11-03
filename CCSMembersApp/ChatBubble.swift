//
//  ChatBubble.swift
//  ChatBubbleScratch
//
//  Created by Sauvik Dolui on 02/09/15.
//  Copyright (c) 2015 Innofied Solution Pvt. Ltd. All rights reserved.
//

import UIKit
import SDWebImage
class ChatBubble: UIView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    // Properties
    var imageViewChat: UIImageView?
    var imageViewBG: UIImageView?
    var text: String?
    var labelChatText: UILabel?
    
    /**
     Initializes a chat bubble view
     
     :param: data   ChatBubble Data
     :param: startY origin.y of the chat bubble frame in parent view
     
     :returns: Chat Bubble
     */
    init(data: ChatBubbleData, startY: CGFloat){
        
        // 1. Initializing parent view with calculated frame
        super.init(frame: ChatBubble.framePrimary(type: data.type, startY:startY))
        
        // Making Background transparent
        self.backgroundColor = UIColor.clear
        
        let padding: CGFloat = 10.0
        
        // 2. Drawing image if any
        let chatImage = data.image
        if chatImage != ""{
            
            let width: CGFloat = 170.0//min(chatImage.size.width, (self.frame.width) - 2 * padding)//CGRectGetWidth(self.frame) - 2 * padding)
            let height: CGFloat = 280//chatImage.size.height * (width / chatImage.size.width)
            imageViewChat = UIImageView(frame: CGRect(x: padding, y: padding, width: width, height: height))//CGRectMake(padding, padding, width, height))
            imageViewChat?.sd_setImage(with: URL(string: chatImage!), placeholderImage: #imageLiteral(resourceName: "SlideMyProfileIcon"))
            imageViewChat?.layer.cornerRadius = 5.0
            imageViewChat?.layer.masksToBounds = true
            self.addSubview(imageViewChat!)
        }
        
        // 3. Going to add Text if any
        if let chatText = data.text {
            // frame calculation
            var startX = padding
            var startY:CGFloat = 5.0
            if let imageView = imageViewChat {
                startY += imageViewChat!.frame.maxX
            }
            labelChatText = UILabel(frame: CGRect(x: startX, y: startY, width: self.frame.width - 2 * startX, height: 5))//CGRectMake(startX, startY, self.frame.width - 2 * startX , 5))
            labelChatText?.textAlignment = data.type == .Mine ? .right : .left
            labelChatText?.font = UIFont.systemFont(ofSize: 14)
            labelChatText?.numberOfLines = 0 // Making it multiline
            labelChatText?.text = data.text
            labelChatText?.textColor = UIColor.black
            labelChatText?.sizeToFit() // Getting fullsize of it
            self.addSubview(labelChatText!)
        }
        // 4. Calculation of new width and height of the chat bubble view
        var viewHeight: CGFloat = 0.0
        var viewWidth: CGFloat = 0.0
        if let imageView = imageViewChat {
            // Height calculation of the parent view depending upon the image view and text label
            viewWidth = max((imageViewChat!.frame.maxX), (labelChatText!.frame.maxX)) + padding
            viewHeight = max((imageViewChat!.frame.maxY), (labelChatText!.frame.maxY)) + padding
            
        } else {
            viewHeight = (labelChatText!.frame.maxY) + padding/2
            viewWidth = (labelChatText!.frame.width) + (labelChatText!.frame.minX) + padding
        }
        
        // 5. Adding new width and height of the chat bubble frame
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: viewWidth, height: viewHeight)//CGRectMake((self.frame.minX), (self.frame.minY), viewWidth, viewHeight)
        
        // 6. Adding the resizable image view to give it bubble like shape
        let bubbleImageFileName = data.type == .Mine ? "bubbleMine" : "bubbleSomeone"
        imageViewBG = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height))//CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)))
        if data.type == .Mine {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 14, bottom: 17, right: 28))
        } else {
            imageViewBG?.image = UIImage(named: bubbleImageFileName)?.resizableImage(withCapInsets: UIEdgeInsets(top: 14, left: 22, bottom: 17, right: 20))
        }
        self.addSubview(imageViewBG!)
        self.sendSubviewToBack(imageViewBG!)
        
        // Frame recalculation for filling up the bubble with background bubble image
        var repsotionXFactor:CGFloat = data.type == .Mine ? 0.0 : -8.0
        var bgImageNewX = (imageViewBG!.frame.minX) + repsotionXFactor
        var bgImageNewWidth =  (imageViewBG!.frame.width) + CGFloat(12.0)
        var bgImageNewHeight =  (imageViewBG!.frame.height) + CGFloat(6.0)
        imageViewBG?.frame = CGRect(x: bgImageNewX, y: 0.0, width: bgImageNewWidth, height: bgImageNewHeight)//CGRectMake(bgImageNewX, 0.0, bgImageNewWidth, bgImageNewHeight)
        
        
        // Keepping a minimum distance from the edge of the screen
        var newStartX:CGFloat = 0.0
        if data.type == .Mine {
            // Need to maintain the minimum right side padding from the right edge of the screen
            var extraWidthToConsider = (imageViewBG!.frame.width)
            newStartX = ScreenSize.SCREEN_WIDTH - extraWidthToConsider
        } else {
            // Need to maintain the minimum left side padding from the left edge of the screen
            newStartX = -(imageViewBG!.frame.minX) + 3.0
        }
        
        self.frame = CGRect(x: newStartX, y: self.frame.minY, width: frame.width, height: frame.height)//CGRectMake(newStartX, CGRectGetMinY(self.frame), CGRectGetWidth(frame), CGRectGetHeight(frame))
        
    }
    
    // 6. View persistance support
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - FRAME CALCULATION
    class func framePrimary(type:BubbleDataType, startY: CGFloat) -> CGRect{
        let paddingFactor: CGFloat = 0.02
        let sidePadding = ScreenSize.SCREEN_WIDTH * paddingFactor
        let maxWidth = ScreenSize.SCREEN_WIDTH * 0.65 // We are cosidering 65% of the screen width as the Maximum with of a single bubble
        let startX: CGFloat = type == .Mine ? ScreenSize.SCREEN_WIDTH * (CGFloat(1.0) - paddingFactor) - maxWidth : sidePadding
        return CGRect(x: startX, y: startY, width: maxWidth, height: 5)//CGRectMake(startX, startY, maxWidth, 5) // 5 is the primary height before drawing starts
    }
    
}
