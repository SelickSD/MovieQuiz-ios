import UIKit

extension UIColor {

    private static func getColorForName(_ colorName: String) -> UIColor {
        UIColor(named: colorName) ?? UIColor.white
    }

    static var ypGreen: UIColor {
        self.getColorForName("YP Green")
    }

    static var ypRed: UIColor {
        self.getColorForName("YP Red")
    }

    static var ypBlack: UIColor {
        self.getColorForName("YP Black")
    }

}
