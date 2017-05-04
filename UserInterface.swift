//
//  UserInterface.swift
//  Focals
//
//  Created by Caspar Wylie on 06/08/2016.
//  Copyright © 2016 Caspar Wylie. All rights reserved.
//

/*
 
 USER INTERFACE COMPONENT
 
 */

import Foundation
import UIKit
import SwiftyJSON
import CoreLocation

//MARK: Delegate declaration of all UI actions
@objc protocol UIActionDelegate {
    @objc optional func toggleMap(_ isAddingFocal: Bool);
    @objc optional func openLoginForm();
    @objc optional func addFocalReady(_ comment: String);
    @objc optional func renderTempFocalFromUI(_ tapX: Int, tapY: Int);
    @objc optional func cancelNewFocal();
    @objc optional func loginRequest(_ username: String, password: String);
    @objc optional func updateUserDataRequest(_ username: String, password: String, fullname: String, email: String);
    @objc optional func logoutUser();
    @objc optional func requestUserFocals();
    @objc optional func deleteFocalRequest(_ realID: Int);
    @objc optional func chooseFocalComments(_ tapX: Int, tapY: Int);
    @objc optional func postNewComment(_ commentText: String);
    @objc optional func newVoteComment(_ vote: Int, cID: Int);
    
}

class UserInterface1{
    
    //MARK: Item initiation
    
    //UI Buttons
    var menuButtons: [UIButton] = [];
    var setPOIbutton: UIButton!;
    var infoLabel: UIButton!;
    var doneChoosingTapPosButton: UIButton!;
    var cancelChoosingButton: UIButton!;
    var toggleMenuButton: UIButton!;
    var postFocalButton: UIButton!;
    var loginSubmitButton: UIButton!;
    var cancelLoginButton: UIButton!;
    var signUpSubmitButton: UIButton!;
    var cancelSignUpButton: UIButton!;
    var closeUserFocalView: UIButton!;
    var closeUserProfileView: UIButton!;
    var closeHelpView: UIButton!;
    var closeSingleFocalInfoView: UIButton!;
    var closeFocalCommentsView: UIButton!;
    var deleteFocalButton: UIButton!;
    var newCommentButton: UIButton!;
    
    //UI Text Fields
    var usernameLoginField: UITextField!;
    var passwordLoginField: UITextField!;
    var commentTextfield: UITextField!;
    var signUpFields: (username: UITextField?,
                    password: UITextField?,
                    fullname: UITextField?,
                    email: UITextField?);
    var commentExistingFocalTextfield: UITextField!;
    
    //UI Views
    var loginForm: UIView!;
    var commentForm: UIView!
    var signUpForm: UIView!;
    var userFocalListView: UIView!;
    var focalCommentsView: UIView!;
    var userProfileView: UIView!;
    var helpView: UIView!;
    var singleFocalInfoView: UIView!;
    var userScrollFocalListView: UIScrollView!;
    var focalCommentsListScrollView: UIScrollView!;
    var upVoteCommentIcons: [Int: UIImageView] = [:];
    var downVoteCommentIcons: [Int: UIImageView] = [:];
    
    //UI Labels
    var singleFocalFcommentTitle: UILabel!;
    var upVoteCommentLabels: [Int: UILabel] = [:];
    var downVoteCommentLabels: [Int: UILabel] = [:];
    var helpTextLabel: UILabel!;
    var focalVisitCountLabel: UILabel!;
    
    //General Presets
    var loggedinUserData = (id: 0, username: "Unknown", fullname: "Unknown", email: "Unknown", password: "");
    var actionDelegate: UIActionDelegate?;
    var tapToPost = false;
    var view: UIView!;
    var setTapPointForPost = (x: 0, y: 0);
    var mapShowing = false;
    var vertList = ["My Focals", "Profile", "Logout"];
    var mainMenuShowing = false;
    var vertMenuShowing = false;
    var userFocalLabelYPos = 5;
    var focalCommentListLabelYPos = 5;
    var tagsForBlur = 100;
    let focalIconDest = "focal_icon.png";
    var posFocalToDeleteRealID = 0;
    var userFocalsJSON: JSON!;
    var userFocalFirstCommentsJSON: JSON!;
    var focalCommentsJSON: JSON!;
    var currBlurState = "light";
    var screenSize: CGRect = UIScreen.main.bounds;
    var singleFocalTapRecs: [UITapGestureRecognizer] = [];
    var intentToSignUp = true;
    
    //MARK: UI constants
    let mainTypeFace = "Futura";
    var viewPageWidth: Int!;
    var viewPageX: Int!;
    var mainFont: UIFont!;
    var textFieldFont: UIFont!;
    let mainFontColor = UIColor.black;
    let infoLabelYPos = 20;
    let buttonSpace = 2;
    let singleFocalIconSize = (width: 60, height: 95);
    let userFocalLabelHeight = 18;
    let formWidth = 250;
    let closeButtonWidth = 40;
    let closeButtonHeight = 20;
    let defaultFormY = 60;
    let buttonHeight = 40;
    let commentTextLabelHeight = 20;
    let buttonCornerRadius = CGFloat(3.0);
    let generalButtonWidth = 40;
    let textFieldSize = (width: 190, height: 40);
    
    
   
