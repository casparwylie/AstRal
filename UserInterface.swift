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
    @objc optional func editComment(_ text: String, cID: Int);
    @objc optional func deleteComment(_ cID: Int);
    @objc optional func getFocalComments(_ focalID: Int, updateVisited: Bool);
    
}

class UserInterface1{
    
    //MARK: Item initiation
    
    //UI Buttons
    var menuButtons: [UIButton] = [];
    var setPOIbutton: UIButton!;
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
    var cancelEditingButton: UIButton!;
    var viewOwnFocalCommentsButton: UIButton!;
    
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
    var helpScrollView: UIScrollView!;
    var focalCommentsListScrollView: UIScrollView!;
    var upVoteCommentIcons: [Int: UIImageView] = [:];
    var downVoteCommentIcons: [Int: UIImageView] = [:];
    var editIcons: [Int: UIImageView] = [:];
    var deleteIcons: [Int: UIImageView] = [:];
    var infoMsgView: UIView!;
    
    //UI Labels
    var singleFocalFcommentTitle: UILabel!;
    var upVoteCommentLabels: [Int: UILabel] = [:];
    var downVoteCommentLabels: [Int: UILabel] = [:];
    var commentTextLabels: [Int: UILabel] = [:];
    var helpTextLabel: UILabel!;
    var focalVisitCountLabel: UILabel!;
    var noFocalsLabel: UILabel!;
    var infoMsgLabels: [Int: UILabel] = [:];
    
    //General Presets
    var loggedinUserData = (id: 0, username: "", fullname: "", email: "", password: "");
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
    var ownFocalViewingInfoRealID = 0;
    var userFocalsJSON: JSON!;
    var userFocalFirstCommentsJSON: JSON!;
    var focalCommentsJSON: JSON!;
    var tapAnywhere: UITapGestureRecognizer!;
    var currBlurState = "light";
    var screenSize: CGRect = UIScreen.main.bounds;
    var singleFocalTapRecs: [UITapGestureRecognizer] = [];
    var intentToSignUp = true;
    var choosingFocalPosOptionsWidth = 81;
    let newFocalOptionSpaceFromMid = 1;
    var viewingFocalID = -1;
    var locationFocused = false;
    var misc = Misc();
    
    //MARK: UI constants
    let mainTypeFace = "Heiti SC";
    let mainTypeFaceBold = "STHeitiSC-Medium";//Gujarati Sangam MN";////Malayalam Sangam MN//iosfonts.com/
    var viewPageWidth: Int!;
    var viewPageX: Int!;
    var mainFont: UIFont!;
    var textFieldFont: UIFont!;
    let mainFontColor = UIColor.black;
    let infoLabelYPos = 20;
    let buttonSpace = 2;
    var yMenuPos: Int!;
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
    let infoMessages: [String] = ["Hold up your phone, and tap/drag wherever you want to post it (from camera or map).",//0
                                  "You can't a post focal until your location is found.",//1
                                  "Tap 'Done' when you have chosen a position",//2
                                  "Your password must be longer.",//3
                                  "Your username must be longer.",//4
                                  "You cannot post a focal within a building. You can check this by adding a focal via the map.",//5
                                  "Successfully posted new focal!",//6
                                  "Successfully Posted!",//7
                                  "Successfully Deleted!",//8
                                  "Locating your device, please wait...",//9
                                  "Please calibrate your phone by twisting it around.",//10
                                  "Disconnected. Trying to connect...",//11
                                  "Successfully connected!",//12
                                  "For the proper experience, go outside.",//13
                                  "Locating Focals, please wait...",//14
                                  "Unknown Error. Please try again later.",//15
                                  "Successfully logged in!",//16
                                  "Successfully logged out!",//17
                                  "Successfully updated profile.",//18
                                  "Successfully signed up. You can login now!",//19
                                  "That username already exists.",//20
                                  "That email already exists.",//21
                                  "You will need to allow location services.",//22
                                  "Incorrect username or password.", //23
                                  "The focal must be on the ground.", //24
                                  "That position is too close to another focal. Either comment on the existing one, or post further away.",//25
                                  "Editing comment...",//26
                                  "Successfully edited comment!",//27
                                  "Successfully deleted comment!",//28
                                  "Invalid email address.",//29
                                  "Your internet connection is too weak.",//30
                                  "UNKNOWN"];//31
    
