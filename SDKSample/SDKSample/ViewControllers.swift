//
//  ViewController.swift
//  SDKSample
//
//  Created by Robert Walsh on 11/19/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import UIKit
import UsergridSDK
import SlackTextViewController

extension UIViewController {

    func showAlert(title title: String, message: String?, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: handler))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

@IBDesignable class FormTextField: UITextField {

    @IBInspectable var inset: CGFloat = 0
    @IBOutlet weak var nextResponderField: UIResponder?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    func setUp() {
        addTarget(self, action: "actionKeyboardButtonTapped:", forControlEvents: .EditingDidEndOnExit)
    }

    func actionKeyboardButtonTapped(sender: UITextField) {
        switch nextResponderField {
        case let button as UIButton:
            if button.enabled {
                button.sendActionsForControlEvents(.TouchUpInside)
            } else {
                resignFirstResponder()
            }
        case .Some(let responder):
            responder.becomeFirstResponder()
        default:
            resignFirstResponder()
        }
    }

    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, 0)
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.usernameTextField.text = nil
        self.passwordTextField.text = nil

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action:nil)
    }

    override func viewDidAppear(animated: Bool) {
        Usergrid.logoutCurrentUser()
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
    }

    @IBAction func loginButtonTouched(sender: AnyObject) {
        if let username = usernameTextField.text, password = passwordTextField.text
            where !username.isEmpty && !password.isEmpty
        {
            self.loginUser(username, password: password)
        }
        else
        {
            self.showAlert(title: "Error Authenticating User", message: "Username and password must not be empty.")
        }
    }

    func loginUser(username:String, password:String) {

        let userAuth = UsergridUserAuth(username: username, password: password)

        Usergrid.authenticateUser(userAuth) { (auth, user, error) -> Void in
            if let authErrorDescription = error {
                self.showAlert(title: "Error Authenticating User", message: authErrorDescription)
            } else if let authenticatedUser = user {
                self.showAlert(title: "Authenticated User Successful", message: "User description: \n \(authenticatedUser.stringValue)") { (action) -> Void in
                    self.performSegueWithIdentifier("loginSuccessSegue", sender: self)
                }
            }
        }
    }

    @IBAction func unwind(segue: UIStoryboardSegue) {

    }
}

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.usernameTextField.text = nil
        self.passwordTextField.text = nil
    }

    @IBAction func registerButtonTouched(sender: AnyObject) {
        if let name = nameTextField.text, username = usernameTextField.text, email = emailTextField.text, password = passwordTextField.text
            where !name.isEmpty && !username.isEmpty && !email.isEmpty && !password.isEmpty
        {
                self.createUser(name, username: username, email: email, password: password)
        }
        else
        {
            self.showAlert(title: "Error Registering User", message: "Name, username, email, and password fields must not be empty.")
        }
    }

    func createUser(name:String, username:String, email:String, password:String) {
        let user = UsergridUser(name: name, propertyDict: [UsergridUserProperties.Username.stringValue:username,
                                                           UsergridUserProperties.Email.stringValue:email,
                                                           UsergridUserProperties.Password.stringValue:password])
        user.create() { (response) -> Void in
            if let createdUser = response.user {
                self.showAlert(title: "Registering User Successful", message: "User description: \n \(createdUser.stringValue)") { (action) -> Void in
                    self.performSegueWithIdentifier("unwindSegue", sender: self)
                }
            } else {
                self.showAlert(title: "Error Registering User", message: response.error?.errorDescription)
            }
        }
    }
}

class MessageViewController : SLKTextViewController {

    static let MESSAGE_ENTITY_TYPE = "sdkmessage"
    static let MESSAGE_ENTITY_CREATOR = "creator"
    static let MESSAGE_ENTITY_TEXT = "text"
    static let MESSAGE_ENTITY_CREATOR_THUMBNAIL = "creatorThumb"
    static let MESSAGE_CELL_IDENTIFIER = "MessengerCell"

    var messageEntities: [UsergridEntity] = []

    init() {
        super.init(tableViewStyle: UITableViewStyle.Plain)
        commonInit()
    }
    
    required init!(coder decoder: NSCoder!) {
        super.init(coder: decoder)
        commonInit()
    }

