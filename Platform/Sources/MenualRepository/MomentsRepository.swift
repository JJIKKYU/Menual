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
import MenualEntity

public protocol MomentsRepository {
    func fetch()
    func deleteMoments(uuid: String)
    func visitMoments(momentsItem: MomentsItemRealm)
    func clearOnboarding()
}

public final class MomentsRepositoryImp: MomentsRepository {

    // private var moments: MomentsRealm?
    private let disposeBag = DisposeBag()
    private var diaryArr: [DiaryModelRealm]? = nil
    
    public init() {
        guard let realm = Realm.safeInit() else { return }
        self.diaryArr = realm.objects(DiaryModelRealm.self)
            .toArray(type: DiaryModelRealm.self)
            .filter ({ $0.isDeleted == false })

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

        checkNeedOnboarding()
    }
    
    // 유저의 Moments 방문 유무 체크
    public func visitMoments(momentsItem: MomentsItemRealm) {
        guard let realm = Realm.safeInit() else { return }
        
        realm.safeWrite {
            momentsItem.userChecked = true
        }
    }
    
    public func deleteMoments(uuid: String) {
        print("MomentsRepo :: deletMoments!")

        guard let realm = Realm.safeInit(),
              let momentsRealm = realm.objects(MomentsRealm.self).first
        else { return }
        
        guard let willDeleteDiary = momentsRealm
            .itemsArr
            .filter ({ $0.diaryUUID == uuid })
            .first
        else { return }
        
        realm.safeWrite {
            realm.delete(willDeleteDiary)
        }
    }
    
