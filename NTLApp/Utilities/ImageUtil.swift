//
//  ImageUtil.swift
//  NTLApp
//
//  Created by Tripsdoc on 14/08/23.
//

import UIKit

enum CrossMarkStyle: UInt {
    case OpenCircle
    case GrayedOut
}

class CrossMark: UIView {
    var index: Int!
    private var checkedBool: Bool = true
    private var checkMarkStyleReal: CrossMarkStyle=CrossMarkStyle.GrayedOut
    var checked: Bool {
        get {
            return self.checkedBool
        }
        set(checked) {
            self.checkedBool = checked
            self.setNeedsDisplay()
        }
    }
    
    var crossMarkStyle: CrossMarkStyle {
        get {
            return self.crossMarkStyle
        }
        set(crossMarkStyle) {
            self.crossMarkStyle = crossMarkStyle
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawRectChecked(rect: rect)
    }
    
    func drawRectChecked(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let checkmarkRed = UIColor.red
        let shadow2 = UIColor.black

        let shadow2Offset = CGSize(width: 0.1, height: -0.1)
        let shadow2BlurRadius = 2.5
        let frame = self.bounds
        let group = CGRect(x: frame.minX + 3, y: frame.minY + 3, width: frame.width - 6, height: frame.height - 6)

        let checkedOvalPath = UIBezierPath(ovalIn: CGRect(x: group.minX + floor(group.width * 0.00000 + 0.5), y: group.minY + floor(group.height * 0.00000 + 0.5), width: floor(group.width * 1.00000 + 0.5) - floor(group.width * 0.00000 + 0.5), height: floor(group.height * 1.00000 + 0.5) - floor(group.height * 0.00000 + 0.5)))

        context!.saveGState()
        context!.setShadow(offset: shadow2Offset, blur: CGFloat(shadow2BlurRadius), color: shadow2.cgColor)
        checkmarkRed.setFill()
        checkedOvalPath.fill()
        context!.restoreGState()
        UIColor.white.setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: group.minX + 0.25000 * group.width, y: group.minY + 0.25000 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.75000 * group.height))
        bezierPath.move(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.25000 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.25000 * group.width, y: group.minY + 0.75000 * group.height))
        bezierPath.lineCapStyle = CGLineCap.square
        UIColor.white.setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
    }
}

extension UIImage {
    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func getSizeIn(_ type: DataUnits)-> Int64 {

        guard let data = self.pngData() else {
            return 0
        }

        var size: Int64 = 0

        switch type {
        case .byte:
            size = Int64(Double(data.count))
        case .kilobyte:
            size = Int64(Double(data.count) / 1024)
        case .megabyte:
            size = Int64(Double(data.count) / 1024 / 1024)
        case .gigabyte:
            size = Int64(Double(data.count) / 1024 / 1024 / 1024)
        }

        return size
    }
}
