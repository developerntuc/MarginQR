import Foundation
import CoreImage
import UIKit

public struct MarginQR {
    /// A single letter specifying the error correction format. An NSString object whose display name is CorrectionLevel
    public enum CorrectionLevel: String {
        /// 7%
        case l = "L"
        /// 15%
        case m = "M"
        /// 25%
        case q = "Q"
        /// 30%
        case h = "H"
    }
    
    let message: String
    let correctionLevel: CorrectionLevel
    let quietZone: Int
    let scale: CGFloat
    
    /// Generates a Quick Response code (two-dimensional barcode) from input data.
    ///
    /// Generates an output image representing the input data according to the ISO/IEC 18004:2006 standard. The width and height of each module (square dot) of the code in the output image is one point. To create a QR code from a string or URL, convert it to an NSData object using the NSISOLatin1StringEncoding string encoding.
    /// The inputCorrectionLevel parameter controls the amount of additional data encoded in the output image to provide error correction. Higher levels of error correction result in larger output images but allow larger areas of the code to be damaged or obscured without.
    /// - Parameters:
    ///   - message: The data to be encoded as a QR code. An NSData object whose display name is Message.
    ///   - correctionLevel: A single letter specifying the error correction format. An NSString object whose display name is CorrectionLevel. Default is *M*
    ///   - quietZone: The margin is a clear area around a symbol where nothing is printed. Default is *4*
    ///   - scale: The output image scale. Default is *5*
    public init(message: String,
                correctionLevel: CorrectionLevel = .m,
                quietZone: Int = 4,
                scale: CGFloat = 5.0) {
        self.message = message
        self.correctionLevel = correctionLevel
        self.quietZone = quietZone
        self.scale = scale
    }
    
    var ciImage: CIImage? {
        guard let filter = CIFilter.init(name: "CIQRCodeGenerator",
                                         parameters: ["inputMessage": message.data(using: .utf8),
                                                      "inputCorrectionLevel": correctionLevel.rawValue]),
              let output = filter.outputImage else { return nil }
        
        return output.transformed(by: .init(scaleX: scale, y: scale))
    }
    
    public var uiImage: UIImage? {
        guard let image = ciImage,
              let cgImage = CIContext().createCGImage(image, from: image.extent),
              let moduleWide = cgImage.qrModuleWide,
              let output = cgImage.uiImageWith(quietZone: quietZone, moduleWide: moduleWide) else { return nil }
        return output
    }
}
