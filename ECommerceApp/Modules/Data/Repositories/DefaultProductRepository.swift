import Foundation

public final class DefaultProductRepository: ProductRepository {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    public func fetchProducts() async throws -> [Product] {
        // For demo, return static data instead of a real request
        return [
            Product(id: "1", name: "Coffee Beans", description: "Freshly roasted arabica.", priceCents: 1299, imageURL: nil),
            Product(id: "2", name: "Ceramic Mug", description: "Handmade mug.", priceCents: 1899, imageURL: nil)
        ]
    }

    public func fetchProductDetail(id: String) async throws -> Product {
        try await fetchProducts().first { $0.id == id } ?? {
            throw NSError(domain: "ProductNotFound", code: 404)
        }()
    }
}