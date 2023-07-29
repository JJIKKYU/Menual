//
//  NotificationRepository.swift
//  Menual
//
//  Created by 정진균 on 2023/07/29.
//

import Foundation
import MenualEntity
import UserNotifications

public protocol NotificationRepository: AnyObject {
    func requestAuthorization() async throws -> Bool
    func setAlarm(date: Date, days: [Weekday]) async
}

public class NotificationRepositoryImp: NotificationRepository {
    public init() {
        
    }
    
    public func requestAuthorization() async throws -> Bool {
        guard let granted: Bool = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) else {
            return false
        }
        return granted
    }
    
    public func setAlarm(date: Date, days: [Weekday]) async {
        print("NotificationRepository :: setAlarm! = \(date), \(days)")
        guard let granted: Bool = try? await requestAuthorization() else {
            print("NotificationRepository :: 권한이 없습니다.")
            return
        }
        if !granted { return }
        
        let content: UNMutableNotificationContent = .init()
        content.title = "오늘 일기를 작성해볼까요?"
        content.body = "바디입니다."
        
        let calendar: Calendar = .current
        
        for day in days {
            var dateComp: DateComponents = calendar.dateComponents([.hour, .minute], from: date)
            dateComp.weekday = day.transformIntWeekday()
            
            let identifier: String = "Alarm_\(day.rawValue)"
            
            let request: UNNotificationRequest = .init(
                identifier: identifier,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: true)
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("NotificationRepository :: Notification Add가 정상적으로 되지 못했습니다. \(error.localizedDescription)")
            }
        }
    }
}
