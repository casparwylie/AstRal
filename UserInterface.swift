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
    @objc optional func loginRequest(username: String, password: String);
    @objc optional func signUpRequest(username: String, password: String, fullname: String, email: String);
}

class UserInterface1{
    
    //MARK: Item initiation
    
    var menuButtons: [UIButton] = [];
    var setPOIbutton: UIButton!;
    var infoLabel: UIButton!;
    var doneChoosingTapPosButton: UIButton!;
    var cancelChoosingButton: UIButton!;
    var toggleMenuButton: UIButton!;
    var postStrandButton: UIButton!;
    var loginSubmitButton: UIButton!;
    var cancelLoginButton: UIButton!;
    var signUpSubmitButton: UIButton!;
    var cancelSignUpButton: UIButton!;
    
    var usernameLoginField: UITextField!;
    var passwordLoginField: UITextField!;
    var commentTextfield: UITextField!;
    var signUpFields: (username: UITextField?,password: UITextField?,fullname: UITextField?,email: UITextField?);
    
    var loginForm: UIView!;
    var commentForm: UIView!;
    var signUpForm: UIView!;
    
    var actionDelegate: UIActionDelegate?;
    var tapToPost = false;
    var scrollView: UIScrollView!;
    var view: UIView!;
    var setTapPointForPost = (x: 0, y: 0);
    var mapShowing = false;
    
