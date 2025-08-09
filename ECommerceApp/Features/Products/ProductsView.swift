import UIKit

final class ProductsView: UIView, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .plain)

    var products: [Product] = [] {
        didSet { tableView.reloadData() }
    }

    var onSelect: ((Int) -> Void)?
    var onAddToCart: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorPalette.background
        setupTable()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupTable() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = ColorPalette.separator
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { products.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.reuseId, for: indexPath) as! ProductCell
        cell.configure(with: products[indexPath.row]) { [weak self] in
            self?.onAddToCart?(indexPath.row)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}