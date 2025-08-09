import Foundation

public struct Product: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let priceCents: Int
    public let imageURL: URL?

    public init(id: String, name: String, description: String, priceCents: Int, imageURL: URL?) {
        self.id = id
        self.name = name
        self.description = description
        self.priceCents = priceCents
        self.imageURL = imageURL
    }

    public var priceFormatted: String {
        let dollars = Double(priceCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
}