import Foundation

public struct CartItem: Codable, Hashable, Identifiable {
    public let id: String
    public let product: Product
    public let quantity: Int

    public init(product: Product, quantity: Int) {
        self.id = product.id
        self.product = product
        self.quantity = quantity
    }

    public var subtotalCents: Int { product.priceCents * quantity }
}