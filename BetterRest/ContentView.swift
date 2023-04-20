//
//  ContentView.swift
//  BetterRest
//
//  Created by luis armendariz on 4/13/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section{
                    Text("Desires amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section{
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount){
                        ForEach(0..<21){
                            Text("\($0) cups")
                        }
                    }
                }
                
                Section{
                    Text("Recommended Bedtime")
                        .font(.headline)
                    Text("\(calculateBedTime)")
                        .font(.largeTitle)
                }
                .navigationTitle("BetterSleep")
            }
        }
        
        var calculateBedTime: String {
            var bedTime = "Please set all input values"
            do {
                let config = MLModelConfiguration()
                let model = try SleepCalculator(configuration: config)
                
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                let hour = (components.hour ?? 0) * 60 * 60
                let minute = (components.minute ?? 0) * 60
                
                
                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                let sleepTime = wakeUp - prediction.actualSleep
                
                
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                bedTime = formatter.string(from: sleepTime)
                //            alertTitle = "Your ideal bedtime is..."
                //            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            }catch {
                alertTitle = "Error"
                alertMessage = "Sorry, something went wrong!"
                showingAlert = true
            }
            return bedTime
        }
    }
}













struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
