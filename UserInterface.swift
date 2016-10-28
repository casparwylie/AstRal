//
//  UserInterface.swift
//  Strands
//
//  Created by Caspar Wylie on 06/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 USER INTERFACE COMPONENT
 
 */

import Foundation
import UIKit


//MARK: Delegate declaration of all UI actions
@objc protocol UIActionDelegate {
    @objc optional func toggleMap(isAddingStrand: Bool);
    @objc optional func openLoginForm();
    @objc optional func addStrandReady(comment: String);
    @objc optional func renderTempStrandFromUI(tapX: Int, tapY: Int);
    @objc optional func cancelNewStrand();
}

class UserInterface1{
    
    //MARK: Item initiation
    var buttons: [UIButton] = [];
    var setPOIbutton: UIButton!;
    var infoLabel: UIButton!;
    var doneChoosingTapPosButton: UIButton!;
    var cancelChoosingButton: UIButton!;
    var toggleMenuButton: UIButton!;
    var commentForm: UIView!;
    var postStrandButton: UIButton!;
    var commentTextfield : UITextField!;
    var actionDelegate: UIActionDelegate?;
    var tapToPost = false;
    var scrollView: UIScrollView!;
    var view: UIView!;
    var setTapPointForPost = (x: 0, y: 0);
    var mapShowing = false;
    
    //MARK: UI constants
    let mainFont = UIFont(name: "Futura", size: 12);
    let mainFontColor = UIColor.black;
    let infoLabelYPos = 20;
    let buttonSpace = 2;
    let buttonHeight = 40;
    let buttonCornerRadius = CGFloat(3.0);
    let generalButtonWidth = 40;
    
    var screenSize: CGRect = UIScreen.main.bounds;
    
   
    //MARK:  UIActionDelegate method wrappers
    @objc func buttonAction(_ sender: UIButton!){
        let whichAction = sender.currentTitle!;
        switch whichAction {
        case "Show Map":
            actionDelegate?.toggleMap!(isAddingStrand: self.tapToPost);
            sender.setTitle("Hide Map", for: UIControlState());
            mapShowing = true;
        case "Hide Map":
            actionDelegate?.toggleMap!(isAddingStrand: false);
            sender.setTitle("Show Map", for: UIControlState());
            mapShowing = false;
        case "Login":
            actionDelegate?.openLoginForm!();
        case "Post Strand":
            if(mapShowing==true){
                actionDelegate?.toggleMap!(isAddingStrand: true);
            }
            updateInfoLabel(newText: "Tap wherever you want to post it (from camera or map)", show: true, hideAfter: 0);
            cancelChoosingButton.isHidden = false;
            toggleMenu();
            self.tapToPost = true;
        default:
            toggleMenu();
        }
    }
    
    func toggleMenu(){
        for var button in buttons{
            if(button.isHidden == false){
                button.isHidden = true;
            }else{
                button.isHidden = false;
            }
        }
    }
    
    @objc func wrapTapped(touch: UITapGestureRecognizer){
        let tapPoint = touch.location(in: self.view);
        if(self.tapToPost == true && mapShowing == false){
            actionDelegate?.renderTempStrandFromUI!(tapX: Int(tapPoint.x), tapY: Int(tapPoint.y));
        }else{
            //get strandinfo
        }
    }
    
    func showTapFinishedOptions(){
        doneChoosingTapPosButton.isHidden = false;
        updateInfoLabel(newText: "Tap 'Done' when you have choosen a position", show: true, hideAfter: 0);
    }
    
   
    
    @objc func cancelTap(){
        doneChoosingTapPosButton.isHidden = true;
        updateInfoLabel(newText: " ", show: false, hideAfter: 0);
        self.tapToPost = false;
        cancelChoosingButton.isHidden = true;
        commentForm.isHidden = true;
        actionDelegate?.cancelNewStrand!();
        self.view.endEditing(true);
    }
    
    @objc func newStrandComment(){
        self.tapToPost = false;
        updateInfoLabel(newText: " ", show: false, hideAfter: 0);
        doneChoosingTapPosButton.isHidden = true;
        self.commentForm.isHidden = false;
    }
    
    @objc func postStrand(){
        cancelTap();
        actionDelegate?.addStrandReady!(comment: commentTextfield.text!);
        self.view.endEditing(true);
    }
    
    //MARK: render UI components
    
