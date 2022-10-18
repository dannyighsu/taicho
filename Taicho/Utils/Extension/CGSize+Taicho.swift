//
//  CGSize+Taicho.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/17/22.
//

import Foundation
import UIKit

extension CGSize {
    
    static var greatestFiniteSize: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
    
}
