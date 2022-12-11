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

protocol DiaryTempSaveRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryTempSavePresentable: Presentable {
    var listener: DiaryTempSavePresentableListener? { get set }
    func reloadTableView()
}

protocol DiaryTempSaveListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryTempSavePressentBackBtn(isOnlyDetach: Bool)
}

protocol DiaryTempSaveInteractorDependecy {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryTempSaveInteractor: PresentableInteractor<DiaryTempSavePresentable>, DiaryTempSaveInteractable, DiaryTempSavePresentableListener {
    
    weak var router: DiaryTempSaveRouting?
    weak var listener: DiaryTempSaveListener?
    
    internal let tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModel?>
    internal let tempSaveResetRelay: BehaviorRelay<Bool>
    
    private let dependency: DiaryTempSaveDependency
    private let disposeBag = DisposeBag()
    
    var deleteTempSaveUUIDArrRelay = BehaviorRelay<[String]>(value: [])
    var tempSaveRelay = BehaviorRelay<[TempSaveModel]>(value: [])
    
    var tempSaveModel: List<TempSaveModelRealm>?
    
    var notificationToken: NotificationToken?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryTempSavePresentable,
        dependency: DiaryTempSaveDependency,
        tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModel?>,
        tempSaveResetRelay: BehaviorRelay<Bool>
    ) {
        self.dependency = dependency
        dependency.diaryRepository.fetchTempSave()
        self.tempSaveDiaryModelRelay = tempSaveDiaryModelRelay
        self.tempSaveResetRelay = tempSaveResetRelay
        super.init(presenter: presenter)
        presenter.listener = self
        bind()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        dependency.diaryRepository
            .tempSave
            .subscribe(onNext: { [weak self] tempSave in
                guard let self = self else { return }
                print("TempSave :: tempSave구독! = \(tempSave)")
                self.tempSaveRelay.accept(tempSave)
            })
            .disposed(by: disposeBag)
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
                
            case .update(let model, let deletions, let insertions, let modifications):
                if deletions.count > 0 {
                    
                }
                
                if insertions.count > 0 {
                    
                }
                
                if modifications.count > 0 {
                    
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
        guard let tempSaveDiaryModel: TempSaveModel = dependency.diaryRepository.tempSave.value.filter({ $0.uuid == uuid }).first else { return }
        print("TempSaveDiaryModel = \(tempSaveDiaryModel)")
        tempSaveDiaryModelRelay.accept(tempSaveDiaryModel)
        listener?.diaryTempSavePressentBackBtn(isOnlyDetach: false)
    }
}
