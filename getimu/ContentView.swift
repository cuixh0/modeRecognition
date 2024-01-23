//
//  ContentView.swift
//  getimu
//
//  Created by cui on 2023/12/28.
//

import SwiftUI
import CoreMotion
import SensorKit
import Foundation


struct ContentView: View {
    @State private var period = 0
    @State private var motionManager = CMMotionManager()
    @State private var prePeriod = 0
    @State private var startTimeStamp: Date?

    init() {
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    var body: some View {
            VStack {
                Text("\(period)")
                    .onAppear {
                        // Record the initial timestamp
                        startTimeStamp = Date()

                        // Clear the file and write the initial state
                        clearFile()
                        appendDataToFile()
                        
                        // Start motion updates
                        startMotionUpdates()
                    }
                    .onDisappear {
                        // Stop motion updates when the view disappears
                        stopMotionUpdates()
                    }
                         
                    .onReceive(NotificationCenter.default.publisher(for: UIDevice.proximityStateDidChangeNotification)) { _ in
                        if UIDevice.current.proximityState {
                            // Proximity sensor is close to the user
                            // Check Y-axis and Z-axis acceleration
                            if let acceleration = motionManager.accelerometerData?.acceleration {
                                if acceleration.y < -0.5 {
                                    // Proximity sensor is close, Y-axis acceleration is less than -0.5
                                    period = 2
                                } else if acceleration.y > 0.5 {
                                    // Proximity sensor is close, Y-axis acceleration is greater than 0.5
                                    period = 3
                                }
                                else{
                                    period = 0
                                }
                            }
                        }
                        else{
                            period = 0
                        }

                        // Append data to file only when the state changes
                        if prePeriod != period {
                            prePeriod = period
                            appendDataToFile()
                        }
                    }
                
                let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                
                    if let acceleration = motionManager.accelerometerData?.acceleration {
                        if abs(acceleration.z) < 0.5 && abs(acceleration.x) > 0.3 && period != 2 && period != 3{
                            period = 1
                        }
                        else if abs(acceleration.x) < 0.3 && period != 2 && period != 3{
                            period = 0
                        }
                    }
                    if prePeriod != period {
                        prePeriod = period
                        appendDataToFile()
                    }
                }
                    
                
                
                
                
                    
                
                
                
                
                
                
                // Add a button to trigger file export
                Button("Export Data") {
                    exportData()
                }
            }
        }

    func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { (acceleration, error) in
                // Handle acceleration data if needed
            }
        }
    }

    func stopMotionUpdates() {
        motionManager.stopAccelerometerUpdates()
    }

    
    
    
    func appendDataToFile() {
        guard let startTimeStamp = startTimeStamp else { return }
        
        let currentTimeStamp = Date()
        let elapsedTimeInSeconds = Int(currentTimeStamp.timeIntervalSince(startTimeStamp))

        let content = "\(elapsedTimeInSeconds), \(period)\n"
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileName = "data.csv"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)

            do {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                fileHandle.write(content.data(using: .utf8)!)
                fileHandle.closeFile()
                print("Data appended to file: \(fileURL)")
            } catch {
                print("Error appending data to file: \(error)")
            }
        }
    }


    

    func clearFile() {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileName = "data.csv"
                let fileURL = documentsDirectory.appendingPathComponent(fileName)

                do {
                    try "".write(to: fileURL, atomically: true, encoding: .utf8)
                    print("File cleared: \(fileURL)")
                } catch {
                    print("Error clearing file: \(error)")
                }
            }
        }

    func exportData() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileName = "data.csv"
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}



























































































//
//
//
//
//import SwiftUI
//import CoreMotion
//
//struct ContentView: View {
//    @State private var period = 0
//    @State var currentIndex = 0
//    var periods: [Int] = [0, 2, 0, 1, 3]
//    @State private var motionManager = CMMotionManager()
//    @State private var prePeriod = 0
//    @State private var startTimeStamp: Date?
//    @State private var timer: Timer?
//
//    init() {
//        UIDevice.current.isProximityMonitoringEnabled = true
//    }
//    
//    var body: some View {
//        VStack {
//            Text("\(period)")
//                .onAppear {
//                    // Record the initial timestamp
//                    startTimeStamp = Date()
//
//                    // Clear the file and write the initial state
//                    clearFile()
//                    appendDataToFile()
//                    
//                    // Start motion updates
//                    startMotionUpdates()
//
//                    // Start a timer to update the period every 5 seconds
//                    timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
//                        updatePeriod()
////                        appendDataToFile()
//                    }
//                }
//                .onDisappear {
//                    // Stop motion updates and the timer when the view disappears
//                    stopMotionUpdates()
//                    timer?.invalidate()
//                    timer = nil
//                }
//
//            // Add a button to trigger file export
//            Button("Export Data") {
//                exportData()
//            }
//        }
//    }
//
//    func updatePeriod() {
//        // Update period value based on your logic (e.g., cycling through an array)
//        // Here, we simply increment the period value
//        period = periods[currentIndex]
//           
//           // Check if currentIndex is at the end of the array, reset if true
//           if currentIndex == periods.count - 1 {
//               currentIndex = 0
//           } else {
//               currentIndex += 1
//           }
//    }
//
//    func startMotionUpdates() {
//        // Add your motion updates logic here
//        // Example: Start accelerometer updates
//        if motionManager.isAccelerometerAvailable {
//            motionManager.accelerometerUpdateInterval = 0.1
//            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
//                // Process accelerometer data if needed
//            }
//        }
//    }
//
//    func stopMotionUpdates() {
//        // Add your motion updates stopping logic here
//        motionManager.stopAccelerometerUpdates()
//    }
//
//    func appendDataToFile() {
//        // Add your logic to append data to the file
//        // Here, we append the period value and timestamp to a file
//        guard let timestamp = startTimeStamp else { return }
//        let data = "\(period),\(timestamp.timeIntervalSince1970)\n"
//        appendToFile(data: data)
//    }
//
//    func clearFile() {
//        // Add your logic to clear the file
//        // Here, we simply remove the existing content
//        let filePath = "yourFilePath.txt"
//        do {
//            try "".write(toFile: filePath, atomically: true, encoding: .utf8)
//        } catch {
//            print("Failed to clear file: \(error.localizedDescription)")
//        }
//    }
//
//    func appendToFile(data: String) {
//        // Add your logic to append data to the file
//        let filePath = "yourFilePath.txt"
//        do {
//            let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: filePath))
//            fileHandle.seekToEndOfFile()
//            fileHandle.write(data.data(using: .utf8)!)
//            fileHandle.closeFile()
//        } catch {
//            print("Failed to append to file: \(error.localizedDescription)")
//        }
//    }
//
//    func exportData() {
//        // Add your logic to export data if needed
//        // Here, we simply print a message
//        print("Exporting data...")
//    }
//}
