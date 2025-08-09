import UIKit

final class CartViewController: UIViewController, UITableViewDataSource {
    private let viewModel: CartViewModel

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let totalLabel = UILabel()

    init(viewModel: CartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Cart"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        layout()
        bind()
        Task { await viewModel.load() }
    }

    private func layout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        totalLabel.font = Typography.title
        totalLabel.textAlignment = .right

        let footer = UIView()
        footer.addSubview(totalLabel)
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            totalLabel.topAnchor.constraint(equalTo: footer.topAnchor, constant: Spacing.medium),
            totalLabel.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -Spacing.large),
            totalLabel.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -Spacing.medium)
        ])
        footer.frame.size.height = 60
        tableView.tableFooterView = footer

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bind() {
        viewModel.onItemsChanged = { [weak self] _ in
            self?.tableView.reloadData()
            self?.totalLabel.text = "Total: \(self?.viewModel.totalFormatted ?? "$")"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = viewModel.items[indexPath.row]
        var config = UIListContentConfiguration.valueCell()
        config.text = item.product.name
        config.secondaryText = "x\(item.quantity) — \(item.product.priceFormatted)"
        cell.contentConfiguration = config
        return cell
    }
}