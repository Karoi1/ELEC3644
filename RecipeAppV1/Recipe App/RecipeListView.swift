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
    @StateObject var viewModel = RecipeViewModel()
    var recipeID: [Int]

    var body: some View {
        ScrollView {
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.search(ListID: recipeID)) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeRowView(recipe: recipe)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadRecipes()
        }
    }
}


#Preview {
    RecipeListView(recipeID: [1,2,3,4,5,6,7,8,9,10,11])
}
