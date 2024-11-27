import Foundation


class Recipe: Identifiable, Codable, ObservableObject {
    var id: Int
    var name: String
    var tags: [String]
    var ingredients: [String]
    var steps:[String]
    init(id: Int, name: String, tags: [String] = [], ingredients: [String] = [], steps: [String] = []) {
            self.id = id
            self.name = name
            self.tags = tags
            self.ingredients = ingredients
            self.steps = steps
        }
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
        let url = getDocumentsDirectory().appendingPathComponent("recipe.json")
        do {
            // Step 2: Attempt to load the data from the JSON file
            let data = try Data(contentsOf: url)
            //print("Data loaded successfully from \(url).") // Confirm data loading
            // Step 3: Decode the data into Recipe objects
            let decoder = JSONDecoder()
            let loadedRecipes = try decoder.decode([Recipe].self, from: data)
            
            // Step 4: Assign loaded recipes to the published array
            self.recipes = loadedRecipes
            // Print each recipe name
            //for recipe in loadedRecipes {
                //print("Loaded recipe: \(recipe.name)") // Print the name of each recipe
            //}
            print("Successfully loaded \(loadedRecipes.count) recipes.") // Confirm number of recipes loaded
        } catch {
            // Step 5: Handle any errors during loading or decoding
            print("Failed to load or decode data.json: \(error)")
        }
    }
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    func saveRecipe(newRecipe: Recipe) {
        let url = getDocumentsDirectory().appendingPathComponent("recipe.json")
        let save = recipes + [newRecipe]
        print("========================================")
        print("->Save Recipe,|Q| = \(save.count)")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 美化输出
            let data = try encoder.encode(save)
            try data.write(to: url)
            print("State: success, file: \(url.path)")
        } catch {
            print("State: Fail, Error: \(error.localizedDescription)")
        }
        print("========================================")

    }
    func deleteRecipe(id: Int) {
        var save = recipes
        let url = getDocumentsDirectory().appendingPathComponent("recipe.json")
        if let index = recipes.firstIndex(where: { $0.id == id }) {
            save.remove(at: index)
        }
        print("========================================")
        print("->Save Recipe,|Q| = \(save.count)")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 美化输出
            let data = try encoder.encode(save)
            try data.write(to: url)
            print("State: success, file: \(url.path)")
        } catch {
            print("State: Fail, Error: \(error.localizedDescription)")
        }
        print("========================================")
    }
    func findSpace() -> Int{
        let sortedIds = recipes.map{$0.id}.sorted()
        if let first = sortedIds.first,first>1{
            return 1
        }
        for i in 1..<sortedIds.count-1{
            if sortedIds[i+1] - sortedIds[i]>1{
                return sortedIds[i]+1
            }
        }
        return sortedIds.count>0 ? sortedIds.last!+1 : 0
    }
    func DebugUpdate(save: [Recipe]){
        let url = getDocumentsDirectory().appendingPathComponent("recipe.json")
        print("========================================")
        print("->Save Recipe,|Q| = \(save.count)")
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 美化输出
            let data = try encoder.encode(save)
            try data.write(to: url)
            print("State: success, file: \(url.path)")
        } catch {
            print("State: Fail, Error: \(error.localizedDescription)")
        }
        print("========================================")
    }
}
