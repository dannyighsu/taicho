//
//  UIUtils.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/14/22.
//

import Foundation
import UIKit

class UIUtils {
    
    static func getErrorAlert(_ errorMessage: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Argh Matey! A problem!", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(getDismissAction(alertController))
        return alertController
    }

    static func getAlertBottomSheet(title: String, message: String? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        alertController.addAction(getDismissAction(alertController))
        return alertController
    }
    
    static func addDividerToBottomOfView(_ view: UIView) {
        let divider = UIView()
        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.leftAnchor.constraint(equalTo: view.leftAnchor),
            divider.rightAnchor.constraint(equalTo: view.rightAnchor),
            divider.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    static func height(for text: String, font: UIFont, constrainingWidth width: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil)
        
        return ceil(boundingBox.height)
    }
    
    static func width(for text: String, font: UIFont, constrainingHeight height: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil)
        
        return ceil(boundingBox.width)
    }

    static func emojiImage(fromText text: String, size: CGSize = UIConstants.iconImageSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        text.draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: UIConstants.iconViewDimension - 4)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    // MARK: - Helpers

    private static func getDismissAction(_ alertController: UIAlertController) -> UIAlertAction {
        return UIAlertAction(title: "Cancel", style: .default, handler: { [weak alertController] _ in
            alertController?.dismiss(animated: true, completion: nil)
        })
    }
    
}
