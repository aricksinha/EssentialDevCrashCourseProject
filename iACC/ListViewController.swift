//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

//MARK: - Notes
/*
 - We saw a lot of if else statements - voilates OCP
 
 - Fatal Error is violates Liskov Substitution Principle - interface here says that u can handle any type but fatal error says it can't.It crashes if Item is not a friend, card or transfer
 
 - Aim is to make this more reusable, flexible , polymorphic in nature, easier to extend
 - We can always replace booleans with polymorphism
 - Post Step 8- Adding new feature lets say Article, nothing changes in ListVC, Cell, itemViewModel, ItemService. Add ArticleAPI w/o coupling it with UI and add ArticleItemServiceAdapter, also Article Model needs to converted to ItemViewModel (refer AddArticleFeaturePostStep8 image)
 */

// STEP 5.1- ABSTRACT INTERFACE for Concreate Dependencies. But still we can't make use of this Protocol well, as FriendAPI: APIService will implement all 3 methods, same issue with CardAPI , TransferAPI so this Protocol violates INTERFACE SEGREGATION PRINCIPLE - ISSUE
/*
 protocol APIService {
    func loadFriends(completion: @escaping (Result<[Friend], any Error>) -> Void)
    func loadCards(completion: @escaping (Result<[Card], any Error>) -> Void)
    func loadTransfers(completion: @escaping (Result<[Transfer], any Error>) -> Void)
}
*/

// STEP 5.2: We need to know VC gets decouple from the concept of having to know which service/method to call. We should have one method only that can load any type-Friend,card,transfer etc.
// Problem with bunch of protocol(FriendsService, CardsService, TransferService) is Violates SRP - Solution is move the decision one level above where u have more context- that means, VC shdn't decide which service to use, We shd define a specific service for the VC witth exactly the VC needs.
// What VC needs? - Array of ItemViewModel. We need a protocol that has a method to load list of ItemViewModel

/*
 protocol FriendsService {
     func loadFriends(completion: @escaping (Result<[Friend], any Error>) -> Void)
 }

 protocol CardsService {
     func loadCards(completion: @escaping (Result<[Card], any Error>) -> Void)
 }

 protocol TransferService {
     func loadTransfers(completion: @escaping (Result<[Transfer], any Error>) -> Void)
 }

 extension FriendsAPI: FriendsService {
     
 }

 extension CardAPI: CardsService {
     
 }

 extension TransfersAPI: TransferService {
     
 }
 */

// Step5.3: Just a abstraction regardless of datasource- API, Cache. This is called STRATEGY PATTERN. When u have 1 interface with many diff implementation/ diff context
protocol ItemsService {
    func loadItems(completion: @escaping (Result<[ItemViewModel], any Error>) -> Void)
}

// Refer to DIPViolation diagram
// If FriendsAPI: ItemsService. We are coupling FriendsAPI(high level component) with low level component(The UI) - DIP Violation. API Implementations(like FriendAPI) are generally generic component Can be used in any apps.API implementation shdn't be coupled with UI in this case UIKit. What if we want to use it with other UI framework like SwiftUI/Appkit/Watchkit etc
/*
extension FriendsAPI: ItemsService {
    func loadItems(completion: @escaping (Result<[ItemViewModel], any Error>) -> Void) {
        <#code#>
    }
}
 */

class ListViewController: UITableViewController {
	var items = [ItemViewModel]()
    var service: ItemsService?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			refresh()
		}
	}
	
	@objc private func refresh() {
		refreshControl?.beginRefreshing()
        // Step 4.1: Map the result into ItemViewModel - No type checking.
        // Move logic where we know the context so that no typecasting is needed
        
        // Fetches data directly from Concreate APIs with if else statements
        // Deals with threading & catching, accessing dependency Globally
        
        // Step 5: To make this VC reusable , we need to eliminate Concreate Dependencies of FriendsAPI, CardsAPI, TransferAPI using **🔥 DEPENDENCY INVERSION PRINCIPLE** 🔥.
        // Need a common abstraction to seperate concreate types, For that abstraction we can use PROTOCOL, CLASS, CLOSURE
        /* - Code moved to
        service?.loadItems { [weak self] result in
            DispatchQueue.mainAsyncIfNeeded {
                self?.handleAPIResult(result.map{ items in
                    if User.shared?.isPremium == true {
                        (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).cache.save(items)
                    }
                   return items.map { friend in
                        ItemViewModel(friend: friend) {
                            self?.select(friend: friend)
                        }
                    }
                })
            }
        }
         */
        service?.loadItems(completion: handleAPIResult)
	}
	
    // Step 4.1 : Instead of accepting T , accept ItemViewModel, remove Generics
    // Step 4.2: Everything that context specific should moe out of this method like fromFriendsScreen && User.shared?.isPremium == true logic[only for friend screen &when user is premium] , move it out, to make VC reusable
    // Step 4.3: if we want to transfer money we need to filter the transfer list
           // filteredItems = transfers.filter(\.isSender) - Sender transfer else Receiver transfer
    // let move this logic out of chain to a place where it has context
	private func handleAPIResult(_ result: Result<[ItemViewModel], Error>) {
		switch result {
		case let .success(items):
            // Step 4: In this context we don't know the type
            self.items = items
			self.refreshControl?.endRefreshing()
			self.tableView.reloadData()
			
		case let .failure(error):
            self.showError(error: error)
            self.refreshControl?.endRefreshing()
            // catching logic - we can have friends cache adapter
            // Step8- still VC needs to know these bool which is a ISSUE.Need to eliminate it
            // cache:ItemService and service:ItemService , VC doesn't abt Concreate Implementation which means we can use another Design Pattern
            /// **COMPOSITE DESIGN PATTERN**- TO compose diff implementation into single one
            /*
			if fromFriendsScreen && User.shared?.isPremium == true {
                
                service?.loadItems { [weak self] result in
					DispatchQueue.mainAsyncIfNeeded {
						switch result {
						case let .success(items):
                            self?.items = items
							self?.tableView.reloadData()
							
						case let .failure(error):
                            self?.showError(error: error)
						}
						self?.refreshControl?.endRefreshing()
					}
				}
                
			} else {
                self.showError(error: error)
				self.refreshControl?.endRefreshing()
			}
             */
		}
	}
    
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = items[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ItemCell")
		cell.configure(item)
		return cell
	}
	
    // Step 1 - create seperate methods for each type-Friend, card and transfer
    // Step 2 - To decouple the View from NavigationController : For that Use UIKit API show() . Using this show() method ,VC doesn't need to know whether the VC is inside the Navigation Controller/SplitVC. Using show() , you can decouple VC from its specific context
    
    // Step 3 - Still had the typecasting. Problem is we don't know the context(type of item: Any). How abt we move the logic out of chain(if else chain) & place it somewhere where we know the context of item
    //    - Step 3.1 - One way to do it add a closure to the ItemViewModel & encapsulate the presentation logic or whatever(that happens when item is selected) : Pretty Generic. Each type has its own selection logic which is injected by someone else hence decouples the ViewModel from the Context , also decouples the VC from the Context
    // Step 4 - Now we don't need to create a ViewModel here any more coz items array is [ItemViewModel], Now we cam add new types , new navigation w/o changing selection logic
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let item = items[indexPath.row]
        item.select()
	}
}

