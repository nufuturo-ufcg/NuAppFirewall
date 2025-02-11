/*
    File: ANSIColor.swift
    Project: NuAppFirewall (nufuturo.nuappfirewall)
    Description: ANSIColor defines an enumeration for color codes used in terminal output. 
        It allows easy application of colors to text, supporting red, green, yellow, and reset to standard terminal formatting.

    Created by Walber Araujo on 01/02/2025
*/

import Foundation

enum ANSIColor: String {
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case reset = "\u{001B}[0;0m"
}