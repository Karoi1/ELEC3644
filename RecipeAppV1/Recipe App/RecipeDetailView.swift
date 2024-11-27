import SwiftUI
import UserNotifications

struct RecipeDetailView: View {
    @ObservedObject var user: User
    @State var recipe: Recipe
    @State private var checkedIngredients: Set<String> = []
    @State private var checkedSteps: Set<String> = []
    
    // Timer properties
    @State private var timerDuration: Int = 0 // Duration in seconds
    @State private var remainingTime: Int = 0 // Remaining time for the timer
    @State private var timer: Timer? // The timer object
    @State private var timerLabel: String = "__" // Timer display label
    @State private var isTimerRunning: Bool = false // Timer state

    // Picker state
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0
    @State private var isFavorite: Bool = false
    @State private var ToLoginView: Bool = false
    
    private func updateHistory() {
        if user.state == .online{
            // 删除历史记录中所有与当前食谱 ID 匹配的记录
            user.history.removeAll { $0 == recipe.id }

            // 将当前食谱的 ID 添加到历史记录的第一个索引
            user.history.insert(recipe.id, at: 0)

            print("Updated history: \(user.history)")
        }

    }
    
    private func updateFavorites() {
        if user.state == .online{
            if isFavorite{
                // 如果是收藏状态，确保 recipe id 在 favs 中
                if !user.favs.contains(recipe.id) {
                    user.favs.append(recipe.id)
                }
            } else {
                // 如果不是收藏状态，确保 recipe id 不在 favs 中
                user.favs.removeAll { $0 == recipe.id }
            }
        }

        
    }
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Name and Favorite Button
                HStack {
                    Text(recipe.name)
                        .font(.largeTitle)
                        .fontWeight(.bold) // Thickened title
                    
                    Spacer() // Push the button to the right
                    
                    Button(action: {
                        // Handle favorite action here
                        if user.state == .online {
                            isFavorite.toggle()
                        }
                        if user.state == .offline {
                            ToLoginView = true
                            print("offline will not save favs")
                        }
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(.red)// Color of the heart
                    }
                }
                .onAppear {
                    isFavorite = user.favs.contains(recipe.id)
                }
                .onDisappear {
                    updateFavorites()
                    updateHistory()
                    user.userDataBase.updateUserData(for:user)
                }
                .sheet(isPresented: $ToLoginView){
                    UserView(user: user,onLoginSuccess:{ToLoginView=false})
                }

                // Tags
                HStack {
                    ForEach(recipe.tags, id: \.self) { tag in
                        Text(tag)
                            .padding(5)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                }
                
                // Recipe Image
                let imageName = recipe.id // Assuming you have images named by ID
                Image(String(imageName))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 300)
                    .clipped()
                    .padding(.bottom, 10)

                // Ingredients
                Text("Ingredients")
                    .font(.headline)
                    .padding(.top, 10)
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    HStack {
                        Button(action: {
                            // Toggle the check state for ingredients
                            if checkedIngredients.contains(ingredient) {
                                checkedIngredients.remove(ingredient)
                            } else {
                                checkedIngredients.insert(ingredient)
                            }
                        }) {
                            Image(systemName: checkedIngredients.contains(ingredient) ? "checkmark.square.fill" : "square")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(ingredient)
                            .strikethrough(checkedIngredients.contains(ingredient), color: .black)
                    }
                }

                // Steps
                Text("Steps")
                    .font(.headline)
                    .padding(.top, 10)
                ForEach(recipe.steps, id: \.self) { step in
                    HStack {
                        Button(action: {
                            // Toggle the check state for steps
                            if checkedSteps.contains(step) {
                                checkedSteps.remove(step)
                            } else {
                                checkedSteps.insert(step)
                            }
                        }) {
                            Image(systemName: checkedSteps.contains(step) ? "checkmark.square.fill" : "square")
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(step)
                            .strikethrough(checkedSteps.contains(step), color: .black)
                    }
                }
                Spacer()
                Text("Timer: " + timerLabel)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                // Timer Input and Control
                VStack(spacing: 10) {
                    HStack {
                        // Hour Picker
                        Picker("Hours", selection: $selectedHours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour) h").tag(hour)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)

                        // Minute Picker
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute) m").tag(minute)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)

                        // Second Picker
                        Picker("Seconds", selection: $selectedSeconds) {
                            ForEach(0..<60) { second in
                                Text("\(second) s").tag(second)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)
                        
                        Button(action: {
                            startTimer()
                        }) {
                            Text(isTimerRunning ? "Stop Timer" : "Start Timer")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .padding()
        }
    }

    private func startTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            // Calculate total duration in seconds
            timerDuration = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds
            remainingTime = timerDuration
            timerLabel = "\(remainingTime) seconds left"
            isTimerRunning = true

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
                if remainingTime > 0 {
                    remainingTime -= 1
                    timerLabel = "\(remainingTime) seconds left"
                } else {
                    t.invalidate()
                    timerLabel = "Time's up!"
                    isTimerRunning = false
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        timerLabel = "Timer stopped"
    }
}

#Preview {
    ContentView()
}
