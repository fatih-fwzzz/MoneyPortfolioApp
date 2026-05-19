import UIKit

enum AppTheme {
    enum Colors {
        static let primaryOrange = UIColor(hex: "#F57C00")
        static let secondaryTeal = UIColor(hex: "#4DD0C4")
        static let accentLime = UIColor(hex: "#CDDC39")
        static let deepCocoa = UIColor(hex: "#712D00")
        static let offWhite = UIColor(hex: "#F5F5F5")
        static let cardBackground = UIColor.white
        static let mutedText = UIColor(white: 0.42, alpha: 1)
        static let separator = UIColor(white: 0.9, alpha: 1)
    }

    enum Fonts {
        static func displayBold() -> UIFont {
            UIFont(name: "Poppins-Bold", size: 28) ?? .systemFont(ofSize: 28, weight: .bold)
        }

        static func headlineMedium() -> UIFont {
            UIFont(name: "Poppins-SemiBold", size: 20) ?? .systemFont(ofSize: 20, weight: .semibold)
        }

        static func bodyRegular() -> UIFont {
            UIFont(name: "Poppins-Regular", size: 14) ?? .systemFont(ofSize: 14, weight: .regular)
        }
    }

    enum Radius {
        static let large: CGFloat = 24
        static let standard: CGFloat = 16
        static let pill: CGFloat = 999
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = CGFloat((int >> 16) & 0xFF) / 255
        let g = CGFloat((int >> 8) & 0xFF) / 255
        let b = CGFloat(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

