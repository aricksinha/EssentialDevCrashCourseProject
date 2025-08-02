//	
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    private var friendsCache: FriendsCache!
    
    convenience init(friendsCache: FriendsCache) {
		self.init(nibName: nil, bundle: nil)
        self.friendsCache = friendsCache
		self.setupViewController()
	}

	private func setupViewController() {
		viewControllers = [
			makeNav(for: makeFriendsList(), title: "Friends", icon: "person.2.fill"),
			makeTransfersList(),
			makeNav(for: makeCardsList(), title: "Cards", icon: "creditcard.fill")
		]
	}
	
	private func makeNav(for vc: UIViewController, title: String, icon: String) -> UIViewController {
		vc.navigationItem.largeTitleDisplayMode = .always
		
		let nav = UINavigationController(rootViewController: vc)
		nav.tabBarItem.image = UIImage(
			systemName: icon,
			withConfiguration: UIImage.SymbolConfiguration(scale: .large)
		)
		nav.tabBarItem.title = title
		nav.navigationBar.prefersLargeTitles = true
		return nav
	}
	
	private func makeTransfersList() -> UIViewController {
		let sent = makeSentTransfersList()
		sent.navigationItem.title = "Sent"
		sent.navigationItem.largeTitleDisplayMode = .always
		
		let received = makeReceivedTransfersList()
		received.navigationItem.title = "Received"
		received.navigationItem.largeTitleDisplayMode = .always
		
		let vc = SegmentNavigationViewController(first: sent, second: received)
		vc.tabBarItem.image = UIImage(
			systemName: "arrow.left.arrow.right",
			withConfiguration: UIImage.SymbolConfiguration(scale: .large)
		)
		vc.title = "Transfers"
		vc.navigationBar.prefersLargeTitles = true
		return vc
	}
	
	private func makeFriendsList() -> ListViewController {
		let vc = ListViewController()
		vc.fromFriendsScreen = true
        vc.shouldRetry = true
        vc.maxRetryCount = 2
        vc.title = "Friends"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: vc, action: #selector(addFriend))
        
        let isPremium = User.shared?.isPremium == true
        vc.service =  FriendsAPIItemServiceAdapter(
            api: FriendsAPI.shared,
            cache: isPremium ? friendsCache : NullFriendsCache(),
            select: { [weak vc] item in
                vc?.select(friend: item)
            })
		return vc
	}
	
	private func makeSentTransfersList() -> ListViewController {
		let vc = ListViewController()
		vc.fromSentTransfersScreen = true
        vc.shouldRetry = true
        vc.maxRetryCount = 1
        vc.longDateStyle = true

        vc.navigationItem.title = "Sent"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: vc, action: #selector(sendMoney))
        vc.service = SendTransfersAPIItemServiceAdapter(
            api: TransfersAPI.shared,
            select: { [weak vc] transfer in
            vc?.select(transfer: transfer)
        })
		return vc
	}
	
	private func makeReceivedTransfersList() -> ListViewController {
		let vc = ListViewController()
		vc.fromReceivedTransfersScreen = true
        vc.shouldRetry = true
        vc.maxRetryCount = 1
        vc.longDateStyle = false
        vc.navigationItem.title = "Received"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .done, target: vc, action: #selector(requestMoney))
        vc.service = ReceivedTransfersAPIItemServiceAdapter(
            api: TransfersAPI.shared,
            select: { [weak vc] transfer in
            vc?.select(transfer: transfer)
        })
		return vc
	}
	
	private func makeCardsList() -> ListViewController {
		let vc = ListViewController()
		vc.fromCardsScreen = true
        vc.shouldRetry = false
        vc.title = "Cards"
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: vc, action: #selector(addCard))
        vc.service = CardsAPIItemServiceAdapter(api: CardAPI.shared, select: { [weak vc] item in
            vc?.select(card: item)
        })
		return vc
	}
	
}

// Also refer to SRPandDIP violation image
//We don't want to couple the API with VC coz we want to use many diff APIs & easily plugin API, remove API
/// To mitigate this problem use **ADAPTER PATTREN** to adapt the communication b/t 2 component w/o coupling them. Look at the Adapter pattern diagram
struct FriendsAPIItemServiceAdapter: ItemsService {
    let api: FriendsAPI
    let cache: FriendsCache
    let select: (Friend) -> Void  // inject logic from outside this class
    
    func loadItems(completion: @escaping (Result<[ItemViewModel], any Error>) -> Void) {
        api.loadFriends {  result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map{ items in
                    cache.save(items) // removed isPremium check & always send a msg but if we send this msg to NullFriendsCache and do nothing otherwise do something
                   return items.map { friend in
                        ItemViewModel(friend: friend) {
                            select(friend)
                        }
                    }
                })
            }
        }
    }
}

/// **NULL OBJECT PATTERN** - Defines a instance with same interface but does nothing.Ex given below
class NullFriendsCache: FriendsCache {
    override func save(_ newFriends: [Friend]) {}
}

//STEP-6: Extract logic for Cards
struct CardsAPIItemServiceAdapter: ItemsService {
    let api: CardAPI
    let select: (Card) -> Void // inject logic from outside this class
    
    func loadItems(completion: @escaping (Result<[ItemViewModel], any Error>) -> Void) {
        api.loadCards { items in
            DispatchQueue.mainAsyncIfNeeded {
                completion(items.map{ items in
                    items.map { card in
                        ItemViewModel(card: card) {
                            select(card)
                        }
                    }
                })
            }
        }
    }
}

struct SendTransfersAPIItemServiceAdapter: ItemsService {
    let api: TransfersAPI
    let select: (Transfer) -> Void  // inject logic from outside this class
    
    func loadItems(completion: @escaping (Result<[ItemViewModel], any Error>) -> Void) {
        api.loadTransfers {  result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map{
                    items in
                    items
                        .filter{ $0.isSender }
                        .map { transfer in
                            ItemViewModel(transfer: transfer, longDateStyle: true) {
                                select(transfer)
                            }
                        }
                })
            }
        }
    }
}

struct ReceivedTransfersAPIItemServiceAdapter: ItemsService {
    let api: TransfersAPI
    let select: (Transfer) -> Void  // inject logic from outside this class
    
    func loadItems(completion: @escaping (Result<[ItemViewModel], any Error>) -> Void) {
        api.loadTransfers {  result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map{
                    items in
                    items
                        .filter{ !$0.isSender }
                        .map { transfer in
                            ItemViewModel(transfer: transfer, longDateStyle: false) {
                                select(transfer)
                            }
                        }
                })
            }
        }
    }
}
