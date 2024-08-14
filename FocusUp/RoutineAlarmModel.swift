//
//  RoutineAlarmModel.swift
//  FocusUp
//
//  Created by 김서윤 on 8/14/24.
//

import Foundation
import UIKit
import UserNotifications
import Alamofire

class SetupRoutineAlarms {
    // API 호출 및 루틴 알람 설정 함수
    static func setupRoutineAlarms() {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        APIClient.getRequest(endpoint: "/api/routine/user/all", token: token) { (result: Result<RoutineResponse, AFError>) in
            switch result {
            case .success(let response):
                if response.isSuccess {
                    for routine in response.result.routines {
                        for specRoutine in routine.specRoutine {
                            if let date = SetupRoutineAlarms.combineDateAndTime(dateStr: specRoutine.date, timeStr: specRoutine.startTime) {
                                SetupRoutineAlarms.scheduleNotification(for: routine.id, name: routine.name, at: date)
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch routines: \(error.localizedDescription)")
            }
        }
    }
    
    // 날짜와 시간을 결합하여 Date 객체 생성하는 함수
    static func combineDateAndTime(dateStr: String, timeStr: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.date(from: "\(dateStr) \(timeStr)")
    }
    
    // 알람 설정 함수
    static func scheduleNotification(for id: Int, name: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "루틴 실행할 시간이에요! ⏰️"
        content.body = "< \(name) >"
        content.sound = .default
        content.userInfo = ["alarmID": id, "name": name, "startTime": date, "targetScene": "Alarm"]

        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알람 설정 오류: \(error.localizedDescription)")
            }
        }
    }
}

struct RoutineResponse: Decodable {
    let isSuccess: Bool
    let message: String
    let result: RoutineResult
}

struct RoutineResult: Decodable {
    let routines: [Routine]
}

struct Routine: Decodable {
    let id: Int
    let name: String
    let specRoutine: [SpecRoutine]
}

struct SpecRoutine: Decodable {
    let id: Int
    let date: String
    let startTime: String
}
