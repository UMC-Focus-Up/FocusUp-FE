//
//  UIView+Extension.swift
//  Catstagram
//
//  Created by 김서윤 on 5/4/24.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0 ? false : layer.masksToBounds
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let cgColor = layer.shadowColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIFont {
    
    enum pretendardFontName: String {
        case regular    = "Pretendard-Regular"
        case thin       = "Pretendard-Thin"
        case extralight = "Pretendard-ExtraLight"
        case light      = "Pretendard-Light"
        case medium     = "Pretendard-Medium"
        case semibold   = "Pretendard-SemiBold"
        case bold       = "Pretendard-Bold"
        case extrabold  = "Pretendard-ExtraBold"
        case black      = "Pretendard-Black"
    }
    
    class func pretendardRegular(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.regular.rawValue, size: size)!
    }
    
    class func pretendardThin(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.thin.rawValue, size: size)!
    }
    
    class func pretendardExtralight(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.extralight.rawValue, size: size)!
    }
    
    class func pretendardLight(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.light.rawValue, size: size)!
    }
    
    class func pretendardMedium(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.medium.rawValue, size: size)!
    }
    
    class func pretendardSemibold(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.semibold.rawValue, size: size)!
    }
    
    class func pretendardBold(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.bold.rawValue, size: size)!
    }
    
    class func pretendardExtrabold(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.extrabold.rawValue, size: size)!
    }
    
    class func pretendardBlack(size: CGFloat) -> UIFont {
        return UIFont(name: pretendardFontName.black.rawValue, size: size)!
    }
}
