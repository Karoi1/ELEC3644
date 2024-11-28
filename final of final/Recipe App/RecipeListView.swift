import SwiftUI
import CoreData

@main
struct MySwiftUIApp: App {
    let persistenceController = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.context)
        }
    }
    

    
}
	

struct RecipeListView: View {
    @ObservedObject var user: User

    @StateObject var recipeViewModel: RecipeViewModel = RecipeViewModel()
    var recipeID: [Int]
    var Editable:Bool

    var body: some View {
        ScrollView {
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(RecipeViewModel().search(ListID: recipeID)) { recipe in
                    NavigationLink(destination: RecipeDetailView(user:user,recipe: recipe, isPreview: false,Editable:Editable)) {
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
