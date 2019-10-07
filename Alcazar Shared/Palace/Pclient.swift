//
//  Pclient.swift
//  Alcazar
//
//  Created by Jesse Riddle on 2/5/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public protocol ServerListDelegate {
    func Update()
}

public protocol PclientDelegate {
    var Client: Pclient? { get set }
}

public protocol RoomViewControllerDelegate {
    func SetBackground(image: Pimage)
    func UpdateUsers()
}

public enum PclientConnectionState: UInt32 {
    case Disconnected = 0
    case Handshaking = 1
    case Connected = 2
}

public class Pclient: AppTcpSocketDelegate {
    public static let MaxUsernameLen = 31
    public static let MaxWizpassLen = 31
    public static let ClientIdent = "PC4237" //"AZ1000"
    
    public var Logger: Plogger
    public var ConnectionState: PclientConnectionState
    
    public var Username: String {
        get {
            return self.User.Username
        }
        set {
            self.User.Username = newValue
        }
    }
    public var UsernameLen: Int {
        get {
            return self.User.Username.length
        }
    }
    
    public var Address: String?
    public var Hostname: String?
    public var Port: Int?
    public var Wizpass: String?
    public var User: Puser
    public var SelectedUser: Puser?
    public var Room: Proom?
    public var Server: Pserver?
    
    // Delegates
    public var RoomViewControllerDelegate: RoomViewControllerDelegate?
    public var ServerUserListDelegate: ServerListDelegate?
    public var ServerRoomListDelegate: ServerListDelegate?
    
    private var crypto: Pcrypto
    private var socket: AppTcpSocket
    private var pmsg: Pmsg?
    private var regCounter: UInt32
    private var regCrc: UInt32
    private var puidCounter: UInt32
    private var puidCrc: UInt32
    private var puidChanged: Bool
    private var serverVersion: UInt32?
    var httpServer: String?
    
    func resetState()
    {
        self.socket.Close()
        self.socket.Delegate = self
        
        //self.Logger = Plogger()
        self.ConnectionState = .Disconnected
        self.Server = nil
        self.User = Puser()
        self.User.Color = 0
        self.User.Face = 0
        self.User.X = 0
        self.User.Y = 0
        
        if self.Room != nil {
            self.Room!.UserList.removeAll()
        }
        
        if self.Server != nil {
            self.Server!.UserList.removeAll()
            self.Server!.RoomList.removeAll()
        }
        
        if self.RoomViewControllerDelegate != nil {
            self.RoomViewControllerDelegate!.UpdateUsers()
            //self.RoomViewControllerDelegate!.SetBackground(image: nil)
        }
        
        //self.crypto = Pcrypto()
        self.crypto.ResetState()
        //self.pmsg = nil
        
        self.puidChanged = false
        self.puidCounter = 0xf5dc385e
        self.puidCrc = 0xc144c580
        self.regCounter = 0xcf07309c
        self.regCrc = 0x5905f923
        
        self.User.Username = "Alcazar User"
        self.Wizpass = ""
    }
    
    init(connectionState: PclientConnectionState)
    {
        self.Logger = Plogger()
        self.ConnectionState = connectionState
        self.Server = nil
        self.User = Puser()
        self.User.Color = 1
        self.User.Face = 1
        self.User.X = 0
        self.User.Y = 0
        self.Room = nil
        
        self.crypto = Pcrypto()
        self.pmsg = nil
        
        self.puidChanged = false
        self.puidCounter = 0xf5dc385e
        self.puidCrc = 0xc144c580
        self.regCounter = 0xcf07309c
        self.regCrc = 0x5905f923
        
        self.User.Username = "Alcazar User"
        self.Wizpass = ""
        
        self.socket = AppTcpSocket()
        self.socket.Delegate = self
    }
    
    convenience init()
    {
        self.init(connectionState: .Disconnected)
    }
    
    public func GotoRoom(id: UInt16)
    {
        if self.ConnectionState != .Connected { return }
        
        self.Room!.UserList.removeAll()
        
        self.User.RoomId = id
        //self.RoomViewControllerDelegate!.Add(userSelf: self.UserSelf)
        self.send(pmsg: PmsgGotoRoom(TargetEndianness: self.Server!.Endianness, RoomId: id))
    }
    
