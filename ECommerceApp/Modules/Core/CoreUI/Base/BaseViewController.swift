import UIKit

open class BaseViewController<ViewType: UIView>: UIViewController {
    public let rootView: ViewType

    public init(rootView: ViewType) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func loadView() {
        view = rootView
    }
}