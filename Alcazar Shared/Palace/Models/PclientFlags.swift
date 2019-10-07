//
//  PclientFlags.swift
//  Alcazar
//
//  Created by Jesse Riddle on 3/17/17.
//  Copyright © 2017 Jesse Riddle. All rights reserved.
//

import Foundation

public enum TerminateReason: UInt32
{
    case Nil = 0x00000000
    case Error = 0x00000001
    case CommError = 0x00000002
    case Flood = 0x00000003
    case KilledByPlayer = 0x00000004
    case ServerDown = 0x00000005
    case Unresponsive = 0x00000006
    case KilledBySysop = 0x0000007
    case ServerFull = 0x00000008
    case InvalidSerialNumber = 0x0000009
    case DuplicateUser = 0x0000000a
    case DeathPenaltyActive = 0x0000000b
    case Banished = 0x0000000c
    case BanishKill = 0x0000000d
    case NoGuests = 0x0000000e
    case DemoExpired = 0x0000000f
    case Unknown = 0x00000010
}

public enum EndianType: UInt32
{
    case Unknown = 0x00000000
    case LittleEndian = 0x00000001
    case BigEndian = 0x00000002
}

public struct PerrNav
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let InternalError = PerrNav(rawValue: 0x00000000)
    static let UnknownRoom = PerrNav(rawValue: 0x00000001)
    static let RoomFull = PerrNav(rawValue: 0x00000002)
    static let RoomClosed = PerrNav(rawValue: 0x00000003)
    static let CantAuthor = PerrNav(rawValue: 0x00000004)
    static let PalaceFull = PerrNav(rawValue: 0x00000005)
}

public struct PflagAuxOptions: OptionSet
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let unknownMachine = PflagAuxOptions(rawValue: 0)
    static let mac68k = PflagAuxOptions(rawValue: 1)
    static let macPowerPC = PflagAuxOptions(rawValue: 2)
    static let win16 = PflagAuxOptions(rawValue: 3)
    static let win32 = PflagAuxOptions(rawValue: 4)
    static let java = PflagAuxOptions(rawValue: 5)
    static let macIntel = PflagAuxOptions(rawValue: 6)
    
    static let iOS = PflagAuxOptions(rawValue: 10)
    static let android = PflagAuxOptions(rawValue: 11)
    
    static let osMask = PflagAuxOptions(rawValue: 0x0000000F)
    static let authenticate = PflagAuxOptions(rawValue: 0x80000000)
}

/******************************************************
 ** Upload Capabilities *******************************
 ******************************************************/

public struct PcapUlOptions: OptionSet
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let palaceAssets = PcapUlOptions(rawValue: 0x00000001)
    static let ftpAssets = PcapUlOptions(rawValue: 0x00000002)
    static let httpAssets = PcapUlOptions(rawValue: 0x00000004)
    static let otherAssets = PcapUlOptions(rawValue: 0x00000008)
    static let palaceFiles = PcapUlOptions(rawValue: 0x00000010)
    static let ftpFiles = PcapUlOptions(rawValue: 0x00000020)
    static let httpFiles = PcapUlOptions(rawValue: 0x00000040)
    static let otherFiles = PcapUlOptions(rawValue: 0x00000080)
    static let extended = PcapUlOptions(rawValue: 0x00000100)
}


/******************************************************
 ** Download Capabilities *****************************
 ******************************************************/

public struct PcapDlOptions: OptionSet
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let palaceAssets = PcapDlOptions(rawValue: 0x00000001)
    static let ftpAssets = PcapDlOptions(rawValue: 0x00000002)
    static let httpAssets = PcapDlOptions(rawValue: 0x00000004)
    static let otherAssets = PcapDlOptions(rawValue: 0x00000008)
    static let palaceFiles = PcapDlOptions(rawValue: 0x00000010)
    static let ftpFiles = PcapDlOptions(rawValue: 0x00000020)
    static let httpFiles = PcapDlOptions(rawValue: 0x00000040)
    static let otherFiles = PcapDlOptions(rawValue: 0x00000080)
    static let httpFilesExtended = PcapDlOptions(rawValue: 0x00000100)
    static let extended = PcapDlOptions(rawValue: 0x00000200)
}


/******************************************************
 ** 2D Engine Capabilities ****************************
 ******************************************************/

public struct PcapEngine2dOptions: OptionSet
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let palace2dEngine = PcapEngine2dOptions(rawValue: 0x00000001)
}


/******************************************************
 ** 2D Graphics Capabilities **************************
 ******************************************************/

public struct PcapGraph2dOptions: OptionSet
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let gif87 = PcapGraph2dOptions(rawValue: 0x00000001)
    static let gif89a = PcapGraph2dOptions(rawValue: 0x00000002)
    static let jpg = PcapGraph2dOptions(rawValue: 0x00000004)
    static let tiff = PcapGraph2dOptions(rawValue: 0x00000008)
    static let targa = PcapGraph2dOptions(rawValue: 0x00000010)
    static let bmp = PcapGraph2dOptions(rawValue: 0x00000020)
    static let pct = PcapGraph2dOptions(rawValue: 0x00000040)
}


/******************************************************
 ** 3D Graphics Capabilities **************************
 ******************************************************/

public struct PcapGraph3dOptions: OptionSet
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let vrml1 = PcapGraph3dOptions(rawValue: 0x00000001)
    static let vrml2 = PcapGraph3dOptions(rawValue: 0x00000002)
}

/******************************************************
 ** Magic Numbers *************************************
 ******************************************************/

public struct PmagicOptions: OptionSet
{
    public let rawValue: UInt32
    
    public init(rawValue: UInt32)
    {
        self.rawValue = rawValue
    }
    
    static let pchat = PmagicOptions(rawValue: 0x00011940)
}
