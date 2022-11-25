//
//  LogActivityCollectionHeaderView.swift
//  Taicho
//
//  Created by Daniel Hsu on 11/21/22.
//

import Foundation
import UIKit

protocol LogActivityCollectionHeaderViewDelegate: AnyObject {
    
    func newButtonTapped(forProductivity productivity: ProductivityLevel)
    
}

class LogActivityCollectionHeaderView: UICollectionReusableView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    static var requiredHeight: CGFloat {
        return max(UIUtils.height(for: "F", font: .systemFont(ofSize: 20)) + (2 * UIConstants.interItemSpacing), 44)
    }
    
    weak var delegate: LogActivityCollectionHeaderViewDelegate?
    
    private var productivityLevel: ProductivityLevel = .none
    private let titleLabel = UILabel()
    private let newButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        addSubview(newButton)
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.addTarget(self, action: #selector(newButtonTapped), for: .touchUpInside)
        let attributedTitle = NSAttributedString(string: UIConstants.plusButtonEmoji, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 36)])
        newButton.setAttributedTitle(attributedTitle, for: .normal)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.sideMargin),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            newButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -UIConstants.sideMargin),
            newButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadProductivity(_ productivityLevel: ProductivityLevel) {
        self.productivityLevel = productivityLevel
        titleLabel.text = productivityLevel.longDisplayName
        backgroundColor = UIUtils.backgroundColor(for: productivityLevel)
    }
    
    @objc func newButtonTapped() {
        delegate?.newButtonTapped(forProductivity: productivityLevel)
    }
    
}
