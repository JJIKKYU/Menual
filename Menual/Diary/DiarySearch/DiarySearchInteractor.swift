//
//  DiarySearchInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs
import RxSwift
import RxRealm
import RealmSwift

protocol DiarySearchRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiarySearchPresentable: Presentable {
    var listener: DiarySearchPresentableListener? { get set }
    
    func reloadSearchTableView()
}

protocol DiarySearchListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diarySearchPressedBackBtn()
}

final class DiarySearchInteractor: PresentableInteractor<DiarySearchPresentable>, DiarySearchInteractable, DiarySearchPresentableListener {

    weak var router: DiarySearchRouting?
    weak var listener: DiarySearchListener?
    
    var searchResultList: [DiaryModel] = []

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DiarySearchPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedBackBtn() {
        listener?.diarySearchPressedBackBtn()
    }
    
    func searchTest(keyword: String) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let results = realm.objects(DiaryModelRealm.self)
            .filter("title CONTAINS %@", "\(keyword)")
        
        print("reuslt = \(results)")
        
        searchResultList = []
        for result in results {
            let diary = DiaryModel(result)
            searchResultList.append(diary)
        }
        
        presenter.reloadSearchTableView()
    }
}
