import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        let router = DefaultRouter(navigationController: navigationController)
        let diContainer = DIContainer()
        let appCoordinator = AppCoordinator(router: router, diContainer: diContainer)
        self.appCoordinator = appCoordinator

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        appCoordinator.start()
    }
}