    public func fetch() {
        print("MomentsRepo :: fetch!")
        guard let realm = Realm.safeInit(),
              let momentsRealm = realm.objects(MomentsRealm.self).first
        else { return }

        RefreshManager.shared.loadDataIfNeeded() { success in
            print("MomentsRepo :: \(success)")
            if success == false { return }
            
            print("MomentsRepo :: fetch! - 2")
            Observable.zip(
                setNumberDiaryMomentsItem(),
                setSpecialDayMomentsItem(),
                setlastYearDiaryMomentsItem(),
                setReadCountZeroMomentsItem(),
                setSpecificTimeMomentsItem(),
                setSeasonMomentsItem()
            )
            .subscribe(onNext: { [weak self] number, special, lastYear, readCount, specificTime, season in
                guard let self = self else { return }

                var items: [MomentsItemRealm] = []
                if let number = number {
                    items.append(number)
                }
                
                if let special = special {
                    items.append(contentsOf: special)
                }
                
                if let lastYear = lastYear {
                    items.append(contentsOf: lastYear)
                }
                
                if let readCount = readCount {
                    items.append(contentsOf: readCount)
                }
                
                if let specificTime = specificTime {
                    items.append(contentsOf: specificTime)
                }
                
                if let season = season {
                    items.append(contentsOf: season)
                }

                realm.safeWrite {
                    realm.delete(momentsRealm.items)
                    momentsRealm.items.append(objectsIn: items)
                    momentsRealm.lastUpdatedDate = Date()
                }
            })
            .disposed(by: disposeBag)
        }
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
        
        guard let diaryArr = diaryArr else { return .just(nil) }
        guard let realm = Realm.safeInit() else { return .just(nil) }
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
                                          icon: "120px/clip/bulldog",
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
                                                icon: "120px/calender/table",
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
    
    func checkAvailableDiaryContents(_ diaryDate: Date, targetDay: Int) -> Bool {
        let diffDay = Int(Date().timeIntervalSince(diaryDate) / 86400)
        print("MomentsRepo :: checkAvailableDiaryContents! = diffTime = \(diffDay)")
        // 작성한지 60일이 지았을 경우부터 추천
        return diffDay >= targetDay ? true : false
    }
    
    func getSpecificDayDiary(MMdd: String) -> [DiaryModelRealm]? {
        print("MomentsRepo :: getSpecificDayDiary!")
        // 1. 12.25 등 특정 날짜로 값이 들어옵니다.
        guard let diaryArr = diaryArr else { return nil }

        let momentsDiaryArr: [DiaryModelRealm] = diaryArr
            .filter({
                // 2. 일치하는 날짜가 없거나, 삭제된 경우제외
                print("MomentsRepo :: $0.createdAt.toStringWithMMdd() = \($0.createdAt.toStringWithMMdd())")
                if $0.createdAt.toStringWithMMdd() != MMdd || $0.isDeleted != false { return false }
                
                // 3-1. 이 모먼츠가 추천된 후 유저가 터치한 이력이 있는지 체크
                if let lastMomentsDate = $0.lastMomentsDate {
                    // 3-1-1. 터치한 이력이 있지만, 60일이 지나서 다시 한 번 추천이 가능한지 확인
                    let isAvailableContent: Bool = checkAvailableDiaryContents(lastMomentsDate, targetDay: 60)
                    print("MomentsRepo :: 추천된 후 유저가 터치한 이력이 있습니다., 경과된 시간 = \(isAvailableContent)")
                    if isAvailableContent == false { return false }
                }
                
                // 4. 30일이 지난 콘텐츠인지 확인
                // let isAvailableContent: Bool = checkAvailableDiaryContents($0.createdAt, targetDay: 30)
                
                return true
            })

        print("MomentsRepo :: getSpecificDayDiary = \(diaryArr)")
        return momentsDiaryArr
    }
    
    //MARK: - 작년 오늘 적은 메뉴얼
    func setlastYearDiaryMomentsItem() -> Observable<[MomentsItemRealm]?> {
        guard let diaryArr = diaryArr else { return .just(nil) }
        
        let momentsDiaryArr: [DiaryModelRealm] = diaryArr
            .filter ({
                let diffDay = Int(Date().timeIntervalSince($0.createdAt) / 86400)
                
                return diffDay == 365 ? true : false
            })

        var momentsItems: [MomentsItemRealm] = []
        for diary in momentsDiaryArr {
            let item = MomentsItemRealm(order: 0,
                                        title: "작년 오늘, 내가 보내는 메뉴얼\n365일 전에 적었어요",
                                        uuid: UUID().uuidString,
                                        icon: "120px/calender/wall",
                                        diaryUUID: diary.uuid,
                                        userChecked: false,
                                        createdAt: Date()
            )
            momentsItems.append(item)
        }
        
        return .just(momentsItems)
    }
    
    //MARK: - 한 번도 읽지 않은 메뉴얼
    var readCountZeroTitleData: [String] = [
        "아직 한번도 보지 않은 메뉴얼",
        "먼지가 빼곡히 쌓인 메뉴얼"
    ]
    func setReadCountZeroMomentsItem() -> Observable<[MomentsItemRealm]?> {
        guard let diaryArr = diaryArr else { return .just(nil) }
        guard let momentsDiary: DiaryModelRealm = diaryArr
            .filter ({
                // 1. 조회수가 0인지 체크
                let isReadCountZero: Bool = ($0.readCount == 0)
                
                // 2. 이 모먼츠가 추천된 후 유저가 터치한 이력이 있는지 체크
                if let lastMomentsDate = $0.lastMomentsDate {
                    // 터치한 이력이 있지만, 30일이 지나서 다시 한 번 추천이 가능한지 확인
                    let isAvailableContent: Bool = checkAvailableDiaryContents(lastMomentsDate, targetDay: 30)
                    print("MomentsRepo :: 추천된 후 유저가 터치한 이력이 있습니다., 경과된 시간 = \(isAvailableContent)")
                    if isAvailableContent == false { return false }
                }
                
                return isReadCountZero
            })
            .first
        else { return .just(nil) }

        let title: String = readCountZeroTitleData.randomElement() ?? ""
        let item = MomentsItemRealm(order: 0,
                                    title: title,
                                    uuid: UUID().uuidString,
                                    icon: "120px/book/close",
                                    diaryUUID: momentsDiary.uuid,
                                    userChecked: false,
                                    createdAt: Date()
        )
        
        return .just([item])
    }

    //MARK: - 새벽감석 터지는 메뉴얼
    var specificTimeTitleData: [String] = [
        "새벽 감성 터지는 메뉴얼",
        "나혼자 깨있는 밤에 적은 메뉴얼",
        "모두가 잠든 밤 적은 메뉴얼"
    ]
    func setSpecificTimeMomentsItem() -> Observable<[MomentsItemRealm]?> {
        guard let diaryArr = diaryArr else { return .just(nil) }

        guard let momentsDiary: DiaryModelRealm = diaryArr
            .filter ({
                // 1. 30일이 지나 유저에게 추천 가능한지 체크
                // let isAvailableContent: Bool = checkAvailableDiaryContents($0.createdAt, targetDay: 30)
                
                // 2. 실제로 새벽에 작성했는지  체크
                let hour = Calendar.current.component(.hour, from: $0.createdAt)
                let isSpecificHour = hour >= 0 && hour <= 4 ? true : false
                
                // 3. 이 모먼츠가 추천된 후 유저가 터치한 이력이 있는지 체크
                if let lastMomentsDate = $0.lastMomentsDate {
                    // 터치한 이력이 있지만, 30일이 지나서 다시 한 번 추천이 가능한지 확인
                    let isAvailableContent: Bool = checkAvailableDiaryContents(lastMomentsDate, targetDay: 30)
                    print("MomentsRepo :: 추천된 후 유저가 터치한 이력이 있습니다., 경과된 시간 = \(isAvailableContent)")
                    if isAvailableContent == false { return false }
                }
                
                return isSpecificHour
            })
            .first
        else { return .just(nil) }

        let title: String = specificTimeTitleData.randomElement() ?? ""
        let item = MomentsItemRealm(order: 0,
                                    title: title,
                                    uuid: UUID().uuidString,
                                    icon: "120px/lamp/round",
                                    diaryUUID: momentsDiary.uuid,
                                    userChecked: false,
                                    createdAt: Date()
        )
        
        return .just([item])
    }
    
    //MARK: - 계절
//    var seasonDiaryData: [String] = [
//        "%@에 작성한 메뉴얼",
//    ]
    func getSeason(_ month: Int) -> Season {
        if month >= 3 && month <= 5 {
            return .spring
        } else if month >= 6 && month <= 8 {
            return .summer
        } else if month >= 9 && month <= 11 {
            return .autumn
        } else {
            return .winter
        }
    }
    
    func setSeasonMomentsItem() -> Observable<[MomentsItemRealm]?> {
        guard let diaryArr = diaryArr else { return .just(nil) }

        var seasonTitle: String = ""
        guard let momentsDiary: DiaryModelRealm = diaryArr
            .filter ({
                // 1. 이 모먼츠가 추천된 후 유저가 터치한 이력이 있는지 체크
                if let lastMomentsDate = $0.lastMomentsDate {
                    // 터치한 이력이 있지만, 30일이 지나서 다시 한 번 추천이 가능한지 확인
                    let isAvailableContent: Bool = checkAvailableDiaryContents(lastMomentsDate, targetDay: 30)
                    print("MomentsRepo :: 추천된 후 유저가 터치한 이력이 있습니다., 경과된 시간 = \(isAvailableContent)")
                    if isAvailableContent == false { return false }
                }

                let currentMonth = Calendar.current.component(.month, from: Date())
                let season: Season = getSeason(currentMonth)
                var isAvailableContent: Bool = false
                let month = Calendar.current.component(.month, from: $0.createdAt)

                // 2분기 전 메뉴얼부터 추천 가능
                switch season {
                // 봄이면 가을
                case .spring:
                    isAvailableContent = getSeason(month) == .autumn
                    seasonTitle = "가을"
                // 여름이면 겨울
                case .summer:
                    isAvailableContent = getSeason(month) == .winter
                    seasonTitle = "겨울"
                // 가을이면 봄
                case .autumn:
                    isAvailableContent = getSeason(month) == .spring
                    seasonTitle = "봄"
                // 겨울이면 여름
                case .winter:
                    isAvailableContent = getSeason(month) == .summer
                    seasonTitle = "여름"
                }
                
                return isAvailableContent
            })
            .first
        else { return .just(nil) }

        
        let item = MomentsItemRealm(order: 0,
                                    title: String(format: "%@에 작성한 메뉴얼", seasonTitle),
                                    uuid: UUID().uuidString,
                                    icon: "120px/tea",
                                    diaryUUID: momentsDiary.uuid,
                                    userChecked: false,
                                    createdAt: Date()
        )

        return .just([item])
    }
}

// MARK: - onboarding
extension MomentsRepositoryImp {
    /// 유저가 온보딩을 완료했을때
    public func clearOnboarding() {
        print("MomentsRepo :: clearOnboarding!")
        guard let realm = Realm.safeInit() else { return }
        guard let momentsRealm = realm.objects(MomentsRealm.self).first else { return }
        
        // 백업, 복원 등으로 이미 값이 들어와 있는 상태라면 예외처리
        if momentsRealm.onboardingClearDate != nil { return }
        
        realm.safeWrite {
            momentsRealm.onboardingClearDate = Date()
        }
    }
    
