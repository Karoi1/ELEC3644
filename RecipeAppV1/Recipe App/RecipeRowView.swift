
import SwiftUI

struct RecipeRowView: View {
    var recipe: Recipe
    @State private var selectedCategory: String

    init(recipe: Recipe) {
        self.recipe = recipe
        _selectedCategory = State(initialValue: recipe.tags.first ?? "")
    }

    var body: some View {
        VStack {
            let imageName = recipe.id
            Image(String(imageName))
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 80)
                .cornerRadius(10)

            Text(recipe.name)
                .font(.headline)
                .padding(.top, 8)

            Text(recipe.tags.joined(separator: ", "))
                .font(.subheadline)
                .foregroundColor(.gray)

        }
        .frame(width: 130, height: 130)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}
