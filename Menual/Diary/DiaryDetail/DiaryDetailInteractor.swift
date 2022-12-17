//
//  DiaryDetailInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxSwift
import RxRelay
import RealmSwift

protocol DiaryDetailRouting: ViewableRouting {
    func attachBottomSheet(type: MenualBottomSheetType, menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?)
    func detachBottomSheet(isWithDiaryDetatil: Bool)
    
    // 수정하기
    func attachDiaryWriting(diaryModel: DiaryModelRealm, page: Int)
    func detachDiaryWriting(isOnlyDetach: Bool)
    
    // 이미지 자세히 보기
    func attachDiaryDetailImage(imageDataRelay: BehaviorRelay<Data>)
    func detachDiaryDetailImage(isOnlyDetach: Bool)
}

protocol DiaryDetailPresentable: Presentable {
    var listener: DiaryDetailPresentableListener? { get set }

    func reloadTableView()
    func loadDiaryDetail(model: DiaryModelRealm?)
    func reminderCompViewshowToast(isEding: Bool)
    func setReminderIconEnabled(isEnabled: Bool)
    func setFAB(leftArrowIsEnabled: Bool, rightArrowIsEnabled: Bool)
}
protocol DiaryDetailInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

protocol DiaryDetailListener: AnyObject {
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool)
    func diaryDeleteNeedToast(isNeedToast: Bool)
}

final class DiaryDetailInteractor: PresentableInteractor<DiaryDetailPresentable>, DiaryDetailInteractable, DiaryDetailPresentableListener, AdaptivePresentationControllerDelegate {
    
    var diaryReplyArr: [DiaryReplyModelRealm] = []
    var currentDiaryPage: Int
    var diaryModel: DiaryModelRealm?
    
    let presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    private var disposebag = DisposeBag()
    private let changeCurrentDiarySubject = BehaviorSubject<Bool>(value: false)
    private let imageDataRelay = BehaviorRelay<Data>(value: Data())
    
    // Reminder 관련
    let reminderRequestDateRelay = BehaviorRelay<ReminderRequsetModel?>(value: nil)
    let isHideMenualRelay = BehaviorRelay<Bool>(value: false)
    let isEnabledReminderRelay = BehaviorRelay<Bool?>(value: nil)

    weak var router: DiaryDetailRouting?
    weak var listener: DiaryDetailListener?
    private let dependency: DiaryDetailInteractorDependency
    
    // BottomSheet에서 메뉴를 눌렀을때 사용하는 Relay
    var menuComponentRelay = BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>(value: .none)
    var notificationToken: NotificationToken?
    var replyNotificationToken: NotificationToken?

    init(
        presenter: DiaryDetailPresentable,
        diaryModel: DiaryModelRealm,
        dependency: DiaryDetailInteractorDependency
    ) {
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        self.diaryModel = diaryModel
        self.dependency = dependency
        self.currentDiaryPage = diaryModel.pageNum
        super.init(presenter: presenter)
        presenter.listener = self
        
        self.presentationDelegateProxy.delegate = self
        presenter.loadDiaryDetail(model: diaryModel)
        pressedIndicatorButton(offset: 0, isInitMode: true)
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        bind()
        setDiaryModelRealmOb()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
        print("DiaryDetail :: WillResignActive")
        notificationToken?.invalidate()
        replyNotificationToken?.invalidate()
    }
    
