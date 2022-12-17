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
    func visitMoments(momentsItem: MomentsItemRealm)
}

public final class MomentsRepositoryImp: MomentsRepository {
    // private var moments: MomentsRealm?
    private let disposeBag = DisposeBag()
    
    init() {
        guard let realm = Realm.safeInit() else { return }

        // moments를 한 번도 세팅하지 않은 경우
        let momentsRealm = realm.objects(MomentsRealm.self).first
        if momentsRealm == nil {
            let momentsRealm = MomentsRealm(lastUpdatedDate: Date(), items: [])
            print("MomentsRepo :: momentsRealm을 한 번도 세팅하지 않았습니다.")
            realm.safeWrite {
                realm.add(momentsRealm)
            }
        } else {
            print("MomentsRepo :: momentsRealm이 세팅되어 있습니다.")
        }
    }
    
    // 유저의 Moments 방문 유무 체크
    public func visitMoments(momentsItem: MomentsItemRealm) {
        guard let realm = Realm.safeInit() else { return }
        
        realm.safeWrite {
            momentsItem.userChecked = true
        }
    }
    
    public func fetch() {
        print("MomentsRepo :: fetch!")
        guard let realm = Realm.safeInit(),
              let momentsRealm = realm.objects(MomentsRealm.self).first
        else { return }

        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"

        let lastUpdateDate = momentsRealm.lastUpdatedDate.toStringWithHourMin()
        guard let updateDate = Calendar.current.date(bySettingHour: 03, minute: 00, second: 0, of: Date())?.toStringWithHourMin(),
              let startTime = format.date(from: updateDate),
              let endTime = format.date(from: lastUpdateDate)
        else { return }

        var diffTime = Int(endTime.timeIntervalSince(startTime) / 3600)
        var diffTime2 = Int(startTime.timeIntervalSince(Date()) / 3600)
        
        // 업데이트 시간 차이가 24시간 이상이면 업데이트 진행
        print("MomentsRepo :: diffTime = \(diffTime), diffTime2 = \(diffTime2)")
        if diffTime2 > 24 { return }

        
        print("MomentsRepo :: fetch! - 2")
        Observable.zip(
            setNumberDiaryMomentsItem(),
            setSpecialDayMomentsItem()
        )
//        setNumberDiaryMomentsItem()
//            .compactMap { $0 }
        .subscribe(onNext: { [weak self] numberDiary, specialDiary in
            guard let self = self else { return }

            print("MomentsRepo :: numberDiary = \(numberDiary), = \(specialDiary)")
            var items: [MomentsItemRealm] = []
            if let numberDiary = numberDiary {
                items.append(numberDiary)
            }
            
            if let specialDiary = specialDiary {
                items.append(specialDiary)
            }
            realm.safeWrite {
                realm.delete(momentsRealm.items)
                momentsRealm.items.append(objectsIn: items)
            }
        })
        .disposed(by: disposeBag)
    }

    // 내가 적은 N번째 메뉴얼
    func setNumberDiaryMomentsItem() -> Observable<MomentsItemRealm?> {
        print("MomentsRepo :: 내가 적은 N번쨰 메뉴얼!")
        // 테스트용
//        return .just(MomentsItemRealm(order: 0,
//                                      title: "내가 N번째로 적은 메뉴얼",
//                                      uuid: UUID().uuidString,
//                                      diaryUUID: "TESTUUID",
//                                      userChecked: false,
//                                      createdAt: Date())
//        )
        
        guard let realm = Realm.safeInit() else { return .just(nil) }
        let diaryArr = realm.objects(DiaryModelRealm.self).toArray()
        var findDiary: DiaryModelRealm?
        var title: String = ""
        var diaryUUID: String = ""
        if diaryArr.count >= 109 {
            print("MomentsRepo :: 내가 적은 N번쨰 메뉴얼! - 109")
            guard let diary = diaryArr.filter ({ $0.pageNum == 100 && $0.lastMomentsDate == nil }).first else { return .just(nil) }
            title = "내가 100번째로 적은 메뉴얼"
            diaryUUID = diary.uuid
            findDiary = diary
        } else if diaryArr.count >= 59 {
            print("MomentsRepo :: 내가 적은 N번쨰 메뉴얼! - 59")
            guard let diary = diaryArr.filter ({ $0.pageNum == 50 && $0.lastMomentsDate == nil }).first else { return .just(nil) }
            title = "내가 50번째로 적은 메뉴얼"
            diaryUUID = diary.uuid
            findDiary = diary
        } else if diaryArr.count >= 19 {
            print("MomentsRepo :: 내가 적은 N번쨰 메뉴얼! - 19")
            guard let diary = diaryArr.filter ({ $0.pageNum == 10 && $0.lastMomentsDate == nil }).first else { return .just(nil) }
            title = "내가 10번째로 적은 메뉴얼"
            diaryUUID = diary.uuid
            findDiary = diary
        } else if diaryArr.count >= 1 {
            print("MomentsRepo :: 내가 적은 N번쨰 메뉴얼! - 1")
            guard let diary = diaryArr.filter ({ $0.pageNum == 1 && $0.lastMomentsDate == nil }).first else { return .just(nil) }
            title = "내가 첫 번째로 적은 메뉴얼"
            diaryUUID = diary.uuid
            findDiary = diary
        }

        print("MomentsRepo :: diaryUUID = \(diaryUUID), title = \(title)")
        // 찾은 메뉴얼이 있을 경우에는 lastMomentsDate에, 추천된 이력이 있음을 체크
        if let findDiary = findDiary {
            realm.safeWrite {
                findDiary.lastMomentsDate = Date()
            }
        }

        if findDiary == nil {
            print("MomentsRepo :: findDiary == nil")
            return .just(nil)
        } else {
            print("MomentsRepo :: findDiary != nil")
            return .just(MomentsItemRealm(order: 0,
                                          title: title,
                                          uuid: UUID().uuidString,
                                          diaryUUID: diaryUUID,
                                          userChecked: false,
                                          createdAt: Date())
            )
        }
    }
    
    // 특정 년도, 특정 날짜에 작성한 메뉴얼
    func setSpecialDayMomentsItem() -> Observable<MomentsItemRealm?> {
//        return .just(MomentsItemRealm(order: 0,
//                                      title: "내가 크리스마스에 적은 메뉴얼",
//                                      uuid: UUID().uuidString,
//                                      diaryUUID: "TESTUUID",
//                                      userChecked: false,
//                                      createdAt: Date())
//        )

        guard let realm = Realm.safeInit() else { return .just(nil) }
        let diaryArr = realm.objects(DiaryModelRealm.self).toArray()
        
        let lastDayDiaryArr = diaryArr.filter ({ $0.createdAt.toStringWithMMdd() == "12.31" })
        
        let christmasDiaryArr = diaryArr.filter ({ $0.createdAt.toStringWithMMdd() == "12.25" })
        
        return .just(nil)
    }
}
