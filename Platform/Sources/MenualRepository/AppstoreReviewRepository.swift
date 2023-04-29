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
    /// 1. 리뷰 요청 트리거에 해당하는 지 확인한다 (메뉴얼, 겹쓰기 개수)
    /// 2. 이미 리뷰 요청에 응답한 결과가 있는지 확인한다 (Date가 nil이 아니면 응답하지 않은 것)
    /// 3. 응답하지 않았다면 요청
    public func needReviewPopup() -> Bool {
        guard let realm = Realm.safeInit() else { return false }
        
        // 기본적으로 리뷰는 필요하지 않다고 판단하고 로직 진행
        var needReview: Bool = false

        // 메뉴얼이 5개, 10개, 20개일 경우를 체크하기 위해
        let checkCountArr: [Int] = [5, 10, 20]
        
        // 삭제되지 않은 메뉴얼 개수
        let diaryCount: Int = realm.objects(DiaryModelRealm.self)
            .filter ({ $0.isDeleted == false })
            .count
        
        // 삭제되지 않은 겹쓰기 개수
        let replyCount: Int = realm.objects(DiaryReplyModelRealm.self)
            .filter ({ $0.isDeleted == false })
            .count
        
        print("AppstoreReviewRepository :: diaryCount = \(diaryCount), replyCount = \(replyCount)")
        
        // 5개, 10개, 20개에 포함되는 경우
        // 일단 리뷰가 필요하다고 판단
        if checkCountArr.contains(diaryCount) || checkCountArr.contains(replyCount) {
            needReview = true
        }
        
        // 리뷰가 필요하지 않은 경우 (트리거에 해당하지 않는 경우)
        // return false
        if !needReview { return false }
        
        // 유저가 이전에 이미 리뷰를 작성했거나 거절했을 경우 2차 판단을 위해 realm 가져옴
        guard let reviewModelRealm: ReviewModelRealm = realm.objects(ReviewModelRealm.self).first else { return false }
        
        // reviewModelRealm에서 createAt이 nil일 경우에는 리뷰 요청 가능하므로 true리턴
        guard let date = reviewModelRealm.createdAt else { return true }
        
        // 리뷰에 응답한 결과가 있을 경우
        
        // 24시간 이내일 경우에는 return false
        if !hasPast24Hours(from: date) {
            return false
        }
        
        // 리뷰 요청을 했지만 24시간이 지난 경우
        
        // 리뷰 작성을 했으면 다시 요청하지 않음
        if reviewModelRealm.isApproved { return false }
        
        // 리뷰 요청을 받았지만, 24시간이 지나고, 거절한 유저는 한 번 더 요청
        return true
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

// MARK: - AppstoreReviewRepository에서 사용하는 Util 함수

extension AppstoreReviewRepositoryImp {
    /// 입력값과 비교해 24시간이 지났으면 true를 리턴하는 함수
    func hasPast24Hours(from date: Date) -> Bool {
        // 입력된 날짜와 현재 시간의 차이 계산
        let timeInterval = Date().timeIntervalSince(date)
        // 차이가 24시간 이내인 경우 true 반환
        return timeInterval > 24 * 60 * 60
    }
}
