//
//  NewMessageViewController.swift
//  ios-messaging-app
//
//  Created by Fracisco Igor on 2018-12-06.
//  Copyright © 2018 User. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var messageField: UITextView!
    @IBOutlet weak var sendButton: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func sendClick(_ sender: Any) {
        let values: NSDictionary = [
            "message" :  messageField.text,
            "to" :  emailField.text as Any,
            "from" : AppData.currentUser.email,
            "visible" : 1,
            "timestamp" : NSDate().timeIntervalSince1970
        ]
        AppData.createMessage(data: values)
        AppData.loadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



extension NewMessageViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var suggestions = [Contact]()
        let contacts = DataSource.getEntities(entity: "Contact")
        for contact in contacts{
            if let c = contact as? Contact{
                suggestions.append(c)
            }
        }
        return !autoCompleteText( in : textField, using: string, suggestions: suggestions)
    }
    
    func autoCompleteText( in textField: UITextField, using string: String, suggestions: [Contact]) -> Bool {
        if !string.isEmpty,
            let selectedTextRange = textField.selectedTextRange,
            selectedTextRange.end == textField.endOfDocument,
            let prefixRange = textField.textRange(from: textField.beginningOfDocument, to: selectedTextRange.start),
            let text = textField.text( in : prefixRange) {
                let prefix = text + string
                let matches = suggestions.filter {
                    $0.name!.lowercased().hasPrefix(prefix.lowercased())
                }
                if (matches.count > 0) {
                    textField.text = matches[0].name
                    emailField.text = matches[0].email
                    if let start = textField.position(from: textField.beginningOfDocument, offset: prefix.lengthOfBytes(using: .utf8)) {
                        textField.selectedTextRange = textField.textRange(from: start, to: textField.endOfDocument)
                        return true
                    }
                }
            }
        return false
    }
    
    
    
}