    //MARK: UI constants
    let mainFont = UIFont(name: "Futura", size: 12);
    let textFieldFont = UIFont(name: "Futura", size: 15);
    let mainFontColor = UIColor.black;
    let infoLabelYPos = 20;
    let buttonSpace = 2;
    let buttonHeight = 40;
    let buttonCornerRadius = CGFloat(3.0);
    let generalButtonWidth = 40;
    let textFieldSize = (width: 190, height: 40);
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
            hideAnyViews();
            loginForm.isHidden = false;
        case "Post Strand":
            if(mapShowing==true){
                actionDelegate?.toggleMap!(isAddingStrand: true);
            }
            updateInfoLabel(newText: "Tap wherever you want to post it (from camera or map)", show: true, hideAfter: 0);
            cancelChoosingButton.isHidden = false;
            toggleMenu();
            self.tapToPost = true;
        case "Sign Up":
            hideAnyViews();
            signUpForm.isHidden = false;
        default:
            toggleMenu();
        }
    }
    
    func toggleMenu(){
        for var button in menuButtons{
            if(button.isHidden == false){
                button.isHidden = true;
            }else{
                button.isHidden = false;
            }
        }
    }
    
    @objc func hideAnyViews(){
        loginForm.isHidden = true;
        commentForm.isHidden = true;
        signUpForm.isHidden = true;
        self.view.endEditing(true);
    }
    
    @objc func wrapTapped(touch: UITapGestureRecognizer){
        let tapPoint = touch.location(in: self.view);
        if(self.tapToPost == true && mapShowing == false){
            actionDelegate?.renderTempStrandFromUI!(tapX: Int(tapPoint.x), tapY: Int(tapPoint.y));
        }else{
            //get strandinfo
        }
    }
    
    
    @objc func loginSubmitWrapper(sender: UIButton!){
        self.view.endEditing(true);
        if((usernameLoginField.text?.characters.count)! > 0 && (passwordLoginField.text?.characters.count)! > 0){
            actionDelegate?.loginRequest!(username: usernameLoginField.text!, password: passwordLoginField.text!);
        }
    }
    
    @objc func signUpSubmitWrapper(sender: UIButton!){
        self.view.endEditing(true);
        actionDelegate?.signUpRequest!(username: (signUpFields.username?.text)!, password: (signUpFields.password?.text)!, fullname: (signUpFields.fullname?.text)!, email: (signUpFields.email?.text)!);

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
        
        commentTextfield = addTextFieldProperties(pos: CGRect(x: 5, y: 30, width: textFieldSize.width, height: textFieldSize.height));
        commentTextfield.text = "Enter Comment...";
        
        let postStrandButtonRect = CGRect(x: 5, y: 80, width: 100, height: 40)
        postStrandButton = addButtonProperties(title: "Post Strand", hidden: false, pos: postStrandButtonRect, cornerRadius: buttonCornerRadius);
        postStrandButton.addTarget(self, action: #selector(postStrand), for: .touchUpInside);
        
        commentForm.addSubview(commentTextfield);
        commentForm.addSubview(postStrandButton);
        self.view.addSubview(commentForm);
    }
    
    func renderLoginForm(){
        let formWidth = 250;
        let formHeight = 190;
        let buttonWidthLogin =  120;
        let textWidthLogin =  240;
        
        loginForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: 60 + buttonSpace,width: formWidth, height: formHeight));
        loginForm.isHidden = true;
        loginForm.insertSubview(processBlurEffect(bounds: loginForm.bounds, cornerRadiusVal: buttonCornerRadius), at: 0);
        
        usernameLoginField = addTextFieldProperties(pos: CGRect(x: 5, y: 5, width: textWidthLogin, height: textFieldSize.height));
        usernameLoginField.text = "Username...";
        
        passwordLoginField = addTextFieldProperties(pos: CGRect(x: 5, y: 55, width: textWidthLogin, height: textFieldSize.height));
        passwordLoginField.text = "Password...";
        passwordLoginField.isSecureTextEntry = true;
        
        
        
        let loginSubmitButtonRect = CGRect(x: 5, y: 130, width: buttonWidthLogin, height: textFieldSize.height);
        loginSubmitButton = addButtonProperties(title: "Login", hidden: false, pos: loginSubmitButtonRect, cornerRadius: buttonCornerRadius);
        loginSubmitButton.addTarget(self, action: #selector(loginSubmitWrapper), for: .touchUpInside);
        
        let cancelLoginButtonRect = CGRect(x: 125, y: 130, width: buttonWidthLogin, height: textFieldSize.height);
        cancelLoginButton = addButtonProperties(title: "Cancel", hidden: false, pos: cancelLoginButtonRect, cornerRadius: buttonCornerRadius);
        cancelLoginButton.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        
        loginForm.addSubview(usernameLoginField);
        loginForm.addSubview(passwordLoginField);
        loginForm.addSubview(loginSubmitButton);
        loginForm.addSubview(cancelLoginButton);
        self.view.addSubview(loginForm);
    }

    func renderSignUpForm(){
        let formWidth = 250;
        let formHeight = 290;
        let buttonWidthSignUp =  120;
        let textWidthSignUp =  240;
        
        signUpForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: 60 + buttonSpace,width: formWidth, height: formHeight));
        signUpForm.isHidden = true;
        signUpForm.insertSubview(processBlurEffect(bounds: signUpForm.bounds, cornerRadiusVal: buttonCornerRadius), at: 0);
        
        signUpFields.username = addTextFieldProperties(pos: CGRect(x: 5, y: 5, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.username?.text = "Username...";
        
        signUpFields.password = addTextFieldProperties(pos: CGRect(x: 5, y: 55, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.password?.text = "Password...";
        signUpFields.password?.isSecureTextEntry = true;
        
        signUpFields.fullname = addTextFieldProperties(pos: CGRect(x: 5, y: 105, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.fullname?.text = "Fullname...";
        
        signUpFields.email = addTextFieldProperties(pos: CGRect(x: 5, y: 155, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.email?.text = "Email...";
        
        let signUpSubmitButtonRect = CGRect(x: 5, y: 225, width: buttonWidthSignUp, height: textFieldSize.height);
        signUpSubmitButton = addButtonProperties(title: "Sign Up", hidden: false, pos: signUpSubmitButtonRect, cornerRadius: buttonCornerRadius);
        signUpSubmitButton.addTarget(self, action: #selector(signUpSubmitWrapper), for: .touchUpInside);
        
        let cancelSignUpButtonRect = CGRect(x: 125, y: 225, width: buttonWidthSignUp, height: textFieldSize.height);
        cancelSignUpButton = addButtonProperties(title: "Cancel", hidden: false, pos: cancelSignUpButtonRect, cornerRadius: buttonCornerRadius);
        cancelSignUpButton.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        
        signUpForm.addSubview(signUpFields.username!);
        signUpForm.addSubview(signUpFields.password!);
        signUpForm.addSubview(signUpFields.fullname!);
        signUpForm.addSubview(signUpFields.email!);
        signUpForm.addSubview(signUpSubmitButton);
        signUpForm.addSubview(cancelSignUpButton);
        self.view.addSubview(signUpForm);
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
    
    
    func addTextFieldProperties(pos: CGRect) -> UITextField{
        let textField = UITextField(frame: pos);
        textField.layer.cornerRadius = buttonCornerRadius;
        textField.layer.borderWidth = 1;
        textField.layer.borderColor = UIColor.gray.cgColor;
        textField.textColor = mainFontColor;
        textField.font = textFieldFont;
        return textField;
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
    func renderMenu(loggedin: Bool){
        if(menuButtons.count>0){
            for button in menuButtons{
                button.removeFromSuperview();
            }
            toggleMenuButton.removeFromSuperview();
            menuButtons = [];
        }
        let yPos = Int(screenSize.height) - buttonHeight - 60;
        let toggleWidth = 50;
        let halfTW = toggleWidth/2;
        let toggleMenuRect  = CGRect(x: Int(screenSize.width*0.5)-halfTW,y: yPos+toggleWidth-7, width: toggleWidth,height: toggleWidth);
        toggleMenuButton = addButtonProperties(title: " ", hidden: false, pos: toggleMenuRect, cornerRadius: CGFloat(halfTW));
        toggleMenuButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
        self.view.addSubview(toggleMenuButton);
        
        var buttonList = ["Show Map","Login","Sign Up","Post Strand","Help"];
        if(loggedin == true){
            buttonList = ["Show Map","Post Strand"," Me ", "Help"];
        }
        
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
            menuButtons.append(addButtonProperties(title: buttonTitle, hidden: true, pos: buttonRect, cornerRadius: buttonCornerRadius));
            menuButtons[bCount].addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
            self.view.addSubview(menuButtons[bCount]);
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
        renderMenu(loggedin: false);
        renderGeneralButtons();
        addStrandTapRecognizer();
        renderLoginForm();
        renderSignUpForm();
        renderPostCommentForm();
    }
    
}

