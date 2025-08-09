import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []

    func start() { }

    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

final class AppCoordinator: BaseCoordinator {
    private let router: Router
    private let diContainer: DIContainer

    init(router: Router, diContainer: DIContainer) {
        self.router = router
        self.diContainer = diContainer
    }

    override func start() {
        let productsCoordinator = ProductsCoordinator(router: router, diContainer: diContainer)
        addChild(productsCoordinator)
        productsCoordinator.start()
    }
}