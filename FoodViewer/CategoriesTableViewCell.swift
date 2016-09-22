//
//  CategoriesTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let NoInformation = NSLocalizedString("No categories specified.", comment: "Text to indicate that No categories have been specified in the product data.") 
        static let CategoryText = NSLocalizedString("Assigned to %@ categories.", comment: "Text to indicate the number of categories the product belongs to.")
        static let CategoryOneText = NSLocalizedString("Assigned to 1 category.", comment: "Text to indicate the product belongs to ONE category.")
    }

    @IBOutlet weak var categorySummaryLabel: UILabel!
    
    var product: FoodProduct? = nil {
        didSet {
            if let categories = product?.categories {
                if !categories.isEmpty {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    
                    categorySummaryLabel.text = categories.count == 1 ? Constants.CategoryOneText : String(format: Constants.CategoryText, formatter.string(from: NSNumber(integerLiteral: categories.count))!)
                } else {
                    categorySummaryLabel.text = Constants.NoInformation

                }
                
            } else {
                categorySummaryLabel.text = Constants.NoInformation
            }
        }
    }
}
