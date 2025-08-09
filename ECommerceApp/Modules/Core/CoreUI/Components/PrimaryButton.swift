import UIKit

public final class PrimaryButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    public override init(type buttonType: UIButton.ButtonType) {
        super.init(type: buttonType)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = ColorPalette.primary
        setTitleColor(.white, for: .normal)
        titleLabel?.font = Typography.button
        layer.cornerRadius = 12
        heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}