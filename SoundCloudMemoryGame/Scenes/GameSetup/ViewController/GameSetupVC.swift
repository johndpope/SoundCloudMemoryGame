
import UIKit
import ReactiveCocoa
import ReactiveSwift

class GameSetupVC: UIViewController {
    
    // MARK: --=== Dependencies ==---
    
    var gameSettings: GameSettings!
    
    var viewModel: GameSetupVM!

    
    // MARK: --=== Public ==---
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Memory Game", comment: "Game setup controller title")
        
        setupVMBindings()
        prepareButtons(values: gameSettings.availableGames.keys.sorted())
    }

    
    // MARK: --=== Private ==---
    
    @IBOutlet weak var buttonBar: UIStackView!
    
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView! {
        didSet { activityIndicator.isHidden = true }
    }

    @IBOutlet fileprivate weak var downloadingImagesLabel: UILabel! {
        didSet { downloadingImagesLabel.isHidden = true }
    }
    
    fileprivate func prepareButtons(values: [Int]) {
        values.forEach { (value) in
            let button = ChooseCountButton(with: value)
            button.addTarget(self, action: #selector(pressButtonAction(_:)), for: .touchUpInside)
            buttonBar.addArrangedSubview(button)
        }
    }
    
    fileprivate func setupVMBindings() {
        // Setup bindings
        viewModel.state.producer
            .observe(on: UIScheduler())
            .take(during: self.reactive.lifetime)
            .startWithValues { [unowned self] (state) in
                self.isLoadingIndicatorVisible = (state == .loadingImages)
                
                if case let .error(error) = state {
                    self.showAlert(for: error)
                }
        }
    }
}


// MARK: --=== Actions ==---

extension GameSetupVC {
    
    func pressButtonAction(_ sender: ChooseCountButton) {
        viewModel.prepareGame(with: sender.count)
    }
    
    fileprivate func showAlert(for error: Error) {
        UIAlertController.showAlert(for: error, from: navigationController ?? self)
    }
}


extension GameSetupVC {

    var isLoadingIndicatorVisible: Bool {
        set {
            activityIndicator?.isHidden = !newValue
            downloadingImagesLabel?.isHidden = !newValue
        }
        
        get {
            return (downloadingImagesLabel.isHidden || activityIndicator.isHidden) == false
        }
    }
}
