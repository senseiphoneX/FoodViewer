//
//  IngredientsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsFullTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    @IBOutlet weak var changeLanguageButton: UIButton!
    @IBAction func ChangeLanguageButtonTapped(_ sender: UIButton) {
    }
    
    struct Constants {
        static let NoIngredientsText = NSLocalizedString("no ingredients specified", comment: "Text in a TagListView, when no ingredients are available in the product data.")
        static let UnbalancedWarning = NSLocalizedString(" (WARNING: check brackets, they are unbalanced)", comment: "a warning to check the brackets used, they are unbalanced")
        static let NoLanguageText = NSLocalizedString("none defined", comment: "the ingredients text has no associated language defined")
    }
    
    var ingredients: String? = nil {
        didSet {
            if let text = ingredients {
                if !text.isEmpty {
                    // defined the attributes for allergen text
                    let allergenAttributes = [NSForegroundColorAttributeName : UIColor.red]
                    let noAttributes = [NSForegroundColorAttributeName : UIColor.black]
                    // create a attributable string
                    let myString = NSMutableAttributedString(string: "", attributes: allergenAttributes)
                    let components = text.components(separatedBy: "_")
                    for (index, component) in components.enumerated() {
                        // if the text starts with a "_", then there will be an empty string component
                        let (_, fraction) = modf(Double(index)/2.0)
                        if (fraction) > 0 {
                            let attributedString = NSAttributedString(string: component, attributes: allergenAttributes)
                            myString.append(attributedString)
                        } else {
                            let attributedString = NSAttributedString(string: component, attributes: noAttributes)
                            myString.append(attributedString)
                        }
                    }
                    if  (text.unbalancedDelimiters()) ||
                        (text.oddNumberOfString("_")) {
                        let attributedString = NSAttributedString(string: Constants.UnbalancedWarning, attributes: noAttributes)
                        myString.append(attributedString)
                    }
                    ingredientsLabel.attributedText = myString
                } else {
                    ingredientsLabel.text = Constants.NoIngredientsText
                }
            }
        }
    }
    
    var language: String? = nil {
        didSet {
            changeLanguageButton.setTitle(language != nil ? OFFplists.manager.translateLanguage(language!, language:Locale.preferredLanguages[0])  : Constants.NoLanguageText, for: UIControlState())
        }
    }

    var numberOfLanguages: Int = 0 {
        didSet {
            if numberOfLanguages > 1 {
                changeLanguageButton.isEnabled = true
            } else {
                changeLanguageButton.isEnabled = false
            }
        }
    }

}

extension String {
    
    func unbalancedDelimiters() -> Bool {
        return (self.unbalanced("(", endDelimiter: ")")) ||
            (self.unbalanced("{", endDelimiter: "}")) ||
            (self.unbalanced("[", endDelimiter: "]"))
    }
    
    func unbalanced(_ startDelimiter: String, endDelimiter: String) -> Bool {
        return (self.difference(startDelimiter, endDelimiter: endDelimiter) != 0)
    }

    func difference(_ startDelimiter: String, endDelimiter: String) -> Int {
        return self.components(separatedBy: startDelimiter).count - self.components(separatedBy: endDelimiter).count
    }
    
    func oddNumberOfString(_ testString: String) -> Bool {
        let (_, fraction) = modf(Double(self.components(separatedBy: testString).count-1)/2.0)
        return (fraction > 0)
    }

}
