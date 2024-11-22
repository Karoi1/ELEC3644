//
//  RecipeAppApp.swift
//  RecipeApp
//
//  Created by Yuksing Li on 22/11/2024.
//

import SwiftUI

@main
struct RecipeAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
