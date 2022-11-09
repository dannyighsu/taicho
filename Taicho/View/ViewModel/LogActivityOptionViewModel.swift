//
//  LogActivityOptionViewModel.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/23/22.
//

import Foundation

class LogActivityOptionViewModel {

    var icon: String
    var name: String
    let logEntryPreset: LogEntryPreset?

    init(icon: String, name: String, logEntryPreset: LogEntryPreset? = nil) {
        self.icon = icon
        self.name = name
        self.logEntryPreset = logEntryPreset
    }

    func reload() {
        guard let logEntryPreset = logEntryPreset else {
            return
        }
        self.icon = logEntryPreset.icon
        self.name = logEntryPreset.name
    }

}