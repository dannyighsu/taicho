//
//  Log.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation

/**
 Implementation of an information logger class.
 */
public class Log {
    
    public static func error(_ message: String) {
        NSLog("ERROR: " + message)
    }
    
    public static func assert(_ message: String) {
#if DEBUG
        fatalError(message)
#else
        NSLog("ASSERT: " + message)
#endif
    }
    
    public static func verbose(_ message: String) {
#if DEBUG
        NSLog("VERBOSE: " + message)
#endif
    }
    
}
