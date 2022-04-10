//
//  DiaryRepository.swift
//  Menual
//
//  Created by 정진균 on 2022/04/09.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift
import RxRealm

public protocol DiaryRepository {
    // func addCard(info: AddPaymentMethodInfo) -> AnyPublisher<PaymentMethod, Error>
    // ReadOnlyCurrentValuePublisher<[PaymentMethod]> { get }
    
    var diaryString: Observable<[DiaryModel]> { get }
    var myMenualCount: Int { get }
    // func addDiary(info: DiaryModel) throws -> Observable<DiaryModel>
    func fetch()
    func addDiary(info: DiaryModel)
    
}

public final class DiaryRepositoryImp: DiaryRepository {
    public var diaryString: Observable<[DiaryModel]> { diaryModelSubject }
    
    public var myMenualCount: Int = 0
    public let diaryModelSubject = BehaviorSubject<[DiaryModel]>(value: [
        DiaryModel(title: "타이틀마", weather: "웨덜마", location: "로케이션마", description: "디스크립션마", image: "이미징마")
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
        let realm = try! Realm()
        let result = realm.objects(DiaryModelRealm.self)
        
        diaryModelSubject.onNext(result.map { DiaryModel($0) })
        myMenualCount = result.count
        
        print("DiaryRepository :: fetch! \(myMenualCount)")
    }
    
    public func addDiary(info: DiaryModel) {
        // 1. 추가할 Diary를 info로 받는다
        // 2. Realm에다가 새로운 Diary를 add 한다.
        // 3. add한 diary를 담고 있는 Realm의 Observable를 반환한다.
        
        print("addDiary!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(DiaryModelRealm(info))
        }
        
        let result = realm.objects(DiaryModelRealm.self)
        
        diaryModelSubject.onNext(result.map { DiaryModel($0) })
        myMenualCount = result.count
    }
}
