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
        textPrefill: logEntry.name)
    private lazy var timePropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Time",
        textPrefill: DateUtils.getDisplayFormat(logEntry.time))
    private lazy var productivityPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Productivity Level",
        textPrefill: logEntry.productivityLevel.displayName)
    private lazy var notesPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Notes",
        textPrefill: logEntry.notes)
    private var allPropertyViews: [LogEntryDetailPropertyView] {
        return [namePropertyView, timePropertyView, productivityPropertyView, notesPropertyView]
    }
    
    // These are defaulted to 1000 just to ignore the annoying constraint break warning. In reality they're dynamically sized.
    private lazy var nameHeightConstraint = namePropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var timeHeightConstraint = timePropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var productivityHeightConstraint = productivityPropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var notesHeightConstraint = notesPropertyView.heightAnchor.constraint(equalToConstant: 1000)
    
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
        
        allPropertyViews.forEach {
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
        allPropertyViews.forEach { $0.resignFirstResponder() }
        
        if !validateFields() {
            present(UIUtils.getErrorAlert("Error! Field value invalid."), animated: true)
            return
        }
        
        logEntry.persistCoreData()
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case namePropertyView.propertyTextView:
            guard let name = namePropertyView.propertyTextView.text else {
                present(UIUtils.getErrorAlert("Error! Log must have a name."), animated: true)
                return
            }
            logEntry.name = name
        case timePropertyView.propertyTextView:
            guard let timeString = timePropertyView.propertyTextView.text,
                  let dateTime = DateUtils.getDate(from: timeString) else {
                      Log.assert("Error setting new time")
                      return
                  }
            
            logEntry.time = dateTime
        case productivityPropertyView.propertyTextView:
            guard let productivityString = productivityPropertyView.propertyTextView.text else {
                Log.assert("Failed to get productivity string")
                return
            }
            logEntry.productivityLevel = ProductivityLevel.value(from: productivityString)
        case notesPropertyView.propertyTextView:
            logEntry.notes = notesPropertyView.propertyTextView.text
        default:
            Log.assert("Unknown textview found.")
            return
        }
    }
    
}
