//
//  LogActivityOptionViewModel.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/23/22.
//

import Foundation

class LogActivityOptionViewModel {

    let icon: String
    let name: String
    let logEntryPreset: LogEntryPreset?

    init(icon: String, name: String, logEntryPreset: LogEntryPreset? = nil) {
        self.icon = icon
        self.name = name
        self.logEntryPreset = logEntryPreset
    }

}