    /// 유저에게 Onboarding을 제공해도 되는지 체크
    public func checkNeedOnboarding() {
        guard let realm = Realm.safeInit() else { return }
        guard let momentsRealm = realm.objects(MomentsRealm.self).first else { return }

        // 다이어리를 작성한게 14개가 넘었을 경우에는 clear 상태로 변환
        // 기능이 후에 업데이트 되었으므로, 기존 유저에게 잘못 보이는 현상 수정
        let diaryModelRealmArr = realm.objects(DiaryModelRealm.self)
        if diaryModelRealmArr.count > 14 {
            realm.safeWrite {
                momentsRealm.onboardingIsClear = true
            }
        }

        guard let _ = momentsRealm.onboardingClearDate else { return }
        
        // 클리어한지 하루가 지났다면 표시하지 않아도 되므로 리턴
        RefreshManager.shared.onboardingLoadDataIfNeeded(completion: { success in
            print("MomentsRepo :: success = \(success)")
            if success == true { return }
        })
        
        // 클리어한지 하루가 되지 않았다면 지속 표시
    }
}

// MARK: - MomentsRefrshManager
class RefreshManager: NSObject {

    static let shared = RefreshManager()
    private let calender = Calendar.current

    func loadDataIfNeeded(completion: (Bool) -> Void) {
        guard let realm = Realm.safeInit(),
              let momentsRealm = realm.objects(MomentsRealm.self).first
        else {
            completion(false)
            return
        }
        
        if isRefreshRequired() {
            // load the data
            // defaults.set(Date(), forKey: defaultsKey)
            realm.safeWrite {
                momentsRealm.lastUpdatedDate = Date()
            }
            completion(true)
        } else {
            completion(false)
        }
    }

