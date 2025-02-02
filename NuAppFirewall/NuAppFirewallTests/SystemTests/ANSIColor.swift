//
//  ANSIColor.swift
//  NuAppFirewall
//
//  Created by Walber Araujo on 01/02/25.
//

import Foundation

enum ANSIColor: String {
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case reset = "\u{001B}[0;0m"
}