//
//  IdentificationPackagingTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit


class IdentificationPackagingTagListViewTableViewCell: UITableViewCell {

    private struct Constants {
        static let NoInformation = NSLocalizedString("no packing info specified", comment: "Text for tag in a separate colour, when no packaging infor is available in the product data.") 
    }

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tagListView.alignment = .Center
            tagListView.tagBackgroundColor = UIColor.greenColor()
            tagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                tagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        tagListView.addTag(listItem)
                    }
                    tagListView.tagBackgroundColor = UIColor.greenColor()
                } else {
                    tagListView.addTag(Constants.NoInformation)
                    tagListView.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                tagListView.removeAllTags()
                tagListView.addTag(Constants.NoInformation)
                tagListView.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }

}
