import Foundation

public protocol ProductRepository {
    func fetchProducts() async throws -> [Product]
    func fetchProductDetail(id: String) async throws -> Product
}