    func setDiaryModelRealmOb() {
        guard let realm = Realm.safeInit() else { return }
        guard let diaryModel = self.diaryModel else { return }
        let diary = realm.object(ofType: DiaryModelRealm.self, forPrimaryKey: diaryModel._id)
        if let imageData: Data = diaryModel.originalImage {
            self.imageDataRelay.accept(imageData)
        }

        if let reminder = diaryModel.reminder {
            var dateComponets = DateComponents()
            dateComponets.year = Calendar.current.component(.year, from: reminder.requestDate)
            dateComponets.month = Calendar.current.component(.month, from: reminder.requestDate)
            dateComponets.day = Calendar.current.component(.day, from: reminder.requestDate)

            let reminderRequestModel = ReminderRequsetModel(isEditing: false, requestDateComponents: dateComponets, requestDate: reminder.requestDate)

            self.reminderRequestDateRelay.accept(reminderRequestModel)
            
            print("DiaryDetail :: Reminder가 있습니다!")
            
            self.presenter.setReminderIconEnabled(isEnabled: true)
        } else {
            self.reminderRequestDateRelay.accept(nil)
            self.presenter.setReminderIconEnabled(isEnabled: false)
        }
        
        print("DiaryDetail :: diary = \(diary)")

        self.notificationToken = diary?.observe({ [weak self] changes in
            print("DiaryDetail :: changes = \(changes)")
            guard let self = self else { return }
            switch changes {
            case .change(let model, let proertyChanges):
                print("DiaryDetail :: model = \(model as? DiaryModelRealm)")
                guard let model = model as? DiaryModelRealm else { return }
                if let imageData: Data = self.diaryModel?.originalImage {
                    self.imageDataRelay.accept(imageData)
                }

                if let _ = model.reminder {
                    self.presenter.setReminderIconEnabled(isEnabled: true)
                } else {
                    self.presenter.setReminderIconEnabled(isEnabled: false)
                }

                self.presenter.loadDiaryDetail(model: self.diaryModel)
            case .error(let error):
                fatalError("\(error)")
            case .deleted:
                break
            }
        })

        self.replyNotificationToken = diary?.replies.observe({ [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial(let model):
                // print("DiaryDetail :: realmObserve2 = initial! = \(model)")
                self.diaryReplyArr = Array(model)
                self.presenter.reloadTableView()

            case .update(let model, let deletions, let insertions, _):
                // print("DiaryDetail :: update! = \(model)")
                if deletions.count > 0 {
                    guard let deletionRow: Int = deletions.first else { return }
                    // print("DiaryDetail :: realmObserve2 = deleteRow = \(deletions)")
                    self.diaryReplyArr.remove(at: deletionRow)
                    self.presenter.reloadTableView()
                }
                
                if insertions.count > 0 {
                    guard let insertionRow: Int = insertions.first else { return }
                    let replyModelRealm = model[insertionRow]
                    self.diaryReplyArr.append(replyModelRealm)
                    self.presenter.reloadTableView()
                    // print("DiaryDetail :: realmObserve2 = insertion = \(insertions)")
                }

            case .error(let error):
                fatalError("\(error)")
            }
        })
    }
    
