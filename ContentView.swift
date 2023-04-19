import SwiftUI

struct ContentView: View {
    //  HP
    @State var hp = 0
    /* 
    Adding a task increases HP by 1 point
    Completing a task increases HP by 3 points
    Finishing a timer increases HP by 10 points
    Resetting a running timer decreases HP by 10 points 
    
     HP doesn't go below 0. Reaching or going below 0 counts as a game over and will result in a character reset
     */
    
    // Task
    struct Task: Identifiable {
        var id = UUID() 
        var name: String
        var label: String
        var priority: Int
    }
    
    @State var listOfToDos = [Task(id: UUID(), name: "Buy milk", label: "Personal", priority: 1)]
    @State var taskNames = ["Buy milk"]
    @State var toDoTitle = ""
    @FocusState var titleFocus: Bool
    @State var labelToAppend = ""
    @State var priorityToAppend = 0
    
    // Timer
    @StateObject private var timerModel = ViewModel() 
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let width: Double = 250    
    
    var body: some View {
        VStack {
            ZStack {
                Image("Landscape")
                    .scaledToFill()
                    .frame(width: .infinity)
                    .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    .padding([.bottom], 30)
            
                VStack {
                    Text("HP: " + String(hp))
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .font(.title)
                        .cornerRadius(5.0)
                    
                    Image("Character")
                        .resizable()
                        .frame(width: 200.0, height: 160.0)
                }
            }
            .frame(height: 300)            
            VStack {
                Text("\(timerModel.time)")
                    .padding()
                    .font(.system(size: 70, weight: .medium, design: .rounded))
                    .alert("Time done!", isPresented: $timerModel.showingPositiveAlert) {
                        Button("Continue", role: .cancel) {
                            hp += 10
                        }
                    }
                
                Text("\(timerModel.isBreak ? "Break" : "Work")")
                    
                
                Slider(value: $timerModel.minutes, in: 1...30, step: 1)
                    .frame(width: width)
                    .disabled(timerModel.isActive)
                    .animation(.easeInOut, value: timerModel.minutes)
                
                HStack {
                    Button {
                        timerModel.start(minutes: timerModel.minutes)
                    } label: {
                        Image(systemName: "play.circle.fill")
                    }.disabled(timerModel.isActive).font(.title)
                    
                    Button {
                        timerModel.reset()
                    } label: {
                        Image(systemName: "pause.circle.fill")
                    }
                    .tint(.red)
                    .font(.title)
                    .disabled(!timerModel.isActive)
                    .alert("Timer canceled :(", isPresented: $timerModel.showingNegativeAlert) {
                        Button("Continue", role: .cancel) {
                            if (hp <= 0) {
                                hp = 0
                            } else {
                                hp -= 10

                            }
                        }
                    }
                        
                }.frame(width:width).padding()
            }.onReceive(timer) { _ in
                timerModel.updateCountdown()
            }
            
            Divider()
                .frame(maxWidth: 720, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)

            
            TextField("What's today's adventure?", text: $toDoTitle)
                .frame(width: .infinity, height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .focused($titleFocus)
                .submitLabel(.go)
                .onSubmit {
                    listOfToDos.append(Task(id: UUID(), name: String(toDoTitle), label: labelToAppend, priority: priorityToAppend))
                    taskNames.append(toDoTitle)
                    toDoTitle = ""
                    hp += 1
                    priorityToAppend = 0
                    labelToAppend = ""
                    
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        titleFocus = true
                    }
                }
            
            HStack {
                Button {
                    priorityToAppend = 1
                } label: {
                    Image(systemName: "exclamationmark.3")
                }
                .foregroundColor(.red)
                .font(.title)
                .padding(.horizontal)
                
                Button {
                    priorityToAppend = 2
                } label: {
                    Image(systemName: "exclamationmark.2")
                }
                .foregroundColor(.orange)
                .font(.title)
                .padding(.horizontal)

                
                Button {
                    priorityToAppend = 3
                } label: {
                    Image(systemName: "exclamationmark")
                }
                .foregroundColor(.green)
                .font(.title)
                .padding(.horizontal)

                
                Divider()
                    .frame(height: 50).padding()
                
                Button {
                    labelToAppend = "Work"
                } label: {
                    Image(systemName: "building.2")
                }
                .foregroundColor(.blue)
                .font(.title)
                .padding(.horizontal)
                
                Button {
                    labelToAppend = "Personal"
                } label: {
                    Image(systemName: "person.fill")
                }
                .foregroundColor(.yellow)
                .font(.title)
                .padding(.horizontal)

        }
        
            List(listOfToDos) { task in
                HStack {
                    Button {
                        let index = taskNames.firstIndex(of: String(task.name)) ?? 0
                        taskNames.remove(at: index)
                        listOfToDos.remove(at: index)
                        hp += 3

                    } label: {
                        if (Int(task.priority) == 1) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.red)
                        } else if (Int(task.priority) == 2) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.orange)
                        } else if (Int(task.priority) == 3) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        } else {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                        }
                        
                    }
                    HStack {
                        Text(task.name)
                        Text("--")
                            .foregroundColor(.gray)
                        Text(task.label == "" ? "No label" : task.label)
                            .foregroundColor(.gray)
                    }
                }
            }.frame(maxWidth: 720)
        }
    }
}
