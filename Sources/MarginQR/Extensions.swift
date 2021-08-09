//
//  Extensions.swift
//  MarginQR
//
//  Created by Steve Dao on 9/8/21.
//

import Foundation
import CoreGraphics
import UIKit 

extension CGImage {
  /// Detect the module length of QR image
  var qrModuleWide: CGFloat? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bitsPerComponent = 8
    let bytesPerRow = bytesPerPixel * width
    let bitmapInfo = RGBA32.bitmapInfo

    guard let context = CGContext(data: nil,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: bitsPerComponent,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: bitmapInfo)
    else {
      print("unable to create context")
      return nil
    }
    context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let buffer = context.data else {
      print("unable to get context data")
      return nil
    }

    let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)

    for slash in 0..<Int(height) {
      let offset = slash * width + slash
      if pixelBuffer[offset] == .black {
        return CGFloat(slash)
      }
    }

    return nil
  }

  /// Add more quiet zone since CoreImage hasn't support
  func uiImageWith(quietZone numOfModule: Int, moduleWide: CGFloat) -> UIImage? {
    let qrImage = UIImage(cgImage: self)
    let fullModuleWide = (moduleWide * (CGFloat(numOfModule) - 1))
    let widthWithQuietZone = qrImage.size.width + fullModuleWide * 2
    let sizeWithQuietZone = CGSize(width: widthWithQuietZone, height: widthWithQuietZone)
    let container = CGRect(origin: .zero, size: sizeWithQuietZone)

    UIGraphicsBeginImageContextWithOptions(sizeWithQuietZone, false, qrImage.scale)

    guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
    defer { UIGraphicsEndImageContext() }

    ctx.setFillColor(UIColor.white.cgColor)
    ctx.fill(container)
    qrImage.draw(in: .init(origin: .init(x: fullModuleWide, y: fullModuleWide), size: qrImage.size))

    return UIGraphicsGetImageFromCurrentImageContext()
  }
}