    /// Moments Refresh가 필요한지 체크
    private func isRefreshRequired() -> Bool {
        guard let realm = Realm.safeInit(),
              let momentsRealm = realm.objects(MomentsRealm.self).first
        else { return false }
        
        // onboarding을 완료하지 않았을 경우 moments를 제공하지 않음
        if momentsRealm.onboardingIsClear == false {
            print("MomentsRepo :: onboaridng을 완료하지 않았으므로 moments를 제공하지 않습니다.")
            // 중간 업데이트로 이미 모먼츠가 노출되고 있던 14개 이하 작성자들 Moments 삭제
            realm.safeWrite {
                realm.delete(momentsRealm.items)
            }
            return false
        }
        
        // 테스트 모드일때는 항상 리프레쉬 되도록
        let isTestMode: Bool = UserDefaults.standard.bool(forKey: "test")
        if isTestMode {
            return true
        }
        
        let lastUpdateDate = momentsRealm.lastUpdatedDate
        let updateTime = 0
        
        let diff = calender.dateComponents([.hour], from: lastUpdateDate, to: Date()).hour
        let currentHour =  calender.dateComponents([.hour], from: Date()).hour
        
        print("MomentsRepo :: isRefreshRequired -> diff = \(diff), \(currentHour)")
        
        
        if let diff = calender.dateComponents([.hour], from: lastUpdateDate, to: Date()).hour,
            let currentHour =  calender.dateComponents([.hour], from: Date()).hour,
            diff >= 24, updateTime <= currentHour {
            return true
        } else {
            return false
        }
    }
    
    func onboardingLoadDataIfNeeded(completion: (Bool) -> Void) {
        guard let realm = Realm.safeInit(),
              let momentsRealm = realm.objects(MomentsRealm.self).first
        else {
            completion(false)
            return
        }

        if onboardingIsRefreshRequired() {
            print("MomentsRepo :: onboardingIsRefreshRequired!!!")
            // load the data
            // defaults.set(Date(), forKey: defaultsKey)
            realm.safeWrite {
                momentsRealm.onboardingIsClear = true
            }
            completion(true)
        } else {
            completion(false)
        }
    }
    
    private func onboardingIsRefreshRequired() -> Bool {
        guard let realm = Realm.safeInit(),
              let momentsRealm = realm.objects(MomentsRealm.self).first
        else { return false }
        
        // 테스트 모드일때는 하루 차이 없이 바로 나타나도록
        let isTestMode: Bool = UserDefaults.standard.bool(forKey: "test")
        if isTestMode {
            return true
        }
        
        guard let lastUpdateDate = momentsRealm.onboardingClearDate else { return false }
        let updateTime = 0
        
        let diff = calender.dateComponents([.hour], from: lastUpdateDate, to: Date()).hour
        let currentHour =  calender.dateComponents([.hour], from: Date()).hour
        
        print("MomentsRepo :: onboardingIsRefreshRequired -> diff = \(diff), \(currentHour)")
        
        if let diff = calender.dateComponents([.hour], from: lastUpdateDate, to: Date()).hour,
            let currentHour =  calender.dateComponents([.hour], from: Date()).hour,
            diff >= 24, updateTime <= currentHour {
            return true
        } else {
            return false
        }
    }
}
