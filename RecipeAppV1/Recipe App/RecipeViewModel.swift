import Foundation


struct Recipe: Identifiable, Codable {
    var id: Int
    var name: String
    var tags: [String]
    var ingredients: [String]
    var steps:[String]
}


class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var selectedCategory: String = "" // Change this to suit your filtering needs
    
    init(){
        loadRecipes()
    }
    
    func search(ListID: [Int]) -> [Recipe] {
        // Step 1: Filter the recipes based on the provided ListID
        let filteredRecipes = recipes.filter { ListID.contains($0.id) }
        
        // Step 2: Sort the filtered recipes based on the order of ListID
        let orderedRecipes = ListID.compactMap { id in
            filteredRecipes.first(where: { $0.id == id })
        }
        
        return orderedRecipes
    }
    
    func loadRecipes() {
        // Step 1: Check if the JSON file can be located
        guard let url = Bundle.main.url(forResource: "recipe", withExtension: "json") else {
            print("Failed to locate data.json in bundle.")
            return
        }
        do {
            // Step 2: Attempt to load the data from the JSON file
            let data = try Data(contentsOf: url)
            print("Data loaded successfully from \(url).") // Confirm data loading
            // Step 3: Decode the data into Recipe objects
            let decoder = JSONDecoder()
            let loadedRecipes = try decoder.decode([Recipe].self, from: data)
            
            // Step 4: Assign loaded recipes to the published array
            self.recipes = loadedRecipes
            // Print each recipe name
            for recipe in loadedRecipes {
                print("Loaded recipe: \(recipe.name)") // Print the name of each recipe
            }
            print("Successfully loaded \(loadedRecipes.count) recipes.") // Confirm number of recipes loaded
        } catch {
            // Step 5: Handle any errors during loading or decoding
            print("Failed to load or decode data.json: \(error)")
        }
    }
}