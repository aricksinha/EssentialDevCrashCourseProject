import UIKit

final class ProductDetailViewController: UIViewController {
    private let viewModel: ProductDetailViewModel

    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let addButton = PrimaryButton(type: .system)

    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Detail"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        layout()
        bind()
        populate()
    }

    private func layout() {
        nameLabel.font = Typography.title
        descriptionLabel.font = Typography.body
        descriptionLabel.numberOfLines = 0
        priceLabel.font = Typography.body

        addButton.setTitle("Add to Cart", for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [nameLabel, descriptionLabel, priceLabel, addButton])
        stack.axis = .vertical
        stack.spacing = Spacing.medium
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Spacing.large),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Spacing.large),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Spacing.large)
        ])
    }

    private func bind() {
        viewModel.onAddResult = { [weak self] result in
            switch result {
            case .success:
                self?.showToast("Added to cart")
            case .failure(let error):
                self?.showToast(error.localizedDescription)
            }
        }
    }

    private func populate() {
        nameLabel.text = viewModel.product.name
        descriptionLabel.text = viewModel.product.description
        priceLabel.text = viewModel.product.priceFormatted
    }

    @objc private func addTapped() {
        Task { await viewModel.addToCartTapped() }
    }

    private func showToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak alert] in alert?.dismiss(animated: true) }
    }
}