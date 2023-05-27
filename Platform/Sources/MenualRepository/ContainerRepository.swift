//
//  ContainerRepository.swift
//  
//
//  Created by 정진균 on 2023/05/06.
//

import Foundation
import Swinject
import MenualServices

public protocol ContainerRepository {
    var container: Container { get }
    func registerService()
    func registerRepository()
}

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
        }
        
        container.register(BackupRestoreRepository.self) { _ in
            BackupRestoreRepositoryImp()
        }
        
        container.register(DiaryRepository.self) { _ in
            DiaryRepositoryImp()
        }
        
        container.register(MomentsRepository.self) { _ in
            MomentsRepositoryImp()
        }
    }
}
