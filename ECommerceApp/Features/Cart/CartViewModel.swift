import Foundation

@MainActor
final class CartViewModel {
    private let getCartItems: GetCartItemsUseCase

    private(set) var items: [CartItem] = [] { didSet { onItemsChanged?(items) } }

    var onItemsChanged: (([CartItem]) -> Void)?

    init(getCartItems: GetCartItemsUseCase) {
        self.getCartItems = getCartItems
    }

    func load() async {
        do { items = try await getCartItems.execute() } catch { }
    }

    var totalFormatted: String {
        let totalCents = items.reduce(0) { $0 + $1.subtotalCents }
        let dollars = Double(totalCents) / 100.0
        return String(format: "$%.2f", dollars)
    }
}