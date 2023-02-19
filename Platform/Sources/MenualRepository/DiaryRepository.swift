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
import MenualEntity
import MenualUtil
import UIKit // 제거할 것.. UIImage는 Data로 변경

public protocol DiaryRepository {
    var diaryString: BehaviorRelay<[DiaryModelRealm]> { get }
    var filteredDiaryDic: BehaviorRelay<DiaryHomeFilteredSectionModel?> { get }
    var password: BehaviorRelay<PasswordModelRealm?> { get }

    func fetch()
    func addDiary(info: DiaryModelRealm)
    func updateDiary(info: DiaryModelRealm, uuid: String)
    func updateDiary(DiaryModel: DiaryModelRealm ,reminder: ReminderModelRealm?)
    func hideDiary(isHide: Bool, info: DiaryModelRealm)
    func removeAllDiary()
    func deleteDiary(info: DiaryModelRealm)
    
    // Image
    func saveImageToDocumentDirectory(imageName: String, imageData: Data, completionHandler: @escaping (Bool) -> Void)
    func loadImageFromDocumentDirectory(imageName: String, completionHandler: @escaping (UIImage?) -> Void)
    func deleteImageFromDocumentDirectory(diaryUUID: String, completionHandler: @escaping (Bool) -> Void)
    
    // 겹쓰기 로직
    func addReply(info: DiaryReplyModelRealm, diaryModel: DiaryModelRealm)
    func deleteReply(diaryModel: DiaryModelRealm, replyModel: DiaryReplyModelRealm)
    
    // 최근검색목록 로직
    func addDiarySearch(info: DiaryModelRealm)
    func deleteAllRecentDiarySearch()
    func deleteRecentDiarySearch(uuid: String)
    
    // tempSave 로직
    func addTempSave(diaryModel: DiaryModelRealm, tempSaveUUID: String)
    func updateTempSave(diaryModel: DiaryModelRealm, tempSaveUUID: String)
    func deleteTempSave(uuidArr: [String])
    
    // Filter 로직
    func filterDiary(weatherTypes: [Weather], placeTypes: [Place], isOnlyFilterCount: Bool) -> Int
    
    // Password 로직
    func fetchPassword()
    func addPassword(model: PasswordModelRealm)
    func updatePassword(password: Int, isEnabled: Bool)
    
    // Backup로직
    func backUp()
}

public final class DiaryRepositoryImp: DiaryRepository {
    
    public init() {
        
    }

    public var diaryString: BehaviorRelay<[DiaryModelRealm]> { diaryModelSubject }
    public let diaryModelSubject = BehaviorRelay<[DiaryModelRealm]>(value: [])
    
    public var filteredDiaryDic = BehaviorRelay<DiaryHomeFilteredSectionModel?>(value: nil)
    
