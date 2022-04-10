//
//  DiaryRepositoryMock.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/10.
//

import Foundation
import RxSwift
import RxRelay
@testable import Menual

public final class DiaryRepositoryMock: DiaryRepository {
    public let diaryModelSubject = BehaviorRelay<[DiaryModel]>(value: [])
    public var diaryString: BehaviorRelay<[DiaryModel]> { diaryModelSubject }
    
    public var fetchCallCount = 0
    public func fetch() {
        fetchCallCount += 1
    }
    
    public var addDiaryCallCount = 0
    public var addDiaryInfo: DiaryModel?
    public func addDiary(info: DiaryModel) {
        addDiaryCallCount += 1
        addDiaryInfo = info
        diaryString.accept(diaryString.value + [info])
    }
}

/*
public final class CardOnFileRepositoryMock: CardOnFileRepository {
    
    public var cardOnFikleSubject: CurrentValuePublisher<[PaymentMethod]> = .init([])
    public var cardOnFileString: ReadOnlyCurrentValuePublisher<[PaymentMethod]> { cardOnFikleSubject }
    
    public var addCardCallCount = 0
    public var addCardInfo: AddPaymentMethodInfo?
    public var addedPaymentMethod: PaymentMethod?
    public func addCard(info: AddPaymentMethodInfo) -> AnyPublisher<PaymentMethod, Error> {
        addCardCallCount += 1
        addCardInfo = info
        
        if let addedPaymentMethod = addedPaymentMethod {
            return Just(addedPaymentMethod).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: NSError(domain: "CardOnFileRepositoryMock", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }
    }
    
    public var fetchCallCount = 0
    public func fetch() {
        fetchCallCount += 1
    }
    
    public init() {
        
    }
    
    
}
*/
