
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
            let image = loadSavedImage(newid: recipe.id)
            if recipe.id > 26{
                if let image = image{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 80)
                        .cornerRadius(10)
                }
                else{
                    Image("noImageAvailable")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 80)
                        .cornerRadius(10)
                }
                    
            }
            if recipe.id <= 26{
                Image(String(imageName))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 80)
                    .cornerRadius(10)
            }
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
    
    private func loadSavedImage(newid: Int) -> UIImage? {
        let filename = getDocumentsDirectory().appendingPathComponent("\(newid).png") // Construct the file path
        return UIImage(contentsOfFile: filename.path) // Load the image
    }

    // Get Document Directory path
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

}

#Preview {
    ContentView()
}
