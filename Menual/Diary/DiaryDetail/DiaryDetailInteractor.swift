//
//  DiaryDetailInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxSwift
import RxRelay

protocol DiaryDetailRouting: ViewableRouting {
    func attachBottomSheet(type: MenualBottomSheetType, menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?)
    func detachBottomSheet(isWithDiaryDetatil: Bool)
    
    // 수정하기
    func attachDiaryWriting(diaryModel: DiaryModel, page: Int)
    func detachDiaryWriting(isOnlyDetach: Bool)
    
    // 이미지 자세히 보기
    func attachDiaryDetailImage(imageDataRelay: BehaviorRelay<Data>)
    func detachDiaryDetailImage(isOnlyDetach: Bool)
}

protocol DiaryDetailPresentable: Presentable {
    var listener: DiaryDetailPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func reloadTableView()
    func loadDiaryDetail(model: DiaryModel)
    func testLoadDiaryImage(imageName: UIImage?)
    func reminderCompViewshowToast(isEding: Bool)
    func setReminderIconEnabled(isEnabled: Bool)
}
protocol DiaryDetailInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

protocol DiaryDetailListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool)
    func diaryDeleteNeedToast(isNeedToast: Bool)
}

final class DiaryDetailInteractor: PresentableInteractor<DiaryDetailPresentable>, DiaryDetailInteractable, DiaryDetailPresentableListener, AdaptivePresentationControllerDelegate {
    
    var diaryReplies: [DiaryReplyModel]
    var currentDiaryPage: Int
    var diaryModel: DiaryModel?
    
    let presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    private var disposebag = DisposeBag()
    private let changeCurrentDiarySubject = BehaviorSubject<Bool>(value: false)
    private let imageDataRelay = BehaviorRelay<Data>(value: Data())
    
    // Reminder 관련
    let reminderRequestDateRelay = BehaviorRelay<ReminderRequsetModel?>(value: nil)
    let isHideMenualRelay = BehaviorRelay<Bool>(value: false)
    let isEnabledReminderRelay = BehaviorRelay<Bool?>(value: nil)
    
    // reminder의 Realm UUID
    private var reminderUUID: String?
    // reminder의 Notification UUID
    private var reminderRequestUUID: String?
    private var isEnabledReminder: Bool = false

    weak var router: DiaryDetailRouting?
    weak var listener: DiaryDetailListener?
    private let dependency: DiaryDetailInteractorDependency
    
    // BottomSheet에서 메뉴를 눌렀을때 사용하는 Relay
    var menuComponentRelay = BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>(value: .none)

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryDetailPresentable,
        diaryModel: DiaryModel,
        dependency: DiaryDetailInteractorDependency
    ) {
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        self.diaryModel = diaryModel
        self.dependency = dependency
        self.diaryReplies = diaryModel.replies
        self.currentDiaryPage = diaryModel.pageNum
        super.init(presenter: presenter)
        presenter.listener = self
        
        self.presentationDelegateProxy.delegate = self
        
        print("interactor = \(diaryModel)")
        presenter.loadDiaryDetail(model: diaryModel)
        
        Observable.combineLatest(
            dependency.diaryRepository.diaryString,
            self.changeCurrentDiarySubject
        )
            .subscribe(onNext: { [weak self] diaryArr, isChanged in
                guard let self = self,
                      let diaryModel = self.diaryModel else { return }
                
                print("DiaryDetail :: diaryString 구독 중!, isChanged = \(isChanged), diaryModel.uuid = \(diaryModel.pageNum)")
                guard let currentDiaryModel = diaryArr.filter({ diaryModel.uuid == $0.uuid }).first else { return }
                print("<- reloadTableView")
//                dependency.diaryRepository
//                    .loadImageFromDocumentDirectory(imageName: diaryModel.uuid, completionHandler: { image in
//                        self.presenter.testLoadDiaryImage(imageName:image)
//                    })
                self.diaryModel = currentDiaryModel
                self.diaryReplies = currentDiaryModel.replies
                self.currentDiaryPage = currentDiaryModel.pageNum
                if let imageData: Data = currentDiaryModel.originalImage?.pngData() {
                    self.imageDataRelay.accept(imageData)
                }

                presenter.loadDiaryDetail(model: currentDiaryModel)
            })
            .disposed(by: self.disposebag)
        
        
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
                    dependency.diaryRepository
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
                
                guard let requestDateComponents = model.requestDateComponents,
                      let isEditing = model.isEditing
                else { return }

                switch self.isEnabledReminder {
                case true:
                    print("DiaryDetail :: self.isEnabledReminder = \(self.isEnabledReminder) -> 수정")
                    self.setReminderDate(isEditing: isEditing, requestDateComponents: requestDateComponents)
                    
                    
                case false:
                    print("DiaryDetail :: self.isEnabledReminder = \(self.isEnabledReminder) -> 세팅")
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
        
        
        dependency.diaryRepository
            .reminder
            .subscribe(onNext: { [weak self] reminderArr in
                guard let self = self,
                      let diaryModel = self.diaryModel
                else { return }

                var isEnabled: Bool = false
                for reminder in reminderArr {
                    if reminder.diaryUUID == diaryModel.uuid {
                        isEnabled = true
                        print("DiaryDetail :: reminder! = \(reminder) - 1")

                        self.reminderUUID = reminder.uuid
                        self.reminderRequestUUID = reminder.requestUUID
                        self.isEnabledReminder = isEnabled
                        var dateComponets = DateComponents()
                        dateComponets.year = Calendar.current.component(.year, from: reminder.requestDate)
                        dateComponets.month = Calendar.current.component(.month, from: reminder.requestDate)
                        dateComponets.day = Calendar.current.component(.day, from: reminder.requestDate)
                        // self.reminderRequestDateRelay.accept(dateComponets)
                        
                        let model = ReminderRequsetModel(isEditing: nil,
                                                         requestDateComponents: dateComponets
                        )
                        self.reminderRequestDateRelay.accept(model)
                        
                        print("DiaryDetail :: reminder.requestDate = \(reminder.requestDate)")
                        print("DiaryDetail :: dateComponents = \(dateComponets)")

                        break
                    }
                }

                print("DiaryDetail :: 이 메뉴얼에 reminder가 등록되어 있습니다. => \(isEnabled)")
                self.presenter.setReminderIconEnabled(isEnabled: isEnabled)
            })
            .disposed(by: disposebag)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryDetailPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedReplySubmitBtn(desc: String) {
        guard let diaryModel = diaryModel else {
            return
        }

        let newDiaryReplyModel = DiaryReplyModel(uuid: UUID().uuidString,
                                                 replyNum: 0,
                                                 diaryUuid: diaryModel.uuid,
                                                 desc: desc,
                                                 createdAt: Date(),
                                                 isDeleted: false
        )
        
        dependency.diaryRepository
            .addReply(info: newDiaryReplyModel)
    }
    
    // Diary 이동
    func pressedIndicatorButton(offset: Int) {
        // 1. 현재 diaryNum을 기준으로
        // 2. 왼쪽 or 오른쪽으로 이동 (pageNum이 현재 diaryNum기준 -1, +1)
        // 3. 삭제된 놈이면 건너뛰고 (isDeleted가 true일 경우)
        let diaries = dependency.diaryRepository.diaryString.value
            .filter { $0.isDeleted != true }
            .sorted { $0.createdAt < $1.createdAt }

        let willChangedIdx = (currentDiaryPage - 1) + offset
        print("willChangedIdx = \(willChangedIdx)")
        let willChangedDiaryModel = diaries[safe: willChangedIdx]

        self.diaryModel = willChangedDiaryModel
        print("willChangedDiaryModel = \(willChangedDiaryModel?.pageNum)")
        
        self.changeCurrentDiarySubject.onNext(true)
        print("pass true!")
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

        guard let hideDiary = dependency.diaryRepository
            .hideDiary(isHide: isHide, info: diaryModel) else { return }
        // dependency.diaryRepository.updateDiary(info: <#T##DiaryModel#>)

        print("DiaryDetail :: hideDiary! 2 -> \(hideDiary.isHide)")
        self.diaryModel = hideDiary
        // presenter.loadDiaryDetail(model: hideDiary)
        // self.presenter.reloadTableView()
    }
    
    func reminderCompViewshowToast(isEding: Bool) {
        presenter.reminderCompViewshowToast(isEding: isEding)
    }
    
    func deleteReminderDate() {
        print("DiaryDetail :: deleteReminderDate!")
        let notificationCenter = UNUserNotificationCenter.current()
        
        guard let reminderRequestUUID: String = reminderRequestUUID,
              let reminderUUID: String = reminderUUID else {
            print("DiaryDetail :: 삭제할 reminder UUID가 없습니다.")
            return
        }

        // notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderRequestUUID])
        reminderRequestDateRelay.accept(nil)
        self.isEnabledReminderRelay.accept(nil)
        self.reminderUUID = nil
        self.reminderRequestUUID = nil
        self.isEnabledReminder = false
        dependency.diaryRepository
            .deleteReminder(reminderUUID: reminderUUID)
        print("DiaryDetail :: reminder를 삭제했습니다.")
    }
    
    func setReminderDate(isEditing: Bool, requestDateComponents: DateComponents) {
        print("DiaryDetail :: setReminderDate! = \(requestDateComponents)")
        guard let diaryModel = diaryModel else { return }

        var requestUUID: String = ""

        let content = UNMutableNotificationContent()
        content.title = "알림 테스트입니다."
        content.body = "알림 테스트 알림 테스트 알림 테스트 알림 테스트 알림 테스트"
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
            guard let reminderRequestUUID = reminderRequestUUID else { return }
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderRequestUUID])
        }
        
        notificationCenter.add(request) { error in
            print("Reminder :: 됐나!? - 1")
            if error != nil {
                print("Reminder :: 됐나!? NoError! - 2")
            }
        }
        
        guard let requestDate = Calendar.current.date(from: requestDateComponents) else { return }
        let uuid: String = self.isEnabledReminder == true ? self.reminderUUID ?? "" : UUID().uuidString

        let requestReminderModel = ReminderModel(uuid: uuid,
                                                 diaryUUID: diaryModel.uuid,
                                                 requestDate: requestDate,
                                                 requestUUID: requestUUID,
                                                 createdAt: Date(),
                                                 isEnabled: true
        )
        
        // 이미 리마인더가 적용되어 있다면
        if self.isEnabledReminder {
            print("DiaryDetail :: Reminder가 이미 적용되어 있으므로 update를 호출합니다.")
            
            self.dependency.diaryRepository
                .updateReminder(model: requestReminderModel)

        } else {
            print("DiaryDetail :: Reminder를 새로 생성합니다.")

            self.dependency.diaryRepository
                .addReminder(model: requestReminderModel)
        }

        print("DiaryDetail :: requestDate! -> \(requestReminderModel)")
    }
    
    
    // MARK: - DiaryDetailImage
    func diaryDetailImagePressedBackBtn(isOnlyDetach: Bool) {
        print("DiaryDetail :: diaryDetailImagePressedBackBtn!")
        router?.detachDiaryDetailImage(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedImageView() {
        print("DiaryDetail :: interactor -> pressedImageView!")
        guard let _: Data = diaryModel?.originalImage?.pngData() else { return }
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
