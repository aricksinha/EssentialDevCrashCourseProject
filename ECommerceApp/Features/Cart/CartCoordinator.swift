import UIKit

final class CartCoordinator: BaseCoordinator {
    private let router: Router
    private let diContainer: DIContainer

    init(router: Router, diContainer: DIContainer) {
        self.router = router
        self.diContainer = diContainer
    }

    override func start() {
        let viewModel = CartViewModel(getCartItems: diContainer.getCartItemsUseCase)
        let viewController = CartViewController(viewModel: viewModel)
        router.push(viewController, animated: true)
    }
}