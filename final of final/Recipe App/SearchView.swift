import SwiftUI

struct SearchView: View {
    @ObservedObject var user: User
    @ObservedObject var photoModel: PhotoModel
    @State private var searchText: String = ""
    @StateObject var viewModel = RecipeViewModel()
    @State private var results: [Recipe] = []
    @State private var image:UIImage? = nil
    @State private var showImagePicker=false
    @State private var selectedImageSource = UIImagePickerController.SourceType.photoLibrary
    @State private var placeHolderImage=Image("noImageAvailable")
    
    
    func search() {
        print("Searching for: \(searchText)")
        
        // Filter recipes based on the search text
        results = viewModel.recipes.filter { recipe in
            recipe.name.localizedCaseInsensitiveContains(searchText) ||
            recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            recipe.ingredients.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Print matching recipe names
        for recipe in results {
            print(recipe.name)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Try to Search by: ").navigationBarTitle("Search")
                    Button("",systemImage: "photo.on.rectangle") {
                        selectedImageSource = .photoLibrary
                        showImagePicker=true
                    }
                    Text("or")
                    Button("",systemImage: "camera") {
                        selectedImageSource = .camera
                        showImagePicker=true
                    }
                    Text("||")
                    Button("",systemImage: "magnifyingglass"){
//                        placeHolderImage = Image("noImageAvailable")
                        if image != nil{
                            placeHolderImage = Image(uiImage: image!)
                            photoModel.getPhoto(imageData: (image?.pngData())!)
                            searchText = photoModel.photo.results.first?.imageLabel ?? ""
                        }
                    }
                }.sheet(isPresented: $showImagePicker, onDismiss: {
                    placeHolderImage = (image==nil) ? Image("noImageAvailable") : Image(uiImage: image!)
                }) {
                    ImagePicker(image: self.$image , selectedSource: selectedImageSource)
                }
                
                placeHolderImage.resizable().aspectRatio(contentMode: .fit).frame(width: 350, height: 200)
                if let firstresult = photoModel.photo.results.first{
                    HStack{
                        Text("Most likely is: ").bold().padding(.leading,10)
                        Text(firstresult.imageLabel).bold()
                        Text(String(format: "%.2f%%", firstresult.confidence*100))
                    }
                }
                
                if !searchText.isEmpty {

                    // Display the search results in a grid
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            //TO Change: User() -> user
                            ForEach(results) { recipe in
                                NavigationLink(destination: RecipeDetailView(user:user,recipe: recipe,isPreview: false,Editable: false)) {
                                    RecipeRowView(recipe: recipe)
                                }
                            }
                        }
                    }
                }
            }.padding(.top,1)
            .searchable(text: $searchText, prompt: "Search by Name/Tags/Ingredients")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .onSubmit(of: .search) {
                search()
            }
            .onChange(of: searchText) { oldValue,newValue in
                if newValue.isEmpty {
                    results = []
                } else {
                    search()
                }
            }
            .onAppear {
                viewModel.loadRecipes() // Load recipes when the view appears
            }
        }
    }
}

#Preview {
ContentView()
}

