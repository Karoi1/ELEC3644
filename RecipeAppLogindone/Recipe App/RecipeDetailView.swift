import SwiftUI
import UserNotifications
import AudioToolbox

struct RecipeDetailView: View {
    @ObservedObject var user: User
    @State var recipe: Recipe
    var isPreview: Bool
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
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Top Half - Fixed Image with Title and Favorite Button Overlay
                let imageName = recipe.id // Assuming images are named by ID
                ZStack(alignment: .bottom) {
                    Image(String(imageName))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height / 3) // Set height to half the screen
                        .clipped()
                        .ignoresSafeArea(edges: .horizontal) // Ensure it stretches horizontally but respects vertical safe areas
                    
                    // Title and Favorite Button Overlay
                    ZStack {
                        // Add a semi-transparent background underlay
                        Rectangle()
                            .fill(Color.black.opacity(0.2)) // Black background with 20% opacity
                            .frame(height: 40) // Set the height for the background rectangle
                            .edgesIgnoringSafeArea(.horizontal) // Stretch horizontally across the screen
                        
                        // Title and Favorite Button
                        HStack {
                            // Recipe Title
                            Text(recipe.name)
                                .font(.system(size: 24))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(radius: 5) // Add shadow for better readability
                            
                            Spacer() // Push the favorite button to the right
                            
                            // Favorite Button
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
                        .onAppear {
                            isFavorite = user.favs.contains(recipe.id)
                        }
                        .onDisappear {
                            if !isPreview{
                                updateFavorites()
                                updateHistory()
                                UserDataBase().updateUserData(for:user)
                            }
                            
                        }
                        .sheet(isPresented: $ToLoginView){
                            UserView(user: user,onLoginSuccess:{ToLoginView=false})
                        }
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 3)  // Add shadow around the button
                        }
                        .padding([.leading, .trailing], 20) // Add padding around the title and button
                    }
                    .frame(maxWidth: .infinity) // Ensure the ZStack stretches across the screen // Add padding around the title and button
                }
                
                // Bottom Half - Scrollable Content
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height / 3) // Push content below the image
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Tags with Top Padding
                            HStack {
                                ForEach(recipe.tags, id: \.self) { tag in
                                    Text(tag)
                                        .padding(5)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(5)
                                }
                            }
                            .padding([.horizontal, .top], 20) // Add top padding here

                            // Ingredients
                            Text("Ingredients")
                                .font(.headline)
                                .padding([.top, .horizontal])
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
                                .padding(.horizontal)
                            }

                            // Steps
                            Text("Steps")
                                .font(.headline)
                                .padding([.top, .horizontal], 40)
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
                                .padding(.horizontal)
                            }

                            // Timer
                            VStack(alignment: .center, spacing: 20) {
                                
                                // Timer Display
                                HStack {
                                    Spacer() // Center the label
                                    Text(timerLabel)
                                        .font(.system(size: 25, weight: .bold, design: .rounded))
                                        .foregroundColor(isTimerRunning ? .green : .gray)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.blue.opacity(0.1))
                                        )
                                    Spacer() // Center the label
                                }
                                
                                // Timer Picker
                                HStack(spacing: 15) {
                                    // Hour Picker
                                    VStack {
                                        Text("Hours")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Picker("", selection: $selectedHours) {
                                            ForEach(0..<24) { hour in
                                                Text("\(hour) h").tag(hour)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 60, height: 100) // Adjust size
                                        .clipped()
                                    }

                                    // Minute Picker
                                    VStack {
                                        Text("Minutes")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Picker("", selection: $selectedMinutes) {
                                            ForEach(0..<60) { minute in
                                                Text("\(minute) m").tag(minute)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 60, height: 100)
                                        .clipped()
                                    }

                                    // Second Picker
                                    VStack {
                                        Text("Seconds")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Picker("", selection: $selectedSeconds) {
                                            ForEach(0..<60) { second in
                                                Text("\(second) s").tag(second)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 60, height: 100)
                                        .clipped()
                                    }
                                }
                                .padding(.vertical)
                                
                                // Timer Controls
                                HStack(spacing: 20) {
                                    Spacer()
                                    Button(action: {
                                        startTimer()
                                    }) {
                                        Text(isTimerRunning ? "Stop Timer" : "Start Timer")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(isTimerRunning ? Color.red : Color.blue)
                                            .cornerRadius(10)
                                    }
                                    Spacer()
                                }
                            }
                            .padding([.horizontal, .bottom],40)
                        }
                        .padding(.bottom) // Add bottom padding for better scrolling experience
                        .background(
                            NotebookBackground() // Use the notebook background
                        )
                    }
                    .background(Color.white)
                    .cornerRadius(2, corners: [.topLeft, .topRight]) // Rounded corners for the scrollable section
                }
            }
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
                    
                    // Play a beep sound
                    AudioServicesPlaySystemSound(1005)
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

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 0.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct NotebookBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let lineSpacing: CGFloat = 40 // Spacing between the notebook lines
            let numberOfLines = Int(geometry.size.height / lineSpacing)
            
            Canvas { context, size in
                for i in 0..<numberOfLines {
                    let yPosition = CGFloat(i) * lineSpacing
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: yPosition))
                    path.addLine(to: CGPoint(x: size.width, y: yPosition))
                    
                    context.stroke(
                        path,
                        with: .color(.gray.opacity(0.19)),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [5, 5] // Dotted pattern: 5 points on, 5 points off
                        )
                    )
                }
            }
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.99)) // Light beige background
    }
}
