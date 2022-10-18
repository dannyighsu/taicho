//
//  LogEntryDetailPropertyView.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/17/22.
//

import Foundation
import UIKit

protocol LogEntryDetailPropertyViewDelegate: UITextFieldDelegate & UITextViewDelegate {
    
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
        let textInputViewSize = useTextView
        ? propertyTextView.sizeThatFits(CGSize.greatestFiniteSize).height
        : propertyTextField.sizeThatFits(CGSize.greatestFiniteSize).height
        return UIConstants.interItemSpacing * 3
        + propertyLabel.sizeThatFits(CGSize.greatestFiniteSize).height
        + textInputViewSize
    }
    
    private weak var delegate: LogEntryDetailPropertyViewDelegate?
    
    private let useTextView: Bool
    private let propertyLabel = UILabel()
    private let propertyTextField = UITextField()
    private let propertyTextView = UITextView()
    
    /**
     - param useTextView: If true, will allow for long-format input via a textview.
     */
    init(delegate: LogEntryDetailPropertyViewDelegate,
         labelTitle: String,
         textPrefill: String? = nil,
         textPlaceholder: String? = nil,
         useTextView: Bool = false) {
        self.useTextView = useTextView
        super.init(frame: .zero)
        self.delegate = delegate
        
        configureViews(with: labelTitle, textPrefill: textPrefill, textPlaceholder: textPlaceholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews(with labelTitle: String, textPrefill: String?, textPlaceholder: String?) {
        [propertyLabel, propertyTextField, propertyTextView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
                
        // Configure label
        propertyLabel.text = labelTitle
        propertyLabel.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        NSLayoutConstraint.activate([
            propertyLabel.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.interItemSpacing)
        ])
        
        // Configure text input views
        propertyTextField.font = UIFont.systemFont(ofSize: 16)
        propertyTextView.font = UIFont.systemFont(ofSize: 16)
        propertyTextField.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        propertyTextView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        propertyTextField.layer.cornerRadius = 2.0
        propertyTextView.layer.cornerRadius = 2.0
        propertyTextField.layer.borderColor = UIColor.separator.cgColor
        propertyTextView.layer.borderColor = UIColor.separator.cgColor
        propertyTextField.layer.borderWidth = 1.0
        propertyTextView.layer.borderWidth = 1.0
        propertyTextView.textContainerInset = UIEdgeInsets.defaultTextInsets
        propertyTextField.delegate = delegate
        propertyTextView.delegate = delegate
        
        if useTextView {
            propertyTextField.isHidden = useTextView
            NSLayoutConstraint.activate([
                propertyTextView.topAnchor.constraint(
                    equalTo: propertyLabel.bottomAnchor,
                    constant: UIConstants.interItemSpacing),
                propertyTextView.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: -UIConstants.interItemSpacing)
            ])
            if let textPrefill = textPrefill {
                propertyTextView.text = textPrefill
            }
        } else {
            propertyTextView.isHidden = !useTextView
            NSLayoutConstraint.activate([
                propertyTextField.topAnchor.constraint(
                    equalTo: propertyLabel.bottomAnchor,
                    constant: UIConstants.interItemSpacing)
            ])
            if let textPlaceholder = textPlaceholder {
                propertyTextField.placeholder = textPlaceholder
            }
            if let textPrefill = textPrefill {
                propertyTextField.text = textPrefill
            }
        }
    }
    
}
