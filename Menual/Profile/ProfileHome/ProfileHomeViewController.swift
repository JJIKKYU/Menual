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
    func pressedBackBtn(isOnlyDetach: Bool)
    var profileHomeDataArr_Setting1: [ProfileHomeModel] { get }
    var profileHomeDataArr_Setting2: [ProfileHomeModel] { get }
    
    // ProfilePassword
    func pressedProfilePasswordCell()
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
        $0.contentInset = UIEdgeInsets(top: UIApplication.topSafeAreaHeight + 24, left: 0, bottom: 0, right: 0)
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
        if isMovingFromParent || isBeingDismissed {
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
    }
    
    @objc
    func pressedBackBtn() {
        print("ProfileHomeVC :: pressedBackBtn!")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
}

// MARK: - IBaction
extension ProfileHomeViewController {
    @objc
    func selectedSwitchBtn(_ sender: UISwitch) {
        print("!!")
        switch sender.isOn {
        case true:
            print("isOn!")
        case false:
            print("isOff!")
        }
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
            headerView.title = "메뉴얼 설정"
            return headerView
        case ProfileHomeSection.SETTING2.rawValue:
            headerView.title = "기타"
            return headerView
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case ProfileHomeSection.SETTING1.rawValue:
            return listener?.profileHomeDataArr_Setting1.count ?? 0
        case ProfileHomeSection.SETTING2.rawValue:
            return listener?.profileHomeDataArr_Setting2.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHomeCell", for: indexPath) as? ProfileHomeCell else { return UITableViewCell() }
        let index = indexPath.row
        cell.selectionStyle = .none
        let section = indexPath.section
        switch section {
        case ProfileHomeSection.SETTING1.rawValue:
            guard let data = listener?.profileHomeDataArr_Setting1[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.profileHomeCellType = data.type
            if data.type == .toggle && index == 1 {
                cell.switchBtn.isOn = true
            }
            return cell
        case ProfileHomeSection.SETTING2.rawValue:
            guard let data = listener?.profileHomeDataArr_Setting2[safe: index] else { return UITableViewCell() }
            cell.title = data.title
            cell.profileHomeCellType = data.type
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ProfileHomeCell else { return }
        let section = indexPath.section
        let index = indexPath.row
        print("ProfileHome :: indexpath = \(indexPath)")

        // TODO: - 실제 데이터 기반으로 변경
        switch section {
        case ProfileHomeSection.SETTING1.rawValue:
            guard let data = listener?.profileHomeDataArr_Setting1[safe: index] else { return }
            if data.title == "비밀번호 설정하기" {
                listener?.pressedProfilePasswordCell()
            } else if data.title == "비밀번호 변경하기" {
                listener?.pressedProfilePasswordCell()
            }
//            if data.type == .toggle {
//                cell.switchBtn.isOn = !cell.switchBtn.isOn
//            }
            break
        case ProfileHomeSection.SETTING2.rawValue:
            break
        default:
            break
        }
    }
}