// Instead of Any , pass a type that cell needs- one that has title & subtitle
// If you want to decouple ItemViewModel from concreate types - Friend, Card, Transfer then create custom initializers but as part of extensions and each extensions can go in seperate modules(Transfer Presentation module, Card Presentation Module etc etc). Just make struct of ItemViewModel public & cr8 init for it
// For ex- you can Transfer Module and all the logic related to Transfer can go there ,
struct ItemViewModel {
    let title: String
    let subtitle: String
    let select: () -> Void
}

extension ItemViewModel {
    init(friend: Friend, selection: @escaping () -> Void) {
        title = friend.name
        subtitle = friend.phone
        select = selection
    }
}

extension ItemViewModel {
    init(card: Card, selection: @escaping () -> Void) {
        title = card.number
        subtitle = card.holder
        select = selection
    }
}

// only transfer needs longDataStyle
// These extension can go in transfer Module
extension ItemViewModel {
    init(transfer: Transfer, longDateStyle: Bool, selection: @escaping () -> Void) {
        let numberFormatter = Formatters.number
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = transfer.currencyCode
        
        let amount = numberFormatter.string(from: transfer.amount as NSNumber)!
        title = "\(amount) • \(transfer.description)"
        
        let dateFormatter = Formatters.date
        if longDateStyle {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            subtitle = "Sent to: \(transfer.recipient) on \(dateFormatter.string(from: transfer.date))"
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            subtitle = "Received from: \(transfer.sender) on \(dateFormatter.string(from: transfer.date))"
        }
        select = selection
    }
}

// STEP-10: Can ItemViewModel be protocol? - Yes, coz protocol also allows this goal to allowing new model types w/o changing VC. So VC depends on protocol not on implementation
// Still I will recommend using structure for ItemViewModel is who will implement protocol? - The model, we have issues with using protocol ItemViewModable
protocol ItemViewModable {
    var title: String { get }
    var subtitle: String { get }
    func select()
}

extension Friend: ItemViewModable {
    var title: String { name }
    var subtitle: String { phone }
    // issue with ItemViewModable protocol , it can't use select method, coz select method is supposed to perform nav logic, you don't want ur models to perform nav logic as it couples domain logic with UI detail, with nav details
    // REMEMBER: DOMAIN MODELS SHOULD BE FREE FROM UI, so as to reused across apps with diff UI.
    // So while using protocol for ItemViewModel , u still need to create another type to implement it. So rather use struct
    func select() {}
}


extension UITableViewCell {
    // Ideally cell shouldn't create its own ViewModel so let's move the viewModel one level above
    // Now you can pass any ItemViewModel - friend, card, transfer, article etc etc. Don't need to change the cell anymore , just need to convert Model(from API) into ItemViewModel(UI Model)
	func configure(_ viewModel: ItemViewModel) {
        textLabel?.text = viewModel.title
        detailTextLabel?.text = viewModel.subtitle
	}
}

extension UIViewController {
    func select(friend: Friend) {
        let vc = FriendDetailsViewController()
        vc.friend = friend
        show(vc, sender: self)
    }
    
    func select(card: Card) {
        let vc = CardDetailsViewController()
        vc.card = card
        show(vc, sender: self)
    }
    
    func select(transfer: Transfer) {
        let vc = TransferDetailsViewController()
        vc.transfer = transfer
        show(vc, sender: self)
    }
    
    @objc func addCard() {
        show(AddCardViewController(), sender: self)
    }
    
    @objc func addFriend() {
        show(AddFriendViewController(), sender: self)
    }
    
    @objc func sendMoney() {
        show(SendMoneyViewController(), sender: self)
    }
    
    @objc func requestMoney() {
        show(RequestMoneyViewController(), sender: self)
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        //For decouple VC from context while presenting a model use showDetailVC() UIKit API
        presenterVC.showDetailViewController(alert, sender: self)
    }
}





