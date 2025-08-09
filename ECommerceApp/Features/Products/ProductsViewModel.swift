import Foundation

@MainActor
final class ProductsViewModel {
    private let fetchProducts: FetchProductsUseCase
    private let addToCart: AddToCartUseCase

    weak var coordinator: ProductsCoordinating?

    private(set) var products: [Product] = [] {
        didSet { onProductsChanged?(products) }
    }

    var onProductsChanged: (([Product]) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    init(fetchProducts: FetchProductsUseCase, addToCart: AddToCartUseCase) {
        self.fetchProducts = fetchProducts
        self.addToCart = addToCart
    }

    func load() async {
        onLoadingChanged?(true)
        defer { onLoadingChanged?(false) }
        do {
            products = try await fetchProducts.execute()
        } catch {
            onError?(error.localizedDescription)
        }
    }

    func didSelectProduct(at index: Int) {
        guard products.indices.contains(index) else { return }
        coordinator?.showProductDetail(products[index])
    }

    func addProductToCart(at index: Int) async {
        guard products.indices.contains(index) else { return }
        do { try await addToCart.execute(product: products[index]) } catch { onError?(error.localizedDescription) }
    }

    func cartButtonTapped() {
        coordinator?.showCart()
    }
}