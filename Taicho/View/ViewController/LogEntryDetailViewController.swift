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

    // MARK: - Context

    enum Context {
        case edit
        case new
    }
    
    // MARK: - Properties
    
    private let logEntry: LogEntry?
    private let context: LogEntryDetailViewController.Context
    
    private lazy var namePropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Name",
        textPrefill: logEntry?.name)
    private lazy var timePropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Time",
        textPrefill: DateUtils.getDisplayFormat(logEntry?.time ?? DateUtils.getNowRoundedToNearest15()))
    private lazy var productivityPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Productivity Level",
        textPrefill: logEntry?.productivityLevel.displayName)
    private lazy var notesPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Notes",
        textPrefill: logEntry?.notes)
    private var allPropertyViews: [LogEntryDetailPropertyView] {
        return [namePropertyView, timePropertyView, productivityPropertyView, notesPropertyView]
    }

    private let productivityPicker = ProductivityPickerView()
    private let timePicker = UIUtils.getDefaultTimePicker()
    
    // These are defaulted to 1000 just to ignore the annoying constraint break warning. In reality they're dynamically sized.
    private lazy var nameHeightConstraint = namePropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var timeHeightConstraint = timePropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var productivityHeightConstraint = productivityPropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var notesHeightConstraint = notesPropertyView.heightAnchor.constraint(equalToConstant: 1000)
    
    // MARK: - Initialization
    
    init(logEntry: LogEntry? = nil, logEntryPreset: LogEntryPreset? = nil, context: Context = .new) {
        self.logEntry = logEntry
        self.context = context
        super.init(nibName: nil, bundle: nil)

        if let logEntryPreset = logEntryPreset {
            loadPreset(logEntryPreset)
        }
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

        productivityPicker.productivityPickerDelegate = self
        productivityPropertyView.propertyTextView.inputView = productivityPicker

        timePicker.addTarget(self, action: #selector(timeWasSelected(_:)), for: .valueChanged)
        timePropertyView.propertyTextView.inputView = timePicker
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

        guard let name = namePropertyView.propertyTextView.text, name.count > 0 else {
            present(UIUtils.getErrorAlert("Error! Log must have a name."), animated: true)
            return
        }
        guard let timeString = timePropertyView.propertyTextView.text,
              let dateTime = DateUtils.getDate(from: timeString) else {
                  present(UIUtils.getErrorAlert("Error! Time is invalid."), animated: true)
                  return
              }
        guard let productivityString = productivityPropertyView.propertyTextView.text,
        let productivityLevel = ProductivityLevel.value(from: productivityString) else {
            present(UIUtils.getErrorAlert("Error! Productivity level is invalid."), animated: true)
            return
        }
        let notes = notesPropertyView.propertyTextView.text

        if let logEntry = logEntry {
            logEntry.name = name
            logEntry.productivityLevel = productivityLevel
            logEntry.time = dateTime
            logEntry.notes = notes
        } else {
            let _ = TaichoContainer.container.logEntryDataManager.create(
                name,
                productivityLevel: productivityLevel,
                date: dateTime,
                notes: notes)
        }

        TaichoContainer.container.persistenceController.saveContext()
        cancel()
    }

    private func loadPreset(_ preset: LogEntryPreset) {
        namePropertyView.propertyTextView.text = preset.name
        productivityPropertyView.propertyTextView.text = preset.productivityLevel.displayName
    }
    
    private func configureNavigationItem() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationItem.title = context == .edit ? "Edit Log" : "New Log"
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

    @objc
    func timeWasSelected(_ sender: UIDatePicker) {
        timePropertyView.propertyTextView.text = DateUtils.getDisplayFormat(sender.date)
    }
    
}

extension LogEntryDetailViewController: LogEntryDetailPropertyViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView == productivityPropertyView.propertyTextView else {
            return
        }

        let selectedProductivity = ProductivityLevel.value(from: productivityPropertyView.propertyTextView.text) ?? .high

        guard let indexOfSelectedProductivity = ProductivityLevel.allCases.firstIndex(of: selectedProductivity) else {
            Log.assert("Failed to get index of productivity level.")
            return
        }

        productivityPicker.selectRow(
            indexOfSelectedProductivity,
            inComponent: 0,
            animated: false)
        productivityPicker.pickerView(productivityPicker, didSelectRow: indexOfSelectedProductivity, inComponent: 0)
    }
    
}

extension LogEntryDetailViewController: ProductivityPickerViewDelegate {

    func pickerView(_ pickerView: ProductivityPickerView, didSelectProductivity productivity: ProductivityLevel) {
        productivityPropertyView.propertyTextView.text = productivity.displayName
    }

}
