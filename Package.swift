// swift-tools-version:5.9
//  Package.swift
//  Printer
//
//  Created by Luis Genaro Arvizu Vega on 15/10/21.
//  Copyright © 2021 Kevin. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "Printer",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Printer",
            targets: ["Printer"]
        )
    ],
    targets: [
        .target(
            name: "Printer",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "PrinterTests",
            dependencies: ["Printer"],
            exclude: ["Info.plist"]
        )
    ]
)
