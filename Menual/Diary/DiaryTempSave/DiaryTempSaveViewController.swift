//
//  DiaryTempSaveViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import RIBs
import RxSwift
import UIKit
import SnapKit
import Then

protocol DiaryTempSavePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn()
}

final class DiaryTempSaveViewController: UIViewController, DiaryTempSavePresentable, DiaryTempSaveViewControllable {

    weak var listener: DiaryTempSavePresentableListener?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.dataSource = self
        $0.delegate = self
        $0.register(TempSaveCell.self, forCellReuseIdentifier: "TempSaveCell")
        $0.rowHeight = 80
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        view.backgroundColor = Colors.background
        setViews()
    }
    
    lazy var naviView = MenualNaviView(type: .temporarySave).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backButton.addTarget(self, action: #selector(pressedBackBtn), for: .touchUpInside)
        
        // 휴지통(딜리트) 버튼
        $0.rightButton1.addTarget(self, action: #selector(pressedDeleteBtn), for: .touchUpInside)
        $0.rightButton1.setImage(Asset._24px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.rightButton1.tintColor = .white
    }
    
    func setViews() {
        view.addSubview(naviView)
        view.addSubview(tableView)
        view.bringSubviewToFront(naviView)
        
        naviView.snp.makeConstraints { make in
            make.leading.top.width.equalToSuperview()
            make.height.equalTo(44 + UIApplication.topSafeAreaHeight)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(44 + UIApplication.topSafeAreaHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    func pressedBackBtn() {
        print("pressedBackBtn")
        listener?.pressedBackBtn()
    }
    
    @objc
    func pressedDeleteBtn() {
        print("pressedDeleteBtn")
    }
    
}


extension DiaryTempSaveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TempSaveCell") as? TempSaveCell else {
            return UITableViewCell()
        }
        
        cell.title = "테스트입니다. \(indexPath.row)"
        cell.date = "2022.12.0\(indexPath.row)"
        print("여기!")
        
        return cell
    }
    
    
}
