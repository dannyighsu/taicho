//
//  LogEntryPresetDetailViewController.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/24/22.
//

import Foundation
import UIKit
import EmojiPicker

/**
 Displays the full details of a single log entry preset. Allows for editing and saving the preset.
 */
class LogEntryPresetDetailViewController: UIViewController {

    // MARK: - Properties

    private let logEntryPreset: LogEntryPreset?
    private lazy var selectedIcon = logEntryPreset?.icon ?? UIConstants.notesEmoji
    private var allPropertyViews: [LogEntryDetailPropertyView] {
        return [namePropertyView, productivityPropertyView, iconPropertyView]
    }
    private lazy var namePropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Name",
        textPrefill: logEntryPreset?.name)
    private lazy var productivityPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Productivity Level",
        textPrefill: logEntryPreset?.productivityLevel.displayName)
    private lazy var iconPropertyView = LogEntryDetailPropertyView(
        delegate: self,
        labelTitle: "Icon",
        image: UIUtils.emojiImage(fromText: selectedIcon))
    private let productivityPicker = ProductivityPickerView()

    // These are defaulted to 1000 just to ignore the annoying constraint break warning. In reality they're dynamically sized.
    private lazy var nameHeightConstraint = namePropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var productivityHeightConstraint = productivityPropertyView.heightAnchor.constraint(equalToConstant: 1000)
    private lazy var iconHeightConstraint = iconPropertyView.heightAnchor.constraint(equalToConstant: 1000)

    // MARK: - Initialization

    init(logEntryPreset: LogEntryPreset? = nil) {
        self.logEntryPreset = logEntryPreset
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
            productivityHeightConstraint,
            iconHeightConstraint,
            namePropertyView.topAnchor.constraint(
                equalTo: view.topAnchor, constant: UIConstants.verticalMargin),
            productivityPropertyView.topAnchor.constraint(
                equalTo: namePropertyView.bottomAnchor, constant: UIConstants.interSectionSpacing),
            iconPropertyView.topAnchor.constraint(
                equalTo: productivityPropertyView.bottomAnchor, constant: UIConstants.interSectionSpacing)
        ])

        productivityPicker.productivityPickerDelegate = self
        productivityPropertyView.propertyTextView.inputView = productivityPicker
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Update height constraints based on new view widths.
        [(nameHeightConstraint, namePropertyView),
         (productivityHeightConstraint, productivityPropertyView),
         (iconHeightConstraint, iconPropertyView)].forEach { (constraint, view) in
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

        guard let productivityString = productivityPropertyView.propertyTextView.text,
              let productivityLevel = ProductivityLevel.value(from: productivityString) else {
                  present(UIUtils.getErrorAlert("Error! Must specify a productivity level."), animated: true)
            return
        }

        if let logEntryPreset = logEntryPreset {
            logEntryPreset.name = name
            logEntryPreset.productivityLevel = productivityLevel
            logEntryPreset.icon = selectedIcon
        } else {
            let _ = TaichoContainer.container.logEntryPresetDataManager.create(
                name: name,
                productivity: productivityLevel,
                icon: selectedIcon)
        }

        TaichoContainer.container.persistenceController.saveContext()
        cancel()
    }

    private func configureNavigationItem() {
        navigationController.assertIfNil()?.navigationBar.backgroundColor = .white
        navigationItem.title = "Create New Preset"
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

extension LogEntryPresetDetailViewController: LogEntryDetailPropertyViewDelegate {

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

    func imageTapped() {
        showEmojiPicker()
    }

    private func showEmojiPicker() {
        let emojiPickerVC = EmojiPicker.viewController
        emojiPickerVC.sourceRect = view.frame
        emojiPickerVC.delegate = self
        present(emojiPickerVC, animated: true)
        
    }

}

extension LogEntryPresetDetailViewController: ProductivityPickerViewDelegate {

    func pickerView(_ pickerView: ProductivityPickerView, didSelectProductivity productivity: ProductivityLevel) {
        productivityPropertyView.propertyTextView.text = productivity.displayName
    }

}

extension LogEntryPresetDetailViewController: EmojiPickerViewControllerDelegate {

    func emojiPickerViewController(_ controller: EmojiPickerViewController, didSelect emoji: String) {
        selectedIcon = emoji
        iconPropertyView.iconImage = UIUtils.emojiImage(fromText: emoji)
    }

}
