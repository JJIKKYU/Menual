//
//  ListViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/28.
//

import RIBs
import RxSwift
import UIKit
import Then
import SnapKit

protocol ListPresentableListener: AnyObject {

    func pressedBackBtn(isOnlyDetach: Bool)
}

final class ListViewController: UIViewController, ListPresentable, ListViewControllable {

    weak var listener: ListPresentableListener?
    
    lazy var naviView = MenualNaviView(type: .moments).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        $0.backButton.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.titleLabel.text = "List"
    }
    
    lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        $0.estimatedRowHeight = 72
        $0.rowHeight = 72
        $0.contentInset.top = 44
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
        view.backgroundColor = Colors.background.black
        setViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
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
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    func pressedBackBtn() {
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - UITableView Delegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return UITableViewCell() }
        
        let index = indexPath.row
        
        
        switch index {
        case 0:
            cell.listType = .text
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.dateAndTime = "2099.99.99"
            cell.pageAndReview = "P.999"
        case 1:
            cell.listType = .text
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.dateAndTime = "2099.99.99"
            cell.pageAndReview = "P.999 - 999"
        case 2:
            cell.listType = .textAndImage
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.dateAndTime = "2099.99.99"
            cell.pageAndReview = "P.999"
        case 3:
            cell.listType = .textAndImage
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.dateAndTime = "2099.99.99"
            cell.pageAndReview = "P.999 - 999"
        case 4:
            cell.listType = .hide
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.dateAndTime = "2099.99.99"
            cell.pageAndReview = "P.999"
        case 5:
            cell.listType = .hide
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.dateAndTime = "2099.99.99"
            cell.pageAndReview = "P.999 - 999"
        default:
            break
        }
        
        return cell
    }
    
    
}
