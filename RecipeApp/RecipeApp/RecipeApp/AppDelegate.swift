import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RecipeModel") // Your Core Data model name
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // Load and parse JSON
    func loadJSON() -> [RecipeModel]? {
        guard let url = Bundle.main.url(forResource: "recipe", withExtension: "json") else {
            print("JSON file not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let recipes = try decoder.decode([RecipeModel].self, from: data)
            return recipes
        } catch {
            print("Error loading JSON: \(error)")
            return nil
        }
    }

    // Save recipes to Core Data
    func saveRecipesToCoreData(recipes: [RecipeModel]) {
        let context = persistentContainer.viewContext

        for recipe in recipes {
            let recipeEntity = RecipeEntity(context: context) // Your NSManagedObject subclass

            recipeEntity.name = recipe.name
            recipeEntity.tags = recipe.tags as NSObject // Store as transformable
            recipeEntity.ingredients = recipe.ingredients as NSObject // Store as transformable
            recipeEntity.steps = recipe.steps as NSObject // Store as transformable
        }

        do {
            try context.save()
            print("Recipes saved to Core Data")
        } catch {
            print("Failed to save recipes: \(error)")
        }
    }

    // Import JSON to Core Data
    func importJSONToCoreData() {
        if let recipes = loadJSON() {
            saveRecipesToCoreData(recipes: recipes)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        importJSONToCoreData()
        return true
    }
}
