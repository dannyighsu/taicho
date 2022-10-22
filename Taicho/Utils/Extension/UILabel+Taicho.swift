//
//  UILabel+Taicho.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/22/22.
//

import Foundation
import UIKit

extension UILabel {

    /**
     The width required to correctly display this label.
     */
    var requiredWidth: CGFloat {
        sizeThatFits(CGSize.greatestFiniteSize).width
    }

    /**
     The height required to correctly display this label.
     */
    var requiredHeight: CGFloat {
        sizeThatFits(CGSize.greatestFiniteSize).height
    }

}
