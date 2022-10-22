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
    func attachDiaryWriting(diaryModel: DiaryModel)
    func detachDiaryWriting(isOnlyDetach: Bool)
}

protocol DiaryDetailPresentable: Presentable {
    var listener: DiaryDetailPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func reloadTableView()
    func loadDiaryDetail(model: DiaryModel)
    func testLoadDiaryImage(imageName: UIImage?)
}
protocol DiaryDetailInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

protocol DiaryDetailListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool)
}

final class DiaryDetailInteractor: PresentableInteractor<DiaryDetailPresentable>, DiaryDetailInteractable, DiaryDetailPresentableListener {
    
    var diaryReplies: [DiaryReplyModel]
    var currentDiaryPage: Int
    var diaryModel: DiaryModel?
    
    private var disposebag = DisposeBag()
    private let changeCurrentDiarySubject = BehaviorSubject<Bool>(value: false)

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
        self.diaryModel = diaryModel
        self.dependency = dependency
        self.diaryReplies = diaryModel.replies
        self.currentDiaryPage = diaryModel.pageNum
        super.init(presenter: presenter)
        presenter.listener = self
        
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
                self.diaryReplies = currentDiaryModel.replies
                self.currentDiaryPage = currentDiaryModel.pageNum
                presenter.loadDiaryDetail(model: currentDiaryModel)
                dependency.diaryRepository
                    .loadImageFromDocumentDirectory(imageName: diaryModel.uuid, completionHandler: { iamge in
                        guard let image = iamge else {
                            return
                        }
                        self.presenter.testLoadDiaryImage(imageName:image)
                    })
                self.presenter.reloadTableView()
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
                    self.router?.attachDiaryWriting(diaryModel: diaryModel)
                    
                case .delete:
                    guard let diaryModel = self.diaryModel else { return }
                    dependency.diaryRepository
                        .deleteDiary(info: diaryModel)
                    self.router?.detachBottomSheet(isWithDiaryDetatil: true)
                    
                case .none:
                    break
                }
            })
            .disposed(by: self.disposebag)
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
            .addReplay(info: newDiaryReplyModel)
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
        router?.attachBottomSheet(type: .menu, menuComponentRelay: menuComponentRelay)
    }
    
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool) {
        // TODO
        print("diaryWritingPressedBackBtn")
        router?.detachDiaryWriting(isOnlyDetach: isOnlyDetach)
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

    // 미사용
    func filterWithWeatherPlacePressedFilterBtn() { }
}
 
