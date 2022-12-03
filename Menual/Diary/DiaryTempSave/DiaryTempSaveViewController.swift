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
import RxRelay

protocol DiaryTempSavePresentableListener: AnyObject {
    // TODO: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func pressedBackBtn(isOnlyDetach: Bool)
    var tempSaveRelay: BehaviorRelay<[TempSaveModel]> { get }
    var tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModel?> { get }
    var tempSaveResetRelay: BehaviorRelay<Bool> { get }
    var deleteTempSaveUUIDArrRelay: BehaviorRelay<[String]> { get }
    func deleteTempSave()
    func pressedTempSaveCell(uuid: String)
}

final class DiaryTempSaveViewController: UIViewController, DiaryTempSavePresentable, DiaryTempSaveViewControllable {

    weak var listener: DiaryTempSavePresentableListener?
    private let disposeBag = DisposeBag()
    
    private var isDeleteMode: Bool = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var tableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.dataSource = self
        $0.delegate = self
        $0.register(TempSaveCell.self, forCellReuseIdentifier: "TempSaveCell")
        $0.rowHeight = 80
        $0.backgroundColor = .clear
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    private lazy var deleteBtn = BoxButton(frame: .zero, btnStatus: .inactive, btnSize: .xLarge).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.title = "삭제하기"
        $0.isHidden = true
        $0.addTarget(self, action: #selector(pressedBottomDeleteBtn), for: .touchUpInside)
    }
    
    private let emptyView = Empty().then {
        $0.screenType = .writing
        $0.writingType = .temporarysave
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
        bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent || isBeingDismissed {
            print("!!?")
            listener?.pressedBackBtn(isOnlyDetach: true)
        }
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
        view.addSubview(deleteBtn)
        view.addSubview(emptyView)
        view.bringSubviewToFront(deleteBtn)
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
        
        deleteBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(34)
        }
        
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(180)
        }
    }
    
    func bind() {
        listener?.tempSaveRelay
            .subscribe(onNext: { [weak self] tempSave in
                guard let self = self else { return }
                if tempSave.count == 0 {
                    self.naviView.rightButton1IsActive = false
                    self.naviView.rightButton1.isEnabled = false
                    self.emptyView.isHidden = false
                } else {
                    self.naviView.rightButton1.isEnabled = true
                    self.emptyView.isHidden = true
                }
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        listener?.deleteTempSaveUUIDArrRelay
            .subscribe(onNext: { [weak self] tempSaveArr in
                guard let self = self else { return }
                print("TempSave :: arr = \(tempSaveArr)")
                if tempSaveArr.count == 0 {
                    self.deleteBtn.btnStatus = .inactive
                    self.deleteBtn.title = "삭제하기"
                } else {
                    self.deleteBtn.btnStatus = .active
                    self.deleteBtn.title = "\(tempSaveArr.count)개 삭제하기"
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - IBAction
extension DiaryTempSaveViewController {
    @objc
    func pressedBackBtn() {
        print("pressedBackBtn")
        listener?.pressedBackBtn(isOnlyDetach: false)
    }
    
    @objc
    func pressedDeleteBtn() {
        listener?.deleteTempSaveUUIDArrRelay.accept([])
        isDeleteMode = !isDeleteMode
        deleteBtn.isHidden = !isDeleteMode
        naviView.rightButton1IsActive = isDeleteMode
        tableView.reloadData()
        print("pressedDeleteBtn")
    }
    
    @objc
    func pressedBottomDeleteBtn() {
        print("TempSave :: pressedBottomDeleteBtn")

        // 임시저장된 메뉴얼을 '작성중' 상태로 만들었는데 삭제할 경우
        if let tempSaveDiaryModel = listener?.tempSaveDiaryModelRelay.value {
            let willDeleteTempSaveDiaryModel = listener?.deleteTempSaveUUIDArrRelay.value.filter({ $0 == tempSaveDiaryModel.uuid }).first ?? ""
            
            // 삭제하려고 하는 메뉴얼 중에 작성중인 상태의 메뉴얼이 있을 경우
            if tempSaveDiaryModel.uuid == willDeleteTempSaveDiaryModel {
                print("TempSave :: 삭제하려고 하는 메뉴얼 중에 작성중인 메뉴얼이 있습니다.")
                listener?.tempSaveResetRelay.accept(true)
            }
        }
        
        listener?.deleteTempSave()
        listener?.deleteTempSaveUUIDArrRelay.accept([])
        isDeleteMode = !isDeleteMode
        deleteBtn.isHidden = !isDeleteMode
        naviView.rightButton1IsActive = false
        tableView.reloadData()
        
        // TODO: - 현재 작성중인 메뉴얼도 삭제가 되었다면
        showToast(message: "임시저장된 메뉴얼이 삭제되었습니다.")
    }
}

// MARK: - UITableViewDelegate
extension DiaryTempSaveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listener?.tempSaveRelay.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TempSaveCell") as? TempSaveCell else {
            return UITableViewCell()
        }
        
        guard let tempSaveArr = listener?.tempSaveRelay.value,
              let model: TempSaveModel = tempSaveArr[safe: indexPath.row]
        else { return UITableViewCell() }
        
        let currentTempSaveUUID: String = listener?.tempSaveDiaryModelRelay.value?.uuid ?? ""
        
        // 이전에 선택했던 UUID가 같다면 작성중으로 표현
        if model.uuid == currentTempSaveUUID {
            cell.isWriting = true
            print("TempSave :: 작성중아!")
        } else {
            cell.isWriting = false
        }
        
        cell.isDeleteSelected = false
        cell.isDeleteMode = isDeleteMode
        cell.title = model.title
        cell.date = model.createdAt.toString()
        cell.time = model.createdAt.toStringHourMin()

        print("여기!")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TempSave :: indexPath = \(indexPath)")
        guard let cell = tableView.cellForRow(at: indexPath) as? TempSaveCell else { return }
        
        guard let uuid: String = listener?.tempSaveRelay.value[safe: indexPath.row]?.uuid,
              let selectedUUIDArr: [String] = listener?.deleteTempSaveUUIDArrRelay.value
        else { return }
        print("TempSave :: didSelectedRow = uuid = \(uuid)")

        switch isDeleteMode {
        case true:
            cell.isDeleteSelected = !cell.isDeleteSelected
            let isSelected: Bool = cell.isDeleteSelected
            if isSelected {
                listener?.deleteTempSaveUUIDArrRelay.accept(selectedUUIDArr + [uuid])
            } else {
                listener?.deleteTempSaveUUIDArrRelay.accept(selectedUUIDArr.filter { $0 != uuid })
            }

        case false:
            listener?.pressedTempSaveCell(uuid: uuid)
        }
    }
}
