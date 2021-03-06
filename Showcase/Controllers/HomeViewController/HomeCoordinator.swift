import UIKit
import RxSwift

final class HomeCoordinator: BaseCoordinator<Void> {
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewModel: HomeViewModelType = HomeViewModel()
        let viewController = HomeViewController(viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
                
        viewModel.outputs.showList
            .flatMap({ [weak self] _ -> Observable<CategoriesCoordinatorResult> in
                guard let self = self else { return Observable.empty() }
                return self.showCategories(on: navigationController)
            })
            .map { (result) -> EventModel? in
                switch result {
                case .event(let event): return event
                case .close: return nil
            }}
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: viewModel.inputs.didAddFavorite)
            .disposed(by: disposeBag)
        
        viewModel.outputs.showProfile
            .flatMap({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                return self.showProfile(on: viewController)
            })
            .subscribe()
            .disposed(by: disposeBag)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return Observable.never()
    }
}

// MARK: - Private
extension HomeCoordinator {
    private func showCategories(on rootViewController: UIViewController) -> Observable<CategoriesCoordinatorResult> {
        let categoriesCoordinator = CategoriesCoordinator(rootViewController: rootViewController)
        return coordinate(to: categoriesCoordinator)
    }
    
    private func showProfile(on rootViewController: UIViewController) -> Observable<Void> {
        let profileCoordinator = ProfileCoordinator(rootViewController: rootViewController)
        return coordinate(to: profileCoordinator)
    }
}
