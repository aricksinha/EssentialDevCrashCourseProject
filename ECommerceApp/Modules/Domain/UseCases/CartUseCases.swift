import Foundation

public protocol GetCartItemsUseCase {
    func execute() async throws -> [CartItem]
}

public protocol AddToCartUseCase {
    func execute(product: Product) async throws
}

public final class DefaultGetCartItemsUseCase: GetCartItemsUseCase {
    private let cartRepository: CartRepository

    public init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }

    public func execute() async throws -> [CartItem] {
        try await cartRepository.cartItems()
    }
}

public final class DefaultAddToCartUseCase: AddToCartUseCase {
    private let cartRepository: CartRepository

    public init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }

    public func execute(product: Product) async throws {
        try await cartRepository.add(product: product)
    }
}