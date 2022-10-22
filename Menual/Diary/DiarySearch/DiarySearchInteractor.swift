//
//  DiarySearchInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs
import RxSwift
import RxRelay
import RxRealm
import RealmSwift

protocol DiarySearchRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
    func attachDiaryDetailVC(diaryModel: DiaryModel)
    func detachDiaryDetailVC(isOnlyDetach: Bool)
}

protocol DiarySearchPresentable: Presentable {
    var listener: DiarySearchPresentableListener? { get set }
    
    func reloadSearchTableView()
}

protocol DiarySearchInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

protocol DiarySearchListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diarySearchPressedBackBtn(isOnlyDetach: Bool)
}

final class DiarySearchInteractor: PresentableInteractor<DiarySearchPresentable>, DiarySearchInteractable, DiarySearchPresentableListener {
    
    weak var router: DiarySearchRouting?
    weak var listener: DiarySearchListener?
    private let dependency: DiarySearchInteractorDependency
    var disposeBag = DisposeBag()
    
    var searchResultsRelay = BehaviorRelay<[DiaryModel]>(value: [])
    var recentSearchResultsRelay = BehaviorRelay<[DiarySearchModel]>(value: [])
    // var recentSearchResultList: [SearchModel] = []

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiarySearchPresentable,
        dependency: DiarySearchInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        fetchRecentSearchList()
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        dependency.diaryRepository
            .diarySearch
            .subscribe(onNext: { [weak self] diarySearch in
                guard let self = self else { return }
                print("Search :: -> DiarySearch 구독중!!!")
                print("Search :: = \(diarySearch)")
                self.recentSearchResultsRelay.accept(diarySearch)
            })
            .disposed(by: disposeBag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diarySearchPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    // Realm에서 검색해서 결과값 뿌려주는 함수
    func searchTest(keyword: String) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        // let results = realm.objects(DiaryModelRealm.self)
           //  .filter("title CONTAINS %@", "\(keyword)")
        
        let results = realm.objects(DiaryModelRealm.self)
            .filter("title CONTAINS %@ OR desc CONTAINS %@", "\(keyword)", "\(keyword)")
        
        print("reuslt = \(results)")
        
        var searchResultList = [DiaryModel]()
        for result in results {
            let diary = DiaryModel(result)
            searchResultList.append(diary)
        }
        
        self.searchResultsRelay.accept(searchResultList)
        
        // presenter.reloadSearchTableView()
    }
    
    func searchDataTest(keyword: String) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let model = SearchModel(uuid: NSUUID().uuidString,
                                keyword: keyword,
                                createdAt: Date(),
                                isDeleted: false
        )
        
        realm.safeWrite {
            realm.add(SearchModelRealm(model))
        }
    }
    
    func fetchRecentSearchList() {
        dependency.diaryRepository
            .fetchRecntDiarySearch()
    }
    
    // 검색해서 나온 Cell을 터치했을 경우 -> DiaryDetailVC로 보내줘야함
    func pressedSearchCell(diaryModel: DiaryModel) {
        print("Search :: pressedSearchCell!")
        router?.attachDiaryDetailVC(diaryModel: diaryModel)
        dependency.diaryRepository
            .addDiarySearch(info: diaryModel)
    }
    
    func pressedRecentSearchCell(diaryModelRealm: DiaryModelRealm) {
        print("Search :: pressedRecentSearchCell!")
        let diaryModel: DiaryModel = DiaryModel(diaryModelRealm)
        router?.attachDiaryDetailVC(diaryModel: diaryModel)
    }
    
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryDetailVC(isOnlyDetach: isOnlyDetach)
    }
    
    func tempSaveSearchModel(diaryModel: DiaryModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let searchRealm: DiarySearchModelRealm = DiarySearchModelRealm(
            uuid: UUID().uuidString,
            diaryUuid: diaryModel.uuid,
            diary: DiaryModelRealm(diaryModel),
            createdAt: Date(),
            isDeleted: false
        )
        
        realm.safeWrite {
            realm.add(searchRealm)
        }
    }
    
    func deleteAllRecentSearchData() {
        print("Search :: deleteAllRecentSearchData!")
        
        dependency.diaryRepository
            .deleteAllRecentDiarySearch()
    }
}
