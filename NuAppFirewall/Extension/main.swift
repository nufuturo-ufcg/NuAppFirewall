//
//  main.swift
//  Extension
//
//  Created by ec2-user on 12/09/2024.
//

import Foundation
import NetworkExtension
import OSLog

let filterlogger = Logger(subsystem: "com.nufuturo.nuappfirewall.extension", category: "extension");

autoreleasepool {
    filterlogger.log("System extension mode was called")
    NEProvider.startSystemExtensionMode()
}

dispatchMain()
