//
//  ContainerRepository.swift
//  
//
//  Created by 정진균 on 2023/05/06.
//

import Foundation
import Swinject
import MenualServices

// MARK: - ContainerRepository

public protocol ContainerRepository {
    var container: Container { get }
    func registerService()
    func registerRepository()
}

// MARK: - ContainerRepositoryImp

public class ContainerRepositoryImp: ContainerRepository {
    public let container = Container()
    
    public init() {
        registerService()
        registerRepository()
    }
    
    public func registerService() {
        container.register(IAPServiceProtocol.self) { _ in
            IAPService()
        }
    }
    
    public func registerRepository() {
        container.register(AppstoreReviewRepository.self) { _ in
            AppstoreReviewRepositoryImp()
        }.inObjectScope(.container)
        
        container.register(BackupRestoreRepository.self) { _ in
            BackupRestoreRepositoryImp()
        }.inObjectScope(.container)
        
        container.register(DiaryRepository.self) { _ in
            DiaryRepositoryImp()
        }.inObjectScope(.container)
        
        container.register(MomentsRepository.self) { _ in
            MomentsRepositoryImp()
        }.inObjectScope(.container)
        
        container.register(ProfileRepository.self) { _ in
            ProfileRepositoryImp()
        }.inObjectScope(.container)
        
        container.register(NotificationRepository.self) { _ in
            NotificationRepositoryImp()
        }.inObjectScope(.container)

        container.register(AppUpdateInfoRepository.self) { _ in
            AppUpdateInfoRepositoryImp()
        }.inObjectScope(.container)

        container.register(MigrationRepository.self) { _ in
            MigrationRepositoryImp()
        }.inObjectScope(.container)
    }
}
