//
//  DiaryWritingInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import RealmSwift

protocol DiaryWritingRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryWritingPresentable: Presentable {
    var listener: DiaryWritingPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func pressedBackBtn()
}

protocol DiaryWritingListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryWritingPressedBackBtn()
}

protocol DiaryWritingInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryWritingInteractor: PresentableInteractor<DiaryWritingPresentable>, DiaryWritingInteractable, DiaryWritingPresentableListener {
    
    weak var router: DiaryWritingRouting?
    weak var listener: DiaryWritingListener?
    private let dependency: DiaryWritingInteractorDependency
    private var disposebag: DisposeBag

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryWritingPresentable,
        dependency: DiaryWritingInteractorDependency
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
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
        listener?.diaryWritingPressedBackBtn()
    }
    
    func pressedCheckBtn() {
        print("글 작성 완료 했죠?")
        self.writeDiary()
    }
}

// 글 작성 로직 테스트
extension DiaryWritingInteractor {
    func writeDiary() {
        print("DiaryWritingInteractor :: writeDiary!")
        
        dependency.diaryRepository
            .addDiary(info: DiaryModel(title: "타이틀입니다9999999", weather: "조아요", location: "집", description: "안녕하세요", image: "이미지"))
        
//        let realm = try! Realm()
//        let newDiary = DiaryModelRealm(title: "타이틀입니다", weather: "조아요", location: "집", desc: "안녕하세요", image: "이미지")
//
//        try! realm.write {
//            realm.add(newDiary)
//        }
    }
}
