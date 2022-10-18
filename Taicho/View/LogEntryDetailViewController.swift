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
    private let nameLabel = UILabel()
    private let nameField = UITextField()
    private let timeLabel = UILabel()
    private let timeField = UITextField()
    private let productivityLabel = UILabel()
    private let productivityField = UITextField()
    private let notesLabel = UILabel()
    private let notesTextView = UITextView()
    
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
    
        view.backgroundColor = .white
        
        [nameLabel, nameField, timeLabel, timeField, productivityLabel, productivityField, notesLabel, notesTextView]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
                view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            }
        
        [nameField, timeField, productivityField].forEach { $0.textAlignment = .center }
        
        nameField.delegate = self
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIConstants.verticalMargin),
            nameField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * UIConstants.sideMargin),
            nameField.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: UIConstants.interItemSpacing)
        ])
        
        timeField.delegate = self
        NSLayoutConstraint.activate([
            timeLabel.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            timeLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: UIConstants.interSectionSpacing),
            timeField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * UIConstants.sideMargin),
            timeField.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            timeField.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: UIConstants.interItemSpacing)
        ])
        
        productivityField.delegate = self
        NSLayoutConstraint.activate([
            productivityLabel.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            productivityLabel.topAnchor.constraint(equalTo: timeField.bottomAnchor, constant: UIConstants.interSectionSpacing),
            productivityField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * UIConstants.sideMargin),
            productivityField.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            productivityField.topAnchor.constraint(equalTo: productivityLabel.bottomAnchor, constant: UIConstants.interItemSpacing)
        ])
        
        notesTextView.delegate = self
        NSLayoutConstraint.activate([
            notesLabel.heightAnchor.constraint(equalToConstant: UIConstants.textFieldHeight),
            notesLabel.topAnchor.constraint(equalTo: productivityField.bottomAnchor, constant: UIConstants.interSectionSpacing),
            notesTextView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * UIConstants.sideMargin),
            notesTextView.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: UIConstants.interItemSpacing),
            notesTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        configureLabels()
        updateFieldsFromLogEntry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
    }
    
    // MARK: - Methods
    
    /**
     Updates the displayed fields with data from the log entry.
     */
    func updateFieldsFromLogEntry() {
        nameField.text = logEntry.name
        timeField.text = DateUtils.getDisplayFormat(logEntry.time)
        productivityField.text = logEntry.productivityLevel.displayName
        notesTextView.text = logEntry.notes
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    private func configureLabels() {
        nameLabel.text = "Name"
        timeLabel.text = "Started At"
        productivityLabel.text = "Productivity Level"
        notesLabel.text = "Notes"
    }
    
    private func configureNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(close))
        if let navigationController = navigationController {
            UIUtils.addDividerToBottomOfView(navigationController.navigationBar)
        }
    }
    
}

extension LogEntryDetailViewController: UITextFieldDelegate {
    
    
    
}

extension LogEntryDetailViewController: UITextViewDelegate {
    
    
    
}
