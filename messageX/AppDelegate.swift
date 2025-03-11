//
//  AppDelegate.swift
//  messageX
//
//  Created by М Й on 03.03.2025.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // MARK: - Запуск приложения
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Инициализация Firebase
        FirebaseApp.configure()
        
        // Настройка делегата для уведомлений
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Запрос разрешения на показ уведомлений (alert, badge, sound)
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Ошибка запроса на уведомления: \(error.localizedDescription)")
            } else {
                print("Разрешение получено: \(granted)")
                if granted {
                    // Регистрируем устройство для удалённых уведомлений в главном потоке
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
            }
        }
        return true
    }
    
    // MARK: - Обработка регистрации для удалённых уведомлений
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Преобразовываем deviceToken в строку (шестнадцатеричный формат)
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // Здесь можно отправить token на сервер или в Firebase Cloud Messaging
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Не удалось зарегистрироваться для уведомлений: \(error.localizedDescription)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate методы
    
    // Вызывается, когда приложение открыто и приходит уведомление
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
                                @escaping (UNNotificationPresentationOptions) -> Void) {
        // Показываем уведомление даже когда приложение активно
        completionHandler([.alert, .badge, .sound])
    }
    
    // Вызывается, когда пользователь нажимает на уведомление
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Пользователь нажал на уведомление: \(response.notification.request.content.userInfo)")
        // Здесь можно реализовать переход к нужному экрану, основываясь на содержимом уведомления
        completionHandler()
    }
    
    // MARK: - UISceneSession Lifecycle (если используется SceneDelegate)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Освобождаем ресурсы, связанные с удалёнными сценами, если потребуется
    }
}


