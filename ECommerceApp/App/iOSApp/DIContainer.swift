import Foundation

final class DIContainer {
    // Core
    private lazy var httpClient: HTTPClient = DefaultHTTPClient()
    private lazy var keyValueStore: KeyValueStore = UserDefaultsStore()

    // Data
    private lazy var productRepository: ProductRepository = DefaultProductRepository(httpClient: httpClient)
    private lazy var cartRepository: CartRepository = DefaultCartRepository(store: keyValueStore)

    // Domain Use Cases
    lazy var fetchProductsUseCase: FetchProductsUseCase = DefaultFetchProductsUseCase(productRepository: productRepository)
    lazy var getCartItemsUseCase: GetCartItemsUseCase = DefaultGetCartItemsUseCase(cartRepository: cartRepository)
    lazy var addToCartUseCase: AddToCartUseCase = DefaultAddToCartUseCase(cartRepository: cartRepository)
}