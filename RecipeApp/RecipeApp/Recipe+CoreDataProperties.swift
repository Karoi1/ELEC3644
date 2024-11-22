//
//  Recipe+CoreDataProperties.swift
//  RecipeApp
//
//  Created by Yuksing Li on 22/11/2024.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var name: String?
    @NSManaged public var tags: NSObject?
    @NSManaged public var ingredients: NSObject?
    @NSManaged public var steps: NSObject?

}

extension Recipe : Identifiable {

}
