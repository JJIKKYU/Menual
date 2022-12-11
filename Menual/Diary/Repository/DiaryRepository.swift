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
    
    var diaryString: BehaviorRelay<[DiaryModelRealm]> { get }
    var filteredMonthDic: BehaviorRelay<[DiaryYearModel]> { get }
    var diaryMonthDic: BehaviorRelay<[DiaryYearModel]> { get }
    var diarySearch: BehaviorRelay<[DiarySearchModel]> { get }
    var tempSave: BehaviorRelay<[TempSaveModel]> { get }
    var password: BehaviorRelay<PasswordModel?> { get }
    var reminder: BehaviorRelay<[ReminderModel]> { get }
    
//    var realmDiaryOb: Observable<[DiaryModel]> { get }
    // func addDiary(info: DiaryModel) throws -> Observable<DiaryModel>
    func fetch()
    func fetchTempSave()
    func addDiary(info: DiaryModelRealm)
    func updateDiary(info: DiaryModelRealm)
    func hideDiary(isHide: Bool, info: DiaryModelRealm)
    func removeAllDiary()
    func deleteDiary(info: DiaryModel)
    
    // Image
    func saveImageToDocumentDirectory(imageName: String, imageData: Data, completionHandler: @escaping (Bool) -> Void)
    func loadImageFromDocumentDirectory(imageName: String, completionHandler: @escaping (UIImage?) -> Void)
    func deleteImageFromDocumentDirectory(diaryUUID: String, completionHandler: @escaping (Bool) -> Void)
    
    // 겹쓰기 로직
    func addReply(info: DiaryReplyModel)
    func deleteReply(diaryUUID: String, replyUUID: String)
    
    // 최근검색목록 로직
    func addDiarySearch(info: DiaryModelRealm)
    func deleteAllRecentDiarySearch()
    func deleteRecentDiarySearch(uuid: String)
    
    // tempSave 로직
    func addTempSave(diaryModel: DiaryModel, tempSaveUUID: String)
    func updateTempSave(diaryModel: DiaryModel, tempSaveUUID: String)
    func deleteTempSave(uuidArr: [String])
    
    // Filter 로직
    func filterDiary(weatherTypes: [Weather], placeTypes: [Place], isOnlyFilterCount: Bool) -> Int
    func filterDiary(date: Date, isOnlyFilterCount: Bool) -> Int
    
    // Password 로직
    func fetchPassword()
    func addPassword(model: PasswordModel)
    func updatePassword(model: PasswordModel)
    
    // Reminder 로직
    func fetchReminder()
    func fetchDiaryReminder(diaryUUID: String) -> Observable<ReminderModel?>
    func addReminder(model: ReminderModel)
    func updateReminder(model: ReminderModel)
    func deleteReminder(reminderUUID: String)
}

public final class DiaryRepositoryImp: DiaryRepository {

    public var diaryString: BehaviorRelay<[DiaryModelRealm]> { diaryModelSubject }
    public let diaryModelSubject = BehaviorRelay<[DiaryModelRealm]>(value: [])
    
    public var filteredMonthDic: BehaviorRelay<[DiaryYearModel]> { filteredMonthDicSubject }
    public let filteredMonthDicSubject = BehaviorRelay<[DiaryYearModel]>(value: [])
    
    public var diaryMonthDic: BehaviorRelay<[DiaryYearModel]> { diaryMonthDicSubject }
    public let diaryMonthDicSubject = BehaviorRelay<[DiaryYearModel]>(value: [])
    
    public var diarySearch: BehaviorRelay<[DiarySearchModel]> { diarySearchSubject }
    public let diarySearchSubject = BehaviorRelay<[DiarySearchModel]>(value: [])
    
    public var tempSave: BehaviorRelay<[TempSaveModel]> { tempSaveSubject }
    public let tempSaveSubject = BehaviorRelay<[TempSaveModel]>(value: [])
    
    public var password: BehaviorRelay<PasswordModel?> { passwordSubject }
    public let passwordSubject = BehaviorRelay<PasswordModel?>(value: nil)
    
