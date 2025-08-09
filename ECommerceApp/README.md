# ECommerce iOS App (UIKit, Programmatic) — Modular, MVVM-C, SOLID

This repository provides a modular e-commerce app skeleton built with UIKit (no storyboards), applying MVVM-C within each feature, and SOLID principles across layers.

- Programmatic UI (UIKit)
- MVVM-C per feature (Model-View-ViewModel-Coordinator)
- Modular architecture with Core, Domain, Data, and Feature modules
- DI via protocols and composition root
- Reusable UI and design system
- Testability and separation of concerns

## Structure

- `App/iOSApp`: App entry, composition root, coordinators, router
- `Modules/Core`: Cross-cutting concerns (logging, networking, persistence, UI, design system)
- `Modules/Domain`: Business models, repository protocols, use cases
- `Modules/Data`: Repository implementations, mappers
- `Features`: Feature modules (Products, ProductDetail, Cart, Checkout, Auth)

```
ECommerceApp/
  App/iOSApp/
  Modules/Core/
    CoreKit/
    NetworkKit/
    PersistenceKit/
    CoreUI/
    DesignSystem/
  Modules/Domain/
  Modules/Data/
  Features/
    Products/
    ProductDetail/
    Cart/
    Checkout/
    Auth/
```

## Dependency diagram

```mermaid
graph TD
  App[App (UIKit)] --> AppSupport[AppSupport / Coordinators]
  App --> CoreUI
  App --> DesignSystem

  AppSupport --> Products
  AppSupport --> ProductDetail
  AppSupport --> Cart
  AppSupport --> Checkout
  AppSupport --> Auth

  subgraph Features
    Products --> Domain
    ProductDetail --> Domain
    Cart --> Domain
    Checkout --> Domain
    Auth --> Domain

    Products --> CoreUI
    Products --> DesignSystem
    ProductDetail --> CoreUI
    Cart --> CoreUI
  end

  subgraph Domain
    Domain --> Data
  end

  subgraph Data
    Data --> NetworkKit
    Data --> PersistenceKit
    Data --> CoreKit
  end

  CoreUI --> DesignSystem
  App --> CoreKit
```

## Key patterns and SOLID

- Single Responsibility: Each module targets one purpose; each class has a focused role
- Open-Closed: Add features without modifying existing code; use protocol-based abstractions
- Liskov Substitution: Program to protocols (repositories, clients)
- Interface Segregation: Small, feature-specific protocols (e.g., `ProductRepository`)
- Dependency Inversion: Features depend on Domain protocols; repositories implement them in Data
- Coordinator: Navigation orchestration per feature
- Repository: Data access abstraction over HTTP/persistence
- Use Case: Encapsulates application-specific business logic

## Programmatic UIKit

- No storyboards; views built with UIKit code
- Reusable components in `CoreUI` + style in `DesignSystem`

## Building/Running

1) Create a new iOS app project in Xcode (UIKit, no storyboard, SceneDelegate enabled)
2) Drag-and-drop the folders from this repo into your project (as groups)
3) Ensure the app target includes the `App/iOSApp` files and links the modules via the target membership
4) Set `SceneDelegate` and `AppDelegate` in your Info.plist if needed

Optionally, convert modules to Swift Packages by wrapping each module as its own SPM package.

## Entry flow

- App starts with `AppCoordinator` which sets the root `UINavigationController`
- `AppCoordinator` starts `ProductsCoordinator` (home)
- Coordinators compose dependencies via `DIContainer`

## Extensibility

- Add features by creating a new folder under `Features/<FeatureName>` with Coordinator, ViewModel, ViewController
- Add new Use Cases and Repository protocols in `Modules/Domain`
- Implement data access in `Modules/Data`, fulfilling the repository protocols

## Testing

- ViewModels are pure and testable
- Use Cases and Repositories are injected via protocols to allow mocking

## Notes

- Example code aims for clarity and scaffolding; adapt to your project conventions
- Networking layer demos composition over inheritance and protocol-driven design

## Step-by-step: what each piece does (MVVM-C per feature)

- App layer
  - `AppDelegate` and `SceneDelegate`: Bootstraps the app, creates `UINavigationController`, `DefaultRouter`, `DIContainer`, and starts `AppCoordinator`.
  - `Router`: Abstraction over navigation to decouple view controllers from UIKit navigation APIs.
  - `AppCoordinator`: Composition root for navigation; starts `ProductsCoordinator`.
  - `DIContainer`: Wires concrete implementations (Data) to abstractions (Domain) and exposes Use Cases to features.

- Core modules (reusability)
  - `CoreKit/Logger`: Minimal logging utility.
  - `NetworkKit/HTTPClient`: Protocol for HTTP; `DefaultHTTPClient` implements it using `URLSession`.
  - `PersistenceKit/KeyValueStore`: Protocol for key-value storage; `UserDefaultsStore` implements it.
  - `CoreUI/BaseViewController`: Generic base VC hosting a strongly-typed root view.
  - `CoreUI/PrimaryButton`: Reusable, themed button.
  - `DesignSystem`: Central tokens for color, spacing, and typography used across features.

- Domain module (SOLID: DI, ISP)
  - Entities: `Product`, `CartItem`.
  - Repositories (protocols): `ProductRepository`, `CartRepository`.
  - Use Cases: `FetchProductsUseCase`, `GetCartItemsUseCase`, `AddToCartUseCase`.

- Data module (Repository pattern)
  - `DefaultProductRepository`: Satisfies `ProductRepository` (static demo data here; swap with real HTTP).
  - `DefaultCartRepository`: Satisfies `CartRepository` (UserDefaults-backed demo persistence).

- Feature: Products (MVVM-C)
  - `ProductsCoordinator`: Sets Products as root; routes to Detail and Cart.
  - `ProductsViewModel`: Loads products, handles selection and add-to-cart; exposes outputs via closures.
  - `ProductsView`: Table view UI with `ProductCell` and add button.
  - `ProductsViewController`: Binds VM to View, handles navigation items.

- Feature: ProductDetail (MVVM-C)
  - `ProductDetailCoordinator`: Pushes the detail screen.
  - `ProductDetailViewModel`: Holds selected product; handles add-to-cart.
  - `ProductDetailViewController`: Displays product info; add-to-cart action.

- Feature: Cart (MVVM-C)
  - `CartCoordinator`: Pushes cart.
  - `CartViewModel`: Loads cart; computes total.
  - `CartViewController`: Lists items; shows total.

### Design choices mapped to SOLID and patterns
- **Dependency Inversion**: Features depend on Domain protocols; Data implements them. `DIContainer` injects Use Cases.
- **Interface Segregation**: Small protocol surfaces (per repo, per use case). ViewModels expose minimal closures.
- **Single Responsibility**: Each class has one reason to change (e.g., `ProductDetailViewModel` handles only product detail behavior).
- **Open/Closed**: New features/repos can be added without changing consumers; extend `DIContainer` wiring.
- **Coordinator pattern**: Centralizes navigation; VCs are lean.
- **Repository + Use Case**: Clear separation between data access and business rules.

### Replace demo data with real API
- Implement endpoints in `DefaultProductRepository` using `HTTPClient.request(_:)` and JSON decoding.
- Consider adding `ImageLoader` and caching in Core for product images.