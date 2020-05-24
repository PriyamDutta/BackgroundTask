//
//  LoggerSetup.swift
//  BackgroundTask
//
//  Created by Priyam Dutta on 23/05/20.
//      
//

import Foundation
import XCGLogger

class LoggerSetup {
    
    static let logFile: URL = {
        return (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] ).appendingPathComponent("XCGLogger_Log.txt")
        
    }()
    
    static let logger: XCGLogger = {
        let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)
        let logDestination = FileDestination(writeToFile: LoggerSetup.logFile, identifier: "advancedLogger.fileDestination", shouldAppend: true)
        logDestination.outputLevel = .debug
        logDestination.showLogIdentifier = false
        logDestination.showFunctionName = false
        logDestination.showThreadName = false
        logDestination.showLevel = false
        logDestination.showFileName = true
        logDestination.showLineNumber = true
        logDestination.showDate = true
        logDestination.logQueue = XCGLogger.logQueue
        log.add(destination: logDestination)
        log.logAppDetails()
        return log
    }()
    
    static func getLogs(completion: (_ logString: String) -> Void) {
        do {
            let content = try String(contentsOf: LoggerSetup.logFile, encoding: .utf8)
            completion(content)
        } catch let error {
            print("Error in extracting: \(error.localizedDescription)")
        }
    }
}
