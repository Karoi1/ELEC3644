import SwiftUI

@main
struct MySwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
        }
    }
}

struct RecipeListView: View {
    @StateObject var viewModel = RecipeViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(recipe: recipe)
                }
            }
            .navigationTitle("Recipe List")
            .onAppear {
                viewModel.loadRecipes()
                print("onAppear called")
            }
        }
    }
}




#Preview {
    RecipeListView()
}
