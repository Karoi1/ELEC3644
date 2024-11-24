import SwiftUI

struct RecipeRowView: View {
    var recipe: Recipe
    @State private var selectedCategory: String

    init(recipe: Recipe) {
        self.recipe = recipe
        _selectedCategory = State(initialValue: recipe.tags.first ?? "") // Initialize with the first tag or an empty string
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                let imageName = recipe.id
                Image(String(imageName))
                    .resizable()
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.headline)
                    Text("\(recipe.tags.joined(separator: ", "))") // Display tags as a comma-separated list
                        .font(.subheadline)
                }
            }
        }
    }
}
