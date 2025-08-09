import Foundation

public protocol FetchProductsUseCase {
    func execute() async throws -> [Product]
}

public final class DefaultFetchProductsUseCase: FetchProductsUseCase {
    private let productRepository: ProductRepository

    public init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }

    public func execute() async throws -> [Product] {
        try await productRepository.fetchProducts()
    }
}