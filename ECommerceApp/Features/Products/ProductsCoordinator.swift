import UIKit

protocol ProductsCoordinating: AnyObject {
    func showProductDetail(_ product: Product)
    func showCart()
}

final class ProductsCoordinator: BaseCoordinator, ProductsCoordinating {
    private let router: Router
    private let diContainer: DIContainer

    init(router: Router, diContainer: DIContainer) {
        self.router = router
        self.diContainer = diContainer
    }

    override func start() {
        let viewModel = ProductsViewModel(fetchProducts: diContainer.fetchProductsUseCase,
                                          addToCart: diContainer.addToCartUseCase)
        let viewController = ProductsViewController(viewModel: viewModel)
        viewModel.coordinator = self
        router.setRoot(viewController, hideBar: false)
    }

    func showProductDetail(_ product: Product) {
        let coordinator = ProductDetailCoordinator(router: router, diContainer: diContainer, product: product)
        addChild(coordinator)
        coordinator.start()
    }

    func showCart() {
        let coordinator = CartCoordinator(router: router, diContainer: diContainer)
        addChild(coordinator)
        coordinator.start()
    }
}