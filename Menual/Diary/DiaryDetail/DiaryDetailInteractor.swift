//
//  DiaryDetailInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxSwift

protocol DiaryDetailRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryDetailPresentable: Presentable {
    var listener: DiaryDetailPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func pressedBackBtn()
    func reloadTableView()
    func loadDiaryDetail(model: DiaryModel)
    func testLoadDiaryImage(imageName: UIImage?)
}
protocol DiaryDetailInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

protocol DiaryDetailListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryDetailPressedBackBtn()
}

final class DiaryDetailInteractor: PresentableInteractor<DiaryDetailPresentable>, DiaryDetailInteractable, DiaryDetailPresentableListener {

    var diaryReplies: [DiaryReplyModel]
    let diaryModel: DiaryModel?
    
    private var disposebag = DisposeBag()

    weak var router: DiaryDetailRouting?
    weak var listener: DiaryDetailListener?
    private let dependency: DiaryDetailInteractorDependency

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
        super.init(presenter: presenter)
        presenter.listener = self
        
        print("interactor = \(diaryModel)")
        presenter.loadDiaryDetail(model: diaryModel)

        let image = dependency.diaryRepository
            .loadImageFromDocumentDirectory(imageName: diaryModel.uuid)
        presenter.testLoadDiaryImage(imageName: image)
        
        dependency.diaryRepository
            .diaryString
            .subscribe(onNext: { [weak self] diaryArr in
                guard let self = self else { return }
                print("diaryString 구독 중!, diary = \(diaryArr)")
                guard let currentDiaryModel = diaryArr.filter { diaryModel.uuid == $0.uuid }.first else { return }
                print("<- reloadTableView")
                self.diaryReplies = currentDiaryModel.replies
                presenter.loadDiaryDetail(model: currentDiaryModel)
                self.presenter.reloadTableView()
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
    
    func pressedBackBtn() {
        listener?.diaryDetailPressedBackBtn()
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
}
