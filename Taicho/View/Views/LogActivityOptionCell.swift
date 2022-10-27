//
//  LogActivityOptionCell.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/23/22.
//

import Foundation
import UIKit

/**
 A cell displaying the option to log a new activity.
 */
class LogActivityOptionCell: UICollectionViewCell {

    static var sizeRequired: CGSize {
        let height = iconViewDimension
        + UIUtils.height(for: "S", font: nameFont)
        + UIConstants.interItemSpacing
        + (2 * UIConstants.interSectionSpacing)
        let width = iconViewDimension + (2 * UIConstants.interSectionSpacing)
        return CGSize(width: width, height: height)
    }
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    private static let iconViewDimension: CGFloat = 88
    private static let nameFont = UIFont.systemFont(ofSize: 16, weight: .medium)

    private let activityNameLabel = UILabel()
    private let activityIconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .green

        [activityNameLabel, activityIconView].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        activityIconView.contentMode = .center
        activityIconView.clipsToBounds = true

        activityNameLabel.font = LogActivityOptionCell.nameFont
        activityNameLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            activityIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIconView.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.interSectionSpacing),
            activityIconView.widthAnchor.constraint(equalToConstant: LogActivityOptionCell.iconViewDimension),
            activityIconView.heightAnchor.constraint(equalToConstant: LogActivityOptionCell.iconViewDimension),
            activityNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityNameLabel.topAnchor.constraint(equalTo: activityIconView.bottomAnchor, constant: UIConstants.interItemSpacing),
            activityNameLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -2 * UIConstants.interSectionSpacing)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load(_ viewModel: LogActivityOptionViewModel) {
        activityNameLabel.text = viewModel.name
        activityIconView.image = UIUtils.image(fromText: viewModel.icon, size: CGSize(
            width: LogActivityOptionCell.iconViewDimension,
            height: LogActivityOptionCell.iconViewDimension))
    }

}
