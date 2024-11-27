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
    public var Alllist = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

    var body: some View {
        NavigationStack {
            ScrollView {
                let columns = [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ]

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(viewModel.search(ListID: Alllist)) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeRowView(recipe: recipe)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("All Recipes")
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
