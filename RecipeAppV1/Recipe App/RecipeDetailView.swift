import SwiftUI
import UserNotifications

struct RecipeDetailView: View {
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Name
                Text(recipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold) // Thickened title

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
                    .frame(height: 200)
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
    RecipeListView()
}
