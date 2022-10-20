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
    
    let logEntry: LogEntry
    weak var delegate: LogEntryListCellViewModelDelegate?
    /**
     Publishes updates to the `LogEntry`.
     */
    var publisher: AnyPublisher<LogEntry, Never> {
        return logEntrySubject.eraseToAnyPublisher()
    }
    
    private let logEntrySubject = PassthroughSubject<LogEntry, Never>()
    private lazy var namePublisher = logEntry.publisher(for: \.name).sink() { [weak self] _ in
        guard let self = self else { return }
        self.logEntrySubject.send(self.logEntry)
        self.delegate?.logEntryDidUpdate(self.logEntry)
    }
    
    init(_ logEntry: LogEntry) {
        self.logEntry = logEntry
        super.init()
    }
    
}
