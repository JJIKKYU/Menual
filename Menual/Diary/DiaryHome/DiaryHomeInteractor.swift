//
//  DiaryHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs
import RxSwift
import RealmSwift

protocol DiaryHomeRouting: ViewableRouting {
    func attachMyPage()
    func detachMyPage()
    func attachDiarySearch()
    func detachDiarySearch()
    func attachDiaryMoments()
    func detachDiaryMoments()
    func attachDiaryWriting()
    func detachDiaryWriting()
    func attachDiaryDetail(model: DiaryModel)
    func detachDiaryDetail()
}

protocol DiaryHomePresentable: Presentable {
    var listener: DiaryHomePresentableListener? { get set }
    
    func reloadTableView()
}

protocol DiaryHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

protocol DiaryHomeInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryHomeInteractor: PresentableInteractor<DiaryHomePresentable>, DiaryHomeInteractable, DiaryHomePresentableListener, AdaptivePresentationControllerDelegate {

    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy
    

    weak var router: DiaryHomeRouting?
    weak var listener: DiaryHomeListener?
    private let dependency: DiaryHomeInteractorDependency
    private var disposebag: DisposeBag

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryHomePresentable,
        dependency: DiaryHomeInteractorDependency
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
        self.presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
        
        super.init(presenter: presenter)
        presenter.listener = self
        self.presentationDelegateProxy.delegate = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        print("DiaryHomeInteractor :: Bind!")

        dependency.diaryRepository
            .diaryString
            .subscribe(onNext: { [weak self] diaryArr in
                guard let self = self else { return }
                print("diaryString 구독 중!, diary = \(diaryArr)")
                print("<- reloadTableView")
                self.presenter.reloadTableView()
            })
            .disposed(by: disposebag)

        /*
        dependency.diaryRepository
            .realmDiaryOb
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                print("아이클라우드에서 받아온 정보 : \(data)")
                // self.presenter.reloadTableView()
            })
            .disposed(by: disposebag)
         */
    }
    
    func getMyMenualCount() -> Int {
        return dependency.diaryRepository.diaryString.value.count
    }
    
    func getMyMenualArr() -> [DiaryModel] {
        return dependency.diaryRepository.diaryString.value
    }
    
    // AdaptivePresentationControllerDelegate, Drag로 뷰를 Dismiss 시킬경우에 호출됨
    func presentationControllerDidDismiss() {
        print("!!")
    }
    
    // MARK: - MyPage (ProfileHome) 관련 함수
    func pressedMyPageBtn() {
        print("DiaryHomeInteractor :: pressedMyPageBtn!")
        router?.attachMyPage()
    }
    
    func profileHomePressedBackBtn() {
        print("DiaryHomeInteractor :: profileHomePressedBackBtn!")
        router?.detachMyPage()
    }
    
    // MARK: - Diary Search (검색화면) 관련 함수
    func pressedSearchBtn() {
        print("DiaryHomeInteractor :: pressedSearchBtn!")
        router?.attachDiarySearch()
    }
    
    func diarySearchPressedBackBtn() {
        print("DiaryHomeInteractor :: diarySearchPressedBackBtn!")
        router?.detachDiarySearch()
    }
    
    // MARK: - Moments 관련 함수
    func pressedMomentsTitleBtn() {
        print("DiaryHomeInteractor :: pressedMomentsTitleBtn!")
        router?.attachDiaryMoments()
    }
    
    func pressedMomentsMoreBtn() {
        print("DiaryHomeInteractor :: pressedMomentsMoreBtn!")
        router?.attachDiaryMoments()
    }
    
    func diaryMomentsPressedBackBtn() {
        print("DiaryHomeInteractor :: diaryMomentsPressedBackBtn!")
        router?.detachDiaryMoments()
    }
    
    // MARK: - Diary Writing 관련 함수
    func pressedWritingBtn() {
        print("DiaryHomeInteractor :: pressedWritingBtn!")
        router?.attachDiaryWriting()
    }
    
    func diaryWritingPressedBackBtn() {
        router?.detachDiaryWriting()
    }
    
    // MARK: - Diary detaill 관련 함수
    
    func pressedDiaryCell(index: Int) {
        if let model = dependency.diaryRepository
            .diaryString.value[safe: index] {
            router?.attachDiaryDetail(model: model)
        }
    }
    
    func diaryDetailPressedBackBtn() {
        router?.detachDiaryDetail()
    }
}
