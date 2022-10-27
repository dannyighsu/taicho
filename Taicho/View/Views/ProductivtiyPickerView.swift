//
//  ProductivtiyPickerView.swift
//  Taicho
//
//  Created by Daniel Hsu on 10/25/22.
//

import Foundation
import UIKit

protocol ProductivityPickerViewDelegate: AnyObject {

    func pickerView(_ pickerView: ProductivityPickerView, didSelectProductivity productivity: ProductivityLevel)

}

/**
 A picker view that is its own delegate and data source, displaying the options for productivity levels.

 Will call back to its productivityPickerDelegate when a value is selected.
 */
final class ProductivityPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    weak var productivityPickerDelegate: ProductivityPickerViewDelegate?

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ProductivityLevel.allCases.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ProductivityLevel.allCases[safe: row].assertIfNil()?.displayName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let productivityLevel = ProductivityLevel.allCases[safe: row] else {
            Log.assert("Failed to get productivity for selection at row \(row).")
            return
        }
        productivityPickerDelegate?.pickerView(self, didSelectProductivity: productivityLevel)
    }

}