    func bind() {
        menuComponentRelay
            .subscribe(onNext: { [weak self] comp in
                guard let self = self else { return }
                print("DiaryDetail :: menuComponentRelay!!!! = \(comp)")
                switch comp {
                case .hide:
                    self.hideDiary()
                    
                case .edit:
                    self.router?.detachBottomSheet(isWithDiaryDetatil: false)
                    guard let diaryModel = self.diaryModel else { return }
                    self.router?.attachDiaryWriting(diaryModel: diaryModel, page: diaryModel.pageNum)
                    
                case .delete:
                    guard let diaryModel = self.diaryModel else { return }
                    self.dependency.diaryRepository
                        .deleteDiary(info: diaryModel)
                    self.listener?.diaryDeleteNeedToast(isNeedToast: true)
                    self.router?.detachBottomSheet(isWithDiaryDetatil: true)
                    
                case .none:
                    break
                }
            })
            .disposed(by: self.disposebag)
        
        reminderRequestDateRelay
            .subscribe(onNext: { [weak self] model in
                guard let self = self,
                      let model = model
                else { return }

                print("DiaryDetail :: reminderRequestDateRelay! \(model)")
                
                guard let diaryModel = self.diaryModel,
                      let isEnabledReminder = diaryModel.reminder?.isEnabled,
                      let requestDateComponents = model.requestDateComponents,
                      let isEditing = model.isEditing
                else { return }

                switch isEnabledReminder {
                case true:
                    print("DiaryDetail :: self.isEnabledReminder = \(isEnabledReminder) -> 수정")
                    self.setReminderDate(isEditing: isEditing, requestDateComponents: requestDateComponents)


                case false:
                    print("DiaryDetail :: self.isEnabledReminder = \(isEnabledReminder) -> 세팅")
                    self.setReminderDate(isEditing: isEditing, requestDateComponents: requestDateComponents)
                }
                
            })
            .disposed(by: disposebag)
        
        isEnabledReminderRelay
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self,
                      let isEnabled = isEnabled
                else { return }

                print("DiaryDetail :: Reminder 활성화/비활성화 = \(isEnabled)")
                
                switch isEnabled {
                case true:
                    break

                case false:
                    print("DiaryDetail :: Reminder를 해제합니다!")
                    self.deleteReminderDate()
                    break
                }
            })
            .disposed(by: disposebag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryDetailPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedReplySubmitBtn(desc: String) {
        guard let diaryModel = diaryModel else {
            return
        }
        
        let diaryReplyModelRealm = DiaryReplyModelRealm(uuid: UUID().uuidString,
                                                        replyNum: 0,
                                                        diaryUuid: diaryModel.uuid,
                                                        desc: desc,
                                                        createdAt: Date(),
                                                        isDeleted: false
        )

        self.dependency.diaryRepository
            .addReply(info: diaryReplyModelRealm, diaryModel: diaryModel)
    }

    // Diary 이동
    func pressedIndicatorButton(offset: Int, isInitMode: Bool) {
        
        // 1. 현재 diaryNum을 기준으로
        // 2. 왼쪽 or 오른쪽으로 이동 (pageNum이 현재 diaryNum기준 -1, +1)
        // 3. 삭제된 놈이면 건너뛰고 (isDeleted가 true일 경우)
        guard let realm = Realm.safeInit() else { return }
        let diaries = realm.objects(DiaryModelRealm.self)
            .toArray()
            .filter { $0.isDeleted != true }
            .sorted(by: { $0.createdAt < $1.createdAt })

        let willChangedIdx = (currentDiaryPage - 1) + offset
        print("willChangedIdx = \(willChangedIdx)")
        let willChangedDiaryModel = diaries[safe: willChangedIdx]
        
        // 이전 메뉴얼이 있는지 체크
        var leftArrowIsEnabled: Bool = false
        if let _ = diaries[safe: willChangedIdx - 1] {
            print("DiaryDetail :: prevDiaryModel이 있습니다.")
            leftArrowIsEnabled = true
        }

        // 다음 메뉴얼이 있는지 체크
        var rightArrowIsEnabled: Bool = false
        if let _ = diaries[safe: willChangedIdx + 1] {
            print("DiaryDetail :: nextDiaryModel이 있습니다.")
            rightArrowIsEnabled = true
        }
        
        // 최초 초기화 모드일 경우에는 fab만 세팅
        if isInitMode == true {
            presenter.setFAB(leftArrowIsEnabled: leftArrowIsEnabled, rightArrowIsEnabled: rightArrowIsEnabled)
        } else {
            self.diaryModel = willChangedDiaryModel
            self.currentDiaryPage = willChangedDiaryModel?.pageNum ?? 0
            presenter.loadDiaryDetail(model: self.diaryModel)
            notificationToken = nil
            replyNotificationToken = nil
            self.setDiaryModelRealmOb()
            print("willChangedDiaryModel = \(willChangedDiaryModel?.pageNum)")
            
            // self.changeCurrentDiarySubject.onNext(true)
            presenter.setFAB(leftArrowIsEnabled: leftArrowIsEnabled, rightArrowIsEnabled: rightArrowIsEnabled)
            print("pass true!")
        }
        
    }
    
    func deleteReply(replyModel: DiaryReplyModelRealm) {
        print("DiaryDetail :: DeletReply!")
        guard let diaryModel = self.diaryModel else { return }
        self.dependency.diaryRepository
            .deleteReply(diaryModel: diaryModel, replyModel: replyModel)
    }
    
    func diaryBottomSheetPressedCloseBtn() {
        router?.detachBottomSheet(isWithDiaryDetatil: false)
    }
    
    func pressedReminderBtn() {
        router?.attachBottomSheet(type: .reminder, menuComponentRelay: nil)
    }
    
    // MARK: - FilterComponentView
    func filterWithWeatherPlace(weatherArr: [Weather], placeArr: [Place]) {
        print("filterWithWeatherPlace!, \(weatherArr), \(placeArr)")
    }
    
    // MARK: - BottomSheet Menu
    func pressedMenuMoreBtn() {
        guard let diaryModel = self.diaryModel else { return }
        isHideMenualRelay.accept(diaryModel.isHide)
        router?.attachBottomSheet(type: .menu, menuComponentRelay: menuComponentRelay)
    }
    
    // 유저가 바텀싯을 통해서 숨기기를 눌렀을 경우
    func hideDiary() {
        print("DiaryDetail :: hideDiary! 1")
        guard let diaryModel = diaryModel else { return }
        var isHide: Bool = false
        if diaryModel.isHide == true {
            isHide = false
            print("DiaryDetail :: 이미 숨겨져 있으므로 잠금을 해제합니다.")
        } else {
            isHide = true
            print("DiaryDetail :: 숨깁니다!")
        }

        dependency.diaryRepository
            .hideDiary(isHide: isHide, info: diaryModel)
    }
    
    func reminderCompViewshowToast(isEding: Bool) {
        presenter.reminderCompViewshowToast(isEding: isEding)
    }
    
    func deleteReminderDate() {
        print("DiaryDetail :: deleteReminderDate!")
        
        guard let diaryModel = self.diaryModel,
              let reminderUUID: String = diaryModel.reminder?.uuid else {
            print("DiaryDetail :: 삭제할 reminder UUID가 없습니다.")
            return
        }
        reminderRequestDateRelay.accept(nil)
        self.isEnabledReminderRelay.accept(nil)
        dependency.diaryRepository
            .updateDiary(DiaryModel: diaryModel, reminder: nil)
        print("DiaryDetail :: reminder를 삭제했습니다.")
    }
    
    func setReminderDate(isEditing: Bool, requestDateComponents: DateComponents) {
        print("DiaryDetail :: setReminderDate! = \(requestDateComponents)")
        guard let diaryModel = diaryModel else { return }

        var requestUUID: String = ""

        let content = UNMutableNotificationContent()
        content.title = "오늘 읽기로 한 메뉴얼이 있어요."
        content.body = "\(diaryModel.title)"
        content.userInfo = ["diaryUUID": diaryModel.uuid]
        
        // Create the trigger as a repating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: requestDateComponents, repeats: false)
        
        // Create the request
        requestUUID = UUID().uuidString
        let request = UNNotificationRequest(identifier: requestUUID, content: content, trigger: trigger)
        
        // Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        
        // 수정일 경우에 원래 있는 notification 삭제
        if isEditing == true {
            print("DiaryDetail :: Editing이 true이므로 Reminder를 삭제하고, 새로 등록합니다.")
            guard let reminderRequestUUID = diaryModel.reminder?.uuid else { return }
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderRequestUUID])
        }
        
        notificationCenter.add(request) { error in
            print("Reminder :: 됐나!? - 1")
            if error != nil {
                print("Reminder :: 됐나!? NoError! - 2")
            }
        }
        
        guard let requestDate = Calendar.current.date(from: requestDateComponents) else { return }
        
        var uuid: String = ""
        if let isEnabledReminder: Bool = diaryModel.reminder?.isEnabled,
            isEnabledReminder == true {
            uuid = diaryModel.reminder?.uuid ?? ""
        } else {
            uuid = UUID().uuidString
        }

        let reminderModel = ReminderModelRealm(uuid: uuid,
                                                     requestDate: requestDate,
                                                     createdAt: Date(),
                                                     isEnabled: true
        )
        
        self.dependency.diaryRepository
            .updateDiary(DiaryModel: diaryModel, reminder: reminderModel)

        print("DiaryDetail :: requestDate! -> \(reminderModel)")
    }
    
    
    // MARK: - DiaryDetailImage
    func diaryDetailImagePressedBackBtn(isOnlyDetach: Bool) {
        print("DiaryDetail :: diaryDetailImagePressedBackBtn!")
        router?.detachDiaryDetailImage(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedImageView() {
        print("DiaryDetail :: interactor -> pressedImageView!")
        guard let _: Data = diaryModel?.originalImage else { return }
        router?.attachDiaryDetailImage(imageDataRelay: self.imageDataRelay)
    }

    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: DiaryHomeViewController.ShowToastType) {
        print("DiaryDetail :: diaryWritingPressedBackBtn! ")
        router?.detachDiaryWriting(isOnlyDetach: isOnlyDetach)
    }
    
    func presentationControllerDidDismiss() {
        router?.detachDiaryDetailImage(isOnlyDetach: true)
    }
}
 
// MARK: - 미사용
extension DiaryDetailInteractor {
    func filterWithWeatherPlacePressedFilterBtn() { }
    func filterDatePressedFilterBtn(yearDateFormatString: String) {}
}
