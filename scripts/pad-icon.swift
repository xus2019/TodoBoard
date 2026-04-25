#!/usr/bin/env swift
// Pad a square icon to a 1024×1024 transparent canvas with the original content
// scaled to 824×824 (the macOS Big Sur+ "rounded rectangle" template ratio of
// ~80%), so the rendered Dock/Finder icon visually matches Apple's own apps.
//
// Usage: scripts/pad-icon.swift <input.png> <output.png>

import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write(Data("usage: pad-icon.swift <input.png> <output.png>\n".utf8))
    exit(1)
}

let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])

guard let source = NSImage(contentsOf: inputURL) else {
    FileHandle.standardError.write(Data("failed to read \(args[1])\n".utf8))
    exit(1)
}

let canvasSide = 1024
let inset: CGFloat = 100
let contentRect = NSRect(
    x: inset,
    y: inset,
    width: CGFloat(canvasSide) - inset * 2,
    height: CGFloat(canvasSide) - inset * 2
)

guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: canvasSide,
    pixelsHigh: canvasSide,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 32
) else {
    FileHandle.standardError.write(Data("failed to allocate bitmap\n".utf8))
    exit(1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor.clear.setFill()
NSRect(x: 0, y: 0, width: canvasSide, height: canvasSide).fill(using: .copy)
NSGraphicsContext.current?.imageInterpolation = .high
source.draw(in: contentRect, from: .zero, operation: .sourceOver, fraction: 1.0)
NSGraphicsContext.restoreGraphicsState()

guard let png = rep.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("failed to encode PNG\n".utf8))
    exit(1)
}

try png.write(to: outputURL)
