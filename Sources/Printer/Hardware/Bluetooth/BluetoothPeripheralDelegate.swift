//
//  PeripheralDelegate.swift
//  Printer
//
//  Created by gix on 12/8/16.
//  Copyright © 2016 Kevin. All rights reserved.
//

import CoreBluetooth
import Foundation

@Observable
class BluetoothPeripheralDelegate: NSObject, CBPeripheralDelegate {
    private var services: Set<String>!
    private var characteristics: Set<CBUUID>?

    private let writableCharacteristicUUID = "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F"

    var wellDoneCanWriteData: ((CBPeripheral) -> Void)?

    private(set) var writablePeripheral: CBPeripheral?
    private(set) var writableCharacteristic: CBCharacteristic? {
        didSet {
            if let wc = writableCharacteristic, let wp = writablePeripheral {
                wp.setNotifyValue(true, for: wc)
                wellDoneCanWriteData?(wp)
            }
        }
    }

    convenience init(_ services: Set<String>, characteristics: Set<String>?) {
        self.init()
        self.services = services
        self.characteristics = (characteristics?.map { CBUUID(string: $0) }).map { Set($0) }
    }

    func disconnect(_ peripheral: CBPeripheral) {
        guard let wp = writablePeripheral else {
            return
        }

        if wp.identifier == peripheral.identifier {
            writablePeripheral = nil
            writableCharacteristic = nil
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }

        guard let prServices = peripheral.services else {
            return
        }

        prServices.filter { services.contains($0.uuid.uuidString) }.forEach {
            peripheral.discoverCharacteristics(nil, for: $0)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didDiscoverCharacteristicsFor service: CBService,
                           error: Error?)
    {
        writablePeripheral = peripheral
        writableCharacteristic = service.characteristics?
            .filter { $0.uuid.uuidString == writableCharacteristicUUID }.first
    }

    public func peripheral(_ peripheral: CBPeripheral,
                           didUpdateValueFor characteristic: CBCharacteristic,
                           error: Error?)
    {
        print(characteristic)
    }
}
