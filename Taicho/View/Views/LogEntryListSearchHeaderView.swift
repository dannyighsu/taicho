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

}

class LogEntryListSearchHeaderView: UITableViewHeaderFooterView {

    static var reuseIdentifier: String {
        return String(describing: self)
    }
    static var height: CGFloat {
        // Just budgeting a static height for search bar for now
        return 56 + (3 * UIConstants.interItemSpacing) + UIUtils.height(for: "S", font: dateTextFont)
    }
    private static let dateTextFont = UIFont.systemFont(ofSize: 16, weight: .regular)

    weak var delegate: LogEntryListSearchHeaderViewDelegate? {
        didSet {
            searchBar.delegate = delegate
        }
    }

    private let searchBar = UISearchBar()
    private let dateTextField = UITextField()
    private let datePicker = UIUtils.getDefaultTimePicker()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search Logs"

        contentView.addSubview(dateTextField)
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        dateTextField.text = "No Date Selected"
        dateTextField.inputView = datePicker
        dateTextField.font = LogEntryListSearchHeaderView.dateTextFont
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateWasSelected(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.sideMargin),
            searchBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.interItemSpacing),
            searchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.sideMargin),
            dateTextField.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: UIConstants.interItemSpacing),
            dateTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.sideMargin),
            dateTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: UIConstants.interItemSpacing)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func dateWasSelected(_ sender: UIDatePicker) {
        dateTextField.text = DateUtils.getDisplayFormat(sender.date)
        delegate?.dateWasSelected(sender.date, searchText: searchBar.text)
    }

}
