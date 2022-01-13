//
//  BluetoothBytesParser.swift
//  MVVM-UIKit-HealthExample
//
//  Created by Syed Mahmud on 3/29/21.
//

import Foundation


class BluetoothBytesParser {
    
    private var offset: Int = 0
    private var mValue: Array<UInt8>?
    private let byteOrder = "LITTLE_ENDIAN"
    
    public static let FORMAT_UINT8 = 0x11
    public static let FORMAT_UINT16 = 0x12
    public static let FORMAT_UINT32 = 0x14
    public static let FORMAT_SFLOAT = 0x32
    public static let FORMAT_FLOAT = 0x34
    
    convenience init(value: Array<UInt8>) {
        self.init(value: value, offset: 0)
    }

    init(value: Array<UInt8>, offset: Int) {
        mValue = value
        self.offset = offset
    }
    
    public func setOffset(offset: Int) {
        self.offset = offset
    }
    
    public func getFloatValue(formatType: Int) -> Float {
        let result = Float(getFloatValue(formatType: formatType, offset: offset))
        offset += getTypeLen(formatType: formatType)
        return result
    }
    
    public func getFloatValue(formatType: Int, offset: Int) -> Float {
        switch formatType {
        case BluetoothBytesParser.FORMAT_SFLOAT:
            return bytesToFloat(b0: mValue![offset], b1: mValue![offset + 1])
        case BluetoothBytesParser.FORMAT_FLOAT:
            return bytesToFloat(b0: mValue![offset], b1: mValue![offset + 1],
                                b2: mValue![offset + 2], b3: mValue![offset + 3])
        default:
            return -1.0
        }
    }
    
    private func bytesToFloat(b0: UInt8, b1: UInt8) -> Float {
        let mantissa = unsignedToSigned(unsigned: unsignedByteToInt(b: b0)
                    + ((unsignedByteToInt(b: b1) & 0x0F) << 8),
                    size: 12)
        let exponent = unsignedToSigned(unsigned: unsignedByteToInt(b: b1) >> 4, size: 4)
        return (Float(mantissa) * pow(10.0, Float(exponent)))
    }
    
    private func bytesToFloat(b0: UInt8, b1: UInt8, b2: UInt8, b3: UInt8) -> Float {
        let mantissa = unsignedToSigned(unsigned: unsignedByteToInt(b: b0)
                    + (unsignedByteToInt(b: b1) << 8)
                    + (unsignedByteToInt(b: b2) << 16),
                    size: 24)
        return (Float(mantissa) * pow(10.0, Float(-1)))
    }
    
    private func unsignedToSigned(unsigned: Int, size: Int) -> Int {
        let locUnsigned = unsigned
//        let blah = (unsigned & (1 << size - 1))
//        if ((unsigned & (1 << size - 1)) != 0) {
//            locUnsigned = -1 * ((1 << size - 1) - (unsigned & ((1 << size - 1) - 1)))
//        }
        return locUnsigned
    }
    
    public func getIntValue(formatType: Int) -> Int {
        let result = Int(getIntValue(formatType: formatType, offset: offset))
        offset += getTypeLen(formatType: formatType)
        return result
    }
    
    public func getIntValue(formatType: Int, offset: Int) -> Int {
        switch formatType {
        case BluetoothBytesParser.FORMAT_UINT8:
            return unsignedByteToInt(b: mValue![offset])
        case BluetoothBytesParser.FORMAT_UINT16:
            return unsignedBytesToInt(b0: mValue![offset], b1: mValue![offset + 1])
        default:
            return -1
        }
    }
    
    private func unsignedByteToInt(b: UInt8) -> Int {
        return Int(b & 0xFF)
    }
    
    private func unsignedBytesToInt(b0: UInt8, b1: UInt8) -> Int {
        return (unsignedByteToInt(b: b0) + (unsignedByteToInt(b: b1) << 8));
    }
    
    private func getTypeLen(formatType: Int) -> Int {
        return Int(formatType & 0xF)
    }
    
    public func getDateTime() -> Date {
        let result = getDateTime(offset: offset)
        offset += 7
        return result
    }
    
    public func getDateTime(offset: Int) -> Date {
        // DateTime is always in little endian
        var offset = self.offset
        let year = getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT16, offset: offset)
        offset += getTypeLen(formatType: BluetoothBytesParser.FORMAT_UINT16)
        let month = getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8, offset: offset)
        offset += getTypeLen(formatType: BluetoothBytesParser.FORMAT_UINT8)
        let day = getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8, offset: offset)
        offset += getTypeLen(formatType: BluetoothBytesParser.FORMAT_UINT8)
        let hour = getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8, offset: offset)
        offset += getTypeLen(formatType: BluetoothBytesParser.FORMAT_UINT8)
        let min = getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8, offset: offset)
        offset += getTypeLen(formatType: BluetoothBytesParser.FORMAT_UINT8)
        let sec = getIntValue(formatType: BluetoothBytesParser.FORMAT_UINT8, offset: offset)
        
        let dateComponents = NSDateComponents()
        dateComponents.year = Int(year)
        dateComponents.month = Int(month)
        dateComponents.day = Int(day)
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(min)
        dateComponents.second = Int(sec)
        
        var date = Date()
        if let gregorianCanlendar = NSCalendar(calendarIdentifier: .gregorian) {
            date = gregorianCanlendar.date(from: dateComponents as DateComponents) ?? Date()
        }
        
        return date
    }
}
