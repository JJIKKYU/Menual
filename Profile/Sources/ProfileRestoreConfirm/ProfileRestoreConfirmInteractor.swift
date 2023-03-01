//
//  ProfileRestoreConfirmInteractor.swift
//  Menual
//
//  Created by 정진균 on 2023/02/26.
//

import RIBs
import RxSwift
import MenualRepository
import Foundation
import ZipArchive
import RxRelay
import MenualEntity

public protocol ProfileRestoreConfirmRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol ProfileRestoreConfirmPresentable: Presentable {
    var listener: ProfileRestoreConfirmPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func notVaildZipFile()
    func loadErrorZipFile()
    func fileNameAndDateSetUI()
}

public protocol ProfileRestoreConfirmListener: AnyObject {
    func profileRestoreConfirmPressedBackBtn(isOnlyDetach: Bool)
    func profileRestoreSuccess()
}

public protocol ProfileRestoreConfirmInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var backupRestoreRepository: BackupRestoreRepository { get }
}

final class ProfileRestoreConfirmInteractor: PresentableInteractor<ProfileRestoreConfirmPresentable>, ProfileRestoreConfirmInteractable, ProfileRestoreConfirmPresentableListener {

    weak var router: ProfileRestoreConfirmRouting?
    weak var listener: ProfileRestoreConfirmListener?
    
    private let disposeBag = DisposeBag()
    private let dependency: ProfileRestoreConfirmInteractorDependency
    private let menualRestoreFileRelay = BehaviorSubject<Bool?>(value: nil)
    internal let menualRestoreProgressRelay = BehaviorRelay<CGFloat>(value: -1)
    var fileName: String?
    var fileCreatedAt: String?
    
    internal let fileURL: URL?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: ProfileRestoreConfirmPresentable,
        dependency: ProfileRestoreConfirmInteractorDependency,
        fileURL: URL?
    ) {
        self.dependency = dependency
        self.fileURL = fileURL
        super.init(presenter: presenter)
        bind()
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        if let fileURL = fileURL {
            checkIsMenualZipFile(url: fileURL)
        }
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        menualRestoreFileRelay
            .subscribe(onNext: { [weak self] isRestoreMenualFile in
                guard let self = self,
                      let isRestoreMenualFile = isRestoreMenualFile
                else { return }
                
                switch isRestoreMenualFile {
                case true:
                    print("ProfileRestore :: isRestoreMenualFile! = true")
                    // Valid한 file만 parsing
                    guard let restoreFile = self.parseJsonFile() else {
                        // 오류 핸들러 UI 표시
                        self.presenter.loadErrorZipFile()
                        return
                    }
                    print("ProfileRestore :: restoreFile = \(restoreFile.fileName), \(restoreFile.createdDate)")

                    // self.migrateMenual(restoreFile: restoreFile)

                case false:
                    self.presenter.notVaildZipFile()
                    print("ProfileRestore :: isRestoreMenualFile! = false")
                }
            })
            .disposed(by: disposeBag)
        
        menualRestoreProgressRelay
            .subscribe(onNext: { [weak self] percent in
                guard let self = self else { return }
                if percent < 0 { return }
                print("ProfileRestoreConfirm :: \(percent)")
                
                if percent == 100 {
                    self.listener?.profileRestoreSuccess()
                }
            })
            .disposed(by: disposeBag)
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
                    }
                } else {
                    if fileURL == ".DS_Store" { continue }
                    if let imageData = try? Data(contentsOf: filePath) {
                        var fileName: String = ""
                        var imageType: ImageFileType = .original
                        if fileURL.contains("Original") {
                            fileName = fileURL.replacingOccurrences(of: "Original", with: "")
                            imageType = .original
                        } else if fileURL.contains("Thumb") {
                            fileName = fileURL.replacingOccurrences(of: "Thumb", with: "")
                            imageType = .thumb
                        } else {
                            fileName = fileURL
                            imageType = .crop
                        }
                        let imageFile = ImageFile(fileName: fileName, data: imageData, type: imageType)
                        restoreFile.imageDataArr.append(imageFile)
                    }
                }
            }
        } catch {
            print("Error getting directory contents: \(error.localizedDescription)")
        }
        
        return restoreFile
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.profileRestoreConfirmPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    /// 유저가 선택한 파일이 MenualZipFile인지 체크
    ///  url - 유저의 zip file URL (zip이 아닐 수도 있음)
    func checkIsMenualZipFile(url: URL) {
        print("ProfileRestore :: checkIsMenualZipFile!")
        
        self.fileName = url.lastPathComponent
        self.fileCreatedAt = getFileCreatedAt(url: url)
        self.presenter.fileNameAndDateSetUI()

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

            self.menualRestoreFileRelay.onNext(isDiaryJson)
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
    
    func pressedRestoreBtn() {
        print("ProfileRestoreConfirm :: pressedRestoreBtn!")
        
        guard let restoreFile = self.parseJsonFile() else {
            // 오류 핸들러 UI 표시
            self.presenter.loadErrorZipFile()
            return
        }
        menualRestoreProgressRelay.accept(0)

        self.dependency.backupRestoreRepository
            .restoreWithJson(restoreFile: restoreFile,
                             progressRelay: menualRestoreProgressRelay
            )
        
        menualRestoreProgressRelay.accept(1)

    }
}
