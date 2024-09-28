//
//  Barcode.swift
//  Printer
//
//  Created by gix on 2023/2/2.
//

import Foundation

public struct QRCode: ReceiptItem {
    public enum Model: UInt8 {
        case m_1 = 49
        case m_2 = 50
        case micro = 51
    }
    
    public enum RecoveryLevel: UInt8 {
        case l = 48 // 7%
        case m = 49 // 15%
        case q = 50 // 25%
        case h = 51 // 30%
    }
    public enum ModuleSize: UInt8 {
        case s1D = 0x1D
        case s28 = 0xs28
        case s6B = 0x6B
        case s03 = 0x03
        case s00 = 0x00
        case s31 = 0x31
        case s43 = 0x43
    }
    
    public let m: Model
    public let moduleSize: ModuleSize

    public let content: String
    public let level: RecoveryLevel
    
    //  Sets the size of the module for QR Code to n dots. width == height
    public let width: UInt8
    
    public init(content: String, width: UInt8 = 200, recovery level: RecoveryLevel = .m, m: Model = .m_2, moduleSize: ModuleSize = .s03) {
        self.content = content
        self.m = m
        self.width = width
        self.level = level
        self.moduleSize = moduleSize
    }
    
    //  https://reference.epson-biz.com/modules/ref_escpos/index.php?content_id=145
    public func assemblePrintableData(_ profile: PrinterProfile) -> [UInt8] {
        guard let contentData = content.data(using: profile.encoding) else {
            return []
        }
        // Code type for QR code
       
        // Select the model 
        var data = [29, 40, 107, 4, 0, 49, 65, m.rawValue, 0]

        // Set module size
        data += [29, 40, 107, 3, 0, 49, 67, moduleSize.rawValue]
        
        //  Select the error correction level
        data += [29, 40, 107, 3, 0, 49, 69, level.rawValue]
        
        let total = contentData.count + 3
        let pl = UInt8(total % 256)
        let ph = UInt8(total / 256)
        
        //  Store the data in the symbol storage area
        data += ([29, 40, 107, pl, ph, 49, 80, 48] + contentData)
        
        // Print the symbol data in the symbol storage area
        data += [29, 40, 107, 3, 0, 49, 81, 48]
        
        return data
    }
}
