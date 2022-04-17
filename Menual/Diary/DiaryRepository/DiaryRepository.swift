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
    var realmDiaryOb: Observable<[DiaryModel]> { get }
    // func addDiary(info: DiaryModel) throws -> Observable<DiaryModel>
    func fetch()
    func addDiary(info: DiaryModel)
    func saveImageToDocumentDirectory(imageName: String, image: UIImage)
    func loadImageFromDocumentDirectory(imageName: String) -> UIImage?
}

public final class DiaryRepositoryImp: DiaryRepository {
    

    public var realmDiaryOb: Observable<[DiaryModel]> {
        let realm = try! Realm()

        let result = realm.objects(DiaryModelRealm.self)
        let ob = Observable.array(from: result)
            .map { diaryArr -> [DiaryModel] in
                var arr: [DiaryModel] = []
                for diary in diaryArr {
                    let diaryModel = DiaryModel(uuid: diary.uuid,
                                                title: diary.title,
                                                weather: diary.weather ?? .none,
                                                location: diary.location,
                                                description: diary.desc,
                                                image: diary.image,
                                                readCount: diary.readCount
                    )
                    arr.append(diaryModel)
                }
                return arr
            }
        return ob
    }

    public var diaryString: BehaviorRelay<[DiaryModel]> { diaryModelSubject }
    public let diaryModelSubject = BehaviorRelay<[DiaryModel]>(value: [])
    
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
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let result = realm.objects(DiaryModelRealm.self)
        print("result = \(result)")
        
        diaryModelSubject.accept(result.map { DiaryModel($0) })

    }
    
    public func addDiary(info: DiaryModel) {
        // 1. 추가할 Diary를 info로 받는다
        // 2. Realm에다가 새로운 Diary를 add 한다.
        // 3. add한 diary를 담고 있는 Realm의 Observable를 반환한다.
        
        print("addDiary!")
        // Realm에서 DiaryModelRealm Array를 받아온다.
        guard let realm = Realm.safeInit() else {
            return
        }
        
        let _ = realm.objects(DiaryModelRealm.self)
        
        realm.safeWrite {
            realm.add(DiaryModelRealm(info))
        }
        
        diaryModelSubject.accept(diaryModelSubject.value + [info])
    }
}
