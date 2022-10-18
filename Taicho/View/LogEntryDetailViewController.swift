//
//  LogEntryDetailViewController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/16/22.
//

import Foundation
import UIKit

/**
 Displays the full details of a single log entry. Allows for editing and saving the log entry.
 */
class LogEntryDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let logEntry: LogEntry
    
    private lazy var namePropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Name",
        textPrefill: logEntry.name,
        useTextView: true)
    private lazy var timePropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Time",
        textPrefill: DateUtils.getDisplayFormat(logEntry.time),
        useTextView: true)
    private lazy var productivityPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Productivity Level",
        textPrefill: logEntry.productivityLevel.displayName,
        useTextView: true)
    private lazy var notesPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Notes",
        textPrefill: logEntry.notes,
        useTextView: true)
    
    // These are defaulted to 1000 just to ignore the annoying constraint break warning. In reality they're dynamically sized.
    private lazy var nameHeightConstraint = namePropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var timeHeightConstraint = timePropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var productivityHeightConstraint = productivityPropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var notesHeightConstraint = notesPropertyView.heightAnchor.constraint(equalToConstant: 1000)
    
    // MARK: - Mutable data values
    private lazy var logTime: Date = logEntry.time
    private lazy var logTimeZone: TimeZone = logEntry.timezone
    private lazy var logProductivityLevel: ProductivityLevel = logEntry.productivityLevel
    
    // MARK: - Initialization
    
    init(logEntry: LogEntry) {
        self.logEntry = logEntry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .systemBackground
        
        [namePropertyView, timePropertyView, productivityPropertyView, notesPropertyView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIConstants.sideMargin),
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIConstants.sideMargin)
            ])
        }
        
        NSLayoutConstraint.activate([
            nameHeightConstraint,
            timeHeightConstraint,
            productivityHeightConstraint,
            notesHeightConstraint,
            namePropertyView.topAnchor.constraint(
                equalTo: view.topAnchor, constant: UIConstants.verticalMargin),
            timePropertyView.topAnchor.constraint(
                equalTo: namePropertyView.bottomAnchor, constant: UIConstants.interSectionSpacing),
            productivityPropertyView.topAnchor.constraint(
                equalTo: timePropertyView.bottomAnchor, constant: UIConstants.interSectionSpacing),
            notesPropertyView.topAnchor.constraint(
                equalTo: productivityPropertyView.bottomAnchor, constant: UIConstants.interSectionSpacing)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Update height constraints based on new view widths.
        [(nameHeightConstraint, namePropertyView),
         (timeHeightConstraint, timePropertyView),
         (productivityHeightConstraint, productivityPropertyView),
         (notesHeightConstraint, notesPropertyView)].forEach { (constraint, view) in
            constraint.constant = view.heightRequired
        }
    }
    
    // MARK: - Methods
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        if !validateFields() {
            present(UIUtils.getErrorAlert("Error! Field value invalid."), animated: true)
            return
        }
        guard let name = namePropertyView.getTextValue() else {
            present(UIUtils.getErrorAlert("Error! Log must have a name."), animated: true)
            return
        }
        
        let notes = notesPropertyView.getTextValue()
        
        let newLogEntry = logEntry.copy(
            name: name,
            time: logTime,
            timezone: logTimeZone,
            productivityLevel: logProductivityLevel,
            notes: notes)
        
        newLogEntry.persistCoreData()
        TaichoContainer.container.persistenceController.saveContext()
        cancel()
    }
    
    private func validateFields() -> Bool {
        // TODO
        return true
    }
    
    private func configureNavigationItem() {
        navigationItem.title = "Edit Log"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(save))
        if let navigationController = navigationController {
            UIUtils.addDividerToBottomOfView(navigationController.navigationBar)
        }
    }
    
}

extension LogEntryDetailViewController: LogEntryDetailPropertyViewDelegate {
    
    
    
}
