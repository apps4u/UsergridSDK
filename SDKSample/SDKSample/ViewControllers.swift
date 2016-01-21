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
import WatchConnectivity

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
        UsergridManager.loginUser(username,password: password) { (auth, user, error) -> Void in
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
        UsergridManager.createUser(name, username: username, email: email, password: password) { (response) -> Void in
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

class MessageViewController : SLKTextViewController, WCSessionDelegate {

    static let MESSAGE_CELL_IDENTIFIER = "MessengerCell"

    var messageEntities: [ActivityEntity] = []

    init() {
        super.init(tableViewStyle:.Plain)
        commonInit()
    }
    
    required init!(coder decoder: NSCoder!) {
        super.init(coder: decoder)
        commonInit()
    }

    override static func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    override func viewWillAppear(animated: Bool) {
        self.reloadMessages()
        if let username = Usergrid.currentUser?.name {
            self.navigationItem.title = "\(username)'s Feed"
        }
        super.viewWillAppear(animated)
    }

    func commonInit() {
        self.bounces = true
        self.shakeToClearEnabled = true
        self.keyboardPanningEnabled = true
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.inverted = true

        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }

        self.registerClassForTextView(MessageTextView)
    }

    func reloadMessages() {
        UsergridManager.getFeedMessages { (response) -> Void in
            self.messageEntities = response.entities as? [ActivityEntity] ?? []
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

        UsergridManager.postFeedMessage(self.textView.text) { (response) -> Void in
            if let messageEntity = response.entity as? ActivityEntity {
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                let rowAnimation: UITableViewRowAnimation = self.inverted ? .Bottom : .Top
                let scrollPosition: UITableViewScrollPosition = self.inverted ? .Bottom : .Top

                self.tableView.beginUpdates()
                self.messageEntities.insert(messageEntity, atIndex: 0)
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimation)
                self.tableView.endUpdates()

                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: scrollPosition, animated: true)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)

                self.sendEntitiesToWatch(self.messageEntities)
            }
        }
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

    @IBAction func unwindToChat(segue: UIStoryboardSegue) {

    }

    func populateCell(cell:MessageTableViewCell,feedEntity:ActivityEntity) {

        cell.titleLabel.text = feedEntity.displayName
        cell.bodyLabel.text = feedEntity.content
        cell.thumbnailView.image = nil

        if let imageURLString = feedEntity.imageURL, imageURL = NSURL(string: imageURLString) {
            NSURLSession.sharedSession().dataTaskWithURL(imageURL) { (data, response, error) in
                if let imageData = data, image = UIImage(data: imageData) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.thumbnailView.image = image
                    })
                }
            }.resume()
        }
    }

    func messageCellForRowAtIndexPath(indexPath:NSIndexPath) -> MessageTableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MessageViewController.MESSAGE_CELL_IDENTIFIER) as! MessageTableViewCell
        self.populateCell(cell, feedEntity: self.messageEntities[indexPath.row])

        cell.indexPath = indexPath
        cell.transform = self.tableView.transform

        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let feedEntity = messageEntities[indexPath.row]

        let messageText : NSString = feedEntity.content ?? ""
        if messageText.length == 0 {
            return 0
        }

        let messageUsername : NSString = feedEntity.displayName ?? ""

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

    func sendEntitiesToWatch(messages:[UsergridEntity]) {
        if WCSession.defaultSession().reachable {
            NSKeyedArchiver.setClassName("ActivityEntity", forClass: ActivityEntity.self)
            let data = NSKeyedArchiver.archivedDataWithRootObject(messages)
            WCSession.defaultSession().sendMessageData(data, replyHandler: nil, errorHandler: { (error) -> Void in
                self.showAlert(title: "WCSession Unreachable.", message: "\(error)")
            })
        }
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let action = message["action"] as? String where action == "getMessages" {
            UsergridManager.getFeedMessages { (response) -> Void in
                if let entities = response.entities {
                    self.sendEntitiesToWatch(entities)
                }
            }
        }
    }
}

class FollowViewController : UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var addFollowerButton: UIButton!

    @IBAction func addFollowerButtonTouched(sender:AnyObject?) {
        if let username = usernameTextField.text where !username.isEmpty {
            UsergridManager.followUser(username, completion: { (response) -> Void in
                if response.ok {
                    self.performSegueWithIdentifier("unwindToChatSegue", sender: self)
                } else {
                    self.showAlert(title: "Follow failed.", message: "No user with the username \"\(username)\" found.")
                }
            })
        } else {
            self.showAlert(title: "Follow failed.", message: "Please enter a valid username.")
        }
    }
}

