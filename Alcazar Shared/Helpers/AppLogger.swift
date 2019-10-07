//
//  Logger.swift
//  Alcazar
//
//  Created by Jesse Riddle on 2/6/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public protocol AppLoggerDelegate
{
    func log(message: String, logLevel: LogLevel)
}

public enum LogLevel: UInt32, Comparable, Equatable
{
    case info = 0x01
    case warning = 0x02
    case error = 0x04
    case debug = 0x08
    case trace = 0x10
    case whitespace = 0x8000
    
    public static func ==(lhs: LogLevel, rhs: LogLevel) -> Bool
    {
        return lhs == rhs
    }
    
    public static func !=(lhs: LogLevel, rhs: LogLevel) -> Bool
    {
        return lhs != rhs
    }
    
    public static func <(lhs: LogLevel, rhs: LogLevel) -> Bool
    {
        return lhs < rhs
    }
    
    public static func <=(lhs: LogLevel, rhs: LogLevel) -> Bool
    {
        return lhs <= rhs
    }
    
    public static func >(lhs: LogLevel, rhs: LogLevel) -> Bool
    {
        return lhs > rhs
    }
    
    public static func >=(lhs: LogLevel, rhs: LogLevel) -> Bool
    {
        return lhs >= rhs
    }
}

public class AppLogger
{
    public static let shared = AppLogger()
    
    private struct OutputStreamStruct
    {
        var stream: OutputStream
        var minLogLevel: LogLevel
        var maxLogLevel: LogLevel
    }
    
    private struct DelegateStruct
    {
        var delegate: AppLoggerDelegate
        var minLogLevel: LogLevel
        var maxLogLevel: LogLevel
    }
    
    private var outputStreamStructs: [OutputStreamStruct]
    private var delegateStructs: [DelegateStruct]
    
    init()
    {
        outputStreamStructs = []
        delegateStructs = []
    }
    
    func add(stream: OutputStream, minLogLevel: LogLevel, maxLogLevel: LogLevel)
    {
        outputStreamStructs.append(OutputStreamStruct(stream: stream, minLogLevel: minLogLevel, maxLogLevel: maxLogLevel))
    }
    
    func add(delegate: AppLoggerDelegate, minLogLevel: LogLevel, maxLogLevel: LogLevel) {
        delegateStructs.append(DelegateStruct(delegate: delegate, minLogLevel: minLogLevel, maxLogLevel: maxLogLevel))
    }
    
    func log(message: String, logLevel: LogLevel)
    {
        let data = [UInt8](message.utf8)
        
        for (_, o) in outputStreamStructs.enumerated() {
            if (o.minLogLevel <= logLevel && logLevel <= o.maxLogLevel) {
                o.stream.write(data, maxLength: data.count)
            }
        }
        
        for (_, o) in delegateStructs.enumerated() {
            if (o.minLogLevel <= logLevel && logLevel <= o.maxLogLevel) {
                o.delegate.log(message: message, logLevel: logLevel)
            }
        }
    }
    
    func Log(info: String) { log(message: info, logLevel: .info) }
    func Log(warning: String) { log(message: warning, logLevel: .warning) }
    func Log(error: String) { log(message: error, logLevel: .error) }
    func Log(debug: String) { log(message: debug, logLevel: .debug) }
    func Log(trace: String) { log(message: trace, logLevel: .trace) }
    
    func info(message: String)
    {
        log(message: message, logLevel: .info)
    }
    
    func warn(message: String)
    {
        log(message: message, logLevel: .warning)
    }
    
    func error(message: String)
    {
        log(message: message, logLevel: .error)
    }
    
    func debug(message: String)
    {
        log(message: message, logLevel: .debug)
    }
    
    func trace(message: String)
    {
        log(message: message, logLevel: .trace)
    }
    
    func whitespace()
    {
        log(message: "", logLevel: .whitespace)
    }
}
