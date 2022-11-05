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
    
    private let tableViewHeader = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100)).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = false
    }
    
    let infoViewTimeHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/TIME"
    }
    
    private let infoViewTime = ListInfoView(type: .time).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let infoViewInfoHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/INFO"
    }
    
    private let infoViewInfo = ListInfoView(type: .info).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let infoViewReviewHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/INFO/REVIEW"
    }
    
    private let infoViewReview = ListInfoView(type: .infoReview).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let infoViewWritingHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/INFO/WRITING"
    }
    
    private let infoViewWriting = ListInfoView(type: .infoWriting).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let listTitleViewTitleHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/TITLE"
    }
    
    private let listTitleViewTitle = ListTitleView(type: .title).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let listTitleViewTitlePictureHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/TITLE/PICTURE"
    }
    
    private let listTitleViewTitlePicture = ListTitleView(type: .titlePicture).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let listTitleViewTitleHideHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/TITLE/HIDE"
    }
    
    private let listTitleViewTitleHide = ListTitleView(type: .titleHide).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let listTitleViewBodyTextHeader = ListHeader(type: .text, rightIconType: .none).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "LIST/BODYTEXT"
    }
    
    private let listTitleViewBodyText = ListTitleView(type: .titleBodyText).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.dataSource = self
        $0.register(ListCell.self, forCellReuseIdentifier: "ListCell")
        $0.estimatedRowHeight = 72
        $0.rowHeight = 72
        $0.backgroundColor = Colors.background
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
        view.backgroundColor = Colors.background
        setViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    func setViews() {
        view.backgroundColor = Colors.background
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        self.view.addSubview(naviView)
        self.view.addSubview(tableView)
        self.view.bringSubviewToFront(naviView)
        
        tableView.tableHeaderView = tableViewHeader
        
        tableViewHeader.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(44)
            make.width.equalToSuperview()
            make.height.equalTo(800)
        }
        tableViewHeader.layoutIfNeeded()
        
        tableViewHeader.addSubview(infoViewTimeHeader)
        tableViewHeader.addSubview(infoViewTime)
        tableViewHeader.addSubview(infoViewInfoHeader)
        tableViewHeader.addSubview(infoViewInfo)
        tableViewHeader.addSubview(infoViewReviewHeader)
        tableViewHeader.addSubview(infoViewReview)
        tableViewHeader.addSubview(infoViewWritingHeader)
        tableViewHeader.addSubview(infoViewWriting)
        
        infoViewTimeHeader.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        infoViewTime.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(infoViewTimeHeader.snp.bottom)
            make.height.equalTo(15)
            make.width.equalToSuperview().inset(20)
        }
        
        infoViewInfoHeader.snp.makeConstraints { make in
            make.top.equalTo(infoViewTime.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        infoViewInfo.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(infoViewInfoHeader.snp.bottom)
            make.height.equalTo(15)
            make.width.equalToSuperview().inset(20)
        }
        
        infoViewReviewHeader.snp.makeConstraints { make in
            make.top.equalTo(infoViewInfo.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        infoViewReview.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(infoViewReviewHeader.snp.bottom)
            make.height.equalTo(15)
            make.width.equalToSuperview().inset(20)
        }
        
        infoViewWritingHeader.snp.makeConstraints { make in
            make.top.equalTo(infoViewReview.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        infoViewWriting.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(infoViewWritingHeader.snp.bottom)
            make.height.equalTo(15)
            make.width.equalToSuperview().inset(20)
        }
        
        tableViewHeader.addSubview(listTitleViewTitleHeader)
        tableViewHeader.addSubview(listTitleViewTitle)
        tableViewHeader.addSubview(listTitleViewTitlePictureHeader)
        tableViewHeader.addSubview(listTitleViewTitlePicture)
        tableViewHeader.addSubview(listTitleViewTitleHideHeader)
        tableViewHeader.addSubview(listTitleViewTitleHide)
        tableViewHeader.addSubview(listTitleViewBodyTextHeader)
        tableViewHeader.addSubview(listTitleViewBodyText)
        
        listTitleViewTitleHeader.snp.makeConstraints { make in
            make.top.equalTo(infoViewWriting.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        listTitleViewTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(listTitleViewTitleHeader.snp.bottom)
            make.height.equalTo(18)
            make.width.equalToSuperview().inset(20)
        }
        
        listTitleViewTitlePictureHeader.snp.makeConstraints { make in
            make.top.equalTo(listTitleViewTitle.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        listTitleViewTitlePicture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(listTitleViewTitlePictureHeader.snp.bottom)
            make.height.equalTo(18)
            make.width.equalToSuperview().inset(20)
        }
        
        listTitleViewTitleHideHeader.snp.makeConstraints { make in
            make.top.equalTo(listTitleViewTitlePicture.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        listTitleViewTitleHide.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(listTitleViewTitleHideHeader.snp.bottom)
            make.height.equalTo(18)
            make.width.equalToSuperview().inset(20)
        }
        
        listTitleViewBodyTextHeader.snp.makeConstraints { make in
            make.top.equalTo(listTitleViewTitleHide.snp.bottom).offset(40)
            make.leading.width.equalToSuperview()
            make.height.equalTo(30)
        }
        
        listTitleViewBodyText.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(listTitleViewBodyTextHeader.snp.bottom)
            make.height.equalTo(18)
            make.width.equalToSuperview().inset(20)
        }
        
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as? ListCell else { return UITableViewCell() }
        
        let index = indexPath.row
        
        
        switch index {
        case 0:
            cell.listType = .normal
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.date = "2099.99.99"
            cell.time = "99:99"
        case 1:
            cell.listType = .normal
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.date = "2099.99.99"
            cell.time = "99:99"
            cell.pageCount = "999"
        case 2:
            cell.listType = .textAndImage
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.date = "2099.99.99"
            cell.time = "99:99"
            cell.pageCount = "999"
            cell.reviewCount = "9"
        case 3:
            cell.listType = .textAndImage
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.date = "2099.99.99"
            cell.time = "99:99"
            cell.pageCount = "999"
            cell.reviewCount = "9"
        case 4:
            cell.listType = .hide
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.date = "2099.99.99"
            cell.time = "99:99"
            cell.pageCount = "999"
            cell.reviewCount = "9"
        case 5:
            cell.listType = .hide
            cell.title = "타이틀 노출 영역입니다. 최대 1줄 초과 시 말 줄임표를 사..."
            cell.date = "2099.99.99"
            cell.time = "99:99"
            cell.pageCount = "999"
            cell.reviewCount = "9"
        default:
            break
        }
        
        return cell
    }
    
    
}
