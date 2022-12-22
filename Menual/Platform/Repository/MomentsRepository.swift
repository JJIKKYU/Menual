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
              let updateTime = format.date(from: updateDate),
              let lastUpdateTime = format.date(from: lastUpdateDate)
        else { return }

        // var diffTime = Int(endTime.timeIntervalSince(startTime) / 3600)
        // var diffTime2 = Int(startTime.timeIntervalSince(Date()) / 3600)
        // let diffTime3 = Int(Date().timeIntervalSince(endTime) / 3600)
        
        // 새벽 3시 기준 얼마나 차이가 날까
        let lastUpdateDiffTime = Int(updateTime.timeIntervalSince(lastUpdateTime) / 3600)
        print("MomentsRepo :: updateTime = \(updateTime), lastUpdateTime = \(lastUpdateTime), lastUpdateDiffTime = \(lastUpdateDiffTime)")
        if lastUpdateDiffTime < 24 {
            print("MomentsRepo :: 업데이트 한지 새벽 3시 기준 24시간이 지나지 않아 업데이트 할 필요가 없습니다.")
            // return
        }
        
        // 지금 새벽 3시가 넘었을까?
        let currentTimeDiff = Int(Date().timeIntervalSince(updateTime) / 3600)
        print("MomentsRepo :: currentTimeDiff = \(currentTimeDiff)")
        if currentTimeDiff < 24 {
            print("MomentsRepo :: 새벽 3시가 지나지 않아서 업데이트 할 필요가 없습니다.")
        }

        
        // 이전 업데이트가 오늘 새벽 3시 기준 전 날일 경우,
        // 현재 시간이 새벽 3시 이후일 경우
        
        // 업데이트 시간 차이가 24시간 이상이면 업데이트 진행
        // print("MomentsRepo :: diffTime = \(diffTime), diffTime2 = \(diffTime2)")
        // if diffTime2 > 24 { return }

        
        print("MomentsRepo :: fetch! - 2")
        Observable.zip(
            setNumberDiaryMomentsItem(),
            setSpecialDayMomentsItem()
        )
//        setNumberDiaryMomentsItem()
//            .compactMap { $0 }
        .subscribe(onNext: { [weak self] numberDiary, specialDiaryArr in
            guard let self = self else { return }

            print("MomentsRepo :: numberDiary = \(numberDiary), = \(specialDiaryArr)")
            var items: [MomentsItemRealm] = []
            if let numberDiary = numberDiary {
                items.append(numberDiary)
            }
            
            if let specialDiaryArr = specialDiaryArr {
                items.append(contentsOf: specialDiaryArr)
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
    
    // MARK: - 특정 년도, 특정 날짜에 작성한 메뉴얼
    var specificDayMomentsData: [SpecificDayMomentsModel] = [
        .init(monthDay: "12.31", title: ["%@년의 마지막 날 적었어요.",
                                         "%@년 전 마지막 날 적었어요."]),
        .init(monthDay: "12.25", title: ["%@년 크리스마스에는 산타할아버지가 오셨을까요?",
                                         "%@년 전 크리스마스를 기억해볼까요?",
                                         "%@년 전 크리스마스는 화이트 크리스마스였을까요?"])
    ]

    // 특정 년도, 특정 날짜에 작성한 메뉴얼
    func setSpecialDayMomentsItem() -> Observable<[MomentsItemRealm]?> {
        var momentsItems: [MomentsItemRealm] = []
        let currentYear = Int(Date().toStringWithYYYY()) ?? 0

        for data in specificDayMomentsData {
            if let diaryArr = getSpecificDayDiary(MMdd: data.monthDay) {
                for diary in diaryArr {
                    let year = Int(diary.createdAt.toStringWithYYYY()) ?? 0
                    var argument: String = ""
                    var title: String = ""
                    
                    // 1년 전일 경우에는, '작년'으로 나타날 수 있도록 사용
                    if currentYear - year == 1 {
                        argument = "작"
                        title = data.title[0]
                    } else {
                        let random = (1..<data.title.count).randomElement() ?? 1
                        guard let randomTitle = data.title[safe: random] else { return .just(nil)}
                        argument = String(currentYear - year)
                        title = randomTitle
                    }

                    let item = MomentsItemRealm(order: 0,
                                                title: String(format: title, arguments: [argument]),
                                                uuid: UUID().uuidString,
                                                diaryUUID: diary.uuid,
                                                userChecked: false,
                                                createdAt: Date()
                    )
                    
                    momentsItems.append(item)
                }
            }
        }
        print("MomentsRepo :: momentsItem = \(momentsItems)")
        
        return .just(momentsItems)
    }
    
    func checkAvailableDiaryContents(_ diaryDate: Date) -> Bool {
        let diffDay = Int(Date().timeIntervalSince(diaryDate) / 86400)
        print("MomentsRepo :: checkAvailableDiaryContents! = diffTime = \(diffDay)")
        // 작성한지 60일이 지았을 경우부터 추천
        return diffDay >= 60 ? true : false
    }
    
    func getSpecificDayDiary(MMdd: String) -> [DiaryModelRealm]? {
        print("MomentsRepo :: getSpecificDayDiary!")
        // 1. 12.25 등 특정 날짜로 값이 들어옵니다.
        guard let realm = Realm.safeInit() else { return nil }
        let diaryArr: [DiaryModelRealm] = realm.objects(DiaryModelRealm.self)
            .toArray()
            .filter({
                // 2. 일치하는 날짜가 없거나, 삭제된 경우제외
                print("MomentsRepo :: $0.createdAt.toStringWithMMdd() = \($0.createdAt.toStringWithMMdd())")
                if $0.createdAt.toStringWithMMdd() != MMdd || $0.isDeleted != false { return false }
                
                // 3. 이 모먼츠가 추천된 후 유저가 터치한 이력이 있는지 체크
                if let lastMomentsDate = $0.lastMomentsDate {
                    // 3-1. 터치한 이력이 있지만, 60일이 지나서 다시 한 번 추천이 가능한지 확인
                    let isAvailableContent: Bool = checkAvailableDiaryContents(lastMomentsDate)
                    print("MomentsRepo :: 추천된 후 유저가 터치한 이력이 있습니다., 경과된 시간 = \(isAvailableContent)")
                    if isAvailableContent == false { return false }
                }

                // 4. 30일이 지난 콘텐츠인지 확인
                let isAvailableContent: Bool = checkAvailableDiaryContents($0.createdAt)
                
                // 5. Moments로 추천된 이력이 있는지 체크
                return isAvailableContent
            })

        print("MomentsRepo :: getSpecificDayDiary = \(diaryArr)")
        return diaryArr
    }
}
