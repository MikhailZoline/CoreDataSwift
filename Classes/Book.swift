//
//  Book+CoreDataClass.swift
//  CoreDataSwift
//
//  Created by Mikhail Zoline on 11/23/18.
//  Copyright © 2018 MZ. All rights reserved.
//
//

import UIKit
import CoreData
import Foundation

//(Book)
//@objc public class Book: NSManagedObject
@objc(Book) class Book: NSManagedObject
{
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }
    
    @NSManaged public var author: String?
    @NSManaged public var copyright: Date?
    @NSManaged public var title: String?
    
    var isValid: Bool { return author != nil && copyright != nil && title != nil }
}
