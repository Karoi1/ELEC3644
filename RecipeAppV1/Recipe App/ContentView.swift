import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject var user = User()
    @State private var selectedTab: Tab = .home
    
    enum Tab{
        case home,search,user
    }

    var body: some View {
        TabView(selection: $selectedTab){
            HomeView(user:user)
                .tabItem {
                    Image(systemName: "house")
                    Text("Main")
                }
                .tag(Tab.home)
            SearchView(user:user,photoModel: PhotoModel())
                .tabItem{
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(Tab.search)
            UserView(user:user, onLoginSuccess:{
                selectedTab = .user
            })
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Personal")
                }
                .tag(Tab.user)

        }
    }
}

enum UserState{
    case online
    case offline
}



struct LoginResult {
    var id: Int
    var favs: [Int]
    var history: [Int]
    var myRecipes: [Int]
}


class UserDataBase{
    class UserData: Codable{
        var id: Int
        var name: String
        var password: String
        var favourites: [Int]
        var history: [Int]
        var myRecipes: [Int]
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case password
            case favourites
            case history
            case myRecipes
        }
        
        init(id: Int, name: String, password: String, favourites: [Int], history: [Int],myRecipes: [Int]) {
            self.id = id
            self.name = name
            self.password = password
            self.favourites = favourites
            self.history = history
            self.myRecipes = myRecipes
        }
        
        
        
    }
    private var listUserData: [UserData] = []
    init(){
        loadUserFromJson()
    }
    
    private func loadUserFromJson() {
        let url = getDocumentsDirectory().appendingPathComponent("UserData.json")
        
        do {
            let data = try Data(contentsOf: url)
            let users = try JSONDecoder().decode([UserData].self, from: data)
            self.listUserData = users
            print("Load User JSON success.")
            for i in users{
                print("Username:\"\(i.name)\",Password:\"\(i.password)\",Favourites:\(i.favourites),History:\(i.history),MyRecipes:\(i.myRecipes)")
            }
            print(url)
        } catch {
            print("Error loading or decoding user data: \(error.localizedDescription)")
        }
    }
    
    func validateUser(username: String, password: String) -> LoginResult {
        for user in listUserData {
            if user.name == username && user.password == password {
                return LoginResult(id: user.id, favs: user.favourites, history: user.history, myRecipes: user.myRecipes)
            }
        }
        return LoginResult(id: -1, favs: [], history: [],myRecipes: []) // 登录失败
    }
    func updateUserData(for user: User) {
        // 查找与 user.id 匹配的 UserData
        if let index = listUserData.firstIndex(where: { $0.id == user.id }) {
            // 更新 UserData 的属性
            listUserData[index].name = user.name
            listUserData[index].favourites = user.favs
            listUserData[index].history = user.history
            listUserData[index].myRecipes = user.myRecipes
            
            print("User data updated for user ID: \(user.id)")
        } else {
            print("User with ID \(user.id) not found in userDataList.")
        }
        saveUserData(users: listUserData)
    }
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveUserData(users: [UserData]) {
        let url = getDocumentsDirectory().appendingPathComponent("UserData.json")

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 美化输出
            let data = try encoder.encode(users)
            try data.write(to: url)
            print("User data saved successfully to \(url.path)")
        } catch {
            print("Error writing user data: \(error.localizedDescription)")
        }
    }
    
    func registerUser(inputName: String, inputPassword: String) -> UserData {
        // 检查用户名是否已存在
        for user in listUserData {
            if user.name == inputName {
                print("Username '\(inputName)' already exists.")
                return UserData(id: -1, name: "", password: "", favourites: [], history: [],myRecipes: []) // 用户名已存在，注册失败
            }
        }
        
        // 创建新的 UserData 对象
        let newUser = UserData(id: listUserData.count + 1, name: inputName, password: inputPassword,favourites: [], history: [],myRecipes: [])
        listUserData.append(newUser)
        saveUserData(users: listUserData)
        print("User '\(inputName)' registered successfully.")
        return newUser // 注册成功
    }
}


class User: ObservableObject{
    @Published var state: UserState = .offline
    @Published var id: Int = 0
    @Published var name: String = ""
    @Published var favs: [Int] = []
    @Published var history: [Int] = []
    @Published var myRecipes: [Int] = []
    var userDataBase: UserDataBase = UserDataBase()
    
    
    init(){
        self.state = .offline
        self.id = -1
        self.name = "N/A"
        self.favs = []
        self.history = []
        self.myRecipes = []
    }
    func login(inputUserName: String, inputPassWord: String){
        //check username,password in database
        print("login")
        let result = userDataBase.validateUser(username: inputUserName, password: inputPassWord)
                if result.id != -1 {
                    self.state = .online
                    self.id = result.id
                    self.name = inputUserName
                    self.favs = result.favs
                    self.history = result.history
                    self.myRecipes = result.myRecipes
                    print("login success")
                } else {
                    print("Invalid username or password")
                }
        
    }
    func logout(){
        self.state = .offline
        self.id = -1
        self.name = "N/A"
        self.favs = []
        self.history = []
        print("logout")
    }
    
}



struct UserView: View{
    @ObservedObject var user: User
    var onLoginSuccess: () -> Void
    var body: some View {
        switch user.state{
        case .offline:
            LoginView(user:user, onLoginSuccess: onLoginSuccess)
        case .online:
            OnlineView(user:user)
        }
    }
}


import SwiftUI

struct RegisterView: View {
    @ObservedObject var user: User
    @State private var inputUserName: String = ""
    @State private var inputPassWord: String = ""
    @State private var confirmPassWord: String = "" // 新增确认密码输入
    @State private var registrationSuccess: Bool = false
    @State private var passwordsUnMatch: Bool = false // 检查密码是否匹配
    @State private var nameExists: Bool = false

    func register() {
        // 检查密码是否匹配
        guard inputPassWord == confirmPassWord else {
            passwordsUnMatch = true
            return
        }

        // 创建 UserData 对象并设置 ID 为 10
        let newUserData = UserDataBase().registerUser(inputName: inputUserName, inputPassword: inputPassWord)
        if newUserData.id == -1{
            nameExists = true
            return
        }
        // 在 User 对象中保存用户信息
        user.state = .online
        user.id = newUserData.id
        user.name = newUserData.name
        user.favs = newUserData.favourites
        user.history = newUserData.history
        
        // 注册成功
        registrationSuccess = true
        
        inputUserName = ""
        inputPassWord = ""
        confirmPassWord = ""
        passwordsUnMatch = false
    }
    var body: some View {
        NavigationView {
            VStack(spacing:5){
                Text("Register")
                    .font(.title)
                    .padding(.vertical, 10)
                HStack {
                    Spacer()
                    Text("User Name:").padding(.horizontal, 10)
                    TextField("User", text:$inputUserName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .background(Color.white.opacity(0.2))
                
                HStack {
                    Spacer()
                    Text("Password:   ").padding(.horizontal,10)
                    SecureField("Password", text:$inputPassWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .background(Color.white.opacity(0.2))
                HStack {
                    Spacer()
                    Text("Confirm:      ").padding(.horizontal,10)
                    SecureField("Password", text:$confirmPassWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .background(Color.white.opacity(0.2))
                
                Button(action: {
                                register()
                            }) {
                                HStack {
                                    Text("Register Now")
                                        .font(.headline)
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                }
                            .padding(.vertical, 10)
                if passwordsUnMatch{
                    Text("2 Inputted Passwords are not the same")
                        .foregroundColor(.red)
                }
            }
        }
        .alert(isPresented:$nameExists){
            Alert(title: Text("Username Already Exists"), message: Text("Please choose another username"), dismissButton: .default(Text("OK")))
        }
    }
}

struct LoginView: View {
    @ObservedObject var user: User
    @State var inputUserName: String = ""
    @State var inputPassWord: String = ""
    @State var wronginfo: Bool = false
    @State private var showRegisterView: Bool = false
    var onLoginSuccess: () -> Void
    
    func tryLogin(){
        user.login(inputUserName: inputUserName, inputPassWord: inputPassWord)
        if user.state == .offline{
            wronginfo = true
            inputPassWord = ""
        }else{
            onLoginSuccess()
            inputUserName = ""
            inputPassWord = ""
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing:5){
                Text("Login")
                    .font(.title)
                    .padding(.vertical, 10)
                HStack {
                    Spacer()
                    Text("User Name:").padding(.horizontal, 10)
                    TextField("User", text:$inputUserName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .background(Color.white.opacity(0.2))
                
                HStack {
                    Spacer()
                    Text("Password:   ").padding(.horizontal,10)
                    SecureField("Password", text:$inputPassWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .background(Color.white.opacity(0.2))

                
                Button(action: {
                                tryLogin()
                            }) {
                                HStack {
                                    Text("Login")
                                        .font(.headline)
                                    Image(systemName: "paperplane.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                }
                            .padding(.vertical, 10)
                NavigationLink(destination: RegisterView(user: user)) {
                    Text("Do not have an account? Register now")
                }
                .padding(.vertical, 10)
                
            }
            .navigationTitle("Login")
            
        }
        .alert(isPresented:$wronginfo){
            Alert(title: Text("Wrong Information"), message: Text("Please check your Username and Password"), dismissButton: .default(Text("OK")))
        }
    }


}
struct OnlineView: View{
    @ObservedObject var user: User
    @State var LogoutSuccess: Bool = false
    var viewModel = RecipeViewModel()
    
    
    func tryLogout(){
        user.logout()
        if user.state == .offline{
            LogoutSuccess = true
        }
    }
    
    var body: some View{
        NavigationView{
            VStack{
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    .shadow(radius: 5)

                Text("\(user.name)")
                    .font(.headline)
                Divider()
                    .padding(10)
                
                // NavigationLink for Favourites
                NavigationLink(destination: RecipeListView(user:user,recipeID: user.favs)) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("View Favourites")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .contentShape(Rectangle())
                    
                }
                .buttonStyle(PlainButtonStyle())
                                
                // NavigationLink for History
                NavigationLink(destination: RecipeListView(user: user, recipeID: user.history)) {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        Text("View History")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                
                // NavigationLink for MyRecipe
                NavigationLink(destination: MyRecipeView(user: user)) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.green)
                        Text("My Recipe")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .contentShape(Rectangle())
                }
                
                Text("setting navigationlink here")
                
                Button(action: {
                    tryLogout()
                            })
                {
                    HStack {
                        Text("Logout")
                            .font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                    .padding(.vertical, 10)
                    
            }
            .navigationTitle("Personal")
        }
        .alert(isPresented: $LogoutSuccess){
            Alert(title: Text("Logout"), message: Text("Successfully logout"), dismissButton: .default(Text("OK")))
        }
    }
}

struct AddRecipeView: View {
    //TODO: add a image picker
    @ObservedObject var newRecipe: Recipe
    @State private var recipeName: String = ""
    @State private var tags: [String] = [""]
    @State private var ingredients: [String] = [""]
    @State private var steps: [String] = [""]
    var onSuccess : () -> Void
    
    var body: some View {
        NavigationView {
            Form {
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
                    
                    // 空标签输入框和加号按钮
                    HStack {
                        Button(action: addTag) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("Add a new tag")
                            .opacity(0.2)
                            .onSubmit {
                                addTag()
                            }
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
                    
                    // 空成分输入框和加号按钮
                    HStack {
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("Add a new ingredient")
                            .opacity(0.2)
                            .onSubmit {
                                addIngredient()
                            }
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
                    
                    // 空步骤输入框和加号按钮
                    HStack {
                        Button(action: addStep) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Text("Add a new step")
                            .opacity(0.2)
                            .onSubmit {
                                addStep()
                            }
                    }
                }
                
                Button(action: saveRecipe) {
                    Text("Save Recipe")
                }
                .disabled(recipeName.isEmpty || tags.contains(where: { $0.isEmpty }) || ingredients.contains(where: { $0.isEmpty }) || steps.contains(where: { $0.isEmpty }))
            }
            .navigationTitle("Add Recipe")
        }
    }
    
    private func addTag() {
        tags.append("")
    }
    
    private func removeTag(at index: Int) {
        tags.remove(at: index)
    }
    
    private func addIngredient() {
        ingredients.append("")
    }
    
    private func removeIngredient(at index: Int) {
        ingredients.remove(at: index)
    }
    
    private func addStep() {
        steps.append("")
    }
    
    private func removeStep(at index: Int) {
        steps.remove(at: index)
    }
    
    private func saveRecipe() {
        newRecipe.name = recipeName
        newRecipe.tags = tags.filter { !$0.isEmpty }
        newRecipe.ingredients = ingredients.filter { !$0.isEmpty }
        newRecipe.steps = steps.filter { !$0.isEmpty }
        
        // 这里可以添加代码将食谱保存为 JSON 或存储到您的数据源
        onSuccess()
        print("Recipe saved: \(newRecipe)")
    }
}

struct MyRecipeView: View{
    @ObservedObject var user: User
    @State private var newRecipe: Recipe = Recipe(id: 0, name: "", tags: [], ingredients: [], steps: [])
    @State private var showingAddRecipe: Bool = false
    
    var body: some View {
        NavigationView{
            RecipeListView(user:user,recipeID: user.myRecipes)
                .navigationTitle("My Recipes")
                .navigationBarItems(trailing: Button(action: {
                                showingAddRecipe = true
                            }) {
                                Text("Add Recipe")
                                Image(systemName: "plus")
                            })
                            .sheet(isPresented: $showingAddRecipe) {
                                AddRecipeView(newRecipe: newRecipe,onSuccess:{showingAddRecipe = false})
                            }
        }
    }
    
}

struct HomeView: View {
    @ObservedObject var user: User
    let list = [1,2,3,4,5,6,7,8,9,10,11]
    var body: some View {
        NavigationView {
            RecipeListView(user:user,recipeID: list)
                .navigationTitle("Main menu")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Setting")
                .navigationTitle("Setting")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        //MyRecipeView(user: )
        //AddRecipeView(newRecipe:Recipe(id: 0, name: "", tags: [], ingredients: [], steps: []))
    }
}
