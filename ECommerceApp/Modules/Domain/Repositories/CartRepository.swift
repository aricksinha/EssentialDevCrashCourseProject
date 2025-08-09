import Foundation

public protocol CartRepository {
    func cartItems() async throws -> [CartItem]
    func add(product: Product) async throws
}