//
//  NSMutableAttributedString+Taicho.swift
//  Taicho
//
//  Created by Daniel Hsu on 11/12/22.
//

import Foundation
import UIKit

extension NSMutableAttributedString {

    func with(_ value:String, font: UIFont) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : font
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }

}
