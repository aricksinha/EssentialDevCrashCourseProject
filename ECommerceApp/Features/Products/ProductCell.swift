import UIKit

final class ProductCell: UITableViewCell {
    static let reuseId = "ProductCell"

    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let addButton = PrimaryButton(type: .system)

    private var onAdd: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        selectionStyle = .none

        nameLabel.font = Typography.body
        priceLabel.font = Typography.caption
        priceLabel.textColor = ColorPalette.textSecondary

        addButton.setTitle("Add", for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        let labelsStack = UIStackView(arrangedSubviews: [nameLabel, priceLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = Spacing.xsmall

        let container = UIStackView(arrangedSubviews: [labelsStack, addButton])
        container.axis = .horizontal
        container.spacing = Spacing.medium
        container.alignment = .center

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Spacing.medium),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Spacing.medium),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Spacing.medium),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Spacing.medium)
        ])
    }

    func configure(with product: Product, onAdd: @escaping () -> Void) {
        nameLabel.text = product.name
        priceLabel.text = product.priceFormatted
        self.onAdd = onAdd
    }

    @objc private func addTapped() { onAdd?() }
}