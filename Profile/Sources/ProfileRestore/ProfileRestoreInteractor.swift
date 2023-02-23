//
//  ProfileRestoreInteractor.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import RxRelay
import ZipArchive
import RealmSwift
import MenualUtil
import MenualEntity
import UserNotifications
import MenualRepository

public protocol ProfileRestoreRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol ProfileRestorePresentable: Presentable {
    var listener: ProfileRestorePresentableListener? { get set }
    func exitWithAnimation()
}

public protocol ProfileRestoreListener: AnyObject {
    func pressedProfileRestoreBackBtn(isOnlyDetach: Bool)
}

public protocol ProfileRestoreInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class ProfileRestoreInteractor: PresentableInteractor<ProfileRestorePresentable>, ProfileRestoreInteractable, ProfileRestorePresentableListener {

    weak var router: ProfileRestoreRouting?
    weak var listener: ProfileRestoreListener?
    private let dependency: ProfileRestoreInteractorDependency
    
    private let disposeBag = DisposeBag()
    private let menualRestoreFileRelay = BehaviorRelay<Bool>(value: false)
    var fileName: String?
    var fileCreatedAt: String?

    init(
        presenter: ProfileRestorePresentable,
        dependency: ProfileRestoreInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.pressedProfileRestoreBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func bind() {
        menualRestoreFileRelay
            .subscribe(onNext: { [weak self] isRestoreMenualFile in
                guard let self = self else { return }
                
                switch isRestoreMenualFile {
                case true:
                    print("ProfileRestore :: isRestoreMenualFile! = true")
                    // Valid한 file만 parsing
                    guard let restoreFile = self.parseJsonFile() else {
                        // 오류 핸들러 UI 표시
                        return
                    }
                    print("ProfileRestore :: restoreFile = \(restoreFile.fileName), \(restoreFile.createdDate)")
                    self.dependency.diaryRepository
                        .restoreWithJson(restoreFile: restoreFile)

                    // self.migrateMenual(restoreFile: restoreFile)

                case false:
                    print("ProfileRestore :: isRestoreMenualFile! = false")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func tempZipPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString).zip"
        return path
    }
    
    /// 유저가 선택한 파일이 MenualZipFile인지 체크
    ///  url - 유저의 zip file URL (zip이 아닐 수도 있음)
    func checkIsMenualZipFile(url: URL) {
        print("ProfileRestore :: checkIsMenualZipFile!")
        
        self.fileName = url.lastPathComponent
        self.fileCreatedAt = getFileCreatedAt(url: url)

        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/jsonTest/"
        
        // 메뉴얼 저장된게 없으면 메뉴얼 Zip파일이 아니라고 판단
        var isDiaryJson: Bool = false
        
        // 압축 해제 시작
        SSZipArchive.unzipFile(atPath: url.path, toDestination: path) { fileName, b, c, d in
            print("ProfileRestore :: \(fileName), \(b), \(c) / \(d)")

            // 파일에 diaryJson이 있다면 메뉴얼 파일이므로 isDiaryJson을 true로 변경
            if fileName == "diary.json" {
                isDiaryJson = true
            }
        } completionHandler: { [weak self] a, b, error in
            guard let self = self else { return }

            print("ProfileRestore :: \(a), \(b), error = \(error), isDiaryJson = \(isDiaryJson)")

            self.menualRestoreFileRelay.accept(isDiaryJson)
        }
    }

    /// 파일 생성 일자 확인하는 함수
    func getFileCreatedAt(url: URL) -> String? {
        let fileManager = FileManager.default

        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            let creationDate = attributes[.creationDate] as? Date
            
            if let creationDate = creationDate {
                return creationDate.toString()
            }
        } catch {
            print("Error getting file attributes: \(error.localizedDescription)")
        }

        return nil
    }
    
    /// Cache 폴더에 미리 압축한 내용을 확인하고 RestoreFile에 캐시
    func parseJsonFile() -> RestoreFile? {
        print("ProfileRestore :: parseJsonFile!")
        guard let fileName = fileName,
              let fileCreatedAt = fileCreatedAt else { return nil }
        // Cache폴더에 복원하고자 하는 File을 미리 압축을 해제했음.
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/jsonTest/"

        var restoreFile = RestoreFile(fileName: fileName,
                                      createdDate: fileCreatedAt,
                                      isVaildMenualRestoreFile: true
        )

        // FileManager에서 복원하고자 하는 파일을 캐시
        let fileManager = FileManager.default
        let decoder = JSONDecoder()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(atPath: path)

            for fileURL in fileURLs {
                print("ProfileRestore :: File name: \(fileURL)")
                let filePath = URL(fileURLWithPath: path + fileURL)
                print("filePath = \(filePath)")
                if let restoreFileType = RestoreFileType(rawValue: fileURL) {
                    switch restoreFileType {
                    case .diary:
                        if let diaryJsonData = try? Data(contentsOf: filePath) {
                            restoreFile.diaryData = diaryJsonData
                        }
                    case .diarySearch:
                        if let diarySearchData = try? Data(contentsOf: filePath) {
                            restoreFile.diarySearchData = diarySearchData
                        }
                    case .moments:
                        if let momentsData = try? Data(contentsOf: filePath) {
                            restoreFile.momentsData = momentsData
                        }
                    case .password:
                        if let passwordData = try? Data(contentsOf: filePath) {
                            restoreFile.passwordData = passwordData
                        }
                    case .tempSave:
                        if let tempSaveData = try? Data(contentsOf: filePath) {
                            restoreFile.tempSaveData = tempSaveData
                        }
                    case .backupHistory:
                        if let backupHistoryData = try? Data(contentsOf: filePath) {
                            restoreFile.backupHistoryData = backupHistoryData
                        }
                    }
                } else {
                    if fileURL == ".DS_Store" { continue }
                    if let imageData = try? Data(contentsOf: filePath) {
                        let imageFile = ImageFile(fileName: fileURL, Data: imageData)
                        restoreFile.imageDataArr.append(imageFile)
                    }
                }
            }
        } catch {
            print("Error getting directory contents: \(error.localizedDescription)")
        }
        
        return restoreFile
    }
    
    func restoreDiary(url: URL) {
        checkIsMenualZipFile(url: url)
        /*
        clearDocumentFolder()
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let newPath = path
        
        print("ProfileRestore :: path = \(path), url = \(url.absoluteString), \(url.path)")
        SSZipArchive.unzipFile(atPath: url.path, toDestination: newPath) { _, _, c, d in
        
            print("ProfileRestore :: \(c) / \(d)")
        } completionHandler: { a, b, error in
            print("ProfileRestore :: \(a), \(b), error = \(error)")
            self.restartAppWithPush()
        }
         */

        // SSZipArchive.unzipFileAtPath(zipPath, toDestination: unzipPath)
//        let realm = try? Realm(fileURL: URL(string: "\(newPath)/default.realm")!)
//        let diaryModelRealm = realm?.objects(DiaryModelRealm.self)
//        print("ProfileRestore :: 교체예정인 다이어리 개수 = \(diaryModelRealm?.count)")
//
//        let config = Realm.Configuration(fileURL: URL(string: "\(newPath)/default.realm"))
//        Realm.Configuration.defaultConfiguration = config
//        print("ProfileRestore :: realm = \(realm)")
//        print("ProfileRestore :: config = \(config)")
        // restartAppWithPush()
    }
    
    /// 최종적으로 메뉴얼에 백업 데이터 마이그레이션 작업
    func migrateMenual(restoreFile: RestoreFile) {
        do {
            if let data = restoreFile.diaryData  {
                let json = try JSONDecoder().decode([DiaryModelRealm].self, from: data)
                
            }
        } catch {
            print("ProfileRestore :: migrateMenual Error! \(error)")
        }
    }

    func clearDocumentFolder() {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: path)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: path + "/" + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func restartAppWithPush() {
        print("ProfileRestore :: restartAppWithPush!")
        // var localUserInfo: [AnyHashable : Any] = [:]
        // localUserInfo["pushType"] = "restart"
        
        let content = UNMutableNotificationContent()
        content.title = "메뉴얼 가져오기가 완료되었습니다👏"
        content.body = "터치해 앱을 다시 실행해주세요"
        // content.sound = UNNotificationSound.default
        // content.userInfo = localUserInfo
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request) { error in
            print("ProfileRestore :: error? = \(error)")
        }
        
        presenter.exitWithAnimation()
    }
}
