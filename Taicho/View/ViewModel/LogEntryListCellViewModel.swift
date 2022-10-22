//
//  LogEntryListCellViewModel.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/18/22.
//

import Foundation
import Combine

protocol LogEntryListCellViewModelDelegate: AnyObject {
    
    func logEntryDidUpdate(_ logEntry: LogEntry)
    
}

class LogEntryListCellViewModel: NSObject {
    
    var logEntry: LogEntry {
        didSet {
            logEntrySubject.send(logEntry)
        }
    }
    weak var delegate: LogEntryListCellViewModelDelegate?
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
    
}
