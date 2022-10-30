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
        let height = UIConstants.iconViewDimension
        + UIUtils.height(for: "S", font: nameFont)
        + UIConstants.interItemSpacing
        + (2 * UIConstants.interSectionSpacing)
        let width = UIConstants.iconViewDimension + (2 * UIConstants.interSectionSpacing)
        return CGSize(width: width, height: height)
    }
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    private static let nameFont = UIFont.systemFont(ofSize: 16, weight: .medium)

    private let activityNameLabel = UILabel()
    private let activityIconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

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
            activityIconView.widthAnchor.constraint(equalToConstant: UIConstants.iconViewDimension),
            activityIconView.heightAnchor.constraint(equalToConstant: UIConstants.iconViewDimension),
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
        // For whatever reason the icon looks a bit cut off without the extra 8 height padding here.
        activityIconView.image = UIUtils.emojiImage(fromText: viewModel.icon, size: CGSize(
            width: UIConstants.iconViewDimension,
            height: UIConstants.iconViewDimension + 8))
    }

}
