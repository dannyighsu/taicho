//
//  UITextField+Taicho.swift
//  Taicho
//
//  Created by Daniel Hsu on 11/12/22.
//

import Foundation
import UIKit

extension UITextField {

    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.isTranslucent = true

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneTapped))

        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()

        inputAccessoryView = doneToolbar
    }

    @objc
    func onDoneTapped() {
        resignFirstResponder()
    }

}
