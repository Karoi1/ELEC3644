import SwiftUI

struct EditRecipeView: View {
    @ObservedObject var user: User
    @Binding var oldRecipe: Recipe
    @State private var recipeName: String = ""
    @State private var tags: [String] = [""]
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    var newRecipe: Recipe {
        Recipe(id: oldRecipe.id, name: recipeName, tags: tags.filter { !$0.isEmpty }, ingredients: ingredients.filter { !$0.isEmpty }, steps: steps.filter { !$0.isEmpty })
    }
    
    @Environment(\.presentationMode) var presenMode
    
    @State private var image:UIImage? = Image("noImageAvailable").toUIImage()
    @State private var showImagePicker=false
    @State private var selectedImageSource = UIImagePickerController.SourceType.photoLibrary
    @State private var placeHolderImage = Image("noImageAvailable")
    @State private var oldimage: UIImage? = Image("noImageAvailable").toUIImage()
    
    func initial(){
        oldimage = loadSavedImage(newid: oldRecipe.id)
        recipeName = oldRecipe.name
        tags = oldRecipe.tags
        ingredients = oldRecipe.ingredients
        steps = oldRecipe.steps
    }


    var body: some View {
        Form {
            HStack {
                
                Text("Upload image by: ").navigationBarTitle("Search")
                Button("",systemImage: "photo.on.rectangle") {
                    selectedImageSource = .photoLibrary
                    showImagePicker=true
                }
                Text("or  ")
                Button("",systemImage: "camera") {
                    selectedImageSource = .camera
                    showImagePicker=true
                }
            }.sheet(isPresented: $showImagePicker, onDismiss: {
                placeHolderImage = (image==nil) ? Image("noImageAvailable") : Image(uiImage: image!)
            }) {
                ImagePicker(image: self.$image , selectedSource: selectedImageSource)
            }
            
            placeHolderImage.resizable().aspectRatio(contentMode: .fit).frame(width: 350, height: 200)
            
            
            
            Section(header: Text("Recipe Name")) {
                TextField("Enter recipe name", text: $recipeName)
            }
            
            Section(header: Text("Tags")) {
                ForEach(tags.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            removeTag(at: index)
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        TextField("Tag", text: $tags[index])
                    }
                }
                
                HStack {
                    Button(action: addTag) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Text("Add a new tag")
                        .opacity(0.2)
                }
            }
            
            Section(header: Text("Ingredients")) {
                ForEach(ingredients.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            removeIngredient(at: index)
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        TextField("Ingredient", text: $ingredients[index])
                    }
                }
                
                HStack {
                    Button(action: addIngredient) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Text("Add a new ingredient")
                        .opacity(0.2)
                }
            }
            
            Section(header: Text("Steps")) {
                ForEach(steps.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            removeStep(at: index)
                        }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        TextField("Step", text: $steps[index])
                    }
                }
                
                HStack {
                    Button(action: addStep) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Text("Add a new step")
                        .opacity(0.2)
                }
            }
            
            Button(action: saveRecipe) {
                Text("Save Recipe")
            }
            //.disabled(recipeName.isEmpty || tags.contains(where: { $0.isEmpty }) || ingredients.contains(where: { $0.isEmpty }) || steps.contains(where: { $0.isEmpty }))
        }
        .onAppear(){
            initial()
        }
        .navigationTitle("Design Your Recipe")
        .navigationBarItems(trailing: NavigationLink(destination: RecipeDetailView(user:user, recipe:newRecipe,isPreview:true,Editable: false)) {
            Text("Preview Recipe")
                
            })
                        
    }
    
    private func addTag() {
        tags.append("")
    }
    
    private func removeTag(at index: Int) {
        if index < tags.count {
            tags.remove(at: index)
        }
    }
    
    private func addIngredient() {
        ingredients.append("")
    }
    
    private func removeIngredient(at index: Int) {
        if index < ingredients.count {
            ingredients.remove(at: index)
        }
    }
    
    private func addStep() {
        steps.append("")
    }
    
    private func removeStep(at index: Int) {
        if index < steps.count {
            steps.remove(at: index)
        }
    }
    
    private func saveImageToDocuments(image: UIImage?, newid: Int) {
        // 如果传入的 image 为 nil，使用默认的 globe 图像
        let finalImage: UIImage
        if let image = image {
            finalImage = image
        } else {
            // 加载默认的 globe 图像
            finalImage = placeHolderImage.toUIImage() ?? UIImage() // 确保有一个 UIImage 实例
            print("使用默认图像")
        }

        // 获取文档目录的 URL
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            // 创建文件名
            let fileName = "\(newid).png"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)

            // 将 UIImage 转换为 PNG 数据
            if let pngData = finalImage.pngData() {
                do {
                    // 写入数据到文件
                    try pngData.write(to: fileURL)
                    print("图像成功保存到: \(fileURL.path)")
                } catch {
                    print("保存图像失败: \(error)")
                }
            } else {
                print("图像转换为 PNG 数据失败")
            }
        } else {
            print("无法获取文档目录")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func loadSavedImage(newid: Int) -> UIImage? {
        let filename = getDocumentsDirectory().appendingPathComponent("\(newid).png") // Construct the file path
        return UIImage(contentsOfFile: filename.path) // Load the image
    }
    
    private func saveRecipe() {
        user.myRecipes.append(newRecipe.id)
        oldRecipe = newRecipe
        RecipeViewModel().deleteRecipe(id: newRecipe.id)
        RecipeViewModel().saveRecipe(newRecipe: newRecipe)
        UserDataBase().updateUserData(for: user)
        saveImageToDocuments(image: image!, newid: oldRecipe.id)
        presenMode.wrappedValue.dismiss()
        print("Recipe saved: \(newRecipe)")
    }
}

#Preview {
    ContentView()
}
