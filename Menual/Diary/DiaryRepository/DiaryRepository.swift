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
    var weatherHistory: BehaviorRelay<[WeatherHistoryModel]> { get }
    var placeHistory: BehaviorRelay<[PlaceHistoryModel]> { get }
    var diaryMonthDic: BehaviorRelay<[DiaryYearModel]> { get }
    var diarySearch: BehaviorRelay<[DiarySearchModel]> { get }
    
//    var realmDiaryOb: Observable<[DiaryModel]> { get }
    // func addDiary(info: DiaryModel) throws -> Observable<DiaryModel>
    func fetch()
    func addDiary(info: DiaryModel)
    func updateDiary(info: DiaryModel)
    func addWeatherHistory(info: WeatherHistoryModel)
    func addPlaceHistory(info: PlaceHistoryModel)
    func deleteDiary(info: DiaryModel)
    func saveImageToDocumentDirectory(imageName: String, image: UIImage)
    func loadImageFromDocumentDirectory(imageName: String) -> UIImage?
    
    // 겹쓰기 로직
    func addReplay(info: DiaryReplyModel)
    
    // 최근검색목록 로직
    func addDiarySearch(info: DiaryModel)
}

public final class DiaryRepositoryImp: DiaryRepository {

//    public var realmDiaryOb: Observable<[DiaryModel]> {
//        let realm = try! Realm()
//
//        let result = realm.objects(DiaryModelRealm.self)
//        let ob = Observable.array(from: result)
//            .map { diaryArr -> [DiaryModel] in
//                var arr: [DiaryModel] = []
//                for diary in diaryArr {
//                    let diaryModel = DiaryModel(uuid: diary.uuid,
//                                                title: diary.title,
//                                                weather: diary.weather ?? .none,
//                                                location: diary.location,
//                                                description: diary.desc,
//                                                image: diary.image,
//                                                readCount: diary.readCount
//                    )
//                    arr.append(diaryModel)
//                }
//                return arr
//            }
//        return ob
//    }

    public var diaryString: BehaviorRelay<[DiaryModel]> { diaryModelSubject }
    public let diaryModelSubject = BehaviorRelay<[DiaryModel]>(value: [])
    
    public var diaryMonthDic: BehaviorRelay<[DiaryYearModel]> { diaryMonthDicSubject }
    public let diaryMonthDicSubject = BehaviorRelay<[DiaryYearModel]>(value: [])
    
    public var weatherHistory: BehaviorRelay<[WeatherHistoryModel]> { weatherHistorySubject }
    public let weatherHistorySubject = BehaviorRelay<[WeatherHistoryModel]>(value: [])
    
    public var placeHistory: BehaviorRelay<[PlaceHistoryModel]> { placeHistorySubject }
    public let placeHistorySubject = BehaviorRelay<[PlaceHistoryModel]>(value: [])
    
    public var diarySearch: BehaviorRelay<[DiarySearchModel]> { diarySearchSubject }
    public let diarySearchSubject = BehaviorRelay<[DiarySearchModel]>(value: [])
    
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
    
    public func saveImageToDocumentDirectory(imageName: String, image: UIImage) {
        // 1. 이미지를 저장할 경로를 설정해줘야함 - 도큐먼트 폴더,File 관련된건 Filemanager가 관리함(싱글톤 패턴)
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        print("!!")
        
        // 2. 이미지 파일 이름 & 최종 경로 설정
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        
        // 3. 이미지 압축(image.pngData())
        // 압축할거면 jpegData로~(0~1 사이 값)
        guard let data = image.pngData() else {
            print("압축이 실패했습니다.")
            return
        }
        
        // 4. 이미지 저장: 동일한 경로에 이미지를 저장하게 될 경우, 덮어쓰기하는 경우
        // 4-1. 이미지 경로 여부 확인
        if FileManager.default.fileExists(atPath: imageURL.path) {
            // 4-2. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("이미지 삭제 완료")
            } catch {
                print("이미지를 삭제하지 못했습니다.")
            }
        }
        