    //MARK:  UIActionDelegate method wrappers
    @objc func buttonAction(_ sender: UIButton!){
        let whichAction = sender.currentTitle!;
        switch whichAction {
        case "Show Map":
            actionDelegate?.toggleMap!(self.tapToPost);
            sender.setTitle("Hide Map", for: UIControlState());
            mapShowing = true;
            changeBlurToggle();
            
        case "Hide Map":
            actionDelegate?.toggleMap!(false);
            sender.setTitle("Show Map", for: UIControlState());
            mapShowing = false;
            changeBlurToggle();
            
        case "Login":
            hideAnyViews();
            loginForm.isHidden = false;
            
        case "Post Focal":
            hideAnyViews();
            if(mapShowing==true){
                actionDelegate?.toggleMap!(true);
            }
            updateInfoLabel("Tap wherever you want to post it (from camera or map)", show: true, hideAfter: 0);
            cancelChoosingButton.isHidden = false;
            toggleMenu(false);
            self.tapToPost = true;
            
        case "Sign Up":
            intentToSignUp = true;
            signUpToProfileUpdateTransformForm(false);
            hideAnyViews();
            signUpForm.isHidden = false;
            
        case " Me ":
            toggleMenu(true);
            
        case "My Focals":
            toggleMenu(true);
            hideAnyViews();
            actionDelegate?.requestUserFocals!();
            userFocalListView.isHidden = false;
        
        case "Profile":
            toggleMenu(true);
            hideAnyViews();
            intentToSignUp = false;
            signUpToProfileUpdateTransformForm(true);
            signUpForm.isHidden = false;
        
        case "Logout":
            toggleMenu(true);
            renderMenu(false);
            hideAnyViews();
            actionDelegate?.logoutUser!();
        
        case " Help ":
            hideAnyViews();
            helpView.isHidden = false;
            
            
        default:
            toggleMenu(false);
        }
    }
    
    func toggleMenu(_ vert: Bool){
        for button in menuButtons{
            if(vert == true){
                if(vertList.contains((button.titleLabel?.text)!) == true ){
                    if(button.isHidden == true){
                        button.isHidden = false;
                    }else{
                        button.isHidden = true;
                    }
                }
            }else{
                if(button.isHidden == true && vertList.contains((button.titleLabel?.text)!) == false){
                    button.isHidden = false;
                }else{
                    button.isHidden = true;
                }
                
            }
        }
    }
    
    @objc func hideAnyViews(){
        loginForm.isHidden = true;
        commentForm.isHidden = true;
        signUpForm.isHidden = true;
        userFocalListView.isHidden = true;
        focalCommentsView.isHidden = true;
        singleFocalInfoView.isHidden = true;
        userProfileView.isHidden = true;
        helpView.isHidden = true;
        self.view.endEditing(true);
    }
    
    @objc func closeSingleFocalInfoViewWrap(){
        singleFocalInfoView.isHidden = true;
    }
    
    @objc func wrapTapped(_ touch: UITapGestureRecognizer){
        let tapPoint = touch.location(in: self.view);
        
        if(mapShowing == false){
            if(self.tapToPost == true ){
                actionDelegate?.renderTempFocalFromUI!(Int(tapPoint.x), tapY: Int(tapPoint.y));
                updateInfoLabel("Tap somewhere else or 'Done'", show: true, hideAfter: 0);
            }else{
                actionDelegate?.chooseFocalComments!(Int(tapPoint.x), tapY: Int(tapPoint.y));
            }
        }
    }
    
    
    @objc func loginSubmitWrapper(_ sender: UIButton!){
        self.view.endEditing(true);
        if((usernameLoginField.text?.characters.count)! > 0 && (passwordLoginField.text?.characters.count)! > 0){
            actionDelegate?.loginRequest!(usernameLoginField.text!, password: passwordLoginField.text!);
        }
    }
    
    @objc func signUpSubmitWrapper(_ sender: UIButton!){
        self.view.endEditing(true);
        actionDelegate?.updateUserDataRequest!((signUpFields.username?.text)!, password: (signUpFields.password?.text)!, fullname: (signUpFields.fullname?.text)!, email: (signUpFields.email?.text)!);
    }
    
    func signUpToProfileUpdateTransformForm(_ asProfile: Bool){
        if(asProfile == true){
            signUpFields.username?.text = loggedinUserData.username;
            signUpFields.email?.text = loggedinUserData.email;
            signUpFields.fullname?.text = loggedinUserData.fullname;
            signUpFields.password?.text = loggedinUserData.password;
            signUpSubmitButton.setTitle("Update", for: UIControlState());
        }else{
            signUpFields.username?.text = "Username..";
            signUpFields.email?.text = "Email...";
            signUpFields.fullname?.text = "Fullname...";
            signUpSubmitButton.setTitle("Sign Up", for: UIControlState());
        }
    }

    
    func showTapFinishedOptions(){
        doneChoosingTapPosButton.isHidden = false;
        updateInfoLabel("Tap 'Done' when you have choosen a position", show: true, hideAfter: 0);
    }
    
    
    @objc func cancelTap(){
        doneChoosingTapPosButton.isHidden = true;
        updateInfoLabel(" ", show: false, hideAfter: 0);
        self.tapToPost = false;
        cancelChoosingButton.isHidden = true;
        commentForm.isHidden = true;
        actionDelegate?.cancelNewFocal!();
        self.view.endEditing(true);
    }
    
