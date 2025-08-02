//	
// Copyright © Essential Developer. All rights reserved.
//

import SwiftUI

struct ListView: View {
    @State private var items = [ItemViewModel]()
    @State private var error: Error?
    var service: ItemsService?
    
    private var isShowingError: Binding<Bool> {
        Binding(get: {error != nil }, set: {_ in
            error = nil
        })
    }
    
    var body: some View {
        List(items, id: \.title) { item in
            Button(action: { item.select() }) {
                VStack(alignment: .leading) {
                    Text(item.title)
                    Text(item.subtitle)
                        .font(.caption)
                }
            }
        }
        .refreshable { await refresh() }
        .task {
            if items.isEmpty {
                await refresh() /// equivalent modifier to onAppear but onAppear can't handle async methods
            }
        }
        .alert("Error",
               isPresented: isShowingError,
               actions: {}) {
            if let message = error?.localizedDescription {
                Text(message)
            }
        }
    }
    
    // async method refresh coz refreshable modifier requires async action to control the refresh state
    private func refresh() async {
        do {
            if let service = service {
                self.items = try await service.loadItems()
            }
        } catch {
            self.error = error
        }
    }
}

// Implementation of async loadItem()
extension ItemsService {
    func loadItems() async throws -> [ItemViewModel] {
        try await withCheckedThrowingContinuation { continuation in
            loadItems { result in
                switch result {
                case let .success(items):
                    continuation.resume(returning: items)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