    func renderPostCommentForm(){
        let formWidth = 200;
        let formHeight = 140;
        commentForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: 60 + buttonSpace,width: formWidth, height: formHeight));
        commentForm.isHidden = true;
        commentForm.insertSubview(processBlurEffect(bounds: commentForm.bounds, cornerRadiusVal: buttonCornerRadius), at: 0);
        
        commentTextfield = UITextField(frame: CGRect(x: 5, y: 30, width: 190, height: 40));
        commentTextfield.borderStyle = UITextBorderStyle.line;
        commentTextfield.layer.cornerRadius = buttonCornerRadius;
        commentTextfield.layer.borderWidth = 1;
        commentTextfield.textColor = mainFontColor;
        commentTextfield.font = mainFont;
        commentTextfield.text = "Enter Comment...";
        
        let postStrandButtonRect = CGRect(x: 5, y: 80, width: 100, height: 40)
        postStrandButton = addButtonProperties(title: "Post Strand", hidden: false, pos: postStrandButtonRect, cornerRadius: buttonCornerRadius);
        postStrandButton.addTarget(self, action: #selector(postStrand), for: .touchUpInside);       commentForm.addSubview(commentTextfield);
        commentForm.addSubview(postStrandButton);
        self.view.addSubview(commentForm);
    }
    
    func addStrandTapRecognizer(){
        
        let tapRec: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wrapTapped));
        tapRec.numberOfTapsRequired = 1;
        self.view.addGestureRecognizer(tapRec);
        
    }

    func processBlurEffect(bounds: CGRect, cornerRadiusVal: CGFloat) -> UIVisualEffectView {
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style:
            UIBlurEffectStyle.light));
        blurEffect.frame = bounds;
        blurEffect.isUserInteractionEnabled = false;
        blurEffect.layer.cornerRadius = cornerRadiusVal;
        blurEffect.clipsToBounds = true;
        return blurEffect;
    }
    
    func renderLabel(){
        let infoLabelRect = CGRect(x: 5,y: 20,width: Int(screenSize.width)-10,height: buttonHeight);
        infoLabel = addButtonProperties(title: " ", hidden: true, pos: infoLabelRect, cornerRadius: buttonCornerRadius);
        self.view.addSubview(infoLabel);
    }
    
    func addButtonProperties(title: String, hidden: Bool, pos: CGRect, cornerRadius: CGFloat) ->UIButton{
        let button = UIButton(frame: pos);
        button.setTitle(title, for: UIControlState());
        button.insertSubview(processBlurEffect(bounds: button.bounds, cornerRadiusVal: cornerRadius), at: 0);
        button.titleLabel!.font =  mainFont;
        button.isHidden = hidden;
        button.setTitleColor(mainFontColor, for: .normal);
        return button;
    }
    
    func renderGeneralButtons(){
        
        let doneChoosingTapPosButtonRect = CGRect(x: Int(screenSize.width)-buttonSpace - (2*generalButtonWidth + 5),y: infoLabelYPos + buttonHeight + buttonSpace,width: generalButtonWidth, height: buttonHeight);
        doneChoosingTapPosButton = addButtonProperties(title: "Done", hidden: true, pos: doneChoosingTapPosButtonRect,cornerRadius: buttonCornerRadius);
        doneChoosingTapPosButton.addTarget(self, action: #selector(newStrandComment), for: .touchUpInside);
        self.view.addSubview(doneChoosingTapPosButton);
        
        
        let cancelChoosingButtonRect = CGRect(x: Int(screenSize.width-5) - generalButtonWidth,y: infoLabelYPos + buttonHeight + buttonSpace,width: generalButtonWidth, height: buttonHeight);
        cancelChoosingButton = addButtonProperties(title: "Cancel", hidden: true, pos: cancelChoosingButtonRect,cornerRadius: buttonCornerRadius);
        cancelChoosingButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside);
        self.view.addSubview(cancelChoosingButton);
    }
    
    //MARK:  menu setups
    func renderMenu(){
        
        let yPos = Int(screenSize.height) - buttonHeight - 60;
        let toggleWidth = 50;
        let halfTW = toggleWidth/2;
        let toggleMenuRect  = CGRect(x: Int(screenSize.width*0.5)-halfTW,y: yPos+toggleWidth-7, width: toggleWidth,height: toggleWidth);
        toggleMenuButton = addButtonProperties(title: " ", hidden: false, pos: toggleMenuRect, cornerRadius: CGFloat(halfTW));
        toggleMenuButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
        self.view.addSubview(toggleMenuButton);
        
        let buttonList = ["Show Map","Login","Sign Up","Post Strand","Help"];
        //logggedin "see map", "post strand", "profile", "help
        
        
        var menuWidth = 0;
        let letterToWidthScale = 8;
        
        for var buttonTitle in buttonList{
            menuWidth += buttonTitle.characters.count*letterToWidthScale + buttonSpace;
        }
        
        var bCount = 0;
        var bxPos = Int((Int(screenSize.width)-menuWidth) / 2) + 1;
        
        for var buttonTitle in buttonList{
            
            let buttonWidth = buttonTitle.characters.count*letterToWidthScale;
            let buttonRect = CGRect(x: bxPos,y: yPos, width: buttonWidth,height: buttonHeight);
            buttons.append(addButtonProperties(title: buttonTitle, hidden: true, pos: buttonRect, cornerRadius: buttonCornerRadius));
            buttons[bCount].addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
            self.view.addSubview(buttons[bCount]);
            bCount += 1;
            bxPos += buttonWidth + buttonSpace;
        }
        
    }
    
    //MARK: Update label contents
    func updateInfoLabel(newText: String, show: Bool, hideAfter: Int){
        infoLabel.setTitle(newText, for: UIControlState());
        if(show == false){
            infoLabel.isHidden = true;
        }else{
            infoLabel.isHidden = false;
        }
        if(hideAfter != 0){
            let timeToHide = DispatchTime.now() + .seconds(hideAfter)
            DispatchQueue.main.asyncAfter(deadline: timeToHide, execute: {
                self.infoLabel.isHidden = true;
            })
        }
    }
    
    //MARK: Render all items
    func renderAll(view: UIView){
        self.view = view;
        renderLabel();
        renderMenu();
        renderGeneralButtons();
        addStrandTapRecognizer();
        renderPostCommentForm();
    }
    
}

