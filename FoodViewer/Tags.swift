//
//  Tags.swift
//  FoodViewer
//
//  Created by arnaud on 18/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

//  The Tags object maps a tags-field in OFF. As a tags-field is not always available or filled in an OFF-json,
//  it has been setup as an enum.
//
//  If tags are available, the original tags as supplied vy OFF are stored.
//  For actual use the right language must be set. The language is set as a prefix with a :-delimiter.
//  - no language prefix present, then the product primary language is assumed
//  - language prefix present, then the language prefix is used
//
//  Public methods are available that work on a Tags-object, on a list of tags and on individuel tags

import Foundation

public enum Tags {
    
    case undefined
    case empty
    case available([String])
    
    func description() -> String {
        switch self {
        case .undefined: return NSLocalizedString("unknown", comment: "Text in a TagListView, when the field in the json was not present.")
        case .empty: return NSLocalizedString("none", comment: "Text in a TagListView, when the json provided an empty string.")
        case .available:
            return NSLocalizedString("available", comment: "Text in a TagListView, when tags are available the product data.")        }
    }
    
    //
    // MARK: - Initialisers
    //

    public init() {
        self = .undefined
    }
    
    // initialise tags with a list of strings
    public init(_ list: [String]?) {
        self.init()
        decode(list)
    }
    
    // initialise tags with a comma delimited string
    public init(_ string: String?) {
        self.init(string?.characters.split{ $0 == "," }.map(String.init))
    }
//    
//    // initialise with a list of strings with a languageCode for unlanguaged strings
//    public init(withList list: [String]?, and languageCode: String) {
//        self.init(list)
//        addPrefix(languageCode)
//    }
//    
//    // initialise with a comma delimited string with a languageCode for unlanguaged strings
//    public init(_ string: String?, with languageCode: String) {
//        self.init(string)
//        addPrefix(languageCode)
//    }
    //
    // MARK: - Tags functions
    //
    
//    // add a languageCode to individual tags that have no language
//    public func tags(with languageCode: String) -> [String] {
//        switch self {
//        case let .available(list):
//            if !list.isEmpty {
//                return addPrefix(list, prefix: languageCode)
//            }
//        default:
//            break
//        }
//        return []
//    }
    
    // add a languageCode to tags that have no language and remove languageCode for another language
    public func tags(withAdded languageCode: String, andRemoved otherLanguageCode: String) -> [String] {
        switch self {
        case let .available(list):
            if !list.isEmpty {
                let newList = addPrefix(list, prefix: languageCode)
                return strip(newList, of:otherLanguageCode)
            }
        default:
            break
        }
        return []
    }

//
// MARK: - Single tag functions
//
    
    // returns the tag string at an index if available
    public func tag(at index: Int) -> String? {
        switch self {
        case .undefined, .empty:
            return self.description()
        case let .available(list):
            if index >= 0 && index < list.count {
                return list[index]
            } else {
                assert(true, "Tags array - index out of bounds")
            }
        }
        return nil
    }
    
    // If the tag has a languageCode, remove it
    public func tag(at index: Int, in languageCode: String) -> String? {
        return self.tag(at: index) != nil ? strip(self.tag(at: index)!, of: languageCode) : nil
    }
    
    // remove a tag at an index if available
    public mutating func remove(_ index: Int) {
        switch self {
        case .available(var newList):
            guard index >= 0 && index < newList.count else { break }
            newList.remove(at: index)
            self = .available(newList)
        default:
            break
        }
    }
    

//
// MARK: - Private Tags functions
//
    // returns a tag string without a prefix at an index, if available
    private func stripTag(_ index: Int) -> String? {
        if let currentTag = self.tag(at: index) {
            if currentTag.contains(":") {
                return stripAnyPrefix(currentTag)
            } else {
                return currentTag
            }
        } else {
            return nil
        }
    }
   
    // If there are any tag strings, add a language code.
    private func addPrefix(_ prefix: String) -> [String] {
        switch self {
        case let .available(list):
            if !list.isEmpty {
                return addPrefix(list, prefix: prefix)
            }
        default:
            break
        }
        return []
    }
    
//    
//    // If there are any tag strings, add a language code.
//    private mutating func stripPrefix(_ languageCode: String) {
//        switch self {
//        case let .available(list):
//            if !list.isEmpty {
//                self = .available(strip(list, of: languageCode))
//            }
//        default:
//            break
//        }
//    }


//
// MARK: - Private tag-list functions
//

    private func strip(_ list: [String], of prefix: String) -> [String] {
        var newList: [String] = []
        for string in list {
            newList.append(strip(string, of: prefix))
        }
        return newList
    }

//    private func setPrefix(_ list: [String], prefix: String) -> [String] {
//        var prefixedList: [String] = []
//        for tag in list {
//            if tag.contains(":") {
//                // there is already a prefix
//                prefixedList.append(tag)
//                // is there an language prefix encoded?
//            } else {
//                prefixedList.append(prefix + ":" + tag)
//            }
//        }
//        return prefixedList
//    }
    
    private func addPrefix(_ list: [String], prefix: String) -> [String] {
        var prefixedList: [String] = []
        for tag in list {
            if tag.contains(":") {
                // there is already a prefix
                prefixedList.append(tag)
                // is there an language prefix encoded?
            } else {
                prefixedList.append(prefix + ":" + tag)
            }
        }
        return prefixedList
    }


    // remove any empty tag strings from the list
    private func clean(_ list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.characters.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }
    
    // setup tags with a cleaned list of strings
    private mutating func decode(_ list: [String]?) {
        if let validList = list {
            let newList = clean(validList)
            if newList.isEmpty {
                self = .empty
            } else {
                self = .available(newList)
            }
        } else {
            self = .undefined
        }
    }

//
// MARK: - Private tag functions
//

    private func strip(_ string: String, of prefix: String) -> String {
        return string.hasPrefix(prefix + ":") ? stripAnyPrefix(string) : string
    }
    
    private func stripAnyPrefix(_ string: String) -> String {
        return string.contains(":") ? string.characters.split{ $0 == ":" }.map(String.init)[1]
            : string
    }
    
//    private func tagWithoutPrefix(_ index: Int, locale:String) -> String? {
//        if let currentTag = self.tag(index) {
//            let interfaceLanguage = locale.characters.split{ $0 == "-" }.map(String.init)[0]
//            if currentTag.hasPrefix(interfaceLanguage + ":") {
//                return currentTag.characters.split{ $0 == ":" }.map(String.init)[1]
//            } else {
//                return currentTag
//            }
//        } else {
//            return nil
//        }
//    }
//
}
