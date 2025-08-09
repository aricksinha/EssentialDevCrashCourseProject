import Foundation

public final class DefaultCartRepository: CartRepository {
    private let store: KeyValueStore
    private let key = "cart_items"

    public init(store: KeyValueStore) {
        self.store = store
    }

    public func cartItems() async throws -> [CartItem] {
        try store.get([CartItem].self, forKey: key) ?? []
    }

    public func add(product: Product) async throws {
        var items = try await cartItems()
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            let existing = items[index]
            items[index] = CartItem(product: existing.product, quantity: existing.quantity + 1)
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
        try store.set(items, forKey: key)
    }
}