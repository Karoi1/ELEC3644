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
}


class UserDataBase{
    class UserData: Codable{
        var id: Int
        var name: String
        var password: String
        var favourites: [Int]
        var history: [Int]
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case password
            case favourites
            case history
        }
        
        init(id: Int, name: String, password: String, favourites: [Int], history: [Int]) {
                    self.id = id
                    self.name = name
                    self.password = password
                    self.favourites = favourites
                    self.history = history
        }
        
        
        
    }
    private var listUserData: [UserData] = []
    init(){
        loadUserFromJson()
    }
    
    private func loadUserFromJson(){
        guard let url = Bundle.main.url(forResource: "UserData", withExtension: "json") else {
                    print("User JSON file not found.")
                    return
                }
                
                do {
                    print("Load User Json success.")
                    let data = try Data(contentsOf: url)
                    let users = try JSONDecoder().decode([UserData].self, from: data)
                    self.listUserData = users
                } catch {
                    print("Error loading or decoding user data: \(error)")
                }
    }
    
    func validateUser(username: String, password: String) -> LoginResult {
        for user in listUserData {
            if user.name == username && user.password == password {
                return LoginResult(id: user.id, favs: user.favourites, history: user.history)
            }
        }
        return LoginResult(id: -1, favs: [], history: []) // 登录失败
    }
    func updateUserData(for user: User) {
        // 查找与 user.id 匹配的 UserData
        if let index = listUserData.firstIndex(where: { $0.id == user.id }) {
            // 更新 UserData 的属性
            listUserData[index].name = user.name
            listUserData[index].favourites = user.favs
            listUserData[index].history = user.history
            
            print("User data updated for user ID: \(user.id)")
        } else {
            // 如果没有找到，可能需要添加新用户或处理错误
            print("User with ID \(user.id) not found in userDataList.")
        }
        saveUserData(users: listUserData)
    }
    
    func saveUserData(users: [UserData]) {
        guard let url = Bundle.main.url(forResource: "UserData", withExtension: "json") else {
                    print("User JSON file not found.")
                    return
            }
            
            do {
                print("Load User Json success.")
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted // 美化输出
                let data = try encoder.encode(users)
                try data.write(to: url)
            } catch {
                print("Error writing user data: \(error)")
            }
    }

    // 获取应用的文档目录
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


class User: ObservableObject{
    @Published var state: UserState = .offline
    @Published var id: Int = 0
    @Published var name: String = ""
    @Published var favs: [Int] = []
    @Published var history: [Int] = []
    var userDataBase: UserDataBase = UserDataBase()
    
    
    init(){
        self.state = .offline
        self.id = -1
        self.name = "N/A"
        self.favs = []
        self.history = []
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

struct LoginView: View {
    @ObservedObject var user: User
    @State var inputUserName: String = ""
    @State var inputPassWord: String = ""
    @State var wronginfo: Bool = false
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

            }
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
        }
        .alert(isPresented: $LogoutSuccess){
            Alert(title: Text("Logout"), message: Text("Successfully logout"), dismissButton: .default(Text("OK")))
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
    }
}