    public var password = BehaviorRelay<PasswordModelRealm?>(value: nil)
    
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
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료 -> \(imageURL)")
            } catch {
                print("DiaryWriting :: DiaryRepository :: 이미지를 삭제하지 못했습니다.")
                completionHandler(false)
            }
        }
        
        // 5. 이미지를 도큐먼트에 저장
        // 파일을 저장하는 등의 행위는 조심스러워야하기 때문에 do try catch 문을 사용하는 편임
        do {
            try data.write(to: imageURL)
            print("DiaryWriting :: DiaryRepository :: 이미지 저장완료 -> \(imageURL)")
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
        let thumblURL = documentDirectory.appendingPathComponent(diaryUUID + "Thumb")
        
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
        
        if FileManager.default.fileExists(atPath: thumblURL.path) {
            // 4. 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: thumblURL)
                print("DiaryWriting :: DiaryRepository :: 이미지 삭제 완료 -> Thumb")
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
        
        let diaryModelResults = realm
            .objects(DiaryModelRealm.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
            .filter { $0.isDeleted == false }

        // diaryModelSubject.accept(diaryModelResults.map { DiaryModelRealm(value: $0) })
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

    public func updateDiary(info: DiaryModelRealm, uuid: String) {
        print("Repo :: update Diary!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        guard let data = realm.objects(DiaryModelRealm.self).filter({ $0.uuid == uuid }).first
        else { return }
        
        print("Repo :: update Diary! - 2")

        realm.safeWrite {
            data.readCount = info.readCount + 1
            if data.title != info.title {
                print("Repo :: Diary Title이 변경되었다면 Reminder도 함께 변경해야 합니다.")
                data.title = info.title
            }
            
            if data.desc != info.desc {
                data.desc = info.desc
            }

            // TODO: - 이미지 생성 시점 체크할 것
            if data.image != info.image {
                data.image = info.image
            }

            if data.weather?.weather != info.weather?.weather ||
                data.weather?.detailText != info.weather?.detailText {
                data.weather = info.weather
            }
            
            if data.place?.place != info.place?.place ||
                data.place?.detailText != info.place?.detailText {
                data.place = info.place
            }
        }
    }
    
    public func updateDiary(DiaryModel: DiaryModelRealm ,reminder: ReminderModelRealm?) {
        print("DiaryDetail :: repo :: uuid-1 \(DiaryModel.reminder?.uuid), uuid-2 \(reminder?.uuid)")
        guard let realm = Realm.safeInit() else { return }
        
        // reminder가 있을 경우 업데이트
        if let reminder = reminder {
            realm.safeWrite {
                DiaryModel.reminder = reminder
            }
        }
        // reminder가 없을 경우 삭제
        else {
            // 리마인더가 있다면 로컬에 등록된 Notification과 함께 삭제
            if let reminder = DiaryModel.reminder?.uuid {
                print("DiaryDetail :: repo :: reminder.uuid = \(reminder)")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder])
            }

            realm.safeWrite {
                DiaryModel.reminder = nil
            }
        }
        
    }
    
    public func removeAllDiary() {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        realm.safeWrite {
            realm.delete(realm.objects(DiaryModelRealm.self))
        }
        
        // self.diaryMonthDic.accept([])
        // self.diaryMonthDicSubject.accept([])
        // self.filteredMonthDicSubject.accept([])
        self.diaryModelSubject.accept([])
        self.fetch()
    }
    
    public func deleteDiary(info: DiaryModelRealm) {
        guard let realm = Realm.safeInit() else {
            return
        }

        realm.safeWrite {
            info.isDeleted = true
        }
        
        // 이미지가 있다면 함께 삭제
        if info.image {
            deleteImageFromDocumentDirectory(diaryUUID: info.uuid) { isDeleted in
                print("DiaryRepo :: deleteDiary! 이미지를 함께 삭제합니다 = \(isDeleted)")
            }
        }
        
        // 검색된 결과가 있으면 함께 삭제
        if let searchData = realm.objects(DiarySearchModelRealm.self).filter({ $0.diaryUuid == info.uuid }).first {
            print("DiaryRepo :: 검색한 결과가 있습니다.")
            realm.safeWrite {
                realm.delete(searchData)
            }
        }

        // 리마인더가 있따면 함께 삭제
        if let reminder = info.reminder {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminder.uuid])
        }
    }
    
    public func hideDiary(isHide: Bool, info: DiaryModelRealm) {
        print("DiaryRepository :: hideDiary")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }

        realm.safeWrite {
            info.isHide = isHide
        }
    }
    
    // MARK: - 겹쓰기 로직
    public func addReply(info: DiaryReplyModelRealm, diaryModel: DiaryModelRealm) {
        guard let realm = Realm.safeInit() else {
            return
        }

        let repliesCount = diaryModel
            .repliesArr
            .filter ({ $0.isDeleted == false })
            .count

        info.updateReplyNum(replyNum: repliesCount)
        
        realm.safeWrite {
            diaryModel.replies.append(info)
        }
    }
    
    public func deleteReply(diaryModel: DiaryModelRealm, replyModel: DiaryReplyModelRealm) {
        guard let realm = Realm.safeInit() else {
            return
        }

        realm.safeWrite {
            realm.delete(replyModel)
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
        
        let diarySearchRealmArr = realm.objects(DiarySearchModelRealm.self)
        if diarySearchRealmArr.count >= 5 {
            print("Search :: DiaryRepository :: 5개입니다!")
            guard let diarySearchRealm = diarySearchRealmArr.first else { return }
            realm.safeWrite {
                realm.delete(diarySearchRealm)
            }
        }

        guard let diary = realm.objects(DiaryModelRealm.self).filter ({ $0.uuid == info.uuid}).first else { return }
        let diarySearchModel = DiarySearchModelRealm(diaryUuid: info.uuid,
                                                     diary: diary,
                                                     createdAt: Date(),
                                                     isDeleted: false
        )
        
        realm.safeWrite {
             realm.add(diarySearchModel)
        }
    }
    
    // MARK: - Filter 로직
    public func filterDiary(weatherTypes: [Weather], placeTypes: [Place], isOnlyFilterCount: Bool) -> Int {
        print("diaryRepo :: filterDiary -> 날짜/장소")
        guard let realm = Realm.safeInit() else { return 0 }

        var diaryDictionary = Dictionary<String, DiaryHomeSectionModel>()

        var section = Set<String>()
        let model = realm.objects(DiaryModelRealm.self)
            .filter { diary in
                // 필터가 하나일 경우는 OR, 두 개 일 경우에는 AND로 체크하므로, 필터 체크 개수 계산
                var checkedFilterCount: Int = 0
                if weatherTypes.count != 0 {
                    checkedFilterCount += 1
                }
                if placeTypes.count != 0 {
                    checkedFilterCount += 1
                }

                var isContainWeather: Bool = false
                if let weather = diary.weather?.weather {
                    isContainWeather = weatherTypes.contains(weather)
                } else {
                    isContainWeather = false
                }
                
                var isContainPlace: Bool = false
                if let place = diary.place?.place {
                    isContainPlace = placeTypes.contains(place)
                } else {
                    isContainPlace = false
                }

                if checkedFilterCount == 2 {
                    return diary.isDeleted == false && isContainWeather && isContainPlace
                } else if checkedFilterCount == 1 {
                    return diary.isDeleted == false && isContainWeather || isContainPlace
                }

                return diary.isDeleted == false && isContainWeather || isContainPlace
            }
            .sorted(by: ({ $0.createdAt > $1.createdAt }))
        
        if isOnlyFilterCount == true {
            return model.count
        }

        model.forEach { section.insert($0.createdAt.toStringWithYYYYMM())}

        var arraySection = Array(section)
        arraySection.sort { $0 > $1 }
        arraySection.enumerated().forEach { (index: Int, sectionName: String) in
            diaryDictionary[sectionName] = DiaryHomeSectionModel(sectionName: sectionName,
                                                                 sectionIndex: index,
                                                                 diaries: []
            )
        }
        for diary in model {
            let sectionName: String = diary.createdAt.toStringWithYYYYMM()
            diaryDictionary[sectionName]?.diaries.append(diary)
        }
        
        let filteredSectionModel = DiaryHomeFilteredSectionModel(allCount: model.count,
                                                                 diarySectionModelDic: diaryDictionary
        )
        filteredDiaryDic.accept(filteredSectionModel)
        return model.count
    }
    
    // MARK: - TempSave
    public func addTempSave(diaryModel: DiaryModelRealm, tempSaveUUID: String) {
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let realmModel: TempSaveModelRealm = TempSaveModelRealm(uuid: tempSaveUUID,
                                                                diaryModel: diaryModel,
                                                                createdAt: Date(),
                                                                isDeleted: false
        )

        realm.safeWrite {
             realm.add(realmModel)
        }
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
    }
    
    public func updateTempSave(diaryModel: DiaryModelRealm, tempSaveUUID: String) {
        print("DiaryRepo :: updateTempSave!")
        guard let realm = Realm.safeInit() else {
            return
        }

        let model = TempSaveModelRealm(uuid: tempSaveUUID,
                                       diaryModel: diaryModel,
                                       createdAt: Date(),
                                       isDeleted: false
        )
        
        guard let data = realm.objects(TempSaveModelRealm.self).filter({ $0.uuid == tempSaveUUID }).first else { return }
        
        realm.safeWrite {
            data.title = model.title
            data.weatherDetailText = model.weatherDetailText
            data.weather = model.weather
            data.placeDetailText = model.placeDetailText
            data.place = model.place
            data.image = model.image
            data.createdAt = model.createdAt
            data.isDeleted = model.isDeleted
            data.desc = model.desc
        }
    }
    
    // MARK: - Password
    public func fetchPassword() {
        guard let realm = Realm.safeInit() else {
            return
        }
        print("diaryRepo :: passwordFetch! - 1")

        guard let passwordModelRealm = realm.objects(PasswordModelRealm.self).first
        else { return }
        password.accept(passwordModelRealm)
        print("diaryRepo :: passwordFetch! - 2")
    }
    
    public func addPassword(model: PasswordModelRealm) {
        guard let realm = Realm.safeInit() else {
            return
        }
        print("diaryRepo :: addPassword! - 1")
    
        realm.safeWrite {
            realm.delete(realm.objects(PasswordModelRealm.self))
            realm.add(model)
        }
        
        print("diaryRepo :: addPassword! - 2")
        fetchPassword()
    }
    
    public func updatePassword(password: Int, isEnabled: Bool) {
        guard let realm = Realm.safeInit() else {
            return
        }
        print("diaryRepo :: updatePassword! - 1")
        
        guard let data = realm.objects(PasswordModelRealm.self).first else { return }
        
        realm.safeWrite {
            data.password = password
            data.isEnabled = isEnabled
        }
        
        print("diaryRepo :: updatePassword! - 2")
        
        fetchPassword()
    }
    
    // MARK: - Backup 로직
    public func backUp() {
        print("DiaryRepo :: backup!")
        
        guard let realm = Realm.safeInit() else { return }

        // Diary
        let diaryArray = realm
            .objects(DiaryModelRealm.self)
            .toArray(type: DiaryModelRealm.self)
        let diaryData = try? JSONEncoder().encode(diaryArray)
        if let jsonString = String(data: diaryData ?? Data(), encoding: .utf8) {
            print("DiaryRepo :: diary = \(jsonString)")
        }
        
        // Moments
        let momentsArray =  realm
            .objects(MomentsRealm.self)
            .toArray(type: MomentsRealm.self)
        let momentsData = try? JSONEncoder().encode(momentsArray)
        if let jsonString = String(data: momentsData ?? Data(), encoding: .utf8) {
            print("DiaryRepo :: moments = \(jsonString)")
        }
        
        // TempSave
        let tempSaveArray = realm
            .objects(TempSaveModelRealm.self)
            .toArray(type: TempSaveModelRealm.self)
        let tempSaveData = try? JSONEncoder().encode(tempSaveArray)
        if let jsonString = String(data: tempSaveData ?? Data(), encoding: .utf8) {
            print("DiaryRepo :: tempSave :: \(jsonString)")
        }
        
        // DiarySearch
        let diarySearchArray = realm
            .objects(DiarySearchModelRealm.self)
            .toArray(type: DiarySearchModelRealm.self)
        let diarySearchData = try? JSONEncoder().encode(diarySearchArray)
        if let jsonString = String(data: diarySearchData ?? Data(), encoding: .utf8) {
            print("DiaryRepo :: search :: \(jsonString)")
        }
        
        // let decoded = String(data: jsonData!, encoding: .utf8)!
        // print("DiaryRepo :: jsonData = \(jsonData)")

    }
}