    public var reminder: BehaviorRelay<[ReminderModel]> { reminderSubject }
    public let reminderSubject = BehaviorRelay<[ReminderModel]>(value: [])
    
    public func saveImageToDocumentDirectory(imageName: String, imageData: Data, completionHandler: @escaping (Bool) -> Void) {
        // 1. 이미지를 저장할 경로를 설정해줘야함 - 도큐먼트 폴더,File 관련된건 Filemanager가 관리함(싱글톤 패턴)
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        print("!!")
        
        // 2. 이미지 파일 이름 & 최종 경로 설정
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        
        // 3. 이미지 압축(image.pngData())
        // 압축할거면 jpegData로~(0~1 사이 값)
//        guard let data = image.pngData() else {
//            print("압축이 실패했습니다.")
//            return
//        }
        let data = imageData
        
        // 4. 이미지 저장: 동일한 경로에 이미지를 저장하게 될 경우, 덮어쓰기하는 경우
        // 4-1. 이미지 경로 여부 확인
        if FileManager.default.fileExists(atPath: imageURL.path) {
            // 4-2. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료")
            } catch {
                print("DiaryWriting :: DiaryRepository :: 이미지를 삭제하지 못했습니다.")
                completionHandler(false)
            }
        }
        
        // 5. 이미지를 도큐먼트에 저장
        // 파일을 저장하는 등의 행위는 조심스러워야하기 때문에 do try catch 문을 사용하는 편임
        do {
            try data.write(to: imageURL)
            print("DiaryWriting :: DiaryRepository :: 이미지 저장완료")
            completionHandler(true)
        } catch {
            print("DiaryWriting :: DiaryRepository :: 이미지를 저장하지 못했습니다.")
            completionHandler(false)
        }
    }
    
    public func loadImageFromDocumentDirectory(imageName: String, completionHandler: @escaping (UIImage?) -> Void) {
            
        // 1. 도큐먼트 폴더 경로가져오기
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
        // 2. 이미지 URL 찾기
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            // 3. UIImage로 불러오기
            completionHandler(UIImage(contentsOfFile: imageURL.path))
            // return UIImage(contentsOfFile: imageURL.path)
        }
        
        completionHandler(nil)
    }
    
    public func deleteImageFromDocumentDirectory(diaryUUID: String, completionHandler: @escaping (Bool) -> Void) {
        // 1. 이미지를 삭제할 경로를 설정해줘야함 - 도큐먼트 폴더,File 관련된건 Filemanager가 관리함(싱글톤 패턴)
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        
        // 2. 이미지 파일 이름 & 최종 경로 설정
        let imageURL = documentDirectory.appendingPathComponent(diaryUUID)
        let originalURL = documentDirectory.appendingPathComponent(diaryUUID + "Original")
        
        // 3. 이미지 삭제
        if FileManager.default.fileExists(atPath: imageURL.path) {
            // 4. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료 -> Crop")
            } catch {
                print("DiaryWriting :: DiaryRepository :: 이미지를 삭제하지 못했습니다.")
                completionHandler(false)
            }
        }
        
        if FileManager.default.fileExists(atPath: originalURL.path) {
            // 4. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: originalURL)
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료 -> Original")
            } catch {
                print("DiaryWriting :: DiaryRepository :: 이미지를 삭제하지 못했습니다.")
                completionHandler(false)
            }
        }
        
        completionHandler(true)
    }
    
    public func fetch() {
        print("DiaryRepository :: fetch")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let diaryModelResults = realm.objects(DiaryModelRealm.self).sorted(byKeyPath: "createdAt", ascending: false)
        diaryModelSubject.accept(diaryModelResults.map { DiaryModelRealm(value: $0) })
        
        self.fetchDiary()
        self.fetchReminder()
    }
    
    // MARK: - Diary Fetch
    public func fetchDiary() {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let diaryModelResults = realm.objects(DiaryModelRealm.self).filter { $0.isDeleted != true }
        
        var diaryYearModels: [DiaryYearModel] = []
        
        // 연도별 Diary 세팅
        var beforeYear: String = "0"
        for diary in diaryModelResults {
            let curYear = diary.createdAt.toStringWithYYYY() // 2021, 2022 등으로 변경
            if beforeYear == curYear { continue }
            beforeYear = curYear

            diaryYearModels.append(DiaryYearModel(year: Int(curYear) ?? 0, months: DiaryMonthModel()))
        }

        print("diaryYearModels = \(diaryYearModels)")
        
        // 달별 Diary 세팅
        for index in diaryYearModels.indices {
            // 같은 연도인 Diary만 Filter
            let sortedDiaryModelResults = diaryModelResults.filter { $0.createdAt.toStringWithYYYY() == diaryYearModels[index].year.description }
            
            for diary in sortedDiaryModelResults {
                let diaryMM = diary.createdAt.toStringWithMM() // 01, 02 등으로 변경
                let diaryModel = DiaryModel(diary)

                diaryYearModels[index].months?.updateCount(MM: diaryMM, diary: diaryModel)
                // diaryYearModels[index].months?.addDiary(diary: diary)
                diaryYearModels[index].months?.updateAllCount()
            }

            diaryYearModels[index].months?.sortDiary()
        }
        

        let diaryYearSortedModels = diaryYearModels.sorted { $0.year > $1.year }
        
        print("diaryMonthModels = \(diaryYearModels)")
        
        self.diaryMonthDicSubject.accept(diaryYearSortedModels)
    }
    
    // MARK: - Diary CRUD
    public func addDiary(info: DiaryModelRealm) {
        guard let realm = Realm.safeInit() else {
            return
        }

        let diariesCount = realm.objects(DiaryModelRealm.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .filter({ $0.isDeleted == false })
            .first?
            .pageNum ?? 0

        info.updatePageNum(pageNum: diariesCount)

        realm.safeWrite {
            realm.add(info)
        }
    }

    public func updateDiary(info: DiaryModelRealm) {
        print("update Diary!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(DiaryModelRealm.self).filter({ $0.uuid == info.uuid }).first
        else { return }
        
        realm.safeWrite {
            data.readCount = info.readCount + 1
            if data.title != info.title {
                data.title = info.title
            }
            
            if data.desc != info.desc {
                data.desc = info.desc
            }

            // TODO: - 이미지 생성 시점 체크할 것
//            if data.image != (info.image != nil) ? true : false {
//                data.image = info.image != nil ? true : false
//            }

            if data.weather?.weather != info.weather?.weather ||
                data.weather?.detailText != info.weather?.detailText {
                data.weather = info.weather
            }
            
            if data.place?.place != info.place?.place ||
                data.place?.detailText != info.place?.detailText {
                data.place = info.place
            }
            
            // data.weather = WeatherModelRealm(info.weather ?? WeatherModel(uuid: "", weather: nil, detailText: ""))
            // data.place = PlaceModelRealm(info.place ?? PlaceModel(uuid: "", place: nil, detailText: ""))
        }
        
//        var idx: Int = 0
//        for (index, value) in diaryModelSubject.value.enumerated() {
//            if value.uuid == info.uuid {
//                idx = index
//            }
//        }

//        var arr = diaryModelSubject.value
//        arr[idx] = DiaryModel(uuid: info.uuid,
//                              pageNum: info.pageNum,
//                              title: info.title,
//                              weather: info.weather,
//                              place: info.place,
//                              description: info.description,
//                              image: info.image,
//                              originalImage: info.originalImage,
//                              readCount: info.readCount,
//                              createdAt: info.createdAt,
//                              replies: info.replies,
//                              isDeleted: info.isDeleted,
//                              isHide: info.isHide
//        )

        // diaryModelSubject.accept(arr)
        // self.fetch()
    }
    
    public func removeAllDiary() {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        realm.safeWrite {
            realm.delete(realm.objects(DiaryModelRealm.self))
        }
        
        self.diaryMonthDic.accept([])
        self.diaryMonthDicSubject.accept([])
        self.filteredMonthDicSubject.accept([])
        self.diaryModelSubject.accept([])
        self.fetch()
    }
    
    public func deleteDiary(info: DiaryModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(DiaryModelRealm.self).filter({ $0.uuid == info.uuid }).first
        else { return }
        
//        realm.safeWrite {
//            realm.delete(data)
//        }
        
        realm.safeWrite {
            data.isDeleted = true
        }
        
        // 검색된 결과가 있으면 함께 삭제
        if let searchData = realm.objects(DiarySearchModelRealm.self).filter({ $0.diaryUuid == info.uuid }).first {
            print("DiaryRepo :: 검색한 결과가 있습니다.")
            realm.safeWrite {
                realm.delete(searchData)
            }
        }

        // 리마인더가 있따면 함께 삭제
        if let reminderData: ReminderModelRealm = realm.objects(ReminderModelRealm.self).filter({ $0.diaryUUID == info.uuid }).first {
            deleteReminder(reminderUUID: reminderData.uuid)
        }
        
        // deleteRecentDiarySearch(uuid: )
        
        

        /*
        realm.safeWrite {
            data.isDeleted = true
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
                              originalImage: info.originalImage,
                              readCount: info.readCount,
                              createdAt: info.createdAt,
                              replies: info.replies,
                              isDeleted: true,
                              isHide: info.isHide
        )

        diaryModelSubject.accept(arr)
         */
        // fetch()
    }
    
    public func hideDiary(isHide: Bool, info: DiaryModelRealm) {
        print("DiaryRepository :: hideDiary")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(DiaryModelRealm.self).filter({ $0.uuid == info.uuid }).first
        else { return }
        
        realm.safeWrite {
            data.isHide = isHide
        }
    }
    
    // MARK: - 겹쓰기 로직
    public func addReply(info: DiaryReplyModel) {
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
    }
    
    public func deleteReply(diaryUUID: String, replyUUID: String) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let diary = realm.objects(DiaryModelRealm.self).filter("uuid == %@", diaryUUID).first else {
            return
        }
        
        print("DiaryRepo :: diary = \(diary)")
        
        guard let replyRealm = diary.replies.filter({ $0.uuid == replyUUID }).first else { return }
        
        print("DiaryRepo :: replyRealm = \(replyRealm)")

        realm.safeWrite {
            realm.delete(replyRealm)
        }
    }

    // MARK: - 최근검색목록 로직 (SearchModel)
    public func deleteAllRecentDiarySearch() {
        print("Search :: DiaryRepository :: deleteAllRecentDiarySearch!")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        realm.safeWrite {
            realm.delete(realm.objects(DiarySearchModelRealm.self))
        }
    }
    
    public func deleteRecentDiarySearch(uuid: String) {
        print("Search :: DiaryRepository :: deleteRecentDiarySearch!")
        
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(DiarySearchModelRealm.self).filter({ $0.uuid == uuid }).first
        else { return }
        
        realm.safeWrite {
            realm.delete(data)
        }
    }
    
    public func addDiarySearch(info: DiaryModelRealm) {
        print("Search :: DiaryRepository :: addDiarySearch!")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let diary = realm.objects(DiaryModelRealm.self).filter("uuid == %@", info.uuid).first else { return }
        let diarySearchModel = DiarySearchModelRealm(uuid: UUID().uuidString,
                                                     diaryUuid: info.uuid,
                                                     diary: diary,
                                                     createdAt: Date(),
                                                     isDeleted: false
        )
        
        realm.safeWrite {
             realm.add(diarySearchModel)
        }

        print("Search :: DiaryRepository :: diarySearchModel = \(diarySearchModel)")
        
//        let result: [DiarySearchModel] = (diarySearchSubject.value + [diarySearchModel]).sorted { $0.createdAt > $1.createdAt }
//
//        diarySearchSubject.accept(result)
    }
    
    // MARK: - Filter 로직
    public func filterDiary(weatherTypes: [Weather], placeTypes: [Place], isOnlyFilterCount: Bool) -> Int {
        print("diaryRepo :: filterDiary -> 날짜/장소")
        // fetchDiary 후 얻은 결과 원본
        var diaryMonthDic: [DiaryYearModel] = diaryMonthDicSubject.value

        for (index, _) in diaryMonthDic.enumerated() {
            diaryMonthDic[index].months?.filterDiary(weatherTypes: weatherTypes, placeTypes: placeTypes)
        }
        
        // print("filterDiary! \(diaryMonthDic)")
        var allCount: Int = 0
        for model in diaryMonthDic {
            print("= \(model.year) -> \(String(describing: model.months?.allCount))")
            print("1월, \(model.months?.jan ?? 0)")
            print("2월, \(model.months?.fab ?? 0)")
            print("3월, \(model.months?.mar ?? 0)")
            print("4월, \(model.months?.apr ?? 0)")
            print("5월, \(model.months?.may ?? 0)")
            print("6월, \(model.months?.jul ?? 0)")
            print("7월, \(model.months?.jul ?? 0)")
            print("8월, \(model.months?.aug ?? 0)")
            print("9월, \(model.months?.sep ?? 0)")
            print("10월, \(model.months?.oct ?? 0)")
            print("11월, \(model.months?.nov ?? 0)")
            print("12월, \(model.months?.dec ?? 0)")
            
            if let count = model.months?.allCount {
                allCount += count
            }
        }
        if isOnlyFilterCount == true {
            print("필터 결과 총 개수 = \(allCount)")
            return allCount
        }
        
        // filteredDiaryStringSubject.accept(diaryMonthDic)
        filteredMonthDicSubject.accept(diaryMonthDic)
        return allCount
    }
    
    public func filterDiary(date: Date, isOnlyFilterCount: Bool) -> Int {
        print("diaryRepo :: filterDiary! -> 날짜")
        
        let diarymonthDic: [DiaryYearModel] = diaryMonthDicSubject.value
        
        guard let filteredDiaryYearModel = diarymonthDic.filter({ String($0.year) == date.toStringWithYYYY() }).last else {
            filteredMonthDicSubject.accept([])
            return 0
        }
        var diaryYearModel = filteredDiaryYearModel
        let count = diaryYearModel.months?.filterDiary(date: date)
        
        print("diaryRepo :: filter! = \(filteredDiaryYearModel)")
        
        if isOnlyFilterCount == true {
            print("diaryRepo :: 필터 결과 총 개수 = \(count)")
            return count ?? 0
        }
        
        filteredMonthDicSubject.accept([diaryYearModel])
        return count ?? 0
        // fetchDiary 후 얻은 결과 원본
    }
    
    // MARK: - TempSave
    public func fetchTempSave() {
        guard let realm = Realm.safeInit() else {
            return
        }

        let tempSaveModelResults = realm.objects(TempSaveModelRealm.self).sorted(byKeyPath: "createdAt", ascending: false)
        tempSaveSubject.accept(tempSaveModelResults.map { TempSaveModel($0) })
        print("diaryRepo :: fetchTempSave!")
    }

    public func addTempSave(diaryModel: DiaryModel, tempSaveUUID: String) {
        let model: TempSaveModel = TempSaveModel(uuid: tempSaveUUID,
                                                 diaryModel: diaryModel,
                                                 createAt: Date(),
                                                 isDeleted: false
        )
        
        let realmModel: TempSaveModelRealm = TempSaveModelRealm(model)
        
        print("diaryRepo :: addTempSave!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        realm.safeWrite {
             realm.add(realmModel)
            // realm.create(DiaryModelRealm.self, value: DiaryModelRealm(info))
        }
        
        let result: [TempSaveModel] = (tempSaveSubject.value + [model]).sorted { $0.createdAt > $1.createdAt }
        
        tempSaveSubject.accept(result)
        self.fetchTempSave()

    }
    
    public func deleteTempSave(uuidArr: [String]) {
        print("DiaryRepo :: deleteTempSave!")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let tempSaveModelRealmObjects = realm.objects(TempSaveModelRealm.self)
        var willDeleteModelObjects: [TempSaveModelRealm] = []
        for uuid in uuidArr {
            let model = tempSaveModelRealmObjects.filter { $0.uuid == uuid }
            willDeleteModelObjects.append(contentsOf: model)
        }
        print("DiaryRepo :: willDeleteModelObjects = \(willDeleteModelObjects)")
        
        realm.safeWrite {
            realm.delete(willDeleteModelObjects)
        }
        
        self.fetchTempSave()
    }
    
    public func updateTempSave(diaryModel: DiaryModel, tempSaveUUID: String) {
        print("DiaryRepo :: updateTempSave!")
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let model: TempSaveModel = TempSaveModel(uuid: tempSaveUUID,
                                                 diaryModel: diaryModel,
                                                 createAt: Date(),
                                                 isDeleted: false
        )
        
        guard let data = realm.objects(TempSaveModelRealm.self).filter({ $0.uuid == tempSaveUUID }).first else { return }
        
        realm.safeWrite {
            data.title = model.title
            data.weatherDetailText = model.weatherDetailText
            data.weather = model.weather
            data.placeDetailText = model.placeDetilText
            data.place = model.place
            data.image = model.image != nil ? true : false
            data.createdAt = model.createdAt
            data.isDeleted = model.isDeleted
            data.desc = model.description
        }
        
        self.fetchTempSave()
    }
    
    // MARK: - Password
    public func fetchPassword() {
        guard let realm = Realm.safeInit() else {
            return
        }
        print("diaryRepo :: passwordFetch! - 1")

        guard let passwordModelRealm = realm.objects(PasswordModelRealm.self).first
        else { return }
        let passwordModel = PasswordModel(passwordModelRealm)
        passwordSubject.accept(passwordModel)
        print("diaryRepo :: passwordFetch! - 2")
    }
    
    public func addPassword(model: PasswordModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        print("diaryRepo :: addPassword! - 1")

        let realmModel: PasswordModelRealm = PasswordModelRealm(model)
    
        realm.safeWrite {
             realm.add(realmModel)
    
        }
        
        print("diaryRepo :: addPassword! - 2")
        fetchPassword()
    }
    
    public func updatePassword(model: PasswordModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        print("diaryRepo :: updatePassword! - 1")
        
        guard let data = realm.objects(PasswordModelRealm.self).first else { return }
        
        realm.safeWrite {
            data.password = model.password
            data.isEnabled = model.isEnabled
        }
        
        print("diaryRepo :: updatePassword! - 2")
        
        fetchPassword()
    }
    
    public func fetchReminder() {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let reminderModelRealmResults = realm.objects(ReminderModelRealm.self).sorted(byKeyPath: "createdAt", ascending: false)
        
        self.reminderSubject.accept(reminderModelRealmResults.map { ReminderModel($0) })
    }

    // 한 개의 Reminder만 얻고자 할 경우
    public func fetchDiaryReminder(diaryUUID: String) -> Observable<ReminderModel?> {
        guard let realm = Realm.safeInit() else {
            return Observable.just(nil)
        }
        print("diaryRepo :: fetchDiaryReminder! - 1")

//        guard let reminderModelRealm = realm.objects(ReminderModelRealm.self).filter { $0.diaryUUID == diaryUUID }
//        else { return Observable.just(nil) }
        
        guard let reminderModelRealm = realm.objects(ReminderModelRealm.self).filter({ $0.diaryUUID == diaryUUID }).first else { return Observable.just(nil) }

        let reminderModel = ReminderModel(reminderModelRealm)
        // reminder.accept(reminderModel)
        print("diaryRepo :: fetchDiaryReminder! - 2")
        return Observable.just(reminderModel)
    }
    
    public func addReminder(model: ReminderModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let realmModel = ReminderModelRealm(model)

        realm.safeWrite {
            realm.add(realmModel)
        }
        
        print("diaryRepo :: addReminder!!")
        self.fetchReminder()
    }
    
    public func updateReminder(model: ReminderModel) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(ReminderModelRealm.self).filter ({ $0.uuid == model.uuid }).first else { return }
        
        realm.safeWrite {
            data.isEnabled = model.isEnabled
            data.createdAt = model.createdAt
            data.requestUUID = model.requestUUID
            data.requestDate = model.requestDate
        }
        
        self.fetchReminder()
    }
    
    public func deleteReminder(reminderUUID: String) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(ReminderModelRealm.self).filter({ $0.uuid == reminderUUID }).first
        else { return }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [data.requestUUID])
        
        realm.safeWrite {
            realm.delete(data)
        }
        
        self.fetchReminder()
    }
}
