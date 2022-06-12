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

protocol DiarySearchListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diarySearchPressedBackBtn(isOnlyDetach: Bool)
}

final class DiarySearchInteractor: PresentableInteractor<DiarySearchPresentable>, DiarySearchInteractable, DiarySearchPresentableListener {
    
    weak var router: DiarySearchRouting?
    weak var listener: DiarySearchListener?
    
    var searchResultsRelay = BehaviorRelay<[DiaryModel]>(value: [])
    var recentSearchResultList: [SearchModel] = []

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DiarySearchPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        fetchRecentSearchList()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
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
        guard let realm = Realm.safeInit() else {
            return
        }
        recentSearchResultList.removeAll()
        let results = realm.objects(SearchModelRealm.self)
        for result in results {
            let model = SearchModel(result)
            recentSearchResultList.append(model)
        }
        presenter.reloadSearchTableView()
    }
    
    // 검색해서 나온 Cell을 터치했을 경우 -> DiaryDetailVC로 보내줘야함
    func pressedSearchCell(diaryModel: DiaryModel) {
        router?.attachDiaryDetailVC(diaryModel: diaryModel)
    }
    
    func diaryDetailPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachDiaryDetailVC(isOnlyDetach: isOnlyDetach)
    }
    
}
