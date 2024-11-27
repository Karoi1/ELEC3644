import SwiftUI

@main
struct MySwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct RecipeListView: View {
    @ObservedObject var user: User
    @StateObject var recipeViewModel: RecipeViewModel = RecipeViewModel()
    var recipeID: [Int]

    var body: some View {
        ScrollView {
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(recipeViewModel.search(ListID: recipeID)) { recipe in
                    NavigationLink(destination: RecipeDetailView(user:user,recipe: recipe, isPreview: false)) {
                        RecipeRowView(recipe: recipe)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            recipeViewModel.loadRecipes()
        }
    }
}


#Preview {
    ContentView()
}
