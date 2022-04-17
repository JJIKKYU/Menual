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
    
    var diaryString: BehaviorRelay<[DiaryModel]> { get }
    var realmDiaryOb: Observable<[DiaryModel]> { get }
    // func addDiary(info: DiaryModel) throws -> Observable<DiaryModel>
    func fetch()
    func addDiary(info: DiaryModel)
    
}

public final class DiaryRepositoryImp: DiaryRepository {
    

    public var realmDiaryOb: Observable<[DiaryModel]> {
        let realm = try! Realm()

        let result = realm.objects(DiaryModelRealm.self)
        let ob = Observable.array(from: result)
            .map { diaryArr -> [DiaryModel] in
                var arr: [DiaryModel] = []
                for diary in diaryArr {
                    let diaryModel = DiaryModel(title: diary.title,
                                                weather: diary.weather,
                                                location: diary.location,
                                                description: diary.desc,
                                                image: diary.image
                    )
                    arr.append(diaryModel)
                }
                return arr
            }
        return ob
    }

    public var diaryString: BehaviorRelay<[DiaryModel]> { diaryModelSubject }
    public let diaryModelSubject = BehaviorRelay<[DiaryModel]>(value: [])
    
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
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let result = realm.objects(DiaryModelRealm.self)
        print("result = \(result)")
        
        diaryModelSubject.accept(result.map { DiaryModel($0) })

    }
    
    public func addDiary(info: DiaryModel) {
        // 1. 추가할 Diary를 info로 받는다
        // 2. Realm에다가 새로운 Diary를 add 한다.
        // 3. add한 diary를 담고 있는 Realm의 Observable를 반환한다.
        
        print("addDiary!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        realm.safeWrite {
            realm.add(DiaryModelRealm(info))
        }
        
        diaryModelSubject.accept(diaryModelSubject.value + [info])
    }
}
