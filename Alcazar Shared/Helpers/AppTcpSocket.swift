//
//  AppSocket.swift
//  Alcazar
//
//  Created by Jesse Riddle on 4/11/17.
//  Copyright © 2017 Orkey. All rights reserved.
//

import Foundation

typealias AppTcpSocketReceiveHandler = (Data, Int) -> Void
typealias AppTcpSocketOpenHandler = () -> Void
typealias AppTcpSocketCloseHandler = () -> Void
typealias AppTcpSocketErrorHandler = () -> Void

protocol AppTcpSocketDelegate
{
    var Logger: Plogger { get }
    
    func SocketReceiveHandler(data: Data, len: Int) -> Void
    func SocketOpenHandler()
    func SocketCloseHandler()
    func SocketErrorHandler()
}

class AppTcpSocket: NSObject, StreamDelegate
{
    public let BufLen = 4096
    public var Delegate: AppTcpSocketDelegate?
    //public var Endianness: EndianType = .Unknown
    
    private var iStreamOpened: Bool = false
    private var oStreamOpened: Bool = false
    
    private var iStream: InputStream?
    private var oStream: OutputStream?
    
    private var data: Data
    
    override init()
    {
        self.data = Data()
        super.init()
    }

    //init(endianness: EndianType)
    //{
    //    self.data = Data()
    //    self.Endianness = endianness
    //    super.init()
    //}
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event)
    {
        switch (eventCode) {
        case Stream.Event.openCompleted:
            if aStream == iStream {
                iStreamOpened = true
            }
            else if aStream == oStream {
                oStreamOpened = true
            }
            
            if self.Delegate != nil && self.iStreamOpened && self.oStreamOpened {
                self.Delegate!.SocketOpenHandler()
            }
            break
        case Stream.Event.hasBytesAvailable:
            if aStream == iStream && iStreamOpened {
                let bufLen = self.BufLen
                var buf = [UInt8](repeating: 0, count: bufLen)
                self.data = Data()
                //while iStream!.hasBytesAvailable {
                    //var pBuf = UnsafeBufferPointer(start: buf.withUnsafeBytes { $0 }, count: buf.count)
                let len = iStream!.read(&buf, maxLength: bufLen)
                if 0 < len {
                    self.data.append(&buf, count: len)
                    
                    if self.Delegate != nil && Pmsg.HeaderSizeInBytes <= len {
                        self.Delegate!.SocketReceiveHandler(data: self.data, len: len)
                    }
                }
                //}
            }
            break
        case Stream.Event.hasSpaceAvailable:
            
            break
        case Stream.Event.errorOccurred:
            if aStream == iStream {
                iStreamOpened = false
            }
            
            if aStream == oStream {
                oStreamOpened = false
            }
            
            if self.Delegate != nil {
                self.Delegate!.SocketErrorHandler()
            }
            break
        case Stream.Event.endEncountered:
            if aStream == iStream {
                iStreamOpened = false
            }
            
            if aStream == oStream {
                oStreamOpened = false
            }
            
            if self.Delegate != nil {
                self.Delegate!.SocketCloseHandler()
            }
            break
        default:
            break
        }
    }
    
    func ConnectTo(host: String, port: Int)
    {
        let cfHostname = host as CFString
        let cfPort = UInt32(port)
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        //self.socket_ = TCPClient(address: hostname, port: port32)
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, cfHostname, cfPort, &readStream, &writeStream)
        
        self.iStream = readStream!.takeRetainedValue()
        self.oStream = writeStream!.takeRetainedValue()
        
        self.iStream!.delegate = self
        self.oStream!.delegate = self
        
        self.iStream!.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        self.oStream!.schedule(in: RunLoop.current, forMode: .defaultRunLoopMode)
        
        self.iStream!.open()
        self.oStream!.open()
    }
    
    func Send(data: Data)
    {
        //var buffer = data
        _ = data.withUnsafeBytes { oStream!.write($0, maxLength: data.count) }
    }
    
    func Close()
    {
        if iStreamOpened {
            iStream!.close()
            iStreamOpened = false
            iStream!.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
        }
        iStream = nil
        
        if oStreamOpened {
            oStream!.close()
            oStreamOpened = false
            oStream!.remove(from: RunLoop.current, forMode: .defaultRunLoopMode)
        }
        oStream = nil
    }
    
    func IsOpen() -> Bool
    {
        return iStreamOpened && oStreamOpened
    }
}
