//
//  IngredientsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsTableViewController: UITableViewController {

    fileprivate var tableStructureForProduct: [(SectionType, Int, String?)] = []
    
    fileprivate var ingredientsImage: UIImage? = nil {
        didSet {
            refreshProduct()
        }
    }
    
    fileprivate enum SectionType {
        case ingredients
        case allergens
        case traces
        case additives
        case labels
        case image
    }
    
    // MARK: - Public variables
    
    var product: FoodProduct? {
        didSet {
            if product != nil {
                ingredientsImage = nil
                tableStructureForProduct = analyseProductForTable(product!)
                refreshProduct()
            }
        }
    }
    
    var currentLanguageCode: String? = nil

    // MARK: - Actions and Outlets
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        if refreshControl!.isRefreshing {
            OFFProducts.manager.reload(product!)
            refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source
    
    fileprivate struct Storyboard {
        static let IngredientsCellIdentifier = "Ingredients Full Cell"
        static let AllergensCellIdentifier = "Allergens TagList Cell"
        static let TracesCellIdentifier = "Traces TagList Cell"
        static let AdditivesCellIdentifier = "Additives TagList Cell"
        static let LabelsCellIdentifier = "Labels TagList Cell"
        static let IngredientsImageCellIdentifier = "Ingredients Image Cell"
        static let NoImageCellIdentifier = "No Image Cell"
        static let ShowIdentificationSegueIdentifier = "Show Ingredients Image"
        static let SelectLanguageSegueIdentifier = "Show Ingredients Languages"
    }
    
    fileprivate struct TextConstants {
        static let ShowIdentificationTitle = NSLocalizedString("Image", comment: "Title for the ViewController with the image of the product ingredients.")
        static let ViewControllerTitle = NSLocalizedString("Ingredients", comment: "Title for the ViewController with the product ingredients.")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableStructureForProduct.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, numberOfRows, _) = tableStructureForProduct[section]
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        // we assume that product exists
        switch currentProductSection {
        case .ingredients:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.IngredientsCellIdentifier, for: indexPath) as? IngredientsFullTableViewCell
            // does the product have valid multiple languages
            if (product!.languageCodes.count) > 0 && (currentLanguageCode != nil) {
                cell?.ingredients = product!.ingredientsLanguage[currentLanguageCode!]!
                cell?.numberOfLanguages = product!.languageCodes.count
                cell?.language = product!.languages[currentLanguageCode!]

            } else {
                cell?.ingredients = nil
                cell?.language = nil
                cell?.numberOfLanguages = 0
            }
            return cell!
        case .allergens:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.AllergensCellIdentifier, for: indexPath) as? AllergensFullTableViewCell
            cell?.tagList = product!.translatedAllergens
            return cell!
        case .traces:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TracesCellIdentifier, for: indexPath) as? TracesFullTableViewCell
            cell?.tagList = product!.translatedTraces
            return cell!
        case .additives:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.AdditivesCellIdentifier, for: indexPath) as? AdditivesFullTableViewCell
            cell!.tagList = product!.additives
            return cell!
        case .labels:
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.LabelsCellIdentifier, for: indexPath) as? LabelsFullTableViewCell
            cell?.tagList = product!.labelArray
            return cell!
        case .image:
            if let result = product?.getIngredientsImageData() {
                switch result {
                case .success(let data):
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.IngredientsImageCellIdentifier, for: indexPath) as? IngredientsImageTableViewCell
                    cell?.ingredientsImage = UIImage(data:data)
                    return cell!
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoImageCellIdentifier, for: indexPath) as? NoImageTableViewCell
                    cell?.imageFetchStatus = result
                    return cell!
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.NoImageCellIdentifier, for: indexPath) as? NoImageTableViewCell
                cell?.imageFetchStatus = ImageFetchResult.noImageAvailable
                return cell!
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let (_, _, header) = tableStructureForProduct[section]
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let (currentProductSection, _, _) = tableStructureForProduct[(indexPath as NSIndexPath).section]
        
        switch currentProductSection {
        case .ingredients:
            // set the next language in the array
            if currentLanguageCode != nextLanguageCode() {
                currentLanguageCode = nextLanguageCode()
                // reload the first two rows
                let indexPaths = [IndexPath.init(row: 0, section: 0)]
                tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.fade)
                tableView.deselectRow(at: indexPaths.first!, animated: true)
            }
        default:
            break
        }
        return
    }
    
    fileprivate func nextLanguageCode() -> String {
        let currentIndex = (product?.languageCodes.index(of: currentLanguageCode!))!
        
        let nextIndex = currentIndex == ((product?.languageCodes.count)! - 1) ? 0 : (currentIndex + 1)
        return (product?.languageCodes[nextIndex])!
    }

    fileprivate struct TableStructure {
        static let IngredientsSectionSize = 1
        static let AllergensSectionSize = 1
        static let TracesSectionSize = 1
        static let AdditivesSectionSize = 1
        static let LabelsSectionSize = 1
        static let ImageSectionSize = 1
        static let IngredientsSectionHeader = NSLocalizedString("Ingredients", comment: "Header title for the product ingredients section.")
        static let AllergensSectionHeader = NSLocalizedString("Allergens", comment: "Header title for the product allergens section, i.e. the allergens derived from the ingredients.")
        static let TracesSectionHeader = NSLocalizedString("Traces", comment: "Header title for the product traces section, i.e. the traces are from products which are worked with in the factory and are indicated separate on the label.")
        static let AdditivesSectionHeader = NSLocalizedString("Additives", comment: "Header title for the product additives section, i.e. the additives are derived from the ingredients list.")
        static let LabelsSectionHeader = NSLocalizedString("Labels", comment: "Header title for the product labels section, i.e. images, logos, etc.")
        static let ImageSectionHeader = NSLocalizedString("Ingredients Image", comment: "Header title for the ingredients image section, i.e. the image of the package with the ingredients")
    }
    
    fileprivate func analyseProductForTable(_ product: FoodProduct) -> [(SectionType,Int, String?)] {
        // This function analyses to product in order to determine
        // the required number of sections and rows per section
        // The returnValue is an array with sections
        // And each element is a tuple with the section type and number of rows
        //
        //  The order of each element determines the order in the table
        var sectionsAndRows: [(SectionType,Int, String?)] = []
        
        // 0: ingredients
        sectionsAndRows.append((SectionType.ingredients,
            TableStructure.IngredientsSectionSize,
            TableStructure.IngredientsSectionHeader))
        
        // 1:  allergens section
        sectionsAndRows.append((
            SectionType.allergens,
            TableStructure.AllergensSectionSize,
            TableStructure.AllergensSectionHeader))
        
        // 2: traces section
        sectionsAndRows.append((
            SectionType.traces,
            TableStructure.TracesSectionSize,
            TableStructure.TracesSectionHeader))
    
        // 3: additives section
        sectionsAndRows.append((
            SectionType.additives,
            TableStructure.AdditivesSectionSize,
            TableStructure.AdditivesSectionHeader))
        
        // 4: labels section
        sectionsAndRows.append((
            SectionType.labels,
            TableStructure.LabelsSectionSize,
            TableStructure.LabelsSectionHeader))
        
        
        // 5: image section
        sectionsAndRows.append((
            SectionType.image,
            TableStructure.ImageSectionSize,
            TableStructure.ImageSectionHeader))
        
        // print("\(sectionsAndRows)")
        return sectionsAndRows
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.ShowIdentificationSegueIdentifier:
                if let vc = segue.destination as? imageViewController {
                    if let result = product?.getIngredientsImageData() {
                        // try large image
                        switch result {
                        case .success(let data):
                            vc.image = UIImage(data: data)
                            vc.imageTitle = TextConstants.ShowIdentificationTitle
                        default:
                            vc.image = nil
                        }
                    }
                }
            case Storyboard.SelectLanguageSegueIdentifier:
                // pass the current language on to the popup vc
                if let vc = segue.destination as? SelectLanguageViewController {
                    vc.currentLanguageCode = currentLanguageCode
                    vc.languageCodes = product?.languageCodes
                    vc.primaryLanguageCode = product?.primaryLanguageCode
                    vc.languages = product?.languages
                    vc.sourcePage = 1
                }
            default: break
            }
        }
    }
    // MARK: - Notification handler
    
    func reloadImageSection(_ notification: Notification) {
        tableView.reloadData()
        // tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 5)], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    func refreshProduct() {
        tableView.reloadData()
    }
    
    func removeProduct() {
        product = nil
        tableView.reloadData()
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 88.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
        title = TextConstants.ViewControllerTitle
        
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.reloadImageSection(_:)), name:NSNotification.Name(rawValue: FoodProduct.Notification.IngredientsImageSet), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.refreshProduct), name:NSNotification.Name(rawValue: OFFProducts.Notification.ProductUpdated), object:nil)
        NotificationCenter.default.addObserver(self, selector:#selector(IngredientsTableViewController.removeProduct), name:NSNotification.Name(rawValue: History.Notification.HistoryHasBeenDeleted), object:nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if product != nil {
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        OFFProducts.manager.flushImages()
    }

}
