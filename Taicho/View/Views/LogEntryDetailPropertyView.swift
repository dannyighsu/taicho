//
//  LogEntryDetailPropertyView.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/17/22.
//

import Foundation
import UIKit

protocol LogEntryDetailPropertyViewDelegate: UITextViewDelegate {
    
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
        return UIConstants.interItemSpacing * 3
        + propertyLabel.sizeThatFits(CGSize.greatestFiniteSize).height
        + propertyTextView.sizeThatFits(CGSize.greatestFiniteSize).height
    }
    
    private weak var delegate: LogEntryDetailPropertyViewDelegate?
    
    private let propertyLabel = UILabel()
    private let propertyTextView = UITextView()
    
    /**
     - param useTextView: If true, will allow for long-format input via a textview.
     */
    init(delegate: LogEntryDetailPropertyViewDelegate,
         labelTitle: String,
         textPrefill: String? = nil,
         textPlaceholder: String? = nil) {
        super.init(frame: .zero)
        self.delegate = delegate
        
        configureViews(with: labelTitle, textPrefill: textPrefill, textPlaceholder: textPlaceholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String) {
        propertyTextView.text = text
    }
    
    func getTextValue() -> String? {
        return propertyTextView.text
    }
    
    private func configureViews(with labelTitle: String, textPrefill: String?, textPlaceholder: String?) {
        [propertyLabel, propertyTextView].forEach {
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
        propertyTextView.font = UIFont.systemFont(ofSize: 16)
        propertyTextView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.5)
        propertyTextView.layer.cornerRadius = 2.0
        propertyTextView.layer.borderColor = UIColor.separator.cgColor
        propertyTextView.layer.borderWidth = 1.0
        propertyTextView.textContainerInset = UIEdgeInsets.defaultTextInsets
        propertyTextView.delegate = delegate
        
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
    }
    
}
