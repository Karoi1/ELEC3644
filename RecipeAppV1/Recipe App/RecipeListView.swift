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
                    NavigationLink(destination: RecipeDetailView(user:user,recipe: recipe)) {
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
    RecipeListView(user:User(),recipeID: [1,2,3,4,5,6,7,8,9,10,11])
}
