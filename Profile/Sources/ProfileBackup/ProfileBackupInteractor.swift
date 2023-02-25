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

public protocol ProfileBackupRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol ProfileBackupPresentable: Presentable {
    var listener: ProfileBackupPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func showShareSheet(path: String)
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
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func tempZipPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString).zip"
        return path
    }
    
    func saveZip() {
        print("ProfileBackup :: saveZip!")
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
}
