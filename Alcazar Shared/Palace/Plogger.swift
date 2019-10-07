//
//  PalaceLogger.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/9/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

public protocol PloggerDelegate
{
    func Log(message: Pmessage) //String, logLevel: PmessageType)
}

/*
public func ==(lhs: PmessageType, rhs: PmessageType) -> Bool { return lhs == rhs }
public func <=(lhs: PmessageType, rhs: PmessageType) -> Bool { return lhs <= rhs }
public func >=(lhs: PmessageType, rhs: PmessageType) -> Bool { return lhs >= rhs }
public func <(lhs: PmessageType, rhs: PmessageType) -> Bool { return lhs < rhs }
public func >(lhs: PmessageType, rhs: PmessageType) -> Bool { return lhs > rhs }
*/

public class Plogger
{
    private struct OutputStreamStruct
    {
        var Stream: OutputStream
        var MinLogLevel: PmessageType
        var MaxLogLevel: PmessageType
    }
    
    private struct DelegateStruct
    {
        var Delegate: PloggerDelegate
        var MinLogLevel: PmessageType
        var MaxLogLevel: PmessageType
    }
    
    private struct ReceiverStruct
    {
        var Receiver: PlogReceiver
        var MinLogLevel: PmessageType
        var MaxLogLevel: PmessageType
    }
    
    private var outputStreamStructs: [OutputStreamStruct]
    private var delegateStructs: [DelegateStruct]
    private var receiverStructs: [ReceiverStruct]
    
    typealias PlogReceiver = (Pmessage) -> Void
    public var store: [Pmessage]
    
    init()
    {
        outputStreamStructs = []
        delegateStructs = []
        receiverStructs = []
        store = []
    }
    
    func Add(stream: OutputStream, minLogLevel: PmessageType, maxLogLevel: PmessageType)
    {
        outputStreamStructs.append(OutputStreamStruct(Stream: stream, MinLogLevel: minLogLevel, MaxLogLevel: maxLogLevel))
    }
    
    func Add(delegate: PloggerDelegate, minLogLevel: PmessageType, maxLogLevel: PmessageType) {
        delegateStructs.append(DelegateStruct(Delegate: delegate, MinLogLevel: minLogLevel, MaxLogLevel: maxLogLevel))
    }
    
    func Add(receiver: @escaping PlogReceiver, minLogLevel: PmessageType, maxLogLevel: PmessageType)
    {
        receiverStructs.append(ReceiverStruct(Receiver: receiver, MinLogLevel: minLogLevel, MaxLogLevel: maxLogLevel))
    }
    
    func Log(User: Puser?, Message: String, LogLevel: PmessageType)
    {
        let actualMessage: String //Message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if User == nil {
            actualMessage = Message
        }
        else {
            //actualMessage = "\(User!.Username): \(Message)"
            actualMessage = Message
        }
        let bytes = [UInt8](actualMessage.utf8)
        // TODO windowsCP1252
        //let data = Data(bytes: bytes)
        let plogMessage = Pmessage(user: User, content: actualMessage, type: LogLevel)
        self.store.append(plogMessage)
        
        for (_, o) in outputStreamStructs.enumerated() {
            if (o.MinLogLevel.rawValue <= LogLevel.rawValue && LogLevel.rawValue <= o.MaxLogLevel.rawValue) {
                o.Stream.write(bytes, maxLength: bytes.count)
            }
        }
        
        for (_, o) in delegateStructs.enumerated() {
            if (o.MinLogLevel.rawValue <= LogLevel.rawValue && LogLevel.rawValue <= o.MaxLogLevel.rawValue) {
                o.Delegate.Log(message: plogMessage) //actualMessage) //, logLevel: LogLevel)
            }
        }
        
        for (_, o) in receiverStructs.enumerated() {
            if o.MinLogLevel.rawValue <= LogLevel.rawValue && LogLevel.rawValue <= o.MaxLogLevel.rawValue {
                o.Receiver(plogMessage)
            }
        }
    }
    
    func Log(info: String) { Log(User: nil, Message: info, LogLevel: .Info) }
    func Log(warning: String) { Log(User: nil, Message: warning, LogLevel: .Warning) }
    func Log(error: String) { Log(User: nil, Message: error, LogLevel: .Error) }
    func Log(debug: String) { Log(User: nil, Message: debug, LogLevel: .Debug) }
    func Log(trace: String) { Log(User: nil, Message: trace, LogLevel: .Trace) }
    func Log(user: Puser?, say: String) { Log(User: user, Message: say, LogLevel: .Say) }
    func Log(user: Puser?, whisper: String) { Log(User: user, Message: whisper, LogLevel: .Whisper) }
    func Log(system: String) { Log(User: nil, Message: system, LogLevel: .System) }
}
