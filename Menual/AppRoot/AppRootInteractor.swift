//
//  AppRootInteractor.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import Foundation
import MenualRepository
import RIBs
import RxSwift

// MARK: - AppRootRouting

protocol AppRootRouting: Routing {
    func cleanupViews()
    func attachMainHome()
    func attachProfilePassword()
}

// MARK: - AppRootPresentable

protocol AppRootPresentable: Presentable {
    var listener: AppRootPresentableListener? { get set }
}

// MARK: - AppRootListener

protocol AppRootListener: AnyObject {}

// MARK: - AppRootInteractorDependency

protocol AppRootInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var migrationRepository: MigrationRepository? { get }
}

// MARK: - AppRootInteractor

final class AppRootInteractor: PresentableInteractor<AppRootPresentable>,
    AppRootInteractable,
    AppRootPresentableListener,
    URLHandler
{
    func handle(_ url: URL) {}

    weak var router: AppRootRouting?
    weak var listener: AppRootListener?
    private let disposeBag = DisposeBag()
    private let dependency: AppRootInteractorDependency

    // in constructor.
    init(
        presenter: AppRootPresentable,
        dependency: AppRootInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        dependency.migrationRepository?.reorganizeFilesInDocumentDirectory(completion: { [weak self] isCompleted in
            guard let self = self else { return }
            print("migration! = \(isCompleted)")
        })

        dependency.diaryRepository.fetchPassword()
        dependency.diaryRepository
            .password
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }

                // password 설정을 안했다면
                if model == nil || model?.isEnabled == false {
                    self.router?.attachMainHome()
                } else {
                    self.router?.attachProfilePassword()
                }
            })
            .disposed(by: disposeBag)
    }

    override func willResignActive() {
        super.willResignActive()

        router?.cleanupViews()
    }
}
