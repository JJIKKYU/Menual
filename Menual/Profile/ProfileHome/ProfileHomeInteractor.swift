//
//  ProfileHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import RxSwift
import RxRelay
import CloudKit
import RealmSwift

protocol ProfileHomeRouting: ViewableRouting {
    func attachProfilePassword()
    func detachProfilePassword(isOnlyDetach: Bool)
    
    func attachProfileDeveloper()
    func detachProfileDeveloper(isOnlyDetach: Bool)
    
    func attachProfileOpensource()
    func detachProfileOpensource(isOnlyDetach: Bool)
}

protocol ProfileHomePresentable: Presentable {
    var listener: ProfileHomePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol ProfileHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func profileHomePressedBackBtn(isOnlyDetach: Bool)
}

protocol ProfileHomeInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class ProfileHomeInteractor: PresentableInteractor<ProfileHomePresentable>, ProfileHomeInteractable, ProfileHomePresentableListener {

    var isEnabledPasswordRelay: BehaviorRelay<Bool>
    
    var profileHomeDataArr_Setting1: [ProfileHomeModel] {
        let arr: [ProfileHomeModel] = [
            ProfileHomeModel(section: .SETTING1, type: .arrow, title: "메뉴얼 가이드 보기"),
            ProfileHomeModel(section: .SETTING1, type: .toggle, title: "비밀번호 설정하기"),
            ProfileHomeModel(section: .SETTING1, type: .arrow, title: "비밀번호 변경하기"),
        ]

        return arr
    }
    
    var profileHomeDataArr_Setting2: [ProfileHomeModel] {
        let arr: [ProfileHomeModel] = [
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "iCloud 동기화하기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "메뉴얼 백업하기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "메뉴얼 내보내기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "개발자에게 문의하기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "오픈 소스 라이브러리 보기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "개발자 도구"),
        ]

        return arr
    }
    
