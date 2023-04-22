//
//  AppstoreReviewRepository.swift
//  
//
//  Created by 정진균 on 2023/04/09.
//

import Foundation
import RealmSwift
import MenualEntity

public protocol AppstoreReviewRepository {
    func rejectReview()
    func approveReview()
    func needReviewPopup() -> Bool
}

public class AppstoreReviewRepositoryImp: AppstoreReviewRepository {
    
    public init() {
        guard let realm = Realm.safeInit() else { return }
        if realm.objects(ReviewModelRealm.self).isEmpty {
            realm.safeWrite {
                realm.add(ReviewModelRealm())
            }
        }
    }

    /// 유저에게 리뷰 팝업을 나타내야 하는지 체크하고 Bool Return
    public func needReviewPopup() -> Bool {
        guard let realm = Realm.safeInit() else { return false }
        
        /// 메뉴얼이 5개, 10개, 20개일 경우를 체크하기 위해
        let checkCountArr: [Int] = [5, 10 , 20]
        let diaryCount: Int = realm.objects(DiaryModelRealm.self).count
        let replyCount: Int = realm.objects(DiaryReplyModelRealm.self).count
        
        print("AppstoreReviewRepository :: diaryCount = \(diaryCount), replyCount = \(replyCount)")
        
        // 5개, 10개, 20개에 포함되는 경우
        if checkCountArr.contains(diaryCount) {
            return true
        } else {
            return false
        }
        
        
    }
    
    /// 유저가 리뷰 요청을 거절했을 경우
    public func rejectReview() {
        guard let realm = Realm.safeInit(),
              let data = realm.objects(ReviewModelRealm.self).first
        else { return }

        realm.safeWrite {
            data.isRejected = true
            data.createdAt = Date()
        }
    }
    
    /// 유저가 리뷰 요청을 승인했을 경우
    public func approveReview() {
        guard let realm = Realm.safeInit(),
              let data = realm.objects(ReviewModelRealm.self).first
        else { return }

        realm.safeWrite {
            data.isApproved = true
            data.createdAt = Date()
        }
    }
}
