//
//  LogEntryListSearchHeaderView.swift
//  Taicho
//
//  Created by Daniel Hsu on 11/8/22.
//

import Foundation
import UIKit

protocol LogEntryListSearchHeaderViewDelegate: UISearchBarDelegate {

    func dateWasSelected(_ date: Date, searchText: String?)
    func searchHeaderClearButtonTapped()

}

class LogEntryListSearchHeaderView: UITableViewHeaderFooterView {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var height: CGFloat {
        // Just budgeting a static height for search bar for now
        return 56 + (2 * UIConstants.interItemSpacing) + UIConstants.interSectionSpacing + UIUtils.height(for: "S", font: dateTextFont)
    }
    private static let dateTextFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    private static let clearButtonText = "Clear"
    private static let labelText = "Date Filter: "

    weak var delegate: LogEntryListSearchHeaderViewDelegate? {
        didSet {
            searchBar.delegate = delegate
        }
    }

    private let searchBar = UISearchBar()
    private let dateTextField = UITextField()
    private let clearButton = UIButton()
    private let datePicker = UIUtils.getDefaultTimePicker()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Logs"
        searchBar.searchBarStyle = .minimal

        contentView.addSubview(dateTextField)
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.inputView = datePicker
        dateTextField.addDoneButtonOnKeyboard()
        // This hides the caret in the text field
        dateTextField.tintColor = .clear
        resetDateTextFieldText()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateWasSelected(_:)), for: .valueChanged)

        contentView.addSubview(clearButton)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("Clear", for: .normal)
        clearButton.configuration = .borderless()
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        clearButton.isHidden = true

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.sideMargin),
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.interItemSpacing),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.sideMargin),
            dateTextField.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: UIConstants.interItemSpacing),
            dateTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.sideMargin),
            dateTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.interSectionSpacing),
            dateTextField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -UIConstants.interItemSpacing),
            clearButton.widthAnchor.constraint(equalToConstant: UIUtils.width(
                for: LogEntryListSearchHeaderView.clearButtonText,
                font: LogEntryListSearchHeaderView.dateTextFont) + 26),
            clearButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: UIConstants.interItemSpacing),
            clearButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.interSectionSpacing),
            clearButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.sideMargin)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func dateWasSelected(_ sender: UIDatePicker) {
        dateTextField.attributedText = LogEntryListSearchHeaderView.getTextFieldAttributedText(DateUtils.getDisplayFormat(sender.date))
        delegate?.dateWasSelected(sender.date, searchText: searchBar.text)
        clearButton.isHidden = false
    }

    @objc
    private func clearButtonTapped() {
        resetDateTextFieldText()
        delegate?.searchHeaderClearButtonTapped()
        clearButton.isHidden = true
    }

    private func resetDateTextFieldText() {
        dateTextField.attributedText = LogEntryListSearchHeaderView.getTextFieldAttributedText("No Date Selected")
    }

    private static func getTextFieldAttributedText(_ text: String) -> NSAttributedString {
        return NSMutableAttributedString()
            .with(labelText, font: .systemFont(ofSize: 16, weight: .bold))
            .with(text, font: .systemFont(ofSize: 16, weight: .medium))
    }

}
