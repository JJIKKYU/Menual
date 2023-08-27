//
//  NotificationRepository.swift
//  Menual
//
//  Created by 정진균 on 2023/07/29.
//

import Foundation
import MenualEntity
import RxRelay
import UserNotifications

// MARK: - NotificationRepository

public protocol NotificationRepository: AnyObject {
    var notificationCenter: UNUserNotificationCenter { get }
    var isEnabledNotificationRelay: BehaviorRelay<Bool> { get }
    
    func requestAuthorization() async throws -> Bool
    func setAlarm(date: Date, days: [Weekday]) async -> Bool
    func getCurrentNotifications() async -> [UNNotificationRequest]
    func getCurrentWeekdays() async -> [Weekday]
    func getCurrentNotificationTime() async -> Date?
    func removeAlarmNotification() async
    func checkAlarmIsEnabled()
}

// MARK: - NotificationRepositoryImp

public class NotificationRepositoryImp: NotificationRepository {
    public var notificationCenter: UNUserNotificationCenter = .current()
    public var isEnabledNotificationRelay: BehaviorRelay<Bool> = .init(value: false)
    private let alarmMessageModel: AlarmMessageModel = .init()
    
    public init() {
        checkAlarmIsEnabled()
    }
    
    public func requestAuthorization() async throws -> Bool {
        guard let granted: Bool = try? await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) else {
            return false
        }
        return granted
    }
    
    // 알람을 등록하는 함수
    // 알람이 정상적으로 등록 되었다면 true 리턴
    // 정상적으로 등록되지 않았을 경우 false 리턴
    public func setAlarm(date: Date, days: [Weekday]) async -> Bool {
        print("NotificationRepository :: setAlarm! = \(date), \(days)")
        guard let granted: Bool = try? await requestAuthorization() else {
            print("NotificationRepository :: 권한이 없습니다.")
            return false
        }
        if !granted { return false }
        
        let calendar: Calendar = .current
        
        // 알람을 등록하기 앞서 알람기능을 통해 등록된 모든 알람 삭제
        await removeAlarmNotification()
        
        // 발송할 알림의 content 작성
        let content: UNMutableNotificationContent = .init()
        content.title = "Menual"
        content.sound = .default
        
        // 선택한 날에 맞추어 각각 알림 등록
        for day in days {
            content.body = alarmMessageModel.getRandomMessage()
            // 등록된 알람, 삭제할 알람 체크를 위해서 userInfo 체크
            content.userInfo = [
                "weekDay": day.transformIntWeekday()
            ]

            var dateComp: DateComponents = calendar.dateComponents([.hour, .minute], from: date)
            dateComp.weekday = day.transformIntWeekday()
            dateComp.timeZone = TimeZone.current
            print("NotificationRepository :: dateComp = \(dateComp)")
            
            let identifier: String = "Alarm_\(day.rawValue)"
            
            let request: UNNotificationRequest = .init(
                identifier: identifier,
                content: content,
                trigger: UNCalendarNotificationTrigger(
                    dateMatching: dateComp,
                    repeats: true
                )
            )
            
            print("NotificationRepository :: request = \(request)")
            
            do {
                try await notificationCenter.add(request)
            } catch {
                print("NotificationRepository :: Notification Add가 정상적으로 되지 못했습니다. \(error.localizedDescription)")
                return false
            }
        }
        
        // 최종적으로 알람이 등록되어 있는지 UI 반영을 위해 Relay에 Aceept
        checkAlarmIsEnabled()
        return true
    }
    
    // 현재 등록된 Notification을 획득하는 함수
    public func getCurrentNotifications() async -> [UNNotificationRequest] {
        let notifications: [UNNotificationRequest] = await notificationCenter.pendingNotificationRequests()

        let alarmNotifications: [UNNotificationRequest] = notifications.filter { $0.identifier.contains("Alarm_") }

        print("NotificationRepository :: Notis = \(alarmNotifications)")
        return alarmNotifications
    }
    
    // 현재 등록된 Notification을 Weekday로 변환해서 리턴하는 함수
    public func getCurrentWeekdays() async -> [Weekday] {
        let currentNotifications: [UNNotificationRequest] = await getCurrentNotifications()
        let weekdays: [Weekday] = currentNotifications.compactMap { request in
            // userInfo에 저장된 weekDay를 획득
            // 그 값으로 WeekDay로 형변환
            guard let dayIntValue: Int = request.content.userInfo["weekDay"] as? Int,
                  let weekday: Weekday = Weekday.fromInt(dayIntValue)
            else { return nil }
            return weekday
        }
        return weekdays
    }
    
    // 알람 기능을 통해 등록된 알람을 모두 삭제하는 함수
    public func removeAlarmNotification() async {
        // 현재 등록된 알람의 Weekdays
        let currentNotifications: [Weekday] = await getCurrentWeekdays()
        
        // 지우고자 하는 Identifier 획득
        var willRemoveIdentifiers: [String] = []
        currentNotifications.forEach { weekday in
            let id: String = "Alarm_\(weekday.rawValue)"
            willRemoveIdentifiers.append(id)
        }
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: willRemoveIdentifiers
        )
        
        isEnabledNotificationRelay.accept(false)
    }
    
    // 알람이 등록되어 있는지 체크하는 함수
    public func checkAlarmIsEnabled() {
        Task {
            let notifications: [UNNotificationRequest] = await getCurrentNotifications()
            let isNotificationEnabled: Bool = notifications.count == 0 ? false : true
            isEnabledNotificationRelay.accept(isNotificationEnabled)
        }
    }

    // 알람이 등록되어 있을 경우 시간을 return하는 함수
    public func getCurrentNotificationTime() async -> Date? {
        let currentNotifications: [UNNotificationRequest] = await getCurrentNotifications()
        let time = currentNotifications.compactMap { request in
            if let trigger: UNCalendarNotificationTrigger = request.trigger as? UNCalendarNotificationTrigger {
                let date: Date? = trigger.nextTriggerDate()
                return date
            }
            return nil
        }.first
        return time
    }
}
