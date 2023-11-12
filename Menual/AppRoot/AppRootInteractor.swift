//
//  AppRootInteractor.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import Foundation
import MenualEntity
import MenualRepository
import RIBs
import RxRelay
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
    private let initialStateRelay: BehaviorRelay<InitialState> = .init(value: .idle)
    private let passwordStateRelay: BehaviorRelay<InitialPasswordState?> = .init(value: nil)

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

        bind()

        dependency.migrationRepository?.reorganizeFilesInDocumentDirectory(completion: { [weak self] isCompleted in
            guard let self = self else { return }
            print("migration! = \(isCompleted)")
        })
    }

    override func willResignActive() {
        super.willResignActive()

        router?.cleanupViews()
    }

    private func bind() {
        initialStateRelay
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .idle:
                    print("AppRoot :: Initial 상태입니다.")

                    // password 사용 중인지 fetch
                    self.dependency.diaryRepository.fetchPassword()
                    self.dependency.migrationRepository?.migrationIfNeeded()
                    break

                case .migration:
                    print("AppRoot :: Migration 중입니다.")
                    break

                case .password:
                    print("AppRoot :: Password를 입력할 수 있도록 합니다.")
                    self.router?.attachProfilePassword()
                    break

                case .goHome:
                    print("AppRoot :: Home으로 이동합니다.")
                    self.router?.attachMainHome()
                    break
                }
            })
            .disposed(by: disposeBag)

        guard let migrationRepository = dependency.migrationRepository else { return }

        Observable.combineLatest(
            passwordStateRelay,
            migrationRepository.migrationStateRelay
        )
        .subscribe(onNext: { [weak self] passwordState, migrationState in
            guard let self = self else { return }

            // 마이그레이션이 가장 최우선적으로 확인
            // 필요하지 않거나. complete 상태가 아닐 경우 대기
            if migrationState == .notNeeded &&
                migrationState == .completed {
                self.initialStateRelay.accept(.idle)
                return
            }

            if migrationState == .inProgress {
                self.initialStateRelay.accept(.migration)
                return
            }

            // 마이그레이션이 끝나거나 필요 없을 경우
            if passwordState == .nonPassword {
                self.initialStateRelay.accept(.goHome)
            }
            else if passwordState == .hasPassword {
                self.initialStateRelay.accept(.password)
            }
        })
        .disposed(by: disposeBag)


        dependency.diaryRepository
            .password
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }

                // password 설정을 안했다면
                if model == nil || model?.isEnabled == false {
                    self.passwordStateRelay.accept(.nonPassword)
                } else {
                    self.passwordStateRelay.accept(.hasPassword)

                }
            })
            .disposed(by: disposeBag)
    }
}