    weak var router: ProfileHomeRouting?
    weak var listener: ProfileHomeListener?
    private let disposeBag = DisposeBag()
    private let dependency: ProfileHomeInteractorDependency

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: ProfileHomePresentable,
        dependency: ProfileHomeInteractorDependency
    ) {
        self.isEnabledPasswordRelay = BehaviorRelay<Bool>(value: false)
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
        setEnabledPassword()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    // VC에서 뒤로가기 버튼을 눌렀을경우
    func pressedBackBtn(isOnlyDetach: Bool) {
        // detach 하기 위해서 부모에게 넘겨줌
        listener?.profileHomePressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func bind() {
        dependency.diaryRepository
            .password
            .subscribe(onNext: { [weak self] passwordModel in
                guard let self = self else { return }
                let isEnabled: Bool = passwordModel?.isEnabled ?? false
                self.isEnabledPasswordRelay.accept(isEnabled)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - ProfilePassword
    func setEnabledPassword() {
        var isEnabledPassword: Bool = false
        if let passwordModel = dependency.diaryRepository.password.value {
            isEnabledPassword = passwordModel.isEnabled
        }
        isEnabledPasswordRelay.accept(isEnabledPassword)
    }

    func profilePasswordPressedBackBtn(isOnlyDetach: Bool) {
        print("ProfileHome :: profilePasswordPressedBackBtn")
        router?.detachProfilePassword(isOnlyDetach: isOnlyDetach)
    }

    func pressedProfilePasswordCell() {
        print("ProfileHome :: pressedProfilePasswordCell")
        // 비밀번호 설정을 안했으면 설정할 수 있도록 설정창 띄우기
        if isEnabledPasswordRelay.value == false {
            router?.attachProfilePassword()
        }
        // 비밀번호 설정 했으면 비밀번호 설정 Disabled로 변경
        else {
            guard let model = dependency.diaryRepository.password.value else { return }

            let newModel = PasswordModel(uuid: model.uuid,
                                         password: model.password,
                                         isEnabled: false
            )

            dependency.diaryRepository
                .updatePassword(model: newModel)
        }
    }
    
    // MARK: - ProfileDeveloper (개발자 도구)
    func profileDeveloperPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileDeveloper(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedProfileDeveloperCell() {
        router?.attachProfileDeveloper()
    }
    
    // MARK: - ProfileOpensource (오픈 소스 라이브러리 보기)
    func profileOpensourcePressedBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileOpensource(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedProfileOpensourceCell() {
        router?.attachProfileOpensource()
    }
    
    func goDiaryHome() { }
    
    // MARK: - iCloud 동기화하기
    func saveiCloud() {
        if(isCloudEnabled() == false)
       {
           // self.iCloudSetupNotAvailable()
           return
       }

       let fileManager = FileManager.default

       // self.checkForExistingDir()

       let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents", isDirectory: true)

       let iCloudDocumentToCheckURL = iCloudDocumentsURL?.appendingPathComponent("default.realm", isDirectory: false)

       let realmArchiveURL = iCloudDocumentToCheckURL//containerURL?.appendingPathComponent("MyArchivedRealm.realm")

       if(fileManager.fileExists(atPath: realmArchiveURL?.path ?? ""))
       {
           do
           {
               try fileManager.removeItem(at: realmArchiveURL!)
               print("REPLACE")
               let realm = try! Realm()
               try! realm.writeCopy(toFile: realmArchiveURL!)

           }catch
           {
               print("ERR")
           }
       }
       else
       {
           print("Need to store ")
           let realm = try! Realm()
           try! realm.writeCopy(toFile: realmArchiveURL!)
       }
    }
    
    // Return true if iCloud is enabled
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }
}

struct DocumentsDirectory {
    static let localDocumentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
    static let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
}

/*
class CloudDataManager {

static let sharedInstance = CloudDataManager() // Singleton

// Return the Document directory (Cloud OR Local)
// To do in a background thread

func getDocumentDiretoryURL() -> NSURL {
    print(DocumentsDirectory.iCloudDocumentsURL)
    print(DocumentsDirectory.localDocumentsURL)
    if userDefault.boolForKey("useCloud") && isCloudEnabled()  {
        return DocumentsDirectory.iCloudDocumentsURL! as NSURL
    } else {
        return DocumentsDirectory.localDocumentsURL! as NSURL
    }
}

// Return true if iCloud is enabled

func isCloudEnabled() -> Bool {
    if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
    else { return false }
}

// Delete All files at URL

func deleteFilesInDirectory(url: NSURL?) {
    let fileManager = NSFileManager.defaultManager()
    let enumerator = fileManager.enumeratorAtPath(url!.path!)
    while let file = enumerator?.nextObject() as? String {

        do {
            try fileManager.removeItemAtURL(url!.URLByAppendingPathComponent(file))
            print("Files deleted")
        } catch let error as NSError {
            print("Failed deleting files : \(error)")
        }
    }
}

// Move local files to iCloud
// iCloud will be cleared before any operation
// No data merging

func moveFileToCloud() {
    if isCloudEnabled() {
        deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear destination
        let fileManager = NSFileManager.defaultManager
        let enumerator = fileManager.enumeratorAtPath(DocumentsDirectory.localDocumentsURL!.path!)
        while let file = enumerator?.nextObject() as? String {

            do {
                try fileManager.setUbiquitous(true,
                    itemAtURL: DocumentsDirectory.localDocumentsURL!.URLByAppendingPathComponent(file),
                    destinationURL: DocumentsDirectory.iCloudDocumentsURL!.URLByAppendingPathComponent(file))
                print("Moved to iCloud")
            } catch let error as NSError {
                print("Failed to move file to Cloud : \(error)")
            }
        }
    }
}

// Move iCloud files to local directory
// Local dir will be cleared
// No data merging

func moveFileToLocal() {
    if isCloudEnabled() {
        deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL!)
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path!)
        while let file = enumerator?.nextObject() as? String {

            do {
                try fileManager.setUbiquitous(false,
                    itemAtURL: DocumentsDirectory.iCloudDocumentsURL!.URLByAppendingPathComponent(file),
                    destinationURL: DocumentsDirectory.localDocumentsURL!.URLByAppendingPathComponent(file))
                print("Moved to local dir")
            } catch let error as NSError {
                print("Failed to move file to local dir : \(error)")
            }
        }
    }
}



}
*/
