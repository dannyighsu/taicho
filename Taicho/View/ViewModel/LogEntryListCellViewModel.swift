//
//  LogEntryListCellViewModel.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/18/22.
//

import Foundation
import Combine

class LogEntryListCellViewModel: NSObject {
    
    let logEntry: LogEntry
    /**
     Publishes updates to the `LogEntry`.
     */
    var publisher: AnyPublisher<LogEntry, Never> {
        return logEntrySubject.eraseToAnyPublisher()
    }
    
    private let logEntrySubject = PassthroughSubject<LogEntry, Never>()
    
    init(_ logEntry: LogEntry) {
        self.logEntry = logEntry
        super.init()
    }

    func reload() {
        logEntrySubject.send(logEntry)
    }
    
}