    override static func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    func commonInit() {
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.inverted = true

        self.registerClassForTextView(MessageTextView)
        self.reloadMessages()
    }

    func reloadMessages() {
        let sortByCreatedDateQuery = UsergridQuery().desc("created")
        Usergrid.GET(MessageViewController.MESSAGE_ENTITY_TYPE, query:sortByCreatedDateQuery) { (response) -> Void in
            self.messageEntities = response.entities ?? []
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.rightButton.setTitle("Send", forState: .Normal)

        self.textInputbar.autoHideRightButton = true
        self.textInputbar.maxCharCount = 256
        self.textInputbar.editorTitle.textColor = UIColor.darkGrayColor()

        self.tableView.separatorStyle = .None
        self.tableView.registerClass(MessageTableViewCell.self, forCellReuseIdentifier:MessageViewController.MESSAGE_CELL_IDENTIFIER)
    }

    override func didPressRightButton(sender: AnyObject!) {
        self.textView.refreshFirstResponder()

        let messageEntity = UsergridEntity(type: MessageViewController.MESSAGE_ENTITY_TYPE, propertyDict: [MessageViewController.MESSAGE_ENTITY_CREATOR:Usergrid.currentUser!.username!,MessageViewController.MESSAGE_ENTITY_TEXT:self.textView.text,
            MessageViewController.MESSAGE_ENTITY_CREATOR_THUMBNAIL:Usergrid.currentUser!["picture"]!])
        messageEntity.save { (response) -> Void in
            if let errorDescription = response.error?.errorDescription {
                print("Uploading message error: \(errorDescription)")
            }
        }

        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
        let scrollPosition: UITableViewScrollPosition = self.inverted ? .Bottom : .Top

        self.tableView.beginUpdates()
        self.messageEntities.insert(messageEntity, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
        self.tableView.endUpdates()

        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

        super.didPressRightButton(sender)
    }

    override func keyForTextCaching() -> String! {
        return NSBundle.mainBundle().bundleIdentifier
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageEntities.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.messageCellForRowAtIndexPath(indexPath)
    }

    func messageCellForRowAtIndexPath(indexPath:NSIndexPath) -> MessageTableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MessageViewController.MESSAGE_CELL_IDENTIFIER) as! MessageTableViewCell

        let messageEntity = self.messageEntities[indexPath.row]
        cell.thumbnailView.image = nil
        if let profileImage = messageEntity[MessageViewController.MESSAGE_ENTITY_CREATOR_THUMBNAIL] as? String {
            if let imageURL = NSURL(string: profileImage) {
                NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cell.thumbnailView.image = image
                            })
                        }
                    } else {
                        cell.thumbnailView.image = nil
                    }
                }.resume()
            }
        }
        cell.titleLabel.text = messageEntity[MessageViewController.MESSAGE_ENTITY_CREATOR] as? String
        cell.bodyLabel.text = messageEntity[MessageViewController.MESSAGE_ENTITY_TEXT] as? String
        cell.indexPath = indexPath
        cell.transform = self.tableView.transform

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let messageEntity = messageEntities[indexPath.row]

        let messageText : NSString = messageEntity[MessageViewController.MESSAGE_ENTITY_TEXT] as? NSString ?? ""
        if messageText.length == 0 {
            return 0
        }

        let messageUsername : NSString = messageEntity[MessageViewController.MESSAGE_ENTITY_CREATOR] as? NSString ?? ""

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        paragraphStyle.alignment = .Left

        let pointSize = MessageTableViewCell.defaultFontSize
        let attributes = [NSFontAttributeName:UIFont.boldSystemFontOfSize(pointSize),NSParagraphStyleAttributeName:paragraphStyle]

        let width: CGFloat = CGRectGetWidth(self.tableView.frame) - MessageTableViewCell.kMessageTableViewCellAvatarHeight - 25

        let titleBounds = messageUsername.boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        let bodyBounds = messageText.boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)

        var height = CGRectGetHeight(titleBounds) + CGRectGetHeight(bodyBounds) + 40
        if height < MessageTableViewCell.kMessageTableViewCellMinimumHeight {
            height = MessageTableViewCell.kMessageTableViewCellMinimumHeight
        }

        return height
    }

}

