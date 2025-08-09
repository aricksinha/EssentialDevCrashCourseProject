import Foundation

@MainActor
final class ProductDetailViewModel {
    private let addToCart: AddToCartUseCase
    let product: Product

    var onAddResult: ((Result<Void, Error>) -> Void)?

    init(product: Product, addToCart: AddToCartUseCase) {
        self.product = product
        self.addToCart = addToCart
    }

    func addToCartTapped() async {
        do {
            try await addToCart.execute(product: product)
            onAddResult?(.success(()))
        } catch {
            onAddResult?(.failure(error))
        }
    }
}