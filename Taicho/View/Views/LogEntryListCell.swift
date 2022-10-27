//
//  LogEntryListCell.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/22/22.
//

import Foundation
import UIKit

class LogEntryListCell: UITableViewCell {

    static var reuseIdentifier: String {
        return String(describing: LogEntryListCell.self)
    }

    private static let nameFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    private static let textFont = UIFont.systemFont(ofSize: 16, weight: .light)

    private let nameLabel = UILabel()
    private let timeLabel = UILabel()
    private let productivityLabel = UILabel()

    private var labelWidthConstraintPairs: [(UILabel, NSLayoutConstraint)] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        [nameLabel, timeLabel, productivityLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            labelWidthConstraintPairs.append(($0, $0.widthAnchor.constraint(equalToConstant: $0.requiredWidth)))
        }

        nameLabel.font = LogEntryListCell.nameFont
        timeLabel.font = LogEntryListCell.textFont
        productivityLabel.font = LogEntryListCell.textFont

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.sideMargin),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.interSectionSpacing),
            productivityLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.sideMargin),
            productivityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: UIConstants.interItemSpacing),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -UIConstants.sideMargin),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.interSectionSpacing)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func requiredHeight(for logEntry: LogEntry) -> CGFloat {
        return UIUtils.height(for: logEntry.name, font: nameFont)
        + UIUtils.height(for: logEntry.productivityLevel.displayName, font: textFont)
        + UIConstants.interSectionSpacing * 2 + UIConstants.interItemSpacing
    }

    private static func backgroundColor(for productivityLevel: ProductivityLevel) -> UIColor {
        switch productivityLevel {
        case .high:
            return .blue.withAlphaComponent(0.4)
        case .medium:
            return .cyan.withAlphaComponent(0.4)
        case .low:
            return .blue.withAlphaComponent(0.2)
        case .none:
            return .lightGray.withAlphaComponent(0.4)
        }
    }

    func load(_ viewModel: LogEntryListCellViewModel) {
        nameLabel.text = viewModel.logEntry.name
        timeLabel.text = DateUtils.getDisplayFormat(viewModel.logEntry.time)
        productivityLabel.text = viewModel.logEntry.productivityLevel.displayName

        labelWidthConstraintPairs.forEach { (label, constraint) in
            constraint.constant = label.requiredWidth
        }

        backgroundColor = LogEntryListCell.backgroundColor(for: viewModel.logEntry.productivityLevel)
    }

}
