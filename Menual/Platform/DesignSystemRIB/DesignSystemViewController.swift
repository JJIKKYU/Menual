//
//  DesignSystemViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs
import RxSwift
import SnapKit
import RxRelay
import UIKit

protocol DesignSystemPresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
    var designSystemVariation: [String] { get }
    
    func pressedBoxButtonCell()
    func pressedGnbHeaderCell()
    func pressedListHeaderCell()
    func pressedMomentsCell()
    func pressedDividerCell()
    func pressedCapsuleButtonCell()
    func pressedListButtonCell()
    func pressedFABButtonCell()
}

final class DesignSystemViewController: UIViewController, DesignSystemPresentable, DesignSystemViewControllable {
    var detachRelay: BehaviorRelay<Bool>?
    weak var listener: DesignSystemPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "Design System"
    }
    
    lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.register(DesignSystemCell.self, forCellReuseIdentifier: "DesignSystemCell")
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .white
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        print("이거 됨? \(listener?.designSystemVariation)")
        detachRelay?.accept(true)
    }
    
    func setViews() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.addSubview(naviView)
        self.view.addSubview(tableView)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(44 + UIApplication.topSafeAreaHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - TableView
extension DesignSystemViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DesignSystemCell") as? DesignSystemCell else { return UITableViewCell() }
        
        guard let data = listener?.designSystemVariation else { return UITableViewCell() }
        cell.title = data[safe: indexPath.row] ?? ""
        
        switch data[indexPath.row] {
        case "GNB Header":
            cell.backgroundColor = Colors.tint.main.v400
            break
        case "Badges":
            break
        case "Capsule Button":
            cell.backgroundColor = Colors.tint.main.v400
            break
        case "Box Button":
            cell.backgroundColor = Colors.tint.main.v400
            break
        case "Tabs":
            break
        case "FAB":
            cell.backgroundColor = Colors.tint.main.v400
            break
        case "List Header":
            cell.backgroundColor = Colors.tint.main.v400
            break
        case "Pagination":
            break
        case "Divider":
            cell.backgroundColor = Colors.tint.main.v400
            break
        case "Moments":
            cell.backgroundColor = Colors.tint.main.v400
            break
        case "List":
            cell.backgroundColor = Colors.tint.main.v400
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = listener?.designSystemVariation else { return }
        let selectedData = data[safe: indexPath.row] ?? ""
        print("selectedData = \(selectedData)")
        
        switch selectedData {
        case "GNB Header":
            listener?.pressedGnbHeaderCell()
            break
        case "Badges":
            break
        case "Capsule Button":
            listener?.pressedCapsuleButtonCell()
            break
        case "Box Button":
            listener?.pressedBoxButtonCell()
            break
        case "Tabs":
            break
        case "FAB":
            listener?.pressedFABButtonCell()
            break
        case "List Header":
            listener?.pressedListHeaderCell()
            break
        case "Pagination":
            break
        case "Divider":
            listener?.pressedDividerCell()
            break
        case "Moments":
            listener?.pressedMomentsCell()
            break
        case "List":
            listener?.pressedListButtonCell()
            break
        default:
            break
        }
    }
}
