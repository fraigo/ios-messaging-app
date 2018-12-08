//
//  AutoCompleteText.swift
//  ios-messaging-app
//
//  Created by User on 2018-12-08.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import UIKit

class AutoCompleteTextField : UITextField {
    
    var emailTextField : UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



extension AutoCompleteTextField : UITextFieldDelegate {
    
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
                if let field = emailTextField {
                    field.text = matches[0].email
                }
                if let start = textField.position(from: textField.beginningOfDocument, offset: prefix.lengthOfBytes(using: .utf8)) {
                    textField.selectedTextRange = textField.textRange(from: start, to: textField.endOfDocument)
                    return true
                }
            }
        }
        return false
    }
    
    
    
}

