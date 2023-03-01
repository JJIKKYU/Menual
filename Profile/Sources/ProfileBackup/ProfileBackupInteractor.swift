//
//  ProfileBackupInteractor.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import RxSwift
import ZipArchive
import MenualRepository
import RealmSwift
import MenualEntity

public protocol ProfileBackupRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol ProfileBackupPresentable: Presentable {
    var listener: ProfileBackupPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func showShareSheet(path: String)
    func configueBackupHistoryUI()
}

public protocol ProfileBackupListener: AnyObject {
    func pressedProfileBackupBackBtn(isOnlyDetach: Bool)
}

protocol ProfileBackupInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var backupRestoreRepository: BackupRestoreRepository { get }
}

final class ProfileBackupInteractor: PresentableInteractor<ProfileBackupPresentable>, ProfileBackupInteractable, ProfileBackupPresentableListener {

    weak var router: ProfileBackupRouting?
    weak var listener: ProfileBackupListener?
    private let dependency: ProfileBackupInteractorDependency
    internal var backupHistoryModelRealm: BackupHistoryModelRealm?
    
    /// backupHistory Noti
    var notificationToken: NotificationToken?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: ProfileBackupPresentable,
        dependency: ProfileBackupInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        guard let realm = Realm.safeInit() else { return }
        notificationToken = realm.objects(BackupHistoryModelRealm.self)
            .observe { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .initial(let model):
                    guard let model = model
                        .toArray(type: BackupHistoryModelRealm.self)
                        .first
                    else { return }
                    self.backupHistoryModelRealm = model
                    print("ProfileBack :: model = \(model)")
                    self.presenter.configueBackupHistoryUI()
                    break

                case .update(let model, _, _, _):
                    guard let model = model
                        .toArray(type: BackupHistoryModelRealm.self)
                        .first else { return }
                    self.backupHistoryModelRealm = model
                    self.presenter.configueBackupHistoryUI()
                    break

                case .error(let error):
                    print("ProfileBack :: error! \(error)")
                    break
                }
            }
    }
    
    func checkIsBackupEnabled() -> Bool {
        guard let realm = Realm.safeInit() else { return false }
        let diaryCount = realm.objects(DiaryModelRealm.self).count
        return diaryCount == 0 ? false : true
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func tempZipPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(Date().toString())_Menual_Backup.zip"
        return path
    }
    
    func saveZip() {
        print("ProfileBackup :: saveZip!")
        /// 먼저 json파일을 백업 함
        let dataArr: [Data] = dependency.backupRestoreRepository.backUp()
        print("ProfileBackup :: dataArr = \(dataArr)")
        
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        var filePaths: [String] = []
        var fileElements: [String] = []
        var folderPaths: [String] = []
        let enumerator = FileManager.default.enumerator(atPath: path.first!)
        // Documents폴더를 돌면서 파일의 절대값과, 업로드하고자 하는 상대값을 두 Array에 담아서 저장
        // 폴더는 미리 생성하기 위해서 저장
        print("DiaryRepo :: 파일 while 시작!")
        while let element = enumerator?.nextObject() as? String {
            // Realm은 저장하지 않고, 이미지 파일만 저장하도록
            if element.contains("default") {
                continue
            }

            if let fType = enumerator?.fileAttributes?[FileAttributeKey.type] as? FileAttributeType {
                switch fType {
                case .typeRegular:
                    filePaths.append(path.first! + "/" + element)
                    fileElements.append(element)
                case .typeDirectory:
                    folderPaths.append(element)
                default:
                    break
                }
            }
        }

        print("DiaryRepo :: 압축시작!")
        let savePath: String = tempZipPath()
        let zip = SSZipArchive.init(path: savePath)
        zip.open()
        for path in folderPaths {
            zip.writeFolder(atPath: savePath, withFolderName: path, withPassword: nil)
        }

        for (index, file) in filePaths.enumerated() {
            zip.writeFile(atPath: file, withFileName: fileElements[index], withPassword: nil)
        }
        zip.close()

        presenter.showShareSheet(path: savePath)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.pressedProfileBackupBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func addOrUpdateBackupHistory() {
        print("ProfileBackup :: interactor -> addOrUpdateBackupHistory")
        // backupHistory가 이미 있을 경우
        dependency.backupRestoreRepository.addOrUpdateBackupHistory()
        
    }
}
