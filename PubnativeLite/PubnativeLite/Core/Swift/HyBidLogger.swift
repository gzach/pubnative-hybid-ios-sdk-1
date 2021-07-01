//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

@objc
public enum HyBidLogLevel: Int {
    case None
    case Error
    case Warning
    case Info
    case Debug
}

@objc
public class HyBidLogger: NSObject {
    
    public static var logLevel: HyBidLogLevel = .Info
    
    @objc(setLogLevel:)
    public static func setLogLevel(_ logLevel: HyBidLogLevel) {
        let levelNames = [
            "None",
            "Error",
            "Warning",
            "Info",
            "Debug",
        ]
        
        let levelName = levelNames[logLevel.rawValue]
        print("HyBid Logger: Log level set to ", levelName)
        HyBidLogger.logLevel = logLevel
    }
    
    @objc
    public static func errorLog(fromClass className: String, methodName: String, message: String) {
        if (logLevel.rawValue >= HyBidLogLevel.Error.rawValue) {
            internalLog(fromClass: className, methodName: methodName, message: message, logLevel: .Error)
        }
    }
    
    @objc
    public static func warningLog(fromClass className: String, methodName: String, message: String) {
        if (logLevel.rawValue >= HyBidLogLevel.Warning.rawValue) {
            internalLog(fromClass: className, methodName: methodName, message: message, logLevel: .Warning)
        }
    }
    
    @objc
    public static func infoLog(fromClass className: String, methodName: String, message: String) {
        if (logLevel.rawValue >= HyBidLogLevel.Info.rawValue) {
            internalLog(fromClass: className, methodName: methodName, message: message, logLevel: .Info)
        }
    }
    
    @objc
    public static func debugLog(fromClass className: String, methodName: String, message: String) {
        if (logLevel.rawValue >= HyBidLogLevel.Debug.rawValue) {
            internalLog(fromClass: className, methodName: methodName, message: message, logLevel: .Debug)
        }
    }
    
    static func internalLog(fromClass className: String, methodName: String, message: String, logLevel: HyBidLogLevel) {
        
        var logLevelString = "Error"
        switch logLevel {
            case .Error: logLevelString = "Error"
            case .Info: logLevelString = "Info"
            case .Warning: logLevelString = "Warning"
            default: logLevelString = "Debug"
        }
        
        print("\n ----------------------- \n [LOG TYPE]: \(logLevelString)\n [CLASS]: \(className)\n [METHOD]: \(methodName) \n [MESSAGE]: \(message)\n -----------------------");
    }
}
