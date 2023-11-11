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

// MARK: - DiaryDetailRouting

public protocol DiaryDetailRouting: ViewableRouting {
    func attachBottomSheet(type: MenualBottomSheetType, menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?)
    func detachBottomSheet(isWithDiaryDetatil: Bool)
    
    // 수정하기
    func attachDiaryWriting(diaryModel: DiaryModelRealm, page: Int)
    func detachDiaryWriting(isOnlyDetach: Bool)
    
    // 이미지 자세히 보기
    func attachDiaryDetailImage(uploadImagesRelay: BehaviorRelay<[Data]>, selectedIndex: Int)
    func detachDiaryDetailImage(isOnlyDetach: Bool)
}

// MARK: - DiaryDetailPresentable

public protocol DiaryDetailPresentable: Presentable {
    var listener: DiaryDetailPresentableListener? { get set }

    func reloadTableView()
    func reloadCurrentCell()
    func setCurrentPageDiary()
    func reminderCompViewshowToast(type: ReminderToastType)
    func setReminderIconEnabled(isEnabled: Bool)
    func enableBackSwipe()
    func presentMailVC()
}

// MARK: - DiaryDetailInteractorDependency

public protocol DiaryDetailInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var appstoreReviewRepository: AppstoreReviewRepository { get }
}

// MARK: - DiaryDetailListener

public protocol DiaryDetailListener: AnyObject {
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool)
    func diaryDeleteNeedToast(isNeedToast: Bool)
}

// MARK: - DiaryDetailInteractor

final class DiaryDetailInteractor: PresentableInteractor<DiaryDetailPresentable>, DiaryDetailInteractable, DiaryDetailPresentableListener, AdaptivePresentationControllerDelegate {
    
    var diaryReplyArr: [DiaryReplyModelRealm] = []
    var currentDiaryPage: Int
    var diaryModel: DiaryModelRealm?
    
    let presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    
    private var disposebag = DisposeBag()
    private let changeCurrentDiarySubject = BehaviorSubject<Bool>(value: false)
    internal let uploadImagesRelay: BehaviorRelay<[Data]> = .init(value: [])
    
    // Reminder 관련
    let reminderRequestDateRelay = BehaviorRelay<ReminderRequsetModel?>(value: nil)
    let isHideMenualRelay = BehaviorRelay<Bool>(value: false)
    let isEnabledReminderRelay = BehaviorRelay<Bool?>(value: nil)

    weak var router: DiaryDetailRouting?
    weak var listener: DiaryDetailListener?
    private let dependency: DiaryDetailInteractorDependency

    let currentDiaryModelRelay: BehaviorRelay<DiaryModelRealm?> = .init(value: nil)
    let currentDiaryModelIndexRelay: BehaviorRelay<Int> = .init(value: 0)
    let diaryModelArrRelay: BehaviorRelay<[DiaryModelRealm]> = .init(value: [])

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
        
        getDiaryModelArr()
        currentDiaryModelRelay.accept(diaryModel)
        self.presentationDelegateProxy.delegate = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()