    public func Move(x: UInt16, y: UInt16)
    {
        if self.ConnectionState != .Connected { return }
        
        self.User.X = x
        self.User.Y = y
        //self.Logger.Log(debug: "Move self to (\(self.User.X!), \(self.User.Y!))")
        self.send(pmsg: PmsgMovement(TargetEndianness: self.Server!.Endianness, X: x, Y: y))
        
        if self.RoomViewControllerDelegate != nil {
            //self.Logger.Log(debug: "Invalidating view due to self user move.")
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    public func RequestServerRoomList()
    {
        if self.ConnectionState != .Connected { return }
        
        self.send(pmsg: PmsgServerRoomList(TargetEndianness: self.Server!.Endianness))
    }
    
    public func RequestServerUserList()
    {
        if self.ConnectionState != .Connected { return }
        
        self.send(pmsg: PmsgServerUserList(TargetEndianness: self.Server!.Endianness))
    }
    
    public func RequestServerRoomAndServerUsersLists()
    {
        if self.ConnectionState != .Connected { return }
        
        let serverRoomListPmsg = PmsgServerRoomList(TargetEndianness: self.Server!.Endianness)
        
        let serverUserListPmsg = PmsgServerUserList(TargetEndianness: self.Server!.Endianness)
        
        var pmsgs: [Pmsg] = []
        pmsgs.append(serverRoomListPmsg)
        pmsgs.append(serverUserListPmsg)
        
        self.send(pmsgs: pmsgs)
    }
    
    public func RoomChat(message: String)
    {
        if self.ConnectionState != .Connected { return }
        
        if message.length <= 0 { return }
        
        if (message.substring(to: "'ping".length) == "'ping") {
            self.Ping()
        }
        else if (message.substring(to :"'signoff".length) == "'signoff") {
            self.SignOff()
        }
        else if (message.substring(to: "'gotoroom".length) == "'gotoroom") {
            let mSplit = message.components(separatedBy: " ")
            if 1 < mSplit.count {
                let roomId = UInt16(mSplit[1])
                self.GotoRoom(id: roomId!)
            }
        }
        else if (message.substring(to: "'who".length) == "'who") {
            for user in self.Room!.UserList {
                self.Logger.Log(system: "\(user.Username) (\(user.Id!)) is here.")
            }
        }
        else if (message.substring(to: "'rooms".length) ==
            "'rooms") {
            self.Logger.Log(system: "Listing all rooms...")
            for room in self.Server!.RoomList {
                self.Logger.Log(system: "\(room.Name!) (\(room.UserCount!))")
            }
        }
        else if (message.substring(to: "'users".length) == "'users") {
            self.Logger.Log(system: "Listing all users...")
            for user in self.Server!.UserList {
                self.Logger.Log(system: "\(user.Username) (\(user.Id!)) is in (<RoomName>).")
            }
        }
        else if (message.substring(to: "'w ".length) == "'w ") {
            let mSplit = message.components(separatedBy: " ")
            let toUserId: UInt32?
            if 1 < mSplit.count {
                toUserId = UInt32(mSplit[1])
                //self.send(pmsg: PmsgGotoRoom(TargetEndianness: self.Server.Endianness, RoomId: roomId!))
            }
            else {
                toUserId = nil
            }
            
            let messageOffset = mSplit[0].length + mSplit[1].length + 2
            if toUserId != nil && messageOffset < message.length {
                let xwhisPmsg = PmsgXWhisper(TargetEndianness: self.Server!.Endianness, Ref: self.User.Id!, ToUserId: toUserId!, Message: message.substring(from: messageOffset), crypto: self.crypto)
                self.send(pmsg: xwhisPmsg)
            }
        }
        else {
            let xtalkPmsg = PmsgXTalk(TargetEndianness: self.Server!.Endianness, Ref: self.User.Id!, Message: message, crypto: self.crypto)
            self.send(pmsg: xtalkPmsg)
        }
    }
    
    public func Ping()
    {
        self.sendPing()
    }
    
    public func SignOff()
    {
        if self.ConnectionState != .Connected { return }
        
        self.send(pmsg: PmsgUserLeaving(TargetEndianness: self.Server!.Endianness))
    }
    
    func imageLoaded(sender: Any)
    {
        let image = sender as! Pimage
        
        self.Logger.Log(system: "Image loaded: \(self.httpServer!)/\(image.Name!)")
    }
    
    func backgroundImageLoaded(sender: Any)
    {
        let image = sender as! Pimage
        
        self.Logger.Log(system: "Background loaded: \(self.httpServer!)\(image.Name!)")
        
        if self.RoomViewControllerDelegate != nil {
            self.RoomViewControllerDelegate!.SetBackground(image: image)
        }
    }
    
    func propLoaded(sender: Any)
    {
        
    }
    
    private func sendPing()
    {
        if self.ConnectionState != .Connected { return }
        self.Logger.Log(system: "Ping!")
        
        self.send(pmsg: PmsgPing(TargetEndianness: self.Server!.Endianness))
        
        // TODO reset ping timer?
        //self.PingTimer
    }
    
    private func performHandshake(pmsg: Pmsg)
    {
        if (self.ConnectionState == .Handshaking)
        {
            self.Logger.Log(debug: "Performing handshake")
            switch (pmsg.Id!) {
            case .UnknownServer:
                self.Server!.Endianness = .Unknown
                self.User.Id = pmsg.Ref!
                self.Logger.Log(debug: "My user Id is \(self.User.Id!)")
                self.Logger.Log(error: "Server endianness is unknown")
                break
            case .LittleEndianServer:
                self.Server!.Endianness = .LittleEndian
                self.User.Id = CFSwapInt32BigToHost(pmsg.Ref!)
                self.Logger.Log(debug: "My user Id is \(self.User.Id!)")
                self.Logger.Log(debug: "Server is little endian")
                break
            case .BigEndianServer:
                self.Server!.Endianness = .BigEndian
                self.User.Id = CFSwapInt32BigToHost(pmsg.Ref!)
                self.Logger.Log(debug: "My user Id is \(self.User.Id!)")
                self.Logger.Log(debug: "Server is big endian")
                break
            default:
                self.Server!.Endianness = .Unknown
                self.User.Id = pmsg.Ref!
                self.Logger.Log(debug: "My user Id is \(self.User.Id!)")
                self.Logger.Log(debug: "Server endianness is unknown")
                break
            }
            
            pmsg.TargetEndianness = self.Server!.Endianness
            
            let logonPmsg = PmsgLogon(TargetEndianness: self.Server!.Endianness, username: self.User.Username, wizpass: self.Wizpass!, initialRoomId: UInt16(self.Room!.Id!), regCounter: self.regCounter, regCrc: self.regCrc, puidCounter: self.puidCounter, puidCrc: self.puidCrc)
            
            self.send(pmsg: logonPmsg)
            self.ConnectionState = .Connected
            self.Logger.Log(info: "Connected")
            
            self.RequestServerRoomAndServerUsersLists()
        }
    }
    
    private func handleAltLogon(pmsg: PmsgLogon)
    {
        if self.puidCounter != pmsg.puidCounter || self.puidCrc != pmsg.puidCrc {
            self.Logger.Log(debug: "PUID Changed by Server")
            self.puidCounter = pmsg.puidCounter
            self.puidCrc = pmsg.puidCrc
            self.puidChanged = true
        }
        else {
            self.Logger.Log(debug: "PUID Unchanged")
        }
    }
    
    private func handleTerminate(pmsg: PmsgTerminate)
    {
        self.Logger.Log(error: "The connection to the server has been lost.")
        switch (pmsg.Ref!) {
        case TerminateReason.KilledByPlayer.rawValue:
            self.Logger.Log(info: "You have been killed.")
            break
        case TerminateReason.KilledBySysop.rawValue:
            self.Logger.Log(info: "You have been killed.")
            break
        case TerminateReason.BanishKill.rawValue:
            self.Logger.Log(info: "You have been kicked off the site.")
            break
        case TerminateReason.DeathPenaltyActive.rawValue:
            self.Logger.Log(info: "Your death penalty is still active.")
            break
        case TerminateReason.Banished.rawValue:
            self.Logger.Log(info: "You are not currently allowed on this site.")
            break
        case TerminateReason.Unresponsive.rawValue:
            self.Logger.Log(info: "Your connection was terminated due to inactivity.")
            break
        case TerminateReason.Flood.rawValue:
            self.Logger.Log(info: "Your connection was terminated due to flooding.")
            break
        case TerminateReason.ServerFull.rawValue:
            self.Logger.Log(info: "This server is currently full. Please try again later.")
            break
        case TerminateReason.NoGuests.rawValue:
            self.Logger.Log(info: "Guests are not currently allowed on this site.")
            break
        case TerminateReason.ServerDown.rawValue:
            self.Logger.Log(info: "This palace was shut down by its operator. Try again later.")
            break
        case TerminateReason.InvalidSerialNumber.rawValue:
            self.Logger.Log(info: "You have an invalid serial number.")
            break
        case TerminateReason.DuplicateUser.rawValue:
            self.Logger.Log(info: "There is another user using your serial number.")
            break
        case TerminateReason.DemoExpired.rawValue:
            self.Logger.Log(info: "Your free demo has expired.")
            break
        case TerminateReason.Unknown.rawValue:
            self.Logger.Log(info: "Unknown error.")
            break
        case TerminateReason.CommError.rawValue:
            self.Logger.Log(info: "Communication error.")
            break
        default:
            self.Logger.Log(debug: "Unknown error: \(pmsg.Ref!)")
            break
        }
        
        //self.socket.Close()
        self.Disconnect()
        //self.resetState()
    }
    
    private func handleServerVersion(pmsg: PmsgServerVersion)
    {
        self.Logger.Log(debug: "Server version: \(pmsg.Ref!)")
    }
    
    private func handleServerInfo(pmsg: PmsgServerInfo)
    {
        self.Logger.Log(debug: "Server Info goes here")
    }
    
    private func handleUserStatus(pmsg: PmsgUserStatus)
    {
        
    }
    
    private func handleUserLoggedOnAndMax(pmsg: PmsgUserLoggedOnAndMax)
    {
        if self.RoomViewControllerDelegate != nil {
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    private func handleHttpServer(pmsg: PmsgHttpServer)
    {
        self.Logger.Log(debug: "Our Http server is \(pmsg.HttpServer!)")
        self.httpServer = pmsg.HttpServer!
    }
    
    private func handleRoomDescription(pmsg: PmsgRoom)
    {
        // clear status message for room
        // clear alarms for room
        // stop audio/midi for room
        // clear spot images for room
        
        self.Room!.UserCount = pmsg.room!.UserCount ?? 0
        /*
        for image in pmsg.room!.ImageList! {
            let imageUrl = self.httpServer! + "/" + image.Name!
            self.Logger.Log(system: "Loading image: \(imageUrl)")
            
            image.LoadImage(url: imageUrl, completion: self.imageLoaded)
        } */
        
        /*
        self.Logger.Log(system: "Listing images")
        for image in pmsg.room!.ImageList! {
            self.Logger.Log(system: image.Name!)
        } */
        self.Room!.BackgroundImage = pmsg.room!.BackgroundImage
        
        if self.Room!.BackgroundImage.Name != nil {
            self.Logger.Log(debug: "Loading background image from \(self.httpServer!)\(self.Room!.BackgroundImage.Name!)...")
            self.Room!.BackgroundImage.Load(from: self.httpServer!, completion: backgroundImageLoaded)
        }
    }
    
    private func handleAltRoomDescription(pmsg: PmsgRoom)
    {
        self.Logger.Log(system: "Alt Room Description")
        
        //self.Logger.Log(system: "Listing images")
        //for image in pmsg.room!.ImageList! {
        //    self.Logger.Log(system: image.Name!)
        //}
    }
    
    private func handleRoomUserList(pmsg: PmsgRoomUserList)
    {
        self.Room!.UserList.removeAll()
        
        for user in pmsg.UserList! {
            if user.Id! == self.User.Id! {
                self.User.X = user.X!
                self.User.Y = user.Y!
                
                self.Room!.UserList.append(self.User)
            }
            else {
                self.Room!.UserList.append(user)
            }
            //if user.Id != self.UserSelf.Id {
            
            //}
        }
        
        //self.Room.UserList.append(self.UserSelf)
        
        if self.RoomViewControllerDelegate == nil {
            for user in self.Room!.UserList {
                self.Logger.Log(system: "\(user.Username) (\(user.Id!)) is here.")
            }
        }
        else {
            for user in self.Room!.UserList {
                self.Logger.Log(system: "\(user.Username) (\(user.Id!)) is here.")
                /*
                if self.UserSelf.Id == user.Id! {
                    self.RoomViewControllerDelegate!.Add(userSelf: user)
                }
                else {
                    self.RoomViewControllerDelegate!.Add(user: user)
                }*/
            }
            //self.Logger.Log(debug: "Invalidating view due to user list received.")
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    private func handleServerUserList(pmsg: PmsgServerUserList)
    {
        self.Server!.UserList.removeAll()
        self.Server!.UserList += pmsg.UserList!
        
        if self.ServerUserListDelegate != nil {
            self.ServerUserListDelegate!.Update()
        }
    }
        
    private func handleServerRoomList(pmsg: PmsgServerRoomList)
    {
        self.Server!.RoomList.removeAll()
        
        self.Server!.RoomList += pmsg.RoomList!
        
        if self.ServerRoomListDelegate != nil {
            self.ServerRoomListDelegate!.Update()
        }
    }
        
    private func handleRoomDescend(pmsg: Pmsg)
    {
        if self.RoomViewControllerDelegate != nil {
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    private func handleUserNew(pmsg: PmsgUserNew)
    {
        if pmsg.User != nil {
            if pmsg.User!.Id! == self.User.Id! {
                self.User.X = pmsg.User!.X
                self.User.Y = pmsg.User!.Y
                self.User.Color = pmsg.User!.Color
                self.User.Face = pmsg.User!.Face
                self.User.Flags = pmsg.User!.Flags
                self.User.RoomId = pmsg.User!.RoomId
                self.User.PropIdList = pmsg.User!.PropIdList
                self.User.PropCrcList = pmsg.User!.PropCrcList
                self.User.PropNum = pmsg.User!.PropNum
                
                self.Room!.UserList.append(self.User)
            }
            else {
                self.Room!.UserList.append(pmsg.User!)
            }
            
            self.Logger.Log(system: "\(pmsg.User!.Username) has entered the room.")
            
            if self.RoomViewControllerDelegate != nil {
                //self.Logger.Log(debug: "Invalidating view due to new user received.")
                self.RoomViewControllerDelegate!.UpdateUsers()
                /*
                if self.UserSelf.Id == pmsg.User!.Id! {
                    self.RoomViewControllerDelegate!.Add(userSelf: pmsg.User!)
                }
                else {
                    self.RoomViewControllerDelegate!.Add(user: pmsg.User!)
                } */
            }
        }
    }
    
    private func handlePing(pmsg: PmsgPing)
    {
        self.send(pmsg: PmsgPong(TargetEndianness: self.Server!.Endianness))
        //self.Logger.Log(debug: "Ping! Pong!")
    }
    
    private func handlePong(pmsg: PmsgPong)
    {
        //self.Logger.Log(debug: "Pong!")
    }
        
    private func handleXTalk(pmsg: PmsgXTalk)
    {
        let user = self.Room!.User(with: pmsg.Ref!)
        self.Logger.Log(user: user, say: pmsg.Message!)
    }
    
    private func handleXWhisper(pmsg: PmsgXWhisper)
    {
        let user = self.Room!.User(with: pmsg.Ref!)
        self.Logger.Log(user: user, whisper: pmsg.Message!)
    }
    
    private func handleTalk(pmsg: PmsgTalk)
    {
        let user = self.Room!.User(with: pmsg.Ref!)
        self.Logger.Log(user: user, say: pmsg.Message!)
    }
    
    private func handleAssetIncoming(pmsg: PmsgAsset)
    {
        
    }
        
    private func handleAssetQuery(pmsg: PmsgAssetQuery)
    {
        
    }
        
    private func handleMovement(pmsg: PmsgMovement)
    {
        let userId = pmsg.Ref!
        let user = self.Room!.UserList.User(with: userId)
        
        if user == nil {
            self.Logger.Log(debug: "User nil during movement!")
            return
        }
        
        //self.Logger.Log(debug: "Movement to (\(pmsg.X!), \(pmsg.Y!)) received!")
        user!.X = pmsg.X!
        user!.Y = pmsg.Y!
        
        if self.RoomViewControllerDelegate != nil {
            //self.RoomViewControllerDelegate!.Move(userId: pmsg.Ref!, x: pmsg.X!, y: pmsg.Y!)
            //self.Logger.Log(debug: "Invalidating view due to movement.")
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
        
    private func handleUserColor(pmsg: PmsgUserColor)
    {
        let userId = pmsg.Ref!
        
        let user = self.Server!.UserList.User(with: userId)
        if user != nil {
            user!.Color = pmsg.Color!
        }

        let roomUser = self.Room!.UserList.User(with: userId)
        if roomUser != nil {
            roomUser!.Color = pmsg.Color!
            if self.RoomViewControllerDelegate != nil {
                self.RoomViewControllerDelegate!.UpdateUsers()
            }
        }
    }
    
    private func handleUserFace(pmsg: PmsgUserFace)
    {
        let userId = pmsg.Ref!
        
        let user = self.Server!.UserList.User(with: userId)
        if user != nil {
            user!.Face = pmsg.Face!
        }
        
        let roomUser = self.Room!.UserList.User(with: userId)
        if roomUser != nil {
            roomUser!.Face = pmsg.Face!
            if self.RoomViewControllerDelegate != nil {
                self.RoomViewControllerDelegate!.UpdateUsers()
            }
        }
    }
    
    private func handleUserProp(pmsg: PmsgUserProp)
    {
        
        
        if self.RoomViewControllerDelegate != nil {
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    private func handleUserDescription(pmsg: PmsgUserDescription)
    {
        if self.RoomViewControllerDelegate != nil {
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    private func handleUserRename(pmsg: PmsgUserRename)
    {
        let user = self.Server!.UserList.User(with: pmsg.UserId!)
        
        if user != nil {
            user!.UsernameLen = pmsg.ToUsernameLen!
            user!.Username = pmsg.ToUsername!
        }
    }
    
    private func handleUserLeaving(pmsg: PmsgUserLeaving)
    {
        //if self.Room.UserList.contains(where: { (user) -> Bool in user.Id == pmsg.UserId }) {
            let roomUser = self.Room!.UserList.Remove(with: pmsg.UserId)
        //}
        if roomUser != nil {
            self.Logger.Log(system: "\(roomUser!.Username) has signed off from server (from room).")
        }
        
        let user = self.Server!.UserList.Remove(with: pmsg.UserId)
        
        if user != nil {
            self.Logger.Log(system: "\(user!.Username) has signed off server.")
            //self.Logger.Log(debug: "Invalidating view due to user leaving received.")
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    private func handleUserExitRoom(pmsg: PmsgUserExitRoom)
    {
        //self.Logger.Log(system: "User with id \(pmsg.UserId) has left the room.")
        let user = self.Room!.UserList.Remove(with: pmsg.UserId)
        
        if user != nil {
            self.Logger.Log(system: "\(user!.Username) has left the room.")
            //self.Logger.Log(debug: "Invalidating view due to user exit room received.")
            self.RoomViewControllerDelegate!.UpdateUsers()
        }
    }
    
    private func handlePropMove(pmsg: PmsgPropMove)
    {
        
    }
    
    private func handlePropDelete(pmsg: PmsgPropDelete)
    {
        
    }
    
    private func handlePropNew(pmsg: PmsgPropNew)
    {
        
    }
    
    private func handleDoorLock(pmsg: PmsgDoorLock)
    {
        
    }
    
    private func handleDoorUnlock(pmsg: PmsgDoorUnlock)
    {
        
    }
    
    private func handlePictMove(pmsg: PmsgPictMove)
    {
        
    }
    
    private func handleSpotState(pmsg: PmsgSpotState)
    {
        
    }
    
    private func handleSpotMove(pmsg: PmsgSpotMove)
    {
        
    }
    
    private func handleDraw(pmsg: PmsgDraw)
    {
        
    }
    
    private func handleFileIncoming(pmsg: PmsgFile)
    {
        
    }
    
    private func handleNavError(pmsg: PmsgNavError)
    {
        
    }
    
    private func handleAuthenticate(pmsg: PmsgAuthenticate)
    {
        
    }
    
    private func handleBlowThru(pmsg: PmsgBlowthru)
    {
        
    }
    
    func handlePmsg(pmsg: Pmsg)
    {
        if (self.ConnectionState == .Disconnected)
        {
            self.Logger.Log(debug: "Can't process messages while client state is disconnected: ")
            self.Logger.Log(debug: pmsg.toData().dump())
        }
        else if (self.ConnectionState == .Handshaking) {
            self.performHandshake(pmsg: pmsg)
        }
        else if (self.ConnectionState == .Connected) {
            switch (pmsg.Id!) {
            case .AltLogon:
                //self.Logger.Log(debug: "Server: AltLogon")
                self.handleAltLogon(pmsg: PmsgLogon(pmsg: pmsg))
                break
            case .ConnectionError:
                self.Logger.Log(debug: "Server: Connection Error")
                self.handleTerminate(pmsg: PmsgTerminate(pmsg: pmsg))
                break
            case .ServerVersion:
                self.Logger.Log(debug: "Server: Server Version")
                self.handleServerVersion(pmsg: PmsgServerVersion(pmsg: pmsg))
                break
            case .ServerInfo:
                self.Logger.Log(debug: "Server: Server Info")
                self.handleServerInfo(pmsg: PmsgServerInfo(pmsg: pmsg))
                break
            case .UserStatus:
                self.Logger.Log(debug: "Server: User Status")
                self.handleUserStatus(pmsg: PmsgUserStatus(pmsg: pmsg))
                break
            case .UserLoggedOnAndMax:
                self.Logger.Log(debug: "Server: User Logged on and Max")
                self.handleUserLoggedOnAndMax(pmsg: PmsgUserLoggedOnAndMax(pmsg: pmsg))
                break
            case .HttpServerLocation:
                //self.Logger.Log(debug: "Server: Http Server Location")
                self.handleHttpServer(pmsg: PmsgHttpServer(pmsg: pmsg))
                break
            case .RoomDescription:
                self.Logger.Log(debug: "Server: Room Description")
                self.handleRoomDescription(pmsg: PmsgRoom(pmsg: pmsg))
                break
            case .AltRoomDescription:
                self.Logger.Log(debug: "Server: Alt Room Description")
                self.handleAltRoomDescription(pmsg: PmsgRoom(pmsg: pmsg))
                break
            case .RoomUserList:
                //self.Logger.Log(debug: "Server: Room User List")
                self.handleRoomUserList(pmsg: PmsgRoomUserList(pmsg: pmsg))
                break
            case .ServerUserList:
                //self.Logger.Log(debug: "Server: Server User List")
                self.handleServerUserList(pmsg: PmsgServerUserList(pmsg: pmsg))
                break
            case .ServerRoomList:
                //self.Logger.Log(debug: "Server: Server Room List")
                self.handleServerRoomList(pmsg: PmsgServerRoomList(pmsg: pmsg))
                break
            case .RoomDescend:
                self.Logger.Log(debug: "Server: Room Descend")
                self.handleRoomDescend(pmsg: PmsgRoomDescend(pmsg: pmsg))
                break
            case .UserNew:
                //self.Logger.Log(debug: "Server: New User")
                self.handleUserNew(pmsg: PmsgUserNew(pmsg: pmsg))
                break
            case .Ping:
                //self.Logger.Log(debug: "Server: Ping")
                self.handlePing(pmsg: PmsgPing(pmsg: pmsg))
                break
            case .Pong:
                //self.Logger.Log(debug: "Server: Pong")
                self.handlePong(pmsg: PmsgPong(pmsg: pmsg))
                break
            case .XTalk:
                //self.Logger.Log(debug: "Server: XTalk")
                self.handleXTalk(pmsg: PmsgXTalk(pmsg: pmsg, crypto: self.crypto))
                break
            case .XWhisper:
                //self.Logger.Log(debug: "Server: XWhisper")
                self.handleXWhisper(pmsg: PmsgXWhisper(pmsg: pmsg, crypto: self.crypto))
                break
            case .Talk:
                //self.Logger.Log(debug: "Server: Talk")
                self.handleTalk(pmsg: PmsgTalk(pmsg: pmsg))
                break
            case .AssetIncoming:
                self.Logger.Log(debug: "Server: Asset Incoming")
                self.handleAssetIncoming(pmsg: PmsgAsset(pmsg: pmsg))
                break
            case .AssetQuery:
                self.Logger.Log(debug: "Server: Asset Query")
                self.handleAssetQuery(pmsg: PmsgAssetQuery(pmsg: pmsg))
                break
            case .Movement:
                //self.Logger.Log(debug: "Server: Movement")
                self.handleMovement(pmsg: PmsgMovement(pmsg: pmsg))
                break
            case .UserColor:
                //self.Logger.Log(debug: "Server: User Color")
                self.handleUserColor(pmsg: PmsgUserColor(pmsg: pmsg))
                break
            case .UserFace:
                //self.Logger.Log(debug: "Server: User Face")
                self.handleUserFace(pmsg: PmsgUserFace(pmsg: pmsg))
                break
            case .UserProp:
                self.Logger.Log(debug: "Server: User Prop")
                self.handleUserProp(pmsg: PmsgUserProp(pmsg: pmsg))
                break
            case .UserDescription:
                self.Logger.Log(debug: "Server: User Description")
                self.handleUserDescription(pmsg: PmsgUserDescription(pmsg: pmsg))
                break
            case .UserRename:
                self.Logger.Log(debug: "Server: User Rename")
                self.handleUserRename(pmsg: PmsgUserRename(pmsg: pmsg))
                break
            case .UserLeaving:
                self.Logger.Log(debug: "Server: User Signed Off")
                self.handleUserLeaving(pmsg: PmsgUserLeaving(pmsg: pmsg))
                break
            case .UserExitRoom:
                self.Logger.Log(debug: "Server: User Left Room")
                self.handleUserExitRoom(pmsg: PmsgUserExitRoom(pmsg: pmsg))
                break
            case .PropMove:
                self.Logger.Log(debug: "Server: Prop Moved")
                self.handlePropMove(pmsg: PmsgPropMove(pmsg: pmsg))
                break
            case .PropDelete:
                self.Logger.Log(debug: "Server: Prop Deleted")
                self.handlePropDelete(pmsg: PmsgPropDelete(pmsg: pmsg))
                break
            case .PropNew:
                self.Logger.Log(debug: "Server: New Prop")
                self.handlePropNew(pmsg: PmsgPropNew(pmsg: pmsg))
                break
            case .DoorLock:
                self.Logger.Log(debug: "Server: Door Locked")
                self.handleDoorLock(pmsg: PmsgDoorLock(pmsg: pmsg))
                break
            case .DoorUnlock:
                self.Logger.Log(debug: "Server: Door Unlocked")
                self.handleDoorUnlock(pmsg: PmsgDoorUnlock(pmsg: pmsg))
                break
            case .PictMove:
                self.Logger.Log(debug: "Server: Pict Move")
                self.handlePictMove(pmsg: PmsgPictMove(pmsg: pmsg))
                break
            case .SpotState:
                self.Logger.Log(debug: "Server: Spot State")
                self.handleSpotState(pmsg: PmsgSpotState(pmsg: pmsg))
                break
            case .SpotMove:
                self.Logger.Log(debug: "Server: Spot Move")
                self.handleSpotMove(pmsg: PmsgSpotMove(pmsg: pmsg))
                break
            case .Draw:
                self.Logger.Log(debug: "Server: Draw")
                self.handleDraw(pmsg: PmsgDraw(pmsg: pmsg))
                break
            case .FileIncoming:
                self.Logger.Log(debug: "Server: File Incoming")
                self.handleFileIncoming(pmsg: PmsgFile(pmsg: pmsg))
                break
            case .NavError:
                self.Logger.Log(debug: "Server: Nav Error")
                self.handleNavError(pmsg: PmsgNavError(pmsg: pmsg))
                break
            case .Authenticate:
                self.Logger.Log(debug: "Server: Authenticate")
                self.handleAuthenticate(pmsg: PmsgAuthenticate(pmsg: pmsg))
                break
            case .BlowThru:
                self.Logger.Log(debug: "Server: Blowthru")
                self.handleBlowThru(pmsg: PmsgBlowthru(pmsg: pmsg))
                break
            default:
                self.Logger.Log(error: String(format: "Server: Unknown message with id 0x%x", pmsg.Id!.rawValue))
                break
            }
        }
    }
    
    func SocketReceiveHandler(data: Data, len: Int)
    {
        //self.Logger.Log(debug: data.dump())
        self.Logger.Log(trace: "Read len: \(len), data.count: \(data.count) bytes from stream.")
        var dataOff = 0
        
        // Exception to the rule: we have already started assembling a Pmsg and must continue.
        if self.pmsg != nil { //&& self.pmsg!.PartLen < self.pmsg!.Len! {
            let pmsgSize = Int(self.pmsg!.Len!) + Int(Pmsg.HeaderSizeInBytes)
            self.Logger.Log(trace: "NOTICE: self.pmsg not null. Looks like we're continuing the previous message.")
            self.Logger.Log(trace: "Before append: \(pmsgSize)/\(self.pmsg!.PartLen) bytes.")
            // continue assembling
            
            //let partLenBefore = self.pmsg!.PartLen
            let deficit = Int(self.pmsg!.Len!) - Int(self.pmsg!.PartLen)
            if deficit <= len {
                self.pmsg!.Append(data: data, len: deficit)
                self.Logger.Log(trace: "After append: \(self.pmsg!.Len!)/\(self.pmsg!.PartLen) bytes.")
                dataOff += deficit
                self.Logger.Log(trace: "New Offset: \(dataOff)/\(data.count)")
                
                self.Logger.Log(trace: "Dispatching continued Pmsg @ \(pmsgSize)/\(self.pmsg!.PartLen) bytes!")
                self.handlePmsg(pmsg: self.pmsg!)
                self.pmsg = nil // reset
            }
            else {
                self.pmsg!.Append(data: data, len: len)
                self.Logger.Log(trace: "After append: \(self.pmsg!.Len!)/\(self.pmsg!.PartLen) bytes.")
                // continue...
                self.Logger.Log(trace: "pmsg still to be continued... \(self.pmsg!.PartLen)")
                return
            }
            //let partLenAfter = self.pmsg!.PartLen
            
            //self.Logger.Log(trace: "After append: \(self.pmsg!.Len!)/\(self.pmsg!.PartLen) bytes.")
            

            //totalSize = Int(self.pmsg!.PartLen)
        }
        //else if Pmsg.HeaderSizeInBytes <= data.count {
        //else {
            // not a continuation
            // we need to loop through all the pmsgs in the packet(s).
            // start assembling
        self.Logger.Log(trace: "Picking up offset at \(dataOff)/\(data.count)")
        
            while dataOff < data.count {
                let currentData = Data(data.suffix(from: dataOff))
                var pmsg: Pmsg? = Pmsg(TargetEndianness: self.Server!.Endianness, data: currentData)
                let pmsgSize = dataOff + Int(pmsg!.Len!) + Int(Pmsg.HeaderSizeInBytes)
                //if 1460 < pmsg!.Len! {
                //    return // too large!
                //}
                
                //self.Logger.Log(trace: "NEW MESSAGE. Server: Pmsg = Id: \(pmsg!.Id!), Len: \(pmsgSize)/\(len), Ref: \(pmsg!.Ref!)")
                
                if self.ConnectionState == .Handshaking {
                    self.Logger.Log(trace: "Dispatching Pmsg for Handshaking!")
                    performHandshake(pmsg: pmsg!)
                }
                else if self.ConnectionState == .Connected {
                    self.Logger.Log(trace: "First pass: \(pmsgSize)/\(data.count) bytes.")
                    if pmsg!.Len! <= pmsg!.PartLen {
                        self.Logger.Log(trace: "Dispatching Pmsg @ \(pmsgSize)/\(data.count) bytes!")
                        self.handlePmsg(pmsg: pmsg!)
                    }
                }
                
                //if (lenToRead < Int(pmsg!.Len!)) {
                    //lenToRead = 0
                if (data.count - dataOff < Int(pmsg!.Len!)) {
                    self.Logger.Log(trace: "Pmsg to be continued...")
                    self.pmsg = pmsg
                    dataOff = data.count
                }
                else {
                    dataOff += Pmsg.HeaderSizeInBytes + Int(pmsg!.Len!)
                    pmsg = nil
                }
            }
        //}
    }

    func send(pmsg: Pmsg)
    {
        // reset timer
        //self.pingTimer
        //self.SocketSendHandler(data: pmsg.data)
        self.socket.Send(data: pmsg.toData())
    }
    
    func send(pmsgs: [Pmsg])
    {
        var data = Data()
        for pmsg in pmsgs {
            data.append(pmsg.toData())
        }
        
        self.socket.Send(data: data)
    }
    
    //func SocketSendHandler(data: Data)
    //{
    //    self.socket.Send(data: data)
    //}

    func SocketOpenHandler()
    {
        self.ConnectionState = .Handshaking
        self.Logger.Log(info: "Handshaking")
    }
    
    func SocketCloseHandler()
    {
        //self.socket.Close()
        self.ConnectionState = .Disconnected
        self.Logger.Log(info: "Disconnected")
    }
    
    func SocketErrorHandler()
    {
        self.socket.Close()
        self.Logger.Log(error: "Connection error")
        self.resetState()
    }
    
    public func ConnectTo(hostname: String?, port: Int?, username: String?)
    {
        if hostname == nil {
            return
        }
        
        if self.ConnectionState != .Disconnected {
            self.Disconnect()
        }
        
        //let cfPort = UInt32(port)
        //let cfHostname = hostname as CFString
        let actualPort = port != nil ? port : 9998
        
        if username == nil {
            self.User.Username = "Alcazar User"
        }
        else {
            self.User.Username = username!
        }
        
        socket.ConnectTo(host: hostname!, port: actualPort!)
        
        self.Server = Pserver()
        self.Server!.Endianness = .Unknown
        self.Server!.Address = String("\(hostname!):\(actualPort!)")
        self.Logger.Log(info: "Connecting to \(self.Server!.Address!)")
        
        self.Room = Proom()
        self.Room!.Id = 0
        /*
        switch self.socket_!.connect(timeout: 8) {
        case .failure(_):
            return false
        case .success:
            self.state_ = .handshaking
            guard let response = self.socket_!.read(1024*10) else {
                self.logger.log(debug: "Failed to read connect response from server")
                return false
            }
            //let pmsg = Pmsg.fromBytes(response)
            let d = Data(bytes: response)
            let pmsg = UnsafePointer<Pmsg>(d)
            _processResponse(pmsg: pmsg)
            return true
        }
 */
    }
    
    public func Reconnect()
    {
        var hostname: String?
        var port: Int?
        
        if self.Hostname == nil {
            return //false
        }
        else {
            hostname = self.Hostname
        }
        
        if self.Port == nil {
            port = 9998
        }
        
        self.Disconnect()
        self.ConnectTo(hostname: hostname!, port: port!, username: self.User.Username)
    }
    
    public func ConnectTo(palaceUrl: String)
    {
        if palaceUrl == "" {
            return //false
        }
        
        // strip palace:// if necessary
        //if palaceUrl.substring(to: "palace://".length) == "palace://" {
        //}
        let urlTokens1 = palaceUrl.components(separatedBy: "palace://")
        let phase1 = urlTokens1.last
        
        // extract username if present
        let urlTokens2 = phase1?.components(separatedBy: "@")
        var phase2 = phase1
        let username: String?
        if 1 < urlTokens2!.count {
            username = urlTokens2!.first!
            phase2 = urlTokens2?.last
        }
        else {
            username = nil
            //phase2 = phase1
        }
        
        // separate hostname and port (if present)
        let urlTokens3 = phase2?.components(separatedBy: ":")
        let hostname = urlTokens3?.first
        let portString = urlTokens3?.last
        let port = Int(portString!)
        
        self.ConnectTo(hostname: hostname, port: port, username: username)
    }
    
    public func Disconnect()
    {
        if self.Server != nil && self.Server!.Address != nil {
            self.Logger.Log(debug: "Disconnecting from \(self.Server!.Address!)")
        }
        
        self.resetState()
    }
}
