import UIKit
import RxSwift

enum EventsCoordiantorResult {
    case event(EventModel)
}

final class EventsCoordinator: BaseCoordinator<EventsCoordiantorResult> {
    private let rootViewController: UIViewController
    private let model: EventCategoryModel
    
    init(rootViewController: UIViewController, with model: EventCategoryModel) {
        self.rootViewController = rootViewController
        self.model = model
    }
    
    override func start() -> Observable<EventsCoordiantorResult> {
        let viewModel = EventDetailViewModel(model: model)
        let viewController = EventDetailViewController(viewModel)
        
        (rootViewController as? UINavigationController)?
            .pushViewController(viewController, animated: true)
        
        return viewModel.outputs.selectedEvent.map { EventsCoordiantorResult.event($0) }
            .do(onNext: { [weak self] _ in self?.rootViewController.dismiss(animated: true) })
    }
}
