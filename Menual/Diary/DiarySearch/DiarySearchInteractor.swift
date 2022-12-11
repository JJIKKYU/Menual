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
    func attachDiaryDetailVC(diaryModel: DiaryModelRealm)
    func detachDiaryDetailVC(isOnlyDetach: Bool)
}

protocol DiarySearchPresentable: Presentable {
    var listener: DiarySearchPresentableListener? { get set }
    
    func reloadSearchTableView()
    
    func updateRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType)
    func insertRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType)
    func deleteRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType)
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
    
    var searchResultsRelay = BehaviorRelay<[DiaryModelRealm]>(value: [])
    var recentSearchResultsRelay = BehaviorRelay<[DiarySearchModel]>(value: [])
    var recentSearchModel: List<DiarySearchModelRealm>?
    
    var recentSearchModelNnotificationToken: NotificationToken?

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
        
        recentSearchModelNnotificationToken = nil
    }
    
    func bind() {
        guard let realm = Realm.safeInit() else { return }
        let diarySearchModelRealm = realm.objects(DiarySearchModelRealm.self)
        recentSearchModelNnotificationToken = diarySearchModelRealm.observe({ changes in
            switch changes {
            case .initial(let model):
                print("DiarySearch :: init!")
                self.recentSearchModel = model.list
                self.presenter.reloadSearchTableView()
            case .update(let model, let deletions, let insertions, let modifications):
                print("DiarySearch :: update!")
                if deletions.count > 0 {
                    self.recentSearchModel = model.list
                    self.presenter.deleteRow(at: deletions, section: .recentSearch)
                    print("DiarySearch :: deletions!")
                }
                
                if insertions.count > 0 {
                    print("DiarySearch :: insertions!, insertions = \(insertions)")
                    self.recentSearchModel = model.list
                    self.presenter.insertRow(at: insertions, section: .recentSearch)
                }
                
                if modifications.count > 0 {
                    self.recentSearchModel = model.list
                    self.presenter.updateRow(at: modifications, section: .recentSearch)
                    print("DiarySearch :: modifications!")
                }
            case .error(let error):
                print("DiarySearch :: error!")
            }
        })
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
            .filter("title CONTAINS %@ OR desc CONTAINS %@", "\(keyword)", "\(keyword)").toArray()
        
        print("reuslt = \(results)")
        self.searchResultsRelay.accept(results)
        
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
    func pressedSearchCell(diaryModel: DiaryModelRealm) {
        print("Search :: pressedSearchCell!")
        router?.attachDiaryDetailVC(diaryModel: diaryModel)
        dependency.diaryRepository
            .addDiarySearch(info: diaryModel)
    }
    
    func pressedRecentSearchCell(diaryModel: DiaryModelRealm) {
        print("Search :: pressedRecentSearchCell!")
        router?.attachDiaryDetailVC(diaryModel: diaryModel)
    }
    
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryDetailVC(isOnlyDetach: isOnlyDetach)
    }

    // 최근 검색어 전체 삭제
    func deleteAllRecentSearchData() {
        print("Search :: deleteAllRecentSearchData!")
        
        dependency.diaryRepository
            .deleteAllRecentDiarySearch()
    }
    
    // 최근 검색어 하나 삭제
    func deleteRecentSearchData(uuid: String) {
        print("Search :: deleteRecentSearchData!")

        dependency.diaryRepository
            .deleteRecentDiarySearch(uuid: uuid)
    }
}

// MARK: - 미사용
extension DiarySearchInteractor {
    func diaryDeleteNeedToast(isNeedToast: Bool) { }
}
