import UIKit

final class ProductDetailCoordinator: BaseCoordinator {
    private let router: Router
    private let diContainer: DIContainer
    private let product: Product

    init(router: Router, diContainer: DIContainer, product: Product) {
        self.router = router
        self.diContainer = diContainer
        self.product = product
    }

    override func start() {
        let viewModel = ProductDetailViewModel(product: product, addToCart: diContainer.addToCartUseCase)
        let viewController = ProductDetailViewController(viewModel: viewModel)
        router.push(viewController, animated: true)
    }
}