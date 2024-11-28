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
    var img: String
    var id: Int
    var favs: [Int]
    var history: [Int]
    var myRecipes: [Int]
}


class UserDataBase{
    class UserData: Codable{
        var img: String
        var id: Int
        var name: String
        var password: String
        var favourites: [Int]
        var history: [Int]
        var myRecipes: [Int]
        
        private enum CodingKeys: String, CodingKey {
            case img
            case id
            case name
            case password
            case favourites
            case history
            case myRecipes
        }
        
        init(img: String, id: Int, name: String, password: String, favourites: [Int], history: [Int],myRecipes: [Int]) {
            self.img = img
            self.id = id
            self.name = name
            self.password = password
            self.favourites = favourites
            self.history = history
            self.myRecipes = myRecipes
        }
        
        
        
    }
    var listUserData: [UserData] = []
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
                print("IMG:\"\(i.img)\"ID: \"\(i.id)\",Username:\"\(i.name)\",Password:\"\(i.password)\",Favourites:\(i.favourites),History:\(i.history),MyRecipes:\(i.myRecipes)")
            }
            print(url)
        } catch {
            print("Error loading or decoding user data: \(error.localizedDescription)")
        }
    }
    
    func validateUser(username: String, password: String) -> LoginResult {
        for user in listUserData {
            if user.name == username && user.password == password {
                return LoginResult(img: user.img, id: user.id, favs: user.favourites, history: user.history, myRecipes: user.myRecipes)
            }
        }
        return LoginResult(img: "U1", id: -1, favs: [], history: [],myRecipes: []) // 登录失败
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
        listUserData = listUserData.sorted(by: { $0.id < $1.id })
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
                return UserData(img: "U1", id: -1, name: "", password: "", favourites: [], history: [],myRecipes: []) // 用户名已存在，注册失败
            }
        }
        
        // 创建新的 UserData 对象
        let newUser = UserData(img: "U"+String(Int.random(in: 1...5)), id: UserDataBase().findSpace(), name: inputName, password: inputPassword,favourites: [], history: [],myRecipes: [])
        listUserData.append(newUser)
        saveUserData(users: listUserData)
        print("User '\(inputName)' registered successfully.")
        return newUser // 注册成功
    }
    
    func findSpace() -> Int{
        let sortedIds = listUserData.map{$0.id}.sorted()
        if sortedIds.count<1{
            return 1
        }
        if sortedIds.count==1{
            return sortedIds.first!+1
        }
        if let first = sortedIds.first,first>1{
            return 1
        }
        for i in 1..<sortedIds.count-1{
            if sortedIds[i+1] - sortedIds[i]>1{
                return sortedIds[i]+1
            }
        }
        return sortedIds.count>0 ? sortedIds.last!+1 : 0
    }
}


class User: ObservableObject{
    @Published var state: UserState = .offline
    @Published var img: String = ""
    @Published var id: Int = 0
    @Published var name: String = ""
    @Published var favs: [Int] = []
    @Published var history: [Int] = []
    @Published var myRecipes: [Int] = []
    
    
    init(){
        self.img = ""
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
        let result = UserDataBase().validateUser(username: inputUserName, password: inputPassWord)
                if result.id != -1 {
                    self.state = .online
                    self.img = result.img
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
        UserDataBase().updateUserData(for: self)
        self.state = .offline
        self.img = ""
        self.id = -1
        self.name = "N/A"
        self.favs = []
        self.history = []
        self.myRecipes = []
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
    @State private var confirmPassWord: String = ""
    @State private var registrationSuccess: Bool = false
    @State private var passwordsUnMatch: Bool = false
    @State private var nameExists: Bool = false

    func register() {
        // 检查密码是否匹配
        guard inputPassWord == confirmPassWord else {
            passwordsUnMatch = true
            return
        }
        let newUserData = UserDataBase().registerUser(inputName: inputUserName, inputPassword: inputPassWord)
        if newUserData.id == -1{
            nameExists = true
            return
        }
        user.state = .online
        user.img = newUserData.img
        user.id = newUserData.id
        user.name = newUserData.name
        user.favs = newUserData.favourites
        user.history = newUserData.history
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
    
    func tryLogout(){
        user.logout()
        if user.state == .offline{
            LogoutSuccess = true
        }
    }
    func rollImage(){
        user.img = "U"+String(Int.random(in:1...5))
        UserDataBase().updateUserData(for: user)
    }
    
    var body: some View{
        NavigationView{
            VStack{
                if user.img != ""{
                    Button(action:rollImage){
                        Image(user.img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                            .shadow(radius: 5)
                    }
                    
                }else{
                    Button(action:rollImage){
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                            .shadow(radius: 5)
                    }
                }
                Text("UserName:\(user.name)")
                    .font(.headline)
                Divider()
                    .padding(10)
                
                // NavigationLink for Favourites
                NavigationLink(destination: RecipeListView(user:user,recipeID: user.favs,Editable: false).navigationTitle("Favourite Recipe")) {
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
                NavigationLink(destination: RecipeListView(user: user, recipeID: user.history,Editable: false).navigationTitle("History")) {
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



struct MyRecipeView: View{
    @ObservedObject var user: User
    
    var body: some View {
        RecipeListView(user:user,recipeID: user.myRecipes,Editable: true)
            .navigationTitle("My Recipes")
            .navigationBarItems(trailing: NavigationLink(destination: AddRecipeView(user:user)) {
                Text("Upload Recipe")
                Image(systemName: "plus")
                    
                })
        }

    
}


struct debugView: View{
    var user: User = User()
    var body: some View{
        VStack{
            Button("clean recipe"){
                let list = Array(RecipeViewModel().recipes.prefix(26))
                RecipeViewModel().DebugUpdate(save: list)
            }
            Button("clean user"){
                UserDataBase().saveUserData(users: [])
            }
            Button("Clear directory"){
                clearDocumentsDirectory()
            }
        }
    }
    func clearDocumentsDirectory() {
        let fileManager = FileManager.default
        
        // Get the URL for the documents directory
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                // Get the contents of the documents directory
                let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
                
                // Loop through each file and remove it
                for fileURL in fileURLs {
                    try fileManager.removeItem(at: fileURL)
                }
                print("Documents directory cleared.")
            } catch {
                print("Error clearing documents directory: \(error)")
            }
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
extension Image {
    func toUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        // 设置视图的大小
        let targetSize = CGSize(width: 300, height: 300) // 根据需要调整大小
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        debugView()
        //AddRecipeView(user:User())
        ContentView()
        //MyRecipeView(user: )
        //AddRecipeView(newRecipe:Recipe(id: 0, name: "", tags: [], ingredients: [], steps: []))
    }
}
