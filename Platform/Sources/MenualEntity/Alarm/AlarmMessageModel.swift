//
//  AlarmMessageModel.swift
//
//
//  Created by 정진균 on 2023/08/14.
//

import Foundation

public struct AlarmMessageModel {
    private var messages: [String] = [
        "오늘의 날씨도, 일기와 함께라면 특별해질 수 있어요.",
        "하루를 돌아볼 시간은 충분했나요?",
        "한 줄 한 줄 적어내면, 어느새 정리될 거예요.",
        "간단하게 적어두고, 내일 다시 정리해도 좋아요!",
        "기록하지 않으면 기억나지 않을지도 몰라요.",
        "오늘의 생각을 정리할 시간이에요.",
        "오늘을 의미있게하는 가장 쉬운 방법이 도착했어요.",
        "일년 뒤, 오늘의 일기를 본다면 참 즐거울 거예요.",
        "미래의 나에게 오늘의 이야기를 전달해보세요.",
        "특별한 하루는 기다리지 않아도 찾을 수 있어요."
    ]

    // 위 messages에서 랜덤한 message를 리턴하는 함수
    public func getRandomMessage() -> String {
        let randomIndex: Int = Int.random(in: 0 ..< messages.count)
        let message: String = messages[randomIndex]
        return message
    }
    
    public init() { }
}
