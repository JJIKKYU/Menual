//
//  DiaryRepository.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RxSwift
import RxRelay

public protocol DiaryRepository {
    // func addCard(info: AddPaymentMethodInfo) -> AnyPublisher<PaymentMethod, Error>
    // ReadOnlyCurrentValuePublisher<[PaymentMethod]> { get }
    
    var diaryString: Observable<[DiaryModel]> { get }
    // func addDiary(info: DiaryModel) throws -> Observable<DiaryModel>
    func fetch()
}

public final class DiaryRepositoryImp: DiaryRepository {
    public var diaryString: Observable<[DiaryModel]> { diaryModelSubject }
    
    public let diaryModelSubject = BehaviorSubject<[DiaryModel]>(value: [
        DiaryModel(title: "타이틀마", weather: "웨덜마", location: "로케이션마", description: "디스크립션마", image: "이미징마")
//        PaymentMethod(id: "0", name: "우리은행", digits: "0123", color: "#f19a38ff", isPrimary: false),
//        PaymentMethod(id: "1", name: "신한카드", digits: "0987", color: "#3478f6ff", isPrimary: false),
//        PaymentMethod(id: "2", name: "현대카드", digits: "8121", color: "#78c5f5ff", isPrimary: false),
//        PaymentMethod(id: "3", name: "국민은행", digits: "2812", color: "#65c466ff", isPrimary: false),
//        PaymentMethod(id: "4", name: "카카오뱅크", digits: "8751", color: "#ffcc00ff", isPrimary: false)
    ]
    )
    
    /*
    // public var cardOnFileString: ReadOnlyCurrentValuePublisher<[PaymentMethod]> { paymentMethodsSubject }
    public func addDiary(info: DiaryModel) throws -> Observable<DiaryModel> {
        print("addDiary!")
//        let requset = AddCardRequest(baseURL: baseURL, info: info)
//        return network.send(requset)
//            .map(\.output.card)
//            .handleEvents(receiveSubscription: nil,
//                          receiveOutput: { [weak self] method in
//                guard let this = self else {
//                    return
//                }
//                this.paymentMethodsSubject.send(this.paymentMethodsSubject.value + [method])
//            },
//                          receiveCompletion: nil,
//                          receiveCancel: nil,
//                          receiveRequest: nil)
//            .eraseToAnyPublisher()
//
        let diary = try self.diaryModelSubject.value()
        self.diaryModelSubject.onNext(diary)
        
        return Observable<DiaryModel>
    }
     */
    
    public func fetch() {
        print("fetch!")
    }
}
