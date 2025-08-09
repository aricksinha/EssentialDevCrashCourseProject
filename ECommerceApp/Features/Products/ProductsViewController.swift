import UIKit

final class ProductsViewController: BaseViewController<ProductsView> {
    private let viewModel: ProductsViewModel

    init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
        super.init(rootView: ProductsView())
        title = "Products"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cart", style: .plain, target: self, action: #selector(cartTapped))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        Task { await viewModel.load() }
    }

    private func bind() {
        rootView.onSelect = { [weak self] index in self?.viewModel.didSelectProduct(at: index) }
        rootView.onAddToCart = { [weak self] index in Task { await self?.viewModel.addProductToCart(at: index) } }
        viewModel.onProductsChanged = { [weak self] products in self?.rootView.products = products }
        viewModel.onError = { [weak self] message in self?.showAlert(message: message) }
    }

    @objc private func cartTapped() { viewModel.cartButtonTapped() }

    private func showAlert(title: String = "Error", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}