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
import Foundation
import UserNotifications
import DesignSystem
import MenualEntity
import MenualUtil
import MenualRepository
import DiaryBottomSheet

public protocol DiaryDetailRouting: ViewableRouting {
    func attachBottomSheet(type: MenualBottomSheetType, menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?)
    func detachBottomSheet(isWithDiaryDetatil: Bool)
    
    // 수정하기
    func attachDiaryWriting(diaryModel: DiaryModelRealm, page: Int)
    func detachDiaryWriting(isOnlyDetach: Bool)
    
    // 이미지 자세히 보기
    func attachDiaryDetailImage(imageDataRelay: BehaviorRelay<Data>)
    func detachDiaryDetailImage(isOnlyDetach: Bool)
}

public protocol DiaryDetailPresentable: Presentable {
    var listener: DiaryDetailPresentableListener? { get set }

    func reloadTableView()
    func loadDiaryDetail(model: DiaryModelRealm?)
    func reminderCompViewshowToast(type: ReminderToastType)
    func setReminderIconEnabled(isEnabled: Bool)
    func setFAB(leftArrowIsEnabled: Bool, rightArrowIsEnabled: Bool)
    func enableBackSwipe()
    func presentMailVC()
}
public protocol DiaryDetailInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var appstoreReviewRepository: AppstoreReviewRepository { get }
}

public protocol DiaryDetailListener: AnyObject {
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
        // MARK: - DiaryModel Init 세팅
        guard let realm = Realm.safeInit() else { return }
        guard let diaryModel = self.diaryModel else { return }
        let diary = realm.object(ofType: DiaryModelRealm.self, forPrimaryKey: diaryModel._id)
        if let imageData: Data = diaryModel.originalImage {
            self.imageDataRelay.accept(imageData)
        }

        // Reminder가 있을 경우 처리하는 로직
        if let reminder = diaryModel.reminder {
            // reminder를 선택한 날짜보다 시간이 지났을 경우 비활성화
            let diffTime = Int(Date().timeIntervalSince(reminder.requestDate))
            print("DiaryDetail :: diffTime = \(diffTime)")
            if diffTime > 0 {
                dependency.diaryRepository
                    .updateDiary(DiaryModel: diaryModel, reminder: nil)
            } else {
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminder.requestDate)

                let reminderRequestModel = ReminderRequsetModel(isEditing: false, requestDateComponents: dateComponents, requestDate: reminder.requestDate)

                self.reminderRequestDateRelay.accept(reminderRequestModel)
                print("DiaryDetail :: Reminder가 있습니다!")
                
                self.presenter.setReminderIconEnabled(isEnabled: true)
            }
        } else {
            self.reminderRequestDateRelay.accept(nil)
            self.presenter.setReminderIconEnabled(isEnabled: false)
        }
        
        print("DiaryDetail :: diary = \(diary)")

        // MARK: - DiaryModel 업데이트되었을경우
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
                
                print("DiaryDetail :: propertyChanges = \(proertyChanges)")

                let reminderIsEnabled: Bool = diaryModel.reminder?.isEnabled ?? false
                // reminder가 있을 경우 true/ false로 활성화
                self.presenter.setReminderIconEnabled(isEnabled: reminderIsEnabled)

                for property in proertyChanges {
                    // 타이틀이 변경되고 reminder가 있을 경우에는 reminder도 함께 변경 해주어야함
                    if property.name == "title" {
                        if reminderIsEnabled == true,
                           let reminderRequestDate = model.reminder?.requestDate {
                            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: reminderRequestDate)
                            self.setReminderDate(isEditing: true, requestDateComponents: dateComponents)
                        }
                    }
                }

                self.presenter.loadDiaryDetail(model: self.diaryModel)
            case .error(let error):
                fatalError("\(error)")
            case .deleted:
                break
            }
        })
        // MARK: - DiaryModel의 Reply(겹쓰기)가 업데이트되었을경우
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
                    // 리뷰 요청이 필요하다면 요청할 수 있도록
                    self.showReviewPopupIfNeeded()

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
                      let model = model,
                      let requestDateComponents = model.requestDateComponents,
                      let isEditing = model.isEditing
                else { return }
                
                if let diaryModelRequestDate = self.diaryModel?.reminder?.requestDate {
                    if diaryModelRequestDate == model.requestDate {
                        print("DiaryDetail :: reminder가 다이어리모델과 동일하므로 세팅하지 않습니다.")
                        return
                    }
                }
                
                print("DiaryDetail :: reminderRequestDateRelay! = \(isEditing), \(requestDateComponents)")
                self.setReminderDate(isEditing: isEditing, requestDateComponents: requestDateComponents)
                
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
        guard let diaryModel = diaryModel else { return }
        // 1. 현재 diaryNum을 기준으로
        // 2. 왼쪽 or 오른쪽으로 이동 (pageNum이 현재 diaryNum기준 -1, +1)
        // 3. 삭제된 놈이면 건너뛰고 (isDeleted가 true일 경우)
        guard let realm = Realm.safeInit() else { return }
        let diaries = realm.objects(DiaryModelRealm.self)
            .toArray(type: DiaryModelRealm.self)
            .filter { $0.isDeleted != true }
            .sorted(by: { $0.createdAt < $1.createdAt })

        guard let currentIndex = diaries.firstIndex(of: diaryModel) else { return }
        let willChangedIdx = diaries.index(currentIndex, offsetBy: offset)

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
    
    func reminderCompViewshowToast(type: ReminderToastType) {
        presenter.reminderCompViewshowToast(type: type)
    }
    
    func deleteReminderDate() {
        print("DiaryDetail :: deleteReminderDate!")
        
        guard let diaryModel = self.diaryModel else {
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
        print("DiaryDetail :: diarymodel.title = \(diaryModel.title)")
        content.body = "\(diaryModel.title)"
        content.userInfo = ["diaryUUID": diaryModel.uuid]
        
        // Create the trigger as a repating event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: requestDateComponents, repeats: false)
        
        // Create the request
        var uuid: String = ""
        if let isEnabledReminder: Bool = diaryModel.reminder?.isEnabled,
            isEnabledReminder == true {
            uuid = diaryModel.reminder?.uuid ?? ""
        } else {
            uuid = UUID().uuidString
        }
        print("DiaryDetail :: reminder UUID = \(uuid)")

        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        // Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        
        // 수정일 경우에 원래 있는 notification 삭제
        if isEditing == true {
            print("DiaryDetail :: Editing이 true이므로 Reminder를 삭제하고, 새로 등록합니다.")
            guard let reminderRequestUUID = diaryModel.reminder?.uuid else { return }
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderRequestUUID])
            print("DiaryDetail :: Editing이 true이므로 Reminder를 삭제하고, 새로 등록합니다. - 삭제완료 \(reminderRequestUUID)")
        }
        
        notificationCenter.add(request) { error in
            print("Reminder :: 됐나!? - 1")
            if error != nil {
                print("Reminder :: 됐나!? NoError! - 2")
            }
        }
        
        guard let requestDate = Calendar.current.date(from: requestDateComponents) else { return }

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
        presenter.enableBackSwipe()
    }
    
    func pressedImageView() {
        print("DiaryDetail :: interactor -> pressedImageView!")
        guard let _: Data = diaryModel?.originalImage else { return }
        router?.attachDiaryDetailImage(imageDataRelay: self.imageDataRelay)
    }

    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: ShowToastType) {
        print("DiaryDetail :: diaryWritingPressedBackBtn! ")
        router?.detachDiaryWriting(isOnlyDetach: isOnlyDetach)
    }
    
    func presentationControllerDidDismiss() {
        router?.detachDiaryDetailImage(isOnlyDetach: true)
    }
}

// MARK: - AppstoreReview

extension DiaryDetailInteractor {
    /// 리뷰 요청이 필요한 상황인지 체크하고, 필요하다면 요청을 할 수 있도록 하는 함수
    func showReviewPopupIfNeeded() {
        // 리뷰 요청이 필요한 지
        let needReviewPopup: Bool = self.dependency.appstoreReviewRepository
            .needReviewPopup()
        // 리뷰 요청이 필요하지 않다면 return
        if !needReviewPopup { return }
        
        // 리뷰 요청이 필요하다면 BottomSheet 띄워서 요청하기
        router?.attachBottomSheet(type: .review,
                                  menuComponentRelay: nil)
    }
    
    /// 리뷰요청 건의하기 버튼을 눌렀을 경우
    func reviewCompoentViewPresentQA() {
        presenter.presentMailVC()
    }
}
 
// MARK: - 미사용
extension DiaryDetailInteractor {
    func filterWithWeatherPlacePressedFilterBtn() { }
    func setAlarm(date: Date, days: [Weekday]) async {}
}
