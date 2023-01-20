//
//  DiaryTempSaveInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import RIBs
import RxSwift
import RxRelay
import RealmSwift
import MenualUtil
import MenualEntity
import MenualRepository

public protocol DiaryTempSaveRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol DiaryTempSavePresentable: Presentable {
    var listener: DiaryTempSavePresentableListener? { get set }
    func reloadTableView()
    func deleteRow(at indexs: [Int])
}

public protocol DiaryTempSaveListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryTempSavePressentBackBtn(isOnlyDetach: Bool)
}

protocol DiaryTempSaveInteractorDependecy {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryTempSaveInteractor: PresentableInteractor<DiaryTempSavePresentable>, DiaryTempSaveInteractable, DiaryTempSavePresentableListener {
    
    weak var router: DiaryTempSaveRouting?
    weak var listener: DiaryTempSaveListener?
    
    internal let tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModelRealm?>
    internal let tempSaveResetRelay: BehaviorRelay<Bool>
    
    private let dependency: DiaryTempSaveDependency
    private let disposeBag = DisposeBag()
    
    var deleteTempSaveUUIDArrRelay = BehaviorRelay<[String]>(value: [])
    var tempSaveModel: List<TempSaveModelRealm>?
    var notificationToken: NotificationToken?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryTempSavePresentable,
        dependency: DiaryTempSaveDependency,
        tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModelRealm?>,
        tempSaveResetRelay: BehaviorRelay<Bool>
    ) {
        self.dependency = dependency
        self.tempSaveDiaryModelRelay = tempSaveDiaryModelRelay
        self.tempSaveResetRelay = tempSaveResetRelay
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        realmBind()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    func realmBind() {
        guard let realm = Realm.safeInit() else { return }
        let tempSaveModel = realm.objects(TempSaveModelRealm.self)
        notificationToken = tempSaveModel.observe({ [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let model):
                self.tempSaveModel = model.list
                self.presenter.reloadTableView()
                
            case .update(let model, let deletions, _, _):
                if deletions.count > 0 {
                    self.tempSaveModel = model.list
                    self.presenter.deleteRow(at: deletions)
                }
                
            case .error(let error):
                print("TempSave :: error! = \(error)")
            }
        })
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryTempSavePressentBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func deleteTempSave() {
        dependency.diaryRepository
            .deleteTempSave(uuidArr: deleteTempSaveUUIDArrRelay.value)
    }
    
    func pressedTempSaveCell(uuid: String) {
        print("TempSave :: pressedTempSaveCell -> uuid - \(uuid)")
//        guard let tempSaveDiaryModel: TempSaveModel = dependency.diaryRepository.tempSave.value.filter({ $0.uuid == uuid }).first else { return }
        
        guard let model: TempSaveModelRealm = tempSaveModel?.filter ({ $0.uuid == uuid }).first else { return }
        // print("TempSaveDiaryModel = \(tempSaveDiaryModel)")
        tempSaveDiaryModelRelay.accept(model)
        listener?.diaryTempSavePressentBackBtn(isOnlyDetach: false)
    }
}