    let colorLanguageMap: [String:[String]] = ["red":["disconnected", "error", "must be", "can't", "already exists", "cannot", "incorrect", "too", "invalid"], "green":["success"]];
    
    
   
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
            if(self.locationFocused == true){
                hideAnyViews();
                if(mapShowing==true){
                    actionDelegate?.toggleMap!(true);
                }
                updateInfoLabel(0, show: true, hideAfter: 0);
                renderNewFocalOptions(onForm: false);
                cancelChoosingButton.isHidden = false;
                doneChoosingTapPosButton.isHidden = false;
                toggleMenu(false);
                menuButtons[0].isHidden = false;
                self.tapToPost = true;
            }else{
                updateInfoLabel(1, show: true, hideAfter: 3);
            }
            
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
            if(doneChoosingTapPosButton.isHidden == true){
                toggleMenu(false);
            }
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
    
    @objc func wrapPanned(_ sender: UIPanGestureRecognizer){
        let tapPoint = sender.location(in: view);
        if(mapShowing == false){
            if(self.tapToPost == true ){
                actionDelegate?.renderTempFocalFromUI!(Int(tapPoint.x), tapY: Int(tapPoint.y));
            }
        }
    }
    
    @objc func wrapTapped(_ sender: UITapGestureRecognizer){
        let tapPoint = sender.location(in: view);
        if(mapShowing == false){
            if(self.tapToPost == false ){
                actionDelegate?.chooseFocalComments!(Int(tapPoint.x), tapY: Int(tapPoint.y));
            }else{
                actionDelegate?.renderTempFocalFromUI!(Int(tapPoint.x), tapY: Int(tapPoint.y));
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
        var error = -1;
        let pLength = signUpFields.password?.text?.characters.count;
        let uLength = signUpFields.username?.text?.characters.count;
        let minLength = 4;
        if(( pLength! < minLength && Int(loggedinUserData.id) == 0 )||(Int(loggedinUserData.id) > 0 && pLength! > 0 && pLength! < minLength )){
            error = 3;
        }
        if(uLength! < minLength){
            error = 4;
        }
        
        if(misc.emailValid(email: (signUpFields.email?.text)!) == false){
            error = 29;
        }
        
        if(error == -1){
            actionDelegate?.updateUserDataRequest!((signUpFields.username?.text)!, password: (signUpFields.password?.text)!, fullname: (signUpFields.fullname?.text)!, email: (signUpFields.email?.text)!);
            
                signUpFields.password?.text = "";
            
        }else{
            self.updateInfoLabel(error, show: true, hideAfter: 3);
        }
    }
    
    func signUpToProfileUpdateTransformForm(_ asProfile: Bool){
        if(asProfile == true){
            signUpFields.username?.text = loggedinUserData.username;
            signUpFields.email?.text = loggedinUserData.email;
            signUpFields.fullname?.text = loggedinUserData.fullname;
            signUpFields.password?.placeholder = "Password";
            signUpSubmitButton.setTitle("Update", for: UIControlState());
        }else{
            signUpFields.username?.placeholder = "Username";
            signUpFields.email?.placeholder = "Email";
            signUpFields.fullname?.placeholder = "Fullname";
            signUpSubmitButton.setTitle("Sign Up", for: UIControlState());
        }
    }

    var hasChosenPosNewFocal = false;
    func showTapFinishedOptions(){
        hasChosenPosNewFocal = true;
        removeInfoLabel(messageIDs: [0]);
        updateInfoLabel(2, show: true, hideAfter: 0);
    }
    
    @objc func cancelTap(){
        doneChoosingTapPosButton.isHidden = true;
        removeInfoLabel(messageIDs: [0,2]);
        hasChosenPosNewFocal = false;
        self.tapToPost = false;
        menuButtons[0].isHidden = true;
        cancelChoosingButton.isHidden = true;
        commentForm.isHidden = true;
        actionDelegate?.cancelNewFocal!();
        self.view.endEditing(true);
    }
    
    @objc func newFocalComment(){
        if(hasChosenPosNewFocal == true){
            hasChosenPosNewFocal = false;
            self.tapToPost = false;
            menuButtons[0].isHidden = true;
            removeInfoLabel(messageIDs: [0,2]);
            doneChoosingTapPosButton.isHidden = true;
            renderNewFocalOptions(onForm: true);
            cancelChoosingButton.isHidden = false;
            self.commentForm.isHidden = false;
        }
    }
    
    func renderNewFocalOptions(onForm: Bool){
        
        var frameCancel: CGRect!;
        var fdX = Int(screenSize.width*0.5)-choosingFocalPosOptionsWidth-newFocalOptionSpaceFromMid;
        var fcX = (onForm == true ? 115 :  Int(screenSize.width*0.5)+newFocalOptionSpaceFromMid);
        if(loggedinUserData.id != 0){
            fdX += 33;
            if(onForm == false){
                fcX += 33;
            }
        }
        var frameDone = CGRect(x: fdX,y:yMenuPos, width: choosingFocalPosOptionsWidth,height: buttonHeight);
        if(onForm == true){
            frameCancel = CGRect(x: fcX, y: 5+textFieldSize.height+10, width: 120, height: 40);
        }else{
            frameCancel = CGRect(x:fcX,y: yMenuPos, width: choosingFocalPosOptionsWidth,height: buttonHeight);
        }
        
        if(cancelChoosingButton != nil){
            cancelChoosingButton.removeFromSuperview();
            
        }
        var light = (mapShowing == true) ? false : true;
        
        cancelChoosingButton = addButtonProperties("Cancel", hidden: false, pos: frameCancel,cornerRadius: buttonCornerRadius, blurLight: light);
        cancelChoosingButton.addTarget(self, action: #selector(cancelTap), for: .touchUpInside);
        cancelChoosingButton.isHidden = true;
        
        if(onForm == false){
            doneChoosingTapPosButton = addButtonProperties("Done", hidden: true, pos: frameDone ,cornerRadius: buttonCornerRadius, blurLight: light);
            doneChoosingTapPosButton.addTarget(self, action: #selector(newFocalComment), for: .touchUpInside);
            self.view.addSubview(doneChoosingTapPosButton);
            cancelChoosingButton.isHidden = true;
        }
        
        if(onForm == true){
            commentForm.addSubview(cancelChoosingButton);
        }else{
            self.view.addSubview(cancelChoosingButton);
        }
    }
    
    @objc func newCommentFocal(){
        let text = commentExistingFocalTextfield.text!;
        if(text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != ""){
            self.view.endEditing(true);
            if(editingComment == 0){
                actionDelegate?.postNewComment!(text);
                commentExistingFocalTextfield.text = "";
            }else{
                actionDelegate?.editComment!(text, cID: editingComment);
                cancelEditingComment();
            }
        }
    }
    
    @objc func postFocal(){
        cancelTap();
        actionDelegate?.addFocalReady!(commentTextfield.text!);
        self.view.endEditing(true);
    }
    
    @objc func deleteFocalWrap(){
        actionDelegate?.deleteFocalRequest!(ownFocalViewingInfoRealID);
    }
    
    func addUserFocalLabel(_ text: String, areaName: String, localID: Int){
        
        let focalTextLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userFocalLabelYPos+10, width: 250, height: userFocalLabelHeight));
        let focalAreaLabel: UILabel  = UILabel(frame: CGRect(x: 25, y: userFocalLabelYPos+userFocalLabelHeight+10, width: 250, height: userFocalLabelHeight));
        
        let focalIcon = UIImage(named: focalIconDest);
        let focalIconView = UIImageView(image: focalIcon!);
        focalIconView.tag = localID;
        focalIconView.frame = CGRect(x: 0, y:  userFocalLabelYPos+12, width: 20, height: 30);
        
        focalTextLabel.text = text;
        focalTextLabel.tag = localID;
        focalAreaLabel.text = "in " + areaName;
        
        let uiLabelTap = UITapGestureRecognizer(target: self, action: #selector(showSingleFocalInfo));
        focalTextLabel.addGestureRecognizer(uiLabelTap);
        
        focalTextLabel.isUserInteractionEnabled = true;

        focalTextLabel.font = UIFont(name: mainTypeFace, size: 17);
        focalAreaLabel.font = UIFont(name: mainTypeFaceBold, size: 13);
        
        userScrollFocalListView.addSubview(focalTextLabel);
        userScrollFocalListView.addSubview(focalAreaLabel);
        userScrollFocalListView.addSubview(focalIconView);
        
    }
    
    @objc func showSingleFocalInfo(_ sender: UITapGestureRecognizer){
        let focalInfoLocalID = sender.view?.tag;
        ownFocalViewingInfoRealID = userFocalsJSON[focalInfoLocalID!]["f_id"].int!;
        let relTitleText = userFocalFirstCommentsJSON[focalInfoLocalID!]["c_text"].rawString()!;
        singleFocalFcommentTitle.text = relTitleText;
        singleFocalInfoView.isHidden = false;
    }
    
    @objc func getOwnFocalComments(){
        singleFocalInfoView.isHidden = true;
        viewingFocalID = ownFocalViewingInfoRealID;
        actionDelegate?.getFocalComments!(ownFocalViewingInfoRealID, updateVisited: false);
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
        if(focals.count == 0){
            noFocalsLabel.isHidden = false;
        }else{
            var count = 0;
            noFocalsLabel.isHidden = true;
            for focal in focals{
                let areaName = focals[count]["f_area_name"].rawString()!;
                self.addUserFocalLabel(firstComments[count]["c_text"].rawString()!, areaName: areaName, localID: count);
                self.userFocalLabelYPos += 2*self.userFocalLabelHeight + 10;
                count += 1;
            }
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
    func addFocalCommentLabel(_ text: String, infoString: String, cID: String, downVotes: String, upVotes: String, canVote: Bool, authorName: String, isFirst: Bool){
        let cID = Int(cID);
        let labelWidth = viewPageWidth-20;
        let commentFont = UIFont(name: mainTypeFaceBold, size: 14);
        let labelTextHeight =  1 + Int(getHeightForField(text, font: commentFont!, width: CGFloat(labelWidth)));
        lastCommentHeight = labelTextHeight;
        
        commentTextLabels[cID!] = UILabel(frame: CGRect(x: 5, y: focalCommentListLabelYPos+10, width: labelWidth, height: labelTextHeight));
        
        commentTextLabels[cID!]?.text = text;
        commentTextLabels[cID!]?.numberOfLines = 0;
        commentTextLabels[cID!]?.lineBreakMode = .byWordWrapping;
        commentTextLabels[cID!]?.font = commentFont!;

        let commentInfoLabel: UILabel  = UILabel(frame: CGRect(x: 5, y: focalCommentListLabelYPos+labelTextHeight, width: labelWidth, height: commentInfoHeight));
    
        commentInfoLabel.text = infoString;
        commentInfoLabel.font = UIFont(name: mainTypeFace, size: 10);
        
        
        let commentOptionY = focalCommentListLabelYPos+Int(labelTextHeight) + 30;
        
        if(authorName == loggedinUserData.username && loggedinUserData.id > 0){
            let editIconX = 60;
            let editIconSize = 13;
            
            let editIcon = UIImage(named: "edit_comment_icon.png");
            editIcons[cID!] = UIImageView(image: editIcon!);
            editIcons[cID!]?.tag = cID!;
            editIcons[cID!]?.frame = CGRect(x: editIconX, y: commentOptionY, width: editIconSize, height: editIconSize);
            let editTap = UITapGestureRecognizer(target: self, action: #selector(editComment));
            editIcons[cID!]?.isUserInteractionEnabled = true;
            editIcons[cID!]?.addGestureRecognizer(editTap);
            focalCommentsListScrollView.addSubview(editIcons[cID!]!);
            if(isFirst == false){
                let deleteIconX = editIconX + editIconSize + 15;
                
                let deleteIcon = UIImage(named: "del_comment_icon.png");
                deleteIcons[cID!] = UIImageView(image: deleteIcon!);
                deleteIcons[cID!]?.tag = cID!;
                deleteIcons[cID!]?.frame = CGRect(x: deleteIconX , y: commentOptionY, width: editIconSize, height: editIconSize);
                let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteComment));
                deleteIcons[cID!]?.isUserInteractionEnabled = true;
                deleteIcons[cID!]?.addGestureRecognizer(deleteTap);
                focalCommentsListScrollView.addSubview(deleteIcons[cID!]!);
            }
        }

        
        let voteIconNamePrefix = canVote ? "v" : "vd";
        let vUpIconDest = voteIconNamePrefix + "_up_icon.png";
        let vDownIconDest = voteIconNamePrefix + "_down_icon.png";

        let voteIconX = 160;
        let voteIconHeight = 13;
        let voteIconWidth = 18;
        let voteCountFontSize: CGFloat = 9.0;
       
        let vUpIcon = UIImage(named: vUpIconDest);
        upVoteCommentIcons[cID!] = UIImageView(image: vUpIcon!);
        upVoteCommentIcons[cID!]?.tag = cID!;
        upVoteCommentIcons[cID!]?.frame = CGRect(x: voteIconX+10, y: commentOptionY, width: voteIconWidth, height: voteIconHeight);
        let vUpTap = UITapGestureRecognizer(target: self, action: #selector(voteCommentUp));
        upVoteCommentIcons[cID!]?.isUserInteractionEnabled = canVote;
        upVoteCommentIcons[cID!]?.addGestureRecognizer(vUpTap);
        
        upVoteCommentLabels[cID!] = UILabel(frame: CGRect(x: voteIconX-30, y: commentOptionY, width: 40, height: 10));
        upVoteCommentLabels[cID!]?.text = upVotes;
        upVoteCommentLabels[cID!]?.font = UIFont(name: mainTypeFace, size: voteCountFontSize);
        upVoteCommentLabels[cID!]?.textAlignment = .right;
        upVoteCommentLabels[cID!]?.textColor = UIColor(red: 0.3373, green:0.6784, blue:0.3569, alpha: 1.0);
        
       
        let vDownIcon = UIImage(named: vDownIconDest);
        downVoteCommentIcons[cID!] = UIImageView(image: vDownIcon!);
        downVoteCommentIcons[cID!]?.tag = cID!;
        downVoteCommentIcons[cID!]?.frame = CGRect(x: voteIconX+30, y: commentOptionY, width: voteIconWidth, height: voteIconHeight);
        let vDownTap = UITapGestureRecognizer(target: self, action: #selector(voteCommentDown));
        downVoteCommentIcons[cID!]?.isUserInteractionEnabled = canVote;
        downVoteCommentIcons[cID!]?.addGestureRecognizer(vDownTap);
        
        downVoteCommentLabels[cID!] = UILabel(frame: CGRect(x: voteIconX+50, y: commentOptionY, width: 40, height: 10));
        downVoteCommentLabels[cID!]?.text = downVotes;
        downVoteCommentLabels[cID!]?.font = UIFont(name: mainTypeFace, size: voteCountFontSize);
        downVoteCommentLabels[cID!]?.textAlignment = .left;
        downVoteCommentLabels[cID!]?.textColor = UIColor(red: 0.7882, green: 0.3373, blue: 0.2353, alpha: 1.0);
        
        let cSeparator = UIView(frame: CGRect(x:0,y:commentOptionY+15, width: viewPageWidth-10, height: 1));
        
        cSeparator.layer.borderColor = UIColor.gray.cgColor;
        cSeparator.layer.borderWidth = 1;
        
        focalCommentsListScrollView.addSubview(upVoteCommentLabels[cID!]!);
        focalCommentsListScrollView.addSubview(downVoteCommentLabels[cID!]!);
        focalCommentsListScrollView.addSubview(upVoteCommentIcons[cID!]!);
        focalCommentsListScrollView.addSubview(downVoteCommentIcons[cID!]!);
        focalCommentsListScrollView.addSubview(commentTextLabels[cID!]!);
        focalCommentsListScrollView.addSubview(commentInfoLabel);
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
    
    @objc func deleteComment(_ sender: UITapGestureRecognizer){
        let cID = sender.view?.tag;
        actionDelegate?.deleteComment!(cID!);
        if(editingComment>0){
            cancelEditingComment();
        }
    }
    
    var editingComment = 0;
    @objc func editComment(_ sender: UITapGestureRecognizer){
        let cID = sender.view?.tag;
        editingComment = cID!;
        updateInfoLabel(26, show: true, hideAfter: 4);
        commentExistingFocalTextfield.text = commentTextLabels[cID!]?.text;
        newCommentButton.setTitle("Edit", for: UIControlState());
        cancelEditingButton.isHidden = false;
    }
    
    @objc func cancelEditingComment(){
        editingComment = 0;
        removeInfoLabel(messageIDs: [26]);
        cancelEditingButton.isHidden = true;
        commentExistingFocalTextfield.text = "";
        newCommentButton.setTitle("Post", for: UIControlState());
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
            var isFirst = ( count==focalComments.count-1 ? true : false);
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
            let currentYear = Calendar.current.component(.year, from: Date());
            let commentYear = Calendar.current.component(.year, from: timestampDate as Date);
            let yearString = ( currentYear != commentYear ? "/yyyy": "" );
            dateFormatter.dateFormat = "HH:mm, dd/MM"+yearString;
            let colloquialTime = dateFormatter.string(from: timestampDate as Date);
            let authorName = focalComments[count]["c_u_uname"].rawString()!;
            let infoString = "By " + authorName + ", at " + colloquialTime;
            addFocalCommentLabel(commentText, infoString: infoString, cID: focalComments[count]["c_id"].rawString()!, downVotes:focalComments[count]["c_v_down"].rawString()!,upVotes:focalComments[count]["c_v_up"].rawString()!, canVote: canVote, authorName: authorName, isFirst: isFirst);
            nextYPosCalc = lastCommentHeight + commentInfoHeight;
            focalCommentListLabelYPos += nextYPosCalc;
            count += 1;
        }
        focalCommentsListScrollView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(5+focalCommentListLabelYPos+nextYPosCalc));
    }

    
    //MARK: render UI components
    func renderPostCommentForm(){
        let formHeight = 100;
        commentForm = UIView(frame: CGRect(x:Int(screenSize.width/2)-formWidth/2,y: defaultFormY + buttonHeight + buttonSpace,width: formWidth-10, height: formHeight));
        commentForm.isHidden = true;
        commentForm.insertSubview(processBlurEffect(commentForm.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        
        commentTextfield = addTextFieldProperties(CGRect(x: 5, y: 5, width: 230, height: textFieldSize.height));
        commentTextfield.placeholder = "Enter Comment...";
        
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
        usernameLoginField.placeholder = "Username";
        
        passwordLoginField = addTextFieldProperties(CGRect(x: 5, y: 55, width: textWidthLogin, height: textFieldSize.height));
        passwordLoginField.placeholder = "Password";
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
        signUpFields.username?.placeholder = "Username";
        
        signUpFields.password = addTextFieldProperties(CGRect(x: 5, y: 55, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.password?.placeholder = "Password";
        signUpFields.password?.isSecureTextEntry = true;
        
        signUpFields.fullname = addTextFieldProperties(CGRect(x: 5, y: 105, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.fullname?.placeholder = "Fullname";
        
        signUpFields.email = addTextFieldProperties(CGRect(x: 5, y: 155, width: textWidthSignUp, height: textFieldSize.height));
        signUpFields.email?.placeholder = "Email";
        
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
        
        let deleteButtonWidth = 130;
        let deleteFocalButtonRect = CGRect(x: viewPageWidth/2-(deleteButtonWidth)-2, y: viewHeight-(buttonHeight+5), width: deleteButtonWidth, height: buttonHeight);
        
        deleteFocalButton = addButtonProperties("Delete", hidden: false, pos: deleteFocalButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        deleteFocalButton.addTarget(self, action: #selector(deleteFocalWrap), for: .touchUpInside);
        
        let viewOwnFocalCommentsRect = CGRect(x: (viewPageWidth/2)+2, y: viewHeight-(buttonHeight+5), width: deleteButtonWidth, height: buttonHeight);
        
        viewOwnFocalCommentsButton = addButtonProperties("View Comments", hidden: false, pos: viewOwnFocalCommentsRect, cornerRadius: buttonCornerRadius, blurLight: true);
        viewOwnFocalCommentsButton.addTarget(self, action: #selector(getOwnFocalComments), for: .touchUpInside);

    
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
        singleFocalInfoView.addSubview(viewOwnFocalCommentsButton);
        
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
        
        let cancelEditingWidth = 130;
        let cancelEditingRect = CGRect(x: viewPageWidth-(closeButtonWidth+5)-cancelEditingWidth-5, y: 5, width: cancelEditingWidth, height: closeButtonHeight);
        cancelEditingButton = addButtonProperties("Cancel Editing...", hidden: false, pos:cancelEditingRect, cornerRadius: buttonCornerRadius, blurLight: true);
        cancelEditingButton.addTarget(self, action: #selector(cancelEditingComment), for: .touchUpInside);
        cancelEditingButton.isHidden = true;
        
        focalVisitCountLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 250, height: 25));
        focalVisitCountLabel.font = UIFont(name: mainTypeFaceBold, size: 14);
        
        let commentExistingFocalTFWidth = viewPageWidth-55;
        commentExistingFocalTextfield = addTextFieldProperties(CGRect(x: 5, y: closeButtonHeight+10, width: commentExistingFocalTFWidth, height: textFieldSize.height));
        commentExistingFocalTextfield.placeholder = "Enter Comment...";
        
        let newCommentButtonRect = CGRect(x: 10+commentExistingFocalTFWidth, y: closeButtonHeight+10, width: 40, height: 40);
        newCommentButton = addButtonProperties("Post", hidden: false, pos: newCommentButtonRect, cornerRadius: buttonCornerRadius, blurLight: true);
        newCommentButton.addTarget(self, action: #selector(newCommentFocal), for: .touchUpInside);
        
        focalCommentsView.addSubview(newCommentButton);
        focalCommentsView.addSubview(focalVisitCountLabel);
        focalCommentsView.addSubview(commentExistingFocalTextfield);
        focalCommentsView.addSubview(closeFocalCommentsView);
        focalCommentsView.addSubview(focalCommentsListScrollView);
        focalCommentsView.addSubview(cancelEditingButton);
        self.view.addSubview(focalCommentsView);
        
    }

    func renderUserFocalsView(){
        let viewHeight = 370;
        userFocalListView = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        userFocalListView.isHidden = true;
        userScrollFocalListView = UIScrollView(frame: CGRect(x:5,y: 25,width: viewPageWidth, height: viewHeight-30));
        userScrollFocalListView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(viewHeight));
        userFocalListView.insertSubview(processBlurEffect(userFocalListView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);

        noFocalsLabel = UILabel(frame: CGRect(x: 0, y: 130, width: viewPageWidth, height: buttonHeight));
        noFocalsLabel.text = "You have no focals.";
        noFocalsLabel.isHidden = true;
        noFocalsLabel.textAlignment = .center;
        noFocalsLabel.font = UIFont(name: mainTypeFace, size: 19);
        noFocalsLabel.textColor = UIColor.gray;
        
        let closeUserFocalViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeUserFocalView = addButtonProperties("Close", hidden: false, pos: closeUserFocalViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeUserFocalView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);

        userFocalListView.addSubview(closeUserFocalView);
        userFocalListView.addSubview(userScrollFocalListView);
        userFocalListView.addSubview(noFocalsLabel);
        self.view.addSubview(userFocalListView);
    }
    
    func renderHelpView(){
        let viewHeight = 370;
        helpView = UIView(frame: CGRect(x:viewPageX,y: defaultFormY + buttonSpace,width: viewPageWidth, height: viewHeight));
        helpView.insertSubview(processBlurEffect(helpView.bounds, cornerRadiusVal: buttonCornerRadius, light: true), at: 0);
        helpScrollView = UIScrollView(frame: CGRect(x:5,y: 25,width: viewPageWidth, height: viewHeight-40));
        helpScrollView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(viewHeight));
        helpView.isHidden = true;
        
        let closeHelpViewRect = CGRect(x: viewPageWidth-(closeButtonWidth+5), y: 5, width: closeButtonWidth, height: closeButtonHeight);
        closeHelpView = addButtonProperties("Close", hidden: false, pos:closeHelpViewRect, cornerRadius: buttonCornerRadius, blurLight: true);
        closeHelpView.addTarget(self, action: #selector(hideAnyViews), for: .touchUpInside);
        
        
        helpView.addSubview(closeHelpView);
        helpView.addSubview(helpScrollView);
        self.view.addSubview(helpView);
    
    }
    
    func renderHelpText(text: String){
        let labelTextHeight = getHeightForField(text, font: mainFont, width: CGFloat(200));
        helpTextLabel = UILabel(frame: CGRect(x: 5, y: -80, width: viewPageWidth-25, height: Int(labelTextHeight)));
        helpTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping;
        helpTextLabel.textAlignment = .center;
        helpTextLabel.text = text;
        helpScrollView.contentSize = CGSize(width: CGFloat(viewPageWidth), height: CGFloat(labelTextHeight+20));
        helpTextLabel.numberOfLines = Int(labelTextHeight/20)+1;
        helpTextLabel.font = mainFont;
        helpScrollView.addSubview(helpTextLabel);
        
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
    
    func addFocalPanRecognizer(){
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(wrapPanned));
        self.view.addGestureRecognizer(panRec);
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
        
        let yPos = yMenuPos;
        let toggleWidth = 50;
        let halfTW = toggleWidth/2;
        let toggleMenuRect  = CGRect(x: Int(screenSize.width*0.5)-halfTW,y: yPos!+toggleWidth-7, width: toggleWidth,height: toggleWidth);
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
                useYPos = useYPos! + vertYPos;
            }else{
                
            }
            let buttonRect = CGRect(x: useXPos,y: useYPos!, width: buttonWidthUse,height: buttonHeight);
            
            
            menuButtons.append(addButtonProperties(buttonTitle, hidden: hidden, pos: buttonRect, cornerRadius: buttonCornerRadius, blurLight: blurLight));
            menuButtons[bCount].addTarget(self, action: #selector(buttonAction), for: .touchUpInside);
            self.view.addSubview(menuButtons[bCount]);
            bCount += 1;
            bxPos += buttonWidth + buttonSpace;
        }

    }
    
    func renderMsgLabel(){
        let infoMsgViewRect = CGRect(x:0,y: 0,width: Int(screenSize.width),height: buttonHeight);
        infoMsgView = UIView(frame: infoMsgViewRect);
        let closeTap = UITapGestureRecognizer(target:self,action: #selector(wrapCloseInfoMsg));
        infoMsgView.addGestureRecognizer(closeTap);
        infoMsgView.isHidden = true;
        self.view.addSubview(infoMsgView);
    }
    
    @objc func wrapCloseInfoMsg(){
        infoMsgView.isHidden = true;
    }
    
    //MARK: Update label contents
    /*func updateInfoLabel(_ newText: String, show: Bool, hideAfter: Int){

        if((infoMsgLabel.text?.characters.count)! > 0){
            infoMsgLabel.text = infoMsgLabel.text! + "; " + newText;
        }else{
            infoMsgLabel.text = newText;
        }
        if(show == false){
            infoMsgView.isHidden = true;
        }else{
            infoMsgView.isHidden = false;
        }
        if(hideAfter != 0){
            let timeToHide = DispatchTime.now() + .seconds(hideAfter)
            DispatchQueue.main.asyncAfter(deadline: timeToHide, execute: {
                self.infoMsgView.isHidden = true;
            })
        }
    }*/

    func updateInfoLabel(_ messageID: Int, show: Bool, hideAfter: Int){
        if(infoMsgLabels[messageID] == nil){
            infoMsgView.isHidden = false;
            var totalHeight = buttonHeight*(infoMsgLabels.count);
            infoMsgLabels[messageID] = UILabel(frame: CGRect(x: 0, y: 20+totalHeight, width: Int(screenSize.width), height: buttonHeight));
            infoMsgLabels[messageID]?.lineBreakMode = NSLineBreakMode.byWordWrapping;
            infoMsgLabels[messageID]?.textAlignment = .center;
            infoMsgLabels[messageID]?.text = infoMessages[messageID];
            infoMsgLabels[messageID]?.font = mainFont;
            infoMsgLabels[messageID]?.numberOfLines = 2;
            
            let actualColors: [String:UIColor] = ["red": UIColor(red: 0.9294, green: 0.3843, blue: 0.2863, alpha: 1.0), "green": UIColor(red: 0.4745, green:0.847, blue:0.5568, alpha: 1.0),"none": UIColor(red: 0.7098, green: 0.9059, blue: 1, alpha: 1.0)];
            
            
            var colorFound = false;
            for color in colorLanguageMap{
                for val in colorLanguageMap[color.key]!{
                    if((infoMessages[messageID].lowercased().range(of:val)) != nil){
                        infoMsgLabels[messageID]?.backgroundColor = actualColors[color.key];
                        colorFound = true;
                        break;
                    }
                }
            }
            if(colorFound == false){
                infoMsgLabels[messageID]?.backgroundColor = actualColors["none"];
            }
 
            infoMsgView.addSubview(infoMsgLabels[messageID]!);
            let labelToRemoveByMsgID = messageID;
            totalHeight = buttonHeight*(infoMsgLabels.count);
            
            changeInfoMsgHeight(totalHeight: totalHeight);
            
            if(hideAfter != 0){
                let timeToHide = DispatchTime.now() + .seconds(hideAfter);
                DispatchQueue.main.asyncAfter(deadline: timeToHide, execute: {
                    self.removeInfoLabel(messageIDs: [labelToRemoveByMsgID]);
                });
            }
        }
    }
    
    func changeInfoMsgHeight(totalHeight: Int){
        infoMsgView.backgroundColor = infoMsgLabels.first?.value.backgroundColor;
        infoMsgView.frame = CGRect(x: 0,y:0,width: Int(screenSize.width),height: totalHeight);
    }

    func removeInfoLabel(messageIDs: [Int]){
        for m in messageIDs{
            if(infoMsgLabels[m] != nil){
                infoMsgLabels[m]?.removeFromSuperview();
                infoMsgLabels.removeValue(forKey: m);
                var totalHeight = buttonHeight*(infoMsgLabels.count);
                changeInfoMsgHeight(totalHeight: totalHeight);
                if(infoMsgLabels.count == 0){
                    infoMsgView.isHidden = true;
                }
                var yCount = 20;
                for l in infoMsgLabels{
                    infoMsgLabels[l.key]?.frame = CGRect(x: 0, y: yCount, width: Int(screenSize.width), height: buttonHeight);
                    yCount = yCount + buttonHeight;
                }
            }
        }
    }

    
    //MARK: Render all items
    func renderAll(_ view: UIView){
        self.view = view;
        mainFont = UIFont(name: mainTypeFace, size: 12);
        textFieldFont = UIFont(name: mainTypeFace, size: 15);
        viewPageWidth = Int(screenSize.width)-10;
        viewPageX = Int(screenSize.width/2)-viewPageWidth/2;
        yMenuPos = Int(screenSize.height) - buttonHeight - 60;
        
        renderMenu(false);
        addFocalPanRecognizer();
        addFocalTapRecognizer();
        renderLoginForm();
        renderSignUpForm();
        renderPostCommentForm();
        renderProfileView();
        renderHelpView();
        renderUserFocalsView();
        renderSingleFocalInfoView();
        renderFocalCommentsView();
        renderMsgLabel();
        renderNewFocalOptions(onForm: false);
    }
    
}

