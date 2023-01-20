//
//  DiarySearchInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs
import RxSwift
import RxRelay
import RealmSwift
import MenualEntity
import MenualRepository

public protocol DiarySearchRouting: ViewableRouting {
    func attachDiaryDetailVC(diaryModel: DiaryModelRealm)
    func detachDiaryDetailVC(isOnlyDetach: Bool)
}

public protocol DiarySearchPresentable: Presentable {
    var listener: DiarySearchPresentableListener? { get set }
    
    func reloadSearchTableView()
    
    func updateRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType)
    func insertRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType)
    func deleteRow(at indexs: [Int], section: DiarySearchViewController.DiarySearchSectionType)
}

public protocol DiarySearchInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

public protocol DiarySearchListener: AnyObject {
    func diarySearchPressedBackBtn(isOnlyDetach: Bool)
}

final class DiarySearchInteractor: PresentableInteractor<DiarySearchPresentable>, DiarySearchInteractable, DiarySearchPresentableListener {
    
    weak var router: DiarySearchRouting?
    weak var listener: DiarySearchListener?
    private let dependency: DiarySearchInteractorDependency
    private var disposeBag = DisposeBag()
    
    internal var searchResultsRelay = BehaviorRelay<[DiaryModelRealm]>(value: [])
    internal var recentSearchModel: [DiarySearchModelRealm]?
    
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
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        recentSearchModelNnotificationToken = nil
    }
    
    func bind() {
        guard let realm = Realm.safeInit() else { return }
        let diarySearchModelRealm = realm.objects(DiarySearchModelRealm.self)
        recentSearchModelNnotificationToken = diarySearchModelRealm.observe({ changes in
            switch changes {
            case .initial(let model):
                print("Search :: init!")
                let filteredModel = model
                    .toArray(type: DiarySearchModelRealm.self)
                    .filter ({ $0.isDeleted == false })
                    .sorted(by: { $0.createdAt > $1.createdAt })

                self.recentSearchModel = filteredModel
                self.presenter.reloadSearchTableView()
            case .update(let model, let deletions, let insertions, let modifications):
                print("Search :: update!")
                let filteredModel = model
                    .toArray(type: DiarySearchModelRealm.self)
                    .filter ({ $0.isDeleted == false })
                    .sorted(by: { $0.createdAt > $1.createdAt })

                self.recentSearchModel = filteredModel
                
                if deletions.count > 0 {
                    self.presenter.deleteRow(at: deletions, section: .recentSearch)
                    print("Search :: deletions!")
                }
                
                if insertions.count > 0 {
                    print("Search :: insertions!, insertions = \(insertions)")
                    self.presenter.insertRow(at: insertions, section: .recentSearch)
                }
                
                if modifications.count > 0 {
                    self.presenter.updateRow(at: modifications, section: .recentSearch)
                    print("Search :: modifications!")
                }
            case .error(let error):
                print("Search :: error!, \(error)")
            }
        })
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diarySearchPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    // Realm에서 검색해서 결과값 뿌려주는 함수
    func search(keyword: String) {
        guard let realm = Realm.safeInit() else {
            return
        }

        let results = realm.objects(DiaryModelRealm.self)
            .filter("isDeleted == false AND (title CONTAINS %@ OR desc CONTAINS %@)", "\(keyword)", "\(keyword)")
            .toArray(type: DiaryModelRealm.self)
        
        print("reuslt = \(results)")
        self.searchResultsRelay.accept(results)
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
