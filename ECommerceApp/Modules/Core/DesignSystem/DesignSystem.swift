import UIKit

public enum ColorPalette {
    public static let primary = UIColor.systemBlue
    public static let background = UIColor.systemBackground
    public static let textPrimary = UIColor.label
    public static let textSecondary = UIColor.secondaryLabel
    public static let separator = UIColor.separator
}

public enum Spacing {
    public static let xsmall: CGFloat = 4
    public static let small: CGFloat = 8
    public static let medium: CGFloat = 16
    public static let large: CGFloat = 24
}

public enum Typography {
    public static let title = UIFont.preferredFont(forTextStyle: .title2)
    public static let body = UIFont.preferredFont(forTextStyle: .body)
    public static let caption = UIFont.preferredFont(forTextStyle: .caption1)
    public static let button = UIFont.preferredFont(forTextStyle: .headline)
}