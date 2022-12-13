//
//  MomentsRepository.swift
//  Menual
//
//  Created by 정진균 on 2022/12/03.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift
import RxRealm

public protocol MomentsRepository {
    func fetch()
}

public final class MomentsRepositoryImp: MomentsRepository {
    // private var moments: MomentsRealm?
    private let disposeBag = DisposeBag()
    
//    init() {
//        guard let realm = Realm.safeInit(),
//              let moments = realm.objects(MomentsRealm.self).first
//        else { return }
//        self.moments = moments
//    }
    
    public func fetch() {
        print("MomentsRepo :: fetch!")
        // guard let realm = Realm.safeInit() else { return }
//        
//        // moments를 한 번도 세팅하지 않은 경우
//        if momentRealm == nil {
//            realm.safeWrite {
//                
//            }
//        }
        
        // guard let momentsRealm = realm.objects(MomentsRealm.self).first as? MomentsRealm else { return }
        let updateDate = Calendar.current.date(bySettingHour: 03, minute: 00, second: 0, of: Date())
        print("MomentsRepo :: updateDate = \(updateDate), now = \(Date())")
        /*
        let
        let offsetComps = Calendar.current.dateComponents([.year,.month,.day], from: startDate, to: Date())
       
       if case let (y?, m?, d?) = (offsetComps.year, offsetComps.month, offsetComps.day) {
         print("\(y)년 \(m)월 \(d)일 만큼 차이남")
       }
        */
        
        Observable.combineLatest(
            setNumberDiaryMomentsItem().compactMap { $0 },
            setSpecialDayMomentsItem().compactMap { $0 }
        )
        .subscribe(onNext: { [weak self] numberDiary, specialDiary in
            guard let self = self else { return }
            
            print("MomentsRepo :: numberDiary = \(numberDiary), specialDiary = \(specialDiary)")
        })
        .disposed(by: disposeBag)
    }

    // 내가 적은 N번째 메뉴얼
    func setNumberDiaryMomentsItem() -> Observable<MomentsItemRealm?> {
        // 테스트용
        return .just(MomentsItemRealm(order: 0,
                                      title: "내가 N번째로 적은 메뉴얼",
                                      uuid: UUID().uuidString,
                                      diaryUUID: "TESTUUID",
                                      userChecked: false,
                                      createdAt: Date())
        )
        
        guard let realm = Realm.safeInit() else { return .just(nil) }
        let diaryArr = realm.objects(DiaryModelRealm.self).toArray()
        for (index, diary) in diaryArr.enumerated() {
            if (index + 9) % 10 == 9 {
                // 이미 모먼츠로 추천된 이력이 있으면 넘기기 (일회성이므로)
                if diary.lastMomentsDate != nil { continue }
                // N번째 적은 메뉴얼은 한 번 나타나고 그 다음부터 나타나지 않으므로 바로 리턴
                return .just(MomentsItemRealm(order: 0,
                                              title: "내가 \(index)번째로 적은 메뉴얼",
                                              uuid: UUID().uuidString,
                                              diaryUUID: diary.uuid,
                                              userChecked: false,
                                              createdAt: Date())
                )
            }
        }
        
        return .just(nil)
    }
    
    // 특정 년도, 특정 날짜에 작성한 메뉴얼
    func setSpecialDayMomentsItem() -> Observable<MomentsItemRealm?> {
        return .just(MomentsItemRealm(order: 0,
                                      title: "내가 크리스마스에 적은 메뉴얼",
                                      uuid: UUID().uuidString,
                                      diaryUUID: "TESTUUID",
                                      userChecked: false,
                                      createdAt: Date())
        )

        guard let realm = Realm.safeInit() else { return .just(nil) }
        let diaryArr = realm.objects(DiaryModelRealm.self).toArray()
        
        let lastDayDiaryArr = diaryArr.filter ({ $0.createdAt.toStringWithMMdd() == "12.31" })
        
        let christmasDiaryArr = diaryArr.filter ({ $0.createdAt.toStringWithMMdd() == "12.25" })
        
        return .just(nil)
    }
}
