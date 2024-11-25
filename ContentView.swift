import SwiftUI

struct ContentView: View {
    @StateObject var user = User()
    @State private var selectedTab: Tab = .home
    
    enum Tab{
        case home,search,user
    }

    var body: some View {
        TabView(selection: $selectedTab){
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Main")
                }
                .tag(Tab.home)
            SearchView()
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



class User: ObservableObject{
    @Published var state: UserState = .offline
    @Published var id: Int = 0
    @Published var name: String = ""
    init(){
        self.state = .offline
        self.id = -1
        self.name = "N/A"
    }
    func login(inputUserName: String, inputPassWord: String){
        //check username,password in database
        print("login")
        if inputUserName == "Cecilia" && inputPassWord == "123"{
            self.state = .online
            self.id = 1
            self.name = inputUserName
            print("login success")
        }
        
    }
    func logout(){
        self.state = .offline
        self.id = -1
        self.name = "N/A"
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
    
    func tryLogout(){
        user.logout()
        if user.state == .offline{
            LogoutSuccess = true
        }
    }
    
    var body: some View{
        NavigationView{
            VStack{
                Image("person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("\(user.name)")
                    .font(.headline)
                Divider()
                    .padding(10)
                Text("two navigationlink here,fav/hist")
                Text("setting navigationlink here")
                Button(action: {
                    tryLogout()
                            }) {
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


struct SearchView: View{
    @State private var searchText: String = ""
    func search(){
        searchText = "haha"
        //todo
    }
    
    var body: some View {
        NavigationView {
                Text("image/result view")
                .navigationBarTitle("Search")
        }
        .searchable(text: $searchText, prompt: "Search")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .onSubmit(of: .search){
            search()
        }

    }

    
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            Text("Home")
                .navigationTitle("Main")
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
