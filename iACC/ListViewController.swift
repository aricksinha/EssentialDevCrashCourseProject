//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

//MARK: - Notes
/*
 - We saw a lot of if else statements - voilates OCP
 
 - Fatal Error is violates Liskov Substitution Principle - interface here says that u can handle any type but fatal error says it can't.It crashes if Item is not a friend, card or transfer
 
 -
 
 */
class ListViewController: UITableViewController {
	var items = [ItemViewModel]()
	
	var retryCount = 0
	var maxRetryCount = 0
	var shouldRetry = false
	
	var longDateStyle = false
	
	var fromReceivedTransfersScreen = false
	var fromSentTransfersScreen = false
	var fromCardsScreen = false
	var fromFriendsScreen = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		refreshControl = UIRefreshControl()
		refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
		
		if fromFriendsScreen {
			shouldRetry = true
			maxRetryCount = 2
			
			title = "Friends"
			
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
			
		} else if fromCardsScreen {
			shouldRetry = false
			
			title = "Cards"
			
			navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCard))
			
		} else if fromSentTransfersScreen {
			shouldRetry = true
			maxRetryCount = 1
			longDateStyle = true

			navigationItem.title = "Sent"
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendMoney))

		} else if fromReceivedTransfersScreen {
			shouldRetry = true
			maxRetryCount = 1
			longDateStyle = false
			
			navigationItem.title = "Received"
			navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .done, target: self, action: #selector(requestMoney))
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if tableView.numberOfRows(inSection: 0) == 0 {
			refresh()
		}
	}
	
	@objc private func refresh() {
		refreshControl?.beginRefreshing()
		if fromFriendsScreen {
            // Step 4.1: Map the result into ItemViewModel - No type checking.
            // Move logic where we know the context so that no typecasting is needed
			FriendsAPI.shared.loadFriends { [weak self] result in
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
		} else if fromCardsScreen {
			CardAPI.shared.loadCards { [weak self] result in
				DispatchQueue.mainAsyncIfNeeded {
					self?.handleAPIResult(result.map{ items in
                        items.map { card in
                            ItemViewModel(card: card) {
                                self?.select(card: card)
                            }
                        }
                    })
				}
			}
		} else if fromSentTransfersScreen || fromReceivedTransfersScreen {
			TransfersAPI.shared.loadTransfers { [weak self, longDateStyle, fromSentTransfersScreen] result in
				DispatchQueue.mainAsyncIfNeeded {
                    self?.handleAPIResult(result.map{
                        items in
                        items
                            .filter{ fromSentTransfersScreen ? $0.isSender : !$0.isSender }
                            .map { transfer in
                                ItemViewModel(transfer: transfer, longDateStyle: longDateStyle) {
                                    self?.select(transfer: transfer)
                                }
                            }
                    })
				}
			}
		} else {
			fatalError("unknown context")
		}
	}
	
    // Step 4.1 : Instead of accepting T , accept ItemViewModel, remove Generics
    // Step 4.2: Everything that context specific should moe out of this method like fromFriendsScreen && User.shared?.isPremium == true logic[only for friend screen &when user is premium] , move it out, to make VC reusable
    // Step 4.3: if we want to transfer money we need to filter the transfer list
           // filteredItems = transfers.filter(\.isSender) - Sender transfer else Receiver transfer
    // let move this logic out of chain to a place where it has context
	private func handleAPIResult(_ result: Result<[ItemViewModel], Error>) {
		switch result {
		case let .success(items):
			self.retryCount = 0
            // Step 4: In this context we don't know the type
            self.items = items
			self.refreshControl?.endRefreshing()
			self.tableView.reloadData()
			
		case let .failure(error):
			if shouldRetry && retryCount < maxRetryCount {
				retryCount += 1
				refresh()
				return
			}
			
			retryCount = 0
			
			if fromFriendsScreen && User.shared?.isPremium == true {
				(UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).cache.loadFriends { [weak self] result in
					DispatchQueue.mainAsyncIfNeeded {
						switch result {
						case let .success(items):
                            self?.items = items.map { item in
                                ItemViewModel(friend: item, selection: { [weak self] in
                                    self?.select(friend: item)
                                })
                            }
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
    
    init(_ item: Any, longDateStyle: Bool, selection: @escaping () -> Void) {
        if let friend = item as? Friend {
            self.init(friend: friend, selection: selection)
        } else if let card = item as? Card {
            self.init(card: card, selection: selection)
        } else if let transfer = item as? Transfer {
            self.init(transfer: transfer, longDateStyle: longDateStyle, selection: selection)
        } else {
            fatalError("unknown item: \(item)")
        }
    }
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