        // 5. 이미지를 도큐먼트에 저장
        // 파일을 저장하는 등의 행위는 조심스러워야하기 때문에 do try catch 문을 사용하는 편임
        do {
            try data.write(to: imageURL)
            print("이미지 저장완료")
        } catch {
            print("이미지를 저장하지 못했습니다.")
        }
    }
    
    public func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
            
        // 1. 도큐먼트 폴더 경로가져오기
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
        // 2. 이미지 URL 찾기
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            // 3. UIImage로 불러오기
            return UIImage(contentsOfFile: imageURL.path)
        }
        
        return nil
    }
    
    public func fetch() {
        print("DiaryRepository :: fetch")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let diaryModelResults = realm.objects(DiaryModelRealm.self).sorted(byKeyPath: "createdAt", ascending: false)
        diaryModelSubject.accept(diaryModelResults.map { DiaryModel($0) })
        
        let weatherHistoryResults = realm.objects(WeatherHistoryModelRealm.self)
        weatherHistorySubject.accept(weatherHistoryResults.map { WeatherHistoryModel($0) })
        
        let placeHistoryResults = realm.objects(PlaceHistoryModelRealm.self)
        placeHistorySubject.accept(placeHistoryResults.map { PlaceHistoryModel($0) })
        
        self.fetchMonthDictionary()
        self.fetchDiarySearch()
    }
    
    // MARK: - Diary CRUD
    public func addDiary(info: DiaryModel) {
        // 1. 추가할 Diary를 info로 받는다
        // 2. Realm에다가 새로운 Diary를 add 한다.
        // 3. add한 diary를 담고 있는 Realm의 Observable를 반환한다.
        
        print("addDiary!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let diariesCount = realm.objects(DiaryModelRealm.self).sorted(byKeyPath: "createdAt", ascending: false).first?.pageNum ?? 0
        
        print("diariesCount = \(diariesCount + 1)")
        
        print("addDiary! - 2")
        
        var newInfo = info
        newInfo.updatePageNum(pageNum: diariesCount)
        print("newInfo's pageNum = \(newInfo.pageNum)")
        
        
        realm.safeWrite {
             realm.add(DiaryModelRealm(newInfo))
            // realm.create(DiaryModelRealm.self, value: DiaryModelRealm(info))
        }
        
        let result: [DiaryModel] = (diaryModelSubject.value + [newInfo]).sorted { $0.createdAt > $1.createdAt }
        
        diaryModelSubject.accept(result)
        self.fetchMonthDictionary()
        print("addDiary! - 3")
    }
    
    public func updateDiary(info: DiaryModel) {
        print("update Diary!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(DiaryModelRealm.self).filter({ $0.uuid == info.uuid }).first
        else { return }
        
        realm.safeWrite {
            data.readCount = info.readCount
            data.weather = WeatherModelRealm(info.weather ?? WeatherModel(uuid: "", weather: nil, detailText: ""))
            data.place = PlaceModelRealm(info.place ?? PlaceModel(uuid: "", place: nil, detailText: ""))
        }
        
        var idx: Int = 0
        for (index, value) in diaryModelSubject.value.enumerated() {
            if value.uuid == info.uuid {
                idx = index
            }
        }

        var arr = diaryModelSubject.value
        arr[idx] = DiaryModel(uuid: info.uuid,
                              pageNum: info.pageNum,
                              title: info.title,
                              weather: info.weather,
                              place: info.place,
                              description: info.description,
                              image: info.image,
                              readCount: info.readCount,
                              createdAt: info.createdAt,
                              replies: info.replies,
                              isDeleted: info.isDeleted,
                              isHide: info.isHide
        )

        diaryModelSubject.accept(arr)
    }
    
    public func deleteDiary(info: DiaryModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(DiaryModelRealm.self).filter({ $0.uuid == info.uuid }).first
        else { return }
        
        realm.safeWrite {
            realm.delete(data)
        }
        
        var idx: Int = 0
        for (index, value) in diaryModelSubject.value.enumerated() {
            if value.uuid == info.uuid {
                idx = index
            }
        }

        var arr = diaryModelSubject.value
        arr.remove(at: idx)

        diaryModelSubject.accept(arr)
    }
    
    // MARK: - History CRUD
    public func addWeatherHistory(info: WeatherHistoryModel) {
        print("DiaryRepository :: addWeatherHistory")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        realm.safeWrite {
             realm.add(WeatherHistoryModelRealm(info))
        }
        
        weatherHistorySubject.accept(weatherHistorySubject.value + [info])
    }
    
    public func addPlaceHistory(info: PlaceHistoryModel) {
        print("DiaryRepository :: addPlaceHistory")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        realm.safeWrite {
             realm.add(PlaceHistoryModelRealm(info))
        }
        
        placeHistorySubject.accept(placeHistorySubject.value + [info])
    }
    
    // MARK: - 겹쓰기 로직
    public func addReplay(info: DiaryReplyModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let diary = realm.objects(DiaryModelRealm.self).filter("uuid == %@", info.diaryUuid).first else { return }
        
        let repliesCount = diary.replies.count
        
        var newInfo = info
        newInfo.updateReplyNum(replyNum: repliesCount)
        
        realm.safeWrite {
            diary.replies.append(DiaryReplyModelRealm(newInfo))
        }
        
        let models = realm.objects(DiaryModelRealm.self).map { DiaryModel($0) }
        let result: [DiaryModel] = models.sorted { $0.createdAt > $1.createdAt }
        
        diaryModelSubject.accept(result)
    }
    
    func fetchMonthDictionary() {
        print("fetchMonthDictionary")
        guard let realm = Realm.safeInit() else {
            return
        }
        let diaryModelResults = realm.objects(DiaryModelRealm.self)
        
        var diaryYearModels: [DiaryYearModel] = []
        
        // 연도별 Diary 세팅
        var beforeYear: String = "0"
        for diary in diaryModelResults {
            let curYear = diary.createdAt.toStringWithYYYY()
            if beforeYear == curYear { continue }
            beforeYear = curYear
            diaryYearModels.append(DiaryYearModel(year: Int(curYear) ?? 0, months: DiaryMonthModel()))
        }
        
        // 하나도 작성한 메뉴얼이 없을 경우에는 이번달 Cell을 하나 넣어 줍니다.
        if diaryYearModels.count == 0 {
            let currentMM = Date().toStringWithMM()
            let currentYear = Date().toStringWithYYYY()
            var diaryMonthModel = DiaryMonthModel()
            diaryMonthModel.updateCount(MM: currentMM)
            diaryYearModels.append(DiaryYearModel(year: Int(currentYear) ?? 0, months: diaryMonthModel))
            
            self.diaryMonthDicSubject.accept(diaryYearModels)
            
            return
        }
    
        print("diaryYearModels = \(diaryYearModels)")
        
        // 달별 Diary 세팅
        for index in diaryYearModels.indices {
            let sortedDiaryModelResults = diaryModelResults.filter { $0.createdAt.toStringWithYYYY() == diaryYearModels[index].year.description }
            
            for diary in sortedDiaryModelResults {
                let diaryMM = diary.createdAt.toStringWithMM()
                diaryYearModels[index].months?.updateCount(MM: diaryMM)
            }
        }
        
        let diaryYearSortedModels = diaryYearModels.sorted { $0.year > $1.year }
        
        print("diaryMonthModels = \(diaryYearModels)")
        
        self.diaryMonthDicSubject.accept(diaryYearSortedModels)
    }
    
    // MARK: - 최근검색목록 로직 (SearchModel)
    func fetchDiarySearch() {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        print("fetchDiarySearch!")
        let results = realm.objects(DiarySearchModelRealm.self)
        let sortedResults = results.sorted { $0.createdAt < $1.createdAt }
        diarySearchSubject.accept(results.map { DiarySearchModel($0) })
    }
    
    public func addDiarySearch(info: DiaryModel) {
        print("addDiarySearch!")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let searchRealmData: DiarySearchModelRealm = DiarySearchModelRealm(
            uuid: UUID().uuidString,
            diaryUuid: info.uuid,
            diary: DiaryModelRealm(info),
            createdAt: Date(),
            isDeleted: false
        )
        
        let searchData: DiarySearchModel = DiarySearchModel(searchRealmData)
        
        realm.safeWrite {
            realm.add(searchRealmData)
        }
        
        self.diarySearchSubject.accept(self.diarySearchSubject.value + [searchData])
    }
}


