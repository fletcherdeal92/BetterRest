//
//  ContentView.swift
//  BetterRest
//
//  Created by Fletcher Deal on 7/14/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
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
    
    var sleepTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try sleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
             return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            return "Error"
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Recommended Bedtime")
                    .padding(.top, 25)
                Text(sleepTime)
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .padding(.bottom, 25)
                
                Form {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("When do you want to wake up?")
                            .font(.headline)
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Daily coffee intake")
                            .font(.headline)
                        Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount) {
                            ForEach(1...20, id: \.self) { i in
                                Text(i == 1 ? "1 cup" : "\(i) cups")
                            }
                        }
                    }
                }
                .navigationTitle("BetterRest")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
