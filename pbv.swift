#!/usr/bin/env swift
import Foundation
import Cocoa

let newline = Data([0x0A] as [UInt8])

/**
Write the given string to STDERR.

- parameter str: native string to write encode in utf-8.
- parameter appendNewline: whether or not to write a newline (U+000A) after the given string (defaults to true)
*/
func printErr(_ str: String, appendNewline: Bool = true) {
  // writing to STDERR takes a bit of boilerplate, compared to print()
  if let data = str.data(using: .utf8) {
    FileHandle.standardError.write(data)
    if appendNewline {
      FileHandle.standardError.write(newline)
    }
  }
}

func printTypes(_ pasteboard: NSPasteboard) {
  printErr("Available types for the '\(pasteboard.name.rawValue)' pasteboard:")
  // Apple documentation says `types` "is an array NSString objects",
  // but that's wrong: they are PasteboardType structures.
  if let types = pasteboard.types {
    for type in types {
      printErr("  \(type.rawValue)")
    }
  } else {
    printErr("  (not available)")
  }
}

func printPasteboard(_ pasteboard: NSPasteboard, dataTypeName: String) {
  let dataType = NSPasteboard.PasteboardType(rawValue: dataTypeName)
  if let string = pasteboard.string(forType: dataType) {
    print(string, terminator: "")
  } else {
    printErr("Could not access pasteboard contents as String for type '\(dataTypeName)'")
    printTypes(pasteboard)
  }
}

func printUsage(_ pasteboard: NSPasteboard) {
  let command = CommandLine.arguments.first ?? "pbv"
  printErr("Usage: \(command) [dataType] [-h|--help]\n")
  printTypes(pasteboard)
}

// CommandLine.arguments[0] is the fullpath to this file
// CommandLine.arguments[1] should be the desired type
let args = CommandLine.arguments.dropFirst()
if args.contains("-h") || args.contains("--help") {
  printUsage(NSPasteboard.general)
  exit(0)
} else if args.count > 1 {
  printUsage(NSPasteboard.general)
  exit(1)
}

// (main)
let type = args.first ?? "public.utf8-plain-text"
printPasteboard(NSPasteboard.general, dataTypeName: type)