        bind()
        // 메뉴얼 진입시에 최초 한 번 Notification 등록
        // setDiaryModelRealmOb()
    }

    override func willResignActive() {
        super.willResignActive()

        print("DiaryDetail :: WillResignActive")
        notificationToken?.invalidate()
        replyNotificationToken?.invalidate()
    }
    
    /// Realm 변경점에 대해서 Notification을 받기 위해서 토큰 등록 함수
    func setDiaryModelRealmOb() {
        // MARK: - DiaryModel Init 세팅
        guard let realm: Realm = Realm.safeInit() else { return }
        guard let diaryModel: DiaryModelRealm = currentDiaryModelRelay.value else { return }

        let diary = realm.object(ofType: DiaryModelRealm.self, forPrimaryKey: diaryModel._id)

        // 현재 메뉴얼의 images를 View에 적용하기 위해서 accept
        diaryModel.getImages { [weak self] imageDataArr in
            guard let self = self else { return }
            self.uploadImagesRelay.accept(imageDataArr)
        }
        // let imagesData: [Data] = diaryModel.images
        // self.imagesDataRelay.accept(imagesData)

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

                self.diaryModel?.getImages(completion: { [weak self] imageeDataArr in
                    guard let self = self else { return }
                    self.uploadImagesRelay.accept(imageeDataArr)
                })
//                if let imagesData: [Data] = self.diaryModel?.images {
//                    self.imagesDataRelay.accept(imagesData)
//                }
                
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

                // self.presenter.loadDiaryDetail(model: self.diaryModel)
                // self.presenter.setCurrentPageDiary()
                // self.presenter.reloadTableView()
                self.presenter.reloadCurrentCell()

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
                self.diaryReplyArr = Array(model)
                self.presenter.reloadCurrentCell()

            case .update(let model, let deletions, let insertions, _):
                print("DiaryDetail :: update! = \(model)")
                if deletions.count > 0 {
                    guard let deletionRow: Int = deletions.first else { return }
                    self.diaryReplyArr.remove(at: deletionRow)
                }
                
                if insertions.count > 0 {
                    // 리뷰 요청이 필요하다면 요청할 수 있도록
                    self.showReviewPopupIfNeeded()

                    guard let insertionRow: Int = insertions.first else { return }
                    let replyModelRealm: DiaryReplyModelRealm = model[insertionRow]
                    self.diaryReplyArr.append(replyModelRealm)
                }

                self.presenter.reloadCurrentCell()

            case .error(let error):
                fatalError("\(error)")
            }
        })
    }
    
    private func bind() {
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

        currentDiaryModelRelay
            .subscribe(onNext: { [weak self] currentDiaryModel in
                guard let self = self else { return }
                print("DiaryDetail :: currentDiaryModelRelay! = \(currentDiaryModel?.title)")
                self.notificationToken = nil
                self.replyNotificationToken = nil
                self.setDiaryModelRealmOb()
            })
            .disposed(by: disposebag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryDetailPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedReplySubmitBtn(desc: String) {
        guard let diaryModel: DiaryModelRealm = currentDiaryModelRelay.value else { return }

        let diaryReplyModelRealm = DiaryReplyModelRealm(
            uuid: UUID().uuidString,
            replyNum: 0,
            diaryUuid: diaryModel.uuid,
            desc: desc,
            createdAt: Date(),
            isDeleted: false
        )

        self.dependency.diaryRepository
            .addReply(info: diaryReplyModelRealm, diaryModel: diaryModel)
    }
    
    func deleteReply(replyModel: DiaryReplyModelRealm) {
        print("DiaryDetail :: DeletReply!")
        guard let diaryModel: DiaryModelRealm = currentDiaryModelRelay.value else { return }

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
        guard let diaryModel: DiaryModelRealm = currentDiaryModelRelay.value else { return }

        isHideMenualRelay.accept(diaryModel.isHide)
        router?.attachBottomSheet(type: .menu, menuComponentRelay: menuComponentRelay)
    }
    
    // 유저가 바텀싯을 통해서 숨기기를 눌렀을 경우
    func hideDiary() {
        print("DiaryDetail :: hideDiary! 1")

        guard let diaryModel: DiaryModelRealm = currentDiaryModelRelay.value else { return }

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
    
    func pressedImageView(index: Int) {
        print("DiaryDetail :: interactor -> pressedImageView!")
        router?.attachDiaryDetailImage(uploadImagesRelay: self.uploadImagesRelay, selectedIndex: index)
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

// MARK: - CollectionView Type DiaryDetail

extension DiaryDetailInteractor {
    private func getDiaryModelArr() {
        guard let realm: Realm = .safeInit() else { return }

        let diaryArr: [DiaryModelRealm] = realm.objects(DiaryModelRealm.self)
            .toArray(type: DiaryModelRealm.self)
            .filter ({ $0.isDeleted == false })
            .sorted(by: { $0.createdAt < $1.createdAt })

        diaryModelArrRelay.accept(diaryArr)

        print("DiaryDetail :: getDiaryModelArr = \(diaryArr)")
    }
}

// MARK: - 미사용
extension DiaryDetailInteractor {
    func filterWithWeatherPlacePressedFilterBtn() { }
    func setAlarm(date: Date, days: [Weekday]) async {}
}
