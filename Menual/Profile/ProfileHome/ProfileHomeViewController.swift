//
//  ProfileHomeViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import RxSwift
import UIKit
import SnapKit

protocol ProfileHomePresentableListener: AnyObject {
    func pressedBackBtn()
}

enum ProfileHomeSection: Int {
    case SETTING1 = 0
    case SETTING2 = 1
}

final class ProfileHomeViewController: UIViewController, ProfileHomePresentable, ProfileHomeViewControllable {

    weak var listener: ProfileHomePresentableListener?
    
    lazy var naviView = MenualNaviView(type: .myPage).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
    }
    
    lazy var settingTableView = UITableView(frame: CGRect.zero, style: .grouped).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: UIApplication.topSafeAreaHeight, left: 0, bottom: 0, right: 0)
        $0.sectionHeaderHeight = 34
        $0.delegate = self
        $0.dataSource = self
        $0.register(ProfileHomeCell.self, forCellReuseIdentifier: "ProfileHomeCell")
        $0.rowHeight = 56
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
        
        // 뒤로가기 제스쳐 가능하도록
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        setViews()
    }
    
    func setViews() {
        self.view.addSubview(naviView)
        self.view.addSubview(settingTableView)
        self.view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
            make.top.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        settingTableView.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listener?.pressedBackBtn()
    }
    
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn()
    }
}

// MARK: - UITableView
extension ProfileHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        print("sectionNumber = \(section)")
        let headerView = ListHeader(type: .datepageandicon, rightIconType: .none)
        let divider = Divider(type: ._2px)
        headerView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.top).offset(32)
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(2)
        }

        switch section {
        case ProfileHomeSection.SETTING1.rawValue:
            headerView.title = "SETTING - 1"
            return headerView
        case ProfileHomeSection.SETTING2.rawValue:
            headerView.title = "SETTING - 2"
            return headerView
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHomeCell", for: indexPath) as? ProfileHomeCell else { return UITableViewCell() }
        
        if indexPath.row % 2 == 0 {
            cell.profileHomeCellType = .toggle
        }
        
        cell.title = "안녕하세요 \(indexPath.row)"
        
        return cell
    }
}
