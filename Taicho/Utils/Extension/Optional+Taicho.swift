//
//  Optional+Taicho.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/19/22.
//

import Foundation

extension Optional {

    func assertIfNil() -> Self {
        if self == nil {
            Log.assert("Unexpected empty optional: \(String(describing: self))")
        }
        return self
    }

}
