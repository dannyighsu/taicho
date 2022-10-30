//
//  LogEntryDetailPropertyView.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/17/22.
//

import Foundation
import UIKit

@objc
protocol LogEntryDetailPropertyViewDelegate: UITextViewDelegate {

    /**
     Called when the view's image is tapped.
     */
    @objc
    optional func imageTapped()
    
}

/**
 A view containing an optionally editable log entry property field.
 */
class LogEntryDetailPropertyView: UIView {
    
    /**
     Returns the minimum height required to properly display this view.
     Assumes the text view needs at least 2 lines.
     */
    var heightRequired: CGFloat {
        let inputViewHeight: CGFloat = button.isHidden
        ? propertyTextView.sizeThatFits(CGSize.greatestFiniteSize).height
        : button.currentImage.assertIfNil()?.size.height ?? 0
        return UIConstants.interItemSpacing * 3
        + propertyLabel.requiredHeight
        + inputViewHeight
    }
    
    private weak var delegate: LogEntryDetailPropertyViewDelegate?
    
    private let propertyLabel = UILabel()
    private let button = UIButton()
    let propertyTextView = UITextView()
    var iconImage: UIImage? {
        didSet {
            button.setImage(iconImage, for: .normal)
            imageHeightConstraint.constant = iconImage?.size.height ?? 0
            imageWidthConstraint.constant = iconImage?.size.width ?? 0
            button.isHidden = iconImage == nil
            propertyTextView.isHidden = iconImage != nil
            setNeedsLayout()
        }
    }

    private lazy var imageHeightConstraint = button.heightAnchor.constraint(equalToConstant: iconImage?.size.height ?? 0)
    private lazy var imageWidthConstraint = button.widthAnchor.constraint(equalToConstant: iconImage?.size.width ?? 0)
    
    /**
     - parameter image: If specified, this property view will forego the text entry and use an image-based UIButton instead.
     */
    init(delegate: LogEntryDetailPropertyViewDelegate,
         labelTitle: String,
         textPrefill: String? = nil,
         image: UIImage? = nil,
         textPlaceholder: String? = nil) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.iconImage = image

        [propertyLabel, button, propertyTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: leadingAnchor),
            ])
        }

        // Configure label
        propertyLabel.text = labelTitle
        propertyLabel.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        NSLayoutConstraint.activate([
            propertyLabel.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.interItemSpacing)
        ])

        // Configure text input views
        propertyTextView.font = UIFont.systemFont(ofSize: 16)
        propertyTextView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        propertyTextView.layer.cornerRadius = 2.0
        propertyTextView.layer.borderColor = UIColor.separator.cgColor
        propertyTextView.layer.borderWidth = 1.0
        propertyTextView.textContainerInset = UIEdgeInsets.defaultTextInsets
        propertyTextView.addDoneButtonOnKeyboard()
        propertyTextView.delegate = delegate

        // Configure image view
        button.setImage(iconImage, for: .normal)
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            propertyTextView.topAnchor.constraint(
                equalTo: propertyLabel.bottomAnchor,
                constant: UIConstants.interItemSpacing),
            propertyTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            propertyTextView.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -UIConstants.interItemSpacing),
            button.topAnchor.constraint(
                equalTo: propertyLabel.bottomAnchor,
                constant: UIConstants.interItemSpacing),
            imageHeightConstraint,
            imageWidthConstraint
        ])
        if let textPrefill = textPrefill {
            propertyTextView.text = textPrefill
        }
        if image == nil {
            button.isHidden = true
        } else {
            propertyTextView.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func onButtonTap(_ sender: UIButton) {
        delegate?.imageTapped?()
    }
    
}