    @objc func newFocalComment(){
        self.tapToPost = false;
        updateInfoLabel(" ", show: false, hideAfter: 0);
        doneChoosingTapPosButton.isHidden = true;
        self.commentForm.isHidden = false;
    }
    
    @objc func newCommentFocal(){
        self.view.endEditing(true);
        actionDelegate?.postNewComment!(commentExistingFocalTextfield.text!);
    }
    
    @objc func postFocal(){
        cancelTap();
        actionDelegate?.addFocalReady!(commentTextfield.text!);
        self.view.endEditing(true);
    }
    
    @objc func deleteFocalWrap(){
        actionDelegate?.deleteFocalRequest!(posFocalToDeleteRealID);
    }
    
    func addUserFocalLabel(_ text: String, areaName: String, localID: Int){
        
        let focalTextLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userFocalLabelYPos+10, width: 250, height: userFocalLabelHeight));
        let focalAreaLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userFocalLabelYPos+userFocalLabelHeight+10, width: 250, height: userFocalLabelHeight));
        
        let focalIcon = UIImage(named: focalIconDest);
        let focalIconView = UIImageView(image: focalIcon!);
        focalIconView.tag = localID;
        focalIconView.frame = CGRect(x: 0, y:  userFocalLabelYPos+12, width: 20, height: 30);
        
        focalTextLabel.text = text;
        focalAreaLabel.text = "in " + areaName;
        
        let uiImageTap = UITapGestureRecognizer(target: self, action: #selector(showSingleFocalInfo));
        focalIconView.isUserInteractionEnabled = true;
        focalIconView.addGestureRecognizer(uiImageTap);
        focalTextLabel.font = UIFont(name: mainTypeFace, size: 17);
        focalAreaLabel.font = UIFont(name: mainTypeFace+"-Bold", size: 13);
        
        userScrollFocalListView.addSubview(focalTextLabel);
        userScrollFocalListView.addSubview(focalAreaLabel);
        userScrollFocalListView.addSubview(focalIconView);
        
    }
    
    @objc func showSingleFocalInfo(_ sender: UITapGestureRecognizer){
        let focalInfoLocalID = sender.view?.tag;
        posFocalToDeleteRealID = userFocalsJSON[focalInfoLocalID!]["f_id"].int!;
        let relTitleText = userFocalFirstCommentsJSON[focalInfoLocalID!]["c_text"].rawString()!;
        singleFocalFcommentTitle.text = relTitleText;
        singleFocalInfoView.isHidden = false;
    }
    
    func populateUserFocals(_ focals: JSON, firstComments: JSON){
        userFocalsJSON = focals;
        userFocalFirstCommentsJSON = firstComments;
        for subview in userScrollFocalListView.subviews{
            subview.removeFromSuperview();
        }
        userFocalLabelYPos = 5;
        let labelHeight = 2*userFocalLabelHeight+10;
        userScrollFocalListView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(5+(focals.count*labelHeight)));
        var count = 0;
        for focal in focals{
            let areaName = focals[count]["f_area_name"].rawString()!;
            self.addUserFocalLabel(firstComments[count]["c_text"].rawString()!, areaName: areaName, localID: count);
            self.userFocalLabelYPos += 2*self.userFocalLabelHeight + 10;
            count += 1;
        }
    }
    
    func getHeightForField(_ text: String, font: UIFont, width: CGFloat) ->CGFloat{
        let tempLabel = UILabel(frame: CGRect(x:0,y:0,width:width,height:CGFloat.greatestFiniteMagnitude));
        tempLabel.numberOfLines = 0;
        tempLabel.text = text;
        tempLabel.font = font;
        tempLabel.sizeToFit();
        tempLabel.lineBreakMode = NSLineBreakMode.byWordWrapping;
        return tempLabel.frame.height;
    }
    
    var lastCommentHeight = 0;
    var commentInfoHeight = 40;
    func addFocalCommentLabel(_ text: String, infoString: String, cID: String, downVotes: String, upVotes: String, canVote: Bool){
        let cID = Int(cID);
        let labelWidth = viewPageWidth-20;
        let labelTextHeight =  getHeightForField(text, font: mainFont, width: CGFloat(labelWidth));
        lastCommentHeight = Int(labelTextHeight);
        let commentTextLabel: UILabel  = UILabel(frame: CGRect(x: 5, y: focalCommentListLabelYPos+10, width: labelWidth, height: Int(labelTextHeight)));
        
        commentTextLabel.text = text;
        commentTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping;
        commentTextLabel.numberOfLines = Int(labelTextHeight/20)+1;
        commentTextLabel.font = mainFont;
        
        let commentInfoLabel: UILabel  = UILabel(frame: CGRect(x: 5, y: focalCommentListLabelYPos+Int(labelTextHeight), width: labelWidth, height: commentInfoHeight));
    
        commentInfoLabel.text = infoString;
        commentInfoLabel.font = UIFont(name: mainTypeFace+"-Bold", size: 11);
        
        let voteIconNamePrefix = canVote ? "v" : "vd";
        let vUpIconDest = voteIconNamePrefix + "_up_icon.png";
        let vDownIconDest = voteIconNamePrefix + "_down_icon.png";
        
        
        let voteIconY = focalCommentListLabelYPos+Int(labelTextHeight) + 30;
        let voteIconX = 160;
        let voteIconHeight = 13;
        let voteIconWidth = 18;
        let voteCountFontSize: CGFloat = 9.0;
       
        let vUpIcon = UIImage(named: vUpIconDest);
        upVoteCommentIcons[cID!] = UIImageView(image: vUpIcon!);
        upVoteCommentIcons[cID!]?.tag = cID!;
        upVoteCommentIcons[cID!]?.frame = CGRect(x: voteIconX+10, y: voteIconY, width: voteIconWidth, height: voteIconHeight);
        let vUpTap = UITapGestureRecognizer(target: self, action: #selector(voteCommentUp));
        upVoteCommentIcons[cID!]?.isUserInteractionEnabled = canVote;
        upVoteCommentIcons[cID!]?.addGestureRecognizer(vUpTap);
        
        upVoteCommentLabels[cID!] = UILabel(frame: CGRect(x: voteIconX-30, y: voteIconY, width: 40, height: 10));
        upVoteCommentLabels[cID!]?.text = upVotes;
        upVoteCommentLabels[cID!]?.font = UIFont(name: mainTypeFace, size: voteCountFontSize);
        upVoteCommentLabels[cID!]?.textAlignment = .right;
        upVoteCommentLabels[cID!]?.textColor = UIColor(red: 0.3373, green:0.6784, blue:0.3569, alpha: 1.0);
        
       
        let vDownIcon = UIImage(named: vDownIconDest);
        downVoteCommentIcons[cID!] = UIImageView(image: vDownIcon!);
        downVoteCommentIcons[cID!]?.tag = cID!;
        downVoteCommentIcons[cID!]?.frame = CGRect(x: voteIconX+30, y: voteIconY, width: voteIconWidth, height: voteIconHeight);
        let vDownTap = UITapGestureRecognizer(target: self, action: #selector(voteCommentDown));
        downVoteCommentIcons[cID!]?.isUserInteractionEnabled = canVote;
        downVoteCommentIcons[cID!]?.addGestureRecognizer(vDownTap);
        
        downVoteCommentLabels[cID!] = UILabel(frame: CGRect(x: voteIconX+50, y: voteIconY, width: 40, height: 10));
        downVoteCommentLabels[cID!]?.text = downVotes;
        downVoteCommentLabels[cID!]?.font = UIFont(name: mainTypeFace, size: voteCountFontSize);
        downVoteCommentLabels[cID!]?.textAlignment = .left;
        downVoteCommentLabels[cID!]?.textColor = UIColor(red: 0.7882, green: 0.3373, blue: 0.2353, alpha: 1.0);
        
        let cSeparator = UIView(frame: CGRect(x:0,y:voteIconY+15, width: viewPageWidth-10, height: 1));
        
        cSeparator.layer.borderColor = UIColor.gray.cgColor;
        cSeparator.layer.borderWidth = 1;
        
        focalCommentsListScrollView.addSubview(commentTextLabel);
        focalCommentsListScrollView.addSubview(commentInfoLabel);
        focalCommentsListScrollView.addSubview(upVoteCommentIcons[cID!]!);
        focalCommentsListScrollView.addSubview(downVoteCommentIcons[cID!]!);
        focalCommentsListScrollView.addSubview(upVoteCommentLabels[cID!]!);
        focalCommentsListScrollView.addSubview(downVoteCommentLabels[cID!]!);
        focalCommentsListScrollView.addSubview(cSeparator);
    }
    
    func disableVoteTap(cID: Int){
        downVoteCommentIcons[cID]?.isUserInteractionEnabled = false;
        upVoteCommentIcons[cID]?.isUserInteractionEnabled = false;
        downVoteCommentIcons[cID]?.image = UIImage(named: "vd_down_icon.png");
        upVoteCommentIcons[cID]?.image = UIImage(named: "vd_up_icon.png");
    }
    
    @objc func voteCommentDown(_ sender: UITapGestureRecognizer){
        let cID = sender.view?.tag;
        downVoteCommentLabels[cID!]?.text = String(Int((downVoteCommentLabels[cID!]?.text!)!)! + 1);
        voteComment(vote: -1, cID: cID!);
        disableVoteTap(cID: cID!);
    }
    @objc func voteCommentUp(_ sender: UITapGestureRecognizer){
        let cID = sender.view?.tag;
        upVoteCommentLabels[cID!]?.text = String(Int((upVoteCommentLabels[cID!]?.text!)!)! + 1);
        voteComment(vote: 1, cID: cID!);
        disableVoteTap(cID: cID!);
    }
    func voteComment(vote: Int, cID: Int){
        actionDelegate?.newVoteComment!(vote, cID: cID);
    }
    
    func populateFocalCommentsView(_ focalComments: JSON, userCommentVotes: JSON, focalVisitCount: JSON){
        focalCommentsView.isHidden = false;
        lastCommentHeight = 0;
        for subview in focalCommentsListScrollView.subviews{
            subview.removeFromSuperview();
        }
        focalCommentsJSON = focalComments;
        focalCommentsListScrollView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(800));
        focalCommentListLabelYPos = 5;
        
        focalVisitCountLabel.text = focalVisitCount.rawString()! + " Focal visit(s)";
        
        var count = 0;
        var nextYPosCalc = 0;
        for _ in focalComments{
            var canVote = true;
            let userVotes = userCommentVotes[count];
            if(Int(loggedinUserData.id) != 0){
                for userID in userVotes{
                    print(userID.1["u_id"].int!);
                    if(loggedinUserData.id == userID.1["u_id"].int!){
                        canVote = false;
                        break;
                    }
                }
            }else{
                canVote = false;
            }
            let commentText = focalComments[count]["c_text"].rawString()!;
            let timestamp = focalComments[count]["c_time"].rawString()!;
            let timestampDate = NSDate(timeIntervalSince1970: Double(timestamp)!);
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = " HH:mm dd/mm/yyyy";
            let colloquialTime = dateFormatter.string(from: timestampDate as Date);
            let infoString = "By " + focalComments[count]["c_u_uname"].rawString()! + ", at " + colloquialTime;
            addFocalCommentLabel(commentText, infoString: infoString, cID: focalComments[count]["c_id"].rawString()!, downVotes:focalComments[count]["c_v_down"].rawString()!,upVotes:focalComments[count]["c_v_up"].rawString()!, canVote: canVote);
            nextYPosCalc = lastCommentHeight + commentInfoHeight;
            focalCommentListLabelYPos += nextYPosCalc;
            count += 1;
        }
        focalCommentsListScrollView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(5+focalCommentListLabelYPos+nextYPosCalc));
    }

    
    //MARK: render UI components
    func renderPostCommentForm(){
        let formHeight = 100;
        commentForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: defaultFormY + buttonHeight + buttonSpace,width: formWidth, height: formHeight));
        commentForm.isHidden = true;
        commentForm.insertSubview(processBlurEffect(commentForm.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        commentTextfield = addTextFieldProperties(CGRect(x: 5, y: 5, width: 240, height: textFieldSize.height));
        commentTextfield.text = "Enter Comment...";
        
        let postFocalButtonRect = CGRect(x: 5, y: 5+textFieldSize.height+10, width: 100, height: 40);
        postFocalButton = addButtonProperties("Post Focal", hidden: false, pos: postFocalButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        postFocalButton.addTarget(self, action: #selector(postFocal), for: .touchUpInside);
        
        commentForm.addSubview(commentTextfield);
        commentForm.addSubview(postFocalButton);
        self.view.addSubview(commentForm);
    }
    
    func changeBlurToggle(){
        var light = false;
        if(currBlurState == "dark"){
            light = true;
            currBlurState = "light";
        }else{
            currBlurState = "dark";
        }

        for tag in 100...tagsForBlur{
            let element = self.view.viewWithTag(tag);
            let fromView = element?.superview;
            let useCornerRadius = element?.layer.cornerRadius;
            element?.removeFromSuperview();
            
            let newColor = ((currBlurState == "dark") ? UIColor.white : mainFontColor);
            if let viewAsButton = fromView as? UIButton{
                viewAsButton.setTitleColor(newColor, for: .normal);
            }
            if let viewAsTextField = fromView as? UITextField{
                viewAsTextField.textColor = newColor;
            }
            
            fromView?.insertSubview(processBlurEffect((element?.bounds)!, cornerRadiusVal: useCornerRadius!, light: light), at: 0);
        }
    }
    
    func renderLoginForm(){
        let formHeight = 176;
        let buttonWidthLogin =  viewPageWidth/2 - 10;
        let textWidthLogin =  viewPageWidth-10;
        
        loginForm = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: formHeight));
        loginForm.isHidden = true;
        loginForm.insertSubview(processBlurEffect(loginForm.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        usernameLoginField = addTextFieldProperties(CGRect(x: 5, y: 5, width: textWidthLogin, height: textFieldSize.height));
        usernameLoginField.text = "Test123";
        
        passwordLoginField = addTextFieldProperties(CGRect(x: 5, y: 55, width: textWidthLogin, height: textFieldSize.height));
        passwordLoginField.text = "test123";
        passwordLoginField.isSecureTextEntry = true;
        
        
        
        let loginSubmitButtonRect = CGRect(x: 5, y: 130, width: buttonWidthLogin, height: textFieldSize.height);
        loginSubmitButton = addButtonProperties("Login", hidden: false, pos: loginSubmitButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        loginSubmitButton.addTarget(self, action: #selector(loginSubmitWrapper), for: .touchUpInside);
        
        let cancelLoginButtonRect = CGRect(x: viewPageWidth-(buttonWidthLogin+5), y: 130, width: buttonWidthLogin, height: textFieldSize.height);
        cancelLoginButton = addButtonProperties("Cancel", hidden: false, pos: cancelLoginButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        cancelLoginButton.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        
        loginForm.addSubview(usernameLoginField);
        loginForm.addSubview(passwordLoginField);
        loginForm.addSubview(loginSubmitButton);
        loginForm.addSubview(cancelLoginButton);
        self.view.addSubview(loginForm);
    }

    func renderSignUpForm(){
        toggleMenu(true);
        let formHeight = 271;
        let buttonWidthSignUp = viewPageWidth/2 - 10;
        let textWidthSignUp =  viewPageWidth - 10;
        
        signUpForm = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: formHeight));
        signUpForm.isHidden = true;
        signUpForm.insertSubview(processBlurEffect(signUpForm.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        signUpFields.username = addTextFieldProperties(CGRect(x: 5, y: 5, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.username?.text = "Username...";
        
        signUpFields.password = addTextFieldProperties(CGRect(x: 5, y: 55, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.password?.text = "Password...";
        signUpFields.password?.isSecureTextEntry = true;
        
        signUpFields.fullname = addTextFieldProperties(CGRect(x: 5, y: 105, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.fullname?.text = "Fullname...";
        
        signUpFields.email = addTextFieldProperties(CGRect(x: 5, y: 155, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.email?.text = "Email...";
        
        let signUpSubmitButtonRect = CGRect(x: 5, y: 225, width: buttonWidthSignUp, height: textFieldSize.height);
        signUpSubmitButton = addButtonProperties("Sign Up", hidden: false, pos: signUpSubmitButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        signUpSubmitButton.addTarget(self, action: #selector(signUpSubmitWrapper), for: .touchUpInside);
        
        let cancelSignUpButtonRect = CGRect(x: viewPageWidth-(buttonWidthSignUp+5), y: 225, width: buttonWidthSignUp, height: textFieldSize.height);
        cancelSignUpButton = addButtonProperties("Cancel", hidden: false, pos: cancelSignUpButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        cancelSignUpButton.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        
        signUpForm.addSubview(signUpFields.username!);
        signUpForm.addSubview(signUpFields.password!);
        signUpForm.addSubview(signUpFields.fullname!);
        signUpForm.addSubview(signUpFields.email!);
        signUpForm.addSubview(signUpSubmitButton);
        signUpForm.addSubview(cancelSignUpButton);
        self.view.addSubview(signUpForm);
    }
    
    func renderSingleFocalInfoView(){
        let viewHeight = 250;
        singleFocalInfoView = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        singleFocalInfoView.isHidden = true;
        singleFocalInfoView.insertSubview(processBlurEffect(singleFocalInfoView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        
        let closeSingleFocalInfoRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeSingleFocalInfoView = addButtonProperties("Close", hidden: false, pos: closeSingleFocalInfoRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeSingleFocalInfoView.addTarget(self, action: #selector(closeSingleFocalInfoViewWrap), for: .touchUpInside);
        
        let deleteButtonWidth = 70;
        let deleteFocalButtonRect = CGRect(x: viewPageWidth/2-(deleteButtonWidth/2), y: viewHeight-(buttonHeight+5), width: deleteButtonWidth, height: buttonHeight);
        
        deleteFocalButton = addButtonProperties("Delete", hidden: false, pos: deleteFocalButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        deleteFocalButton.addTarget(self, action: #selector(deleteFocalWrap), for: .touchUpInside);

    
        let focalIcon = UIImage(named: focalIconDest);
        let focalIconView = UIImageView(image: focalIcon!);
        focalIconView.frame = CGRect(x: (viewPageWidth/2)-(singleFocalIconSize.width/2), y:  20, width: singleFocalIconSize.width, height: singleFocalIconSize.height);
        
        singleFocalFcommentTitle = UILabel(frame: CGRect(x: 10, y: singleFocalIconSize.height+5, width: viewPageWidth-20, height: 100));
        singleFocalFcommentTitle.font = UIFont(name: mainTypeFace, size: 15);
        singleFocalFcommentTitle.lineBreakMode = NSLineBreakMode.byWordWrapping;
        singleFocalFcommentTitle.textAlignment = .center;
        singleFocalFcommentTitle.numberOfLines = 3;
        
        
        singleFocalInfoView.addSubview(singleFocalFcommentTitle);
        singleFocalInfoView.addSubview(closeSingleFocalInfoView);
        singleFocalInfoView.addSubview(deleteFocalButton);
        singleFocalInfoView.addSubview(focalIconView);
        
        self.view.addSubview(singleFocalInfoView);
        
    }
    
    func renderFocalCommentsView(){
        let viewHeight = 350;
        focalCommentsView = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        focalCommentsView.isHidden = true;
        focalCommentsView.insertSubview(processBlurEffect(focalCommentsView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        focalCommentsListScrollView = UIScrollView(frame: CGRect(x:5,y: closeButtonHeight+15+textFieldSize.height,width: viewPageWidth, height: viewHeight-(closeButtonHeight+15+textFieldSize.height)));

        let closefocalCommentsViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeFocalCommentsView = addButtonProperties("Close", hidden: false, pos: closefocalCommentsViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeFocalCommentsView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        focalVisitCountLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 250, height: 25));
        focalVisitCountLabel.font = UIFont(name: mainTypeFace+"-Bold", size: 11);
        
        let commentExistingFocalTFWidth = viewPageWidth-55;
        commentExistingFocalTextfield = addTextFieldProperties(CGRect(x: 5, y: closeButtonHeight+10, width: commentExistingFocalTFWidth, height: textFieldSize.height));
        commentExistingFocalTextfield.text = "Enter Comment...";
        
        let newCommentButtonRect = CGRect(x: 10+commentExistingFocalTFWidth, y: closeButtonHeight+10, width: 40, height: 40);
        newCommentButton = addButtonProperties("Post", hidden: false, pos: newCommentButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        newCommentButton.addTarget(self, action: #selector(newCommentFocal), for: .touchUpInside);
        
        focalCommentsView.addSubview(newCommentButton);
        focalCommentsView.addSubview(focalVisitCountLabel);
        focalCommentsView.addSubview(commentExistingFocalTextfield);
        focalCommentsView.addSubview(closeFocalCommentsView);
        focalCommentsView.addSubview(focalCommentsListScrollView);
        self.view.addSubview(focalCommentsView);
        
    }
    

    
    func renderUserFocalsView(){
        let viewHeight = 370;
        userFocalListView = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        userFocalListView.isHidden = true;
        userScrollFocalListView = UIScrollView(frame: CGRect(x:5,y: 25,width: viewPageWidth, height: viewHeight-30));
        userScrollFocalListView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(viewHeight));
        userFocalListView.insertSubview(processBlurEffect(userFocalListView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);

        let closeUserFocalViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeUserFocalView = addButtonProperties("Close", hidden: false, pos: closeUserFocalViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeUserFocalView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);

        userFocalListView.addSubview(closeUserFocalView);
        userFocalListView.addSubview(userScrollFocalListView);
        self.view.addSubview(userFocalListView);
    }
    
    func renderHelpView(){
        let viewHeight = 370;
        helpView = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        helpView.insertSubview(processBlurEffect(helpView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        helpView.isHidden = true;
        
        
        let closeHelpViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeHelpView = addButtonProperties("Close", hidden: false, pos:closeHelpViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeHelpView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        self.view.addSubview(helpView);
        helpView.addSubview(closeHelpView);
    
    }
    
    func renderHelpText(text: String){
        helpTextLabel = UILabel(frame: CGRect(x: 5, y: 10, width: 280, height: 360));
        helpTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping;
        helpTextLabel.text = text;
        let labelTextHeight = getHeightForField(text, font: mainFont, width: CGFloat(200));
        helpTextLabel.numberOfLines = Int(labelTextHeight/20)+1;
        helpTextLabel.font = mainFont;
        helpView.addSubview(helpTextLabel);
        
    }
    
    func renderProfileView(){
        let viewHeight = 370;
        userProfileView = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        userProfileView.isHidden = true;
        userProfileView.insertSubview(processBlurEffect(userProfileView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        let closeUserProfileViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeUserProfileView = addButtonProperties("Close", hidden: false, pos: closeUserProfileViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeUserProfileView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        userProfileView.addSubview(closeUserProfileView);
        self.view.addSubview(userProfileView);
    }
    
    func addFocalTapRecognizer(){
        
        let tapRec: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(wrapTapped));
        tapRec.numberOfTapsRequired = 1;
        self.view.addGestureRecognizer(tapRec);
        
    }

    func processBlurEffect(_ bounds: CGRect, cornerRadiusVal: CGFloat, light: Bool) -> UIVisualEffectView {
        
        var style = UIBlurEffectStyle.light;
        if(light==false){
            style = UIBlurEffectStyle.dark;
        }
        
        let blurEffect = UIVisualEffectView(effect: UIBlurEffect(style:
            style));
        blurEffect.frame = bounds;
        blurEffect.isUserInteractionEnabled = false;
        blurEffect.layer.cornerRadius = cornerRadiusVal;
        blurEffect.clipsToBounds = true;
        blurEffect.tag = tagsForBlur;
        tagsForBlur += 1;
        return blurEffect;
    }
    
    func renderLabel(){
        let infoLabelRect = CGRect(x: 5,y: 20,width: Int(screenSize.width)-10,height: buttonHeight);
        infoLabel = addButtonProperties(" ", hidden: true, pos: infoLabelRect, cornerRadius: buttonCornerRadius, blurLight: true);
        self.view.addSubview(infoLabel);
    }
    
    func addButtonProperties(_ title: String, hidden: Bool, pos: CGRect, cornerRadius: CGFloat, blurLight: Bool) ->UIButton{
        let button = UIButton(frame: pos);
        if(blurLight == true){
            button.setTitleColor(mainFontColor, for: .normal);
        }else{
            button.setTitleColor(UIColor.white, for: .normal);
        }
        button.setTitle(title, for: UIControlState());
        button.insertSubview(processBlurEffect(button.bounds, cornerRadiusVal: cornerRadius, light: blurLight), at: 0);
        button.titleLabel!.font =  mainFont;
        button.isHidden = hidden;
        return button;
    }
    
    
    func addTextFieldProperties(_ pos: CGRect) -> UITextField{
        let textField = UITextField(frame: pos);
        textField.insertSubview(processBlurEffect(textField.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        textField.layer.borderColor = UIColor.gray.cgColor;
        textField.textColor = mainFontColor;
        textField.font = textFieldFont;
        return textField;
    }
    
    func renderGeneralButtons(){
        
        let doneChoosingTapPosButtonRect = CGRect(x: Int(screenSize.width)-buttonSpace - (2*generalButtonWidth + 5),y: infoLabelYPos + buttonHeight + buttonSpace,width: generalButtonWidth, height: buttonHeight);
        doneChoosingTapPosButton = addButtonProperties("Done", hidden: true, pos: doneChoosingTapPosButtonRect,cornerRadius: buttonCornerRadius, blurLight: true);
        doneChoosingTapPosButton.addTarget(self, action: #selector(newFocalComment), for: .touchUpInside);
        self.view.addSubview(doneChoosingTapPosButton);
        
        
        let cancelChoosingButtonRect = CGRect(x: Int(screenSize.width-5) - generalButtonWidth,y: infoLabelYPos + buttonHeight + buttonSpace,width: generalButtonWidth, height: buttonHeight);
        cancelChoosingButton = addButtonProperties("Cancel", hidden: true, pos: cancelChoosingButtonRect,cornerRadius: buttonCornerRadius, blurLight: true);
        cancelChoosingButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside);
        self.view.addSubview(cancelChoosingButton);
    }
    
    //MARK:  menu setups
    func renderMenu(_ loggedin: Bool){
        if(menuButtons.count>0){
            for button in menuButtons{
                button.removeFromSuperview();
            }
            toggleMenuButton.removeFromSuperview();
            menuButtons = [];
        }
        
        var mapName = "Show Map";
        var blurLight = true;
        if(mapShowing==true){
            mapName = "Hide Map"
            blurLight = false;
        }
        
        
        let yPos = Int(screenSize.height) - buttonHeight - 60;
        let toggleWidth = 50;
        let halfTW = toggleWidth/2;
        let toggleMenuRect  = CGRect(x: Int(screenSize.width*0.5)-halfTW,y: yPos+toggleWidth-7, width: toggleWidth,height: toggleWidth);
        toggleMenuButton = addButtonProperties(" ", hidden: false, pos: toggleMenuRect, cornerRadius: CGFloat(halfTW), blurLight: blurLight);
        toggleMenuButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
        self.view.addSubview(toggleMenuButton);
        
       
        var buttonList = [mapName,"Login","Sign Up","Post Focal"," Help "];
        if(loggedin == true){
            buttonList = [mapName,"Post Focal"," Me ", " Help ", "My Focals", "Profile", "Logout"];
        }
        
        var menuWidth = 0;
        let letterToWidthScale = 8;
        
        for var buttonTitle in buttonList{
            if(vertList.contains(buttonTitle) == false){
                menuWidth += buttonTitle.characters.count*letterToWidthScale + buttonSpace;
            }
        }
        
        var bCount = 0;
        var bxPos = Int((Int(screenSize.width)-menuWidth) / 2) + 1;
        var vertYPos = 0;
        for var buttonTitle in buttonList{
            
            let buttonWidth = buttonTitle.characters.count*letterToWidthScale;
            var useYPos = yPos;
            var useXPos = bxPos;
            var hidden = false;
            var buttonWidthUse = buttonWidth;
            if(vertList.contains(buttonTitle)){
                vertYPos -= buttonHeight + buttonSpace;
                useXPos = 172;
                buttonWidthUse = 82;
                hidden = true;
                useYPos = useYPos + vertYPos;
            }else{
                
            }
            let buttonRect = CGRect(x: useXPos,y: useYPos, width: buttonWidthUse,height: buttonHeight);
            
            
            menuButtons.append(addButtonProperties(buttonTitle, hidden: hidden, pos: buttonRect, cornerRadius: buttonCornerRadius, blurLight: blurLight));
            menuButtons[bCount].addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
            self.view.addSubview(menuButtons[bCount]);
            bCount += 1;
            bxPos += buttonWidth + buttonSpace;
        }

    }
    
    //MARK: Update label contents
    func updateInfoLabel(_ newText: String, show: Bool, hideAfter: Int){

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
    func renderAll(_ view: UIView){
        self.view = view;
        mainFont = UIFont(name: mainTypeFace, size: 12);
        textFieldFont = UIFont(name: mainTypeFace, size: 15);
        viewPageWidth = Int(screenSize.width)-10;
        viewPageX = Int(screenSize.width/2)-viewPageWidth/2;
        
        renderLabel();
        renderMenu(false);
        renderGeneralButtons();
        addFocalTapRecognizer();
        renderLoginForm();
        renderSignUpForm();
        renderFocalCommentsView();
        renderPostCommentForm();
        renderProfileView();
        renderHelpView();
        renderUserFocalsView();
        renderSingleFocalInfoView();
    }
    
}

