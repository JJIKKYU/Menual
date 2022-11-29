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
import SSZipArchive
import ZIPFoundation

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
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        
        
        var filePaths: [String] = []
        let enumerator = FileManager.default.enumerator(atPath: path.first!)
       while let element = enumerator?.nextObject() as? String {
           print(element)

           if let fType = enumerator?.fileAttributes?[FileAttributeKey.type] as? FileAttributeType{

               switch fType{
               case .typeRegular:
                   print("a file")
                   filePaths.append(path.first! + "/" + element)
               case .typeDirectory:
                   print("a dir")
                   filePaths.append(path.first! + "/" + element)
               default:
                   break
               }
           }

       }
        
        if let directoryPath = path.first {
//            SSZipArchive.createZipFile(atPath: tempZipPath(),
//                                       withContentsOfDirectory: directoryPath + "/",
//                                       keepParentDirectory: false
//            )
//
//            DispatchQueue.main.async {
//                SSZipArchive.createZipFile(atPath: self.tempZipPath(),
//                                           withFilesAtPaths: filePaths
//                )
//
//            }
            let tempZipPath2 = tempZipPath()
//            SSZipArchive.createZipFile(atPath: tempZipPath2,
//                                       withFilesAtPaths: filePaths,
//                                       withPassword: nil,
//                                       keepSymlinks: false
//            )
//
            let a = SSZipArchive.init(path: tempZipPath2)
            a.open()
            // a.writeFolder(atPath: tempZipPath2, withFolderName: "123", withPassword: nil)
            a.writeFolder(atPath: tempZipPath2, withFolderName: "default.realm.management", withPassword: nil)
//            SSZipArchive.createZipFile(atPath: tempZipPath()+"_2",
//                                       withContentsOfDirectory: directoryPath,
//                                       keepParentDirectory: false
//            )
            
            for file in filePaths {
                print("- \(file)")
                a.writeFile(file, withPassword: nil)
                // a.writeFile(atPath: file, withFileName: nil, withPassword: nil)
            }
            
            
            a.close()
            

        }
        
  
        
    }
    
    func tempZipPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        path += "/\(UUID().uuidString).zip"
        return path
    }
}
