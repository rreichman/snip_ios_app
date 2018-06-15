//
//  AppCoordinator.swift
//  iOSapp
//
//  Created by Carl Zeiger on 5/17/18.
//  Copyright © 2018 Ran Reichman. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Crashlytics

class AppCoordinator: Coordinator {
    let disposeBag: DisposeBag = DisposeBag()
    var childCoordinators: [Coordinator] = []
    var window: UIWindow!
    var userActivity: NSUserActivity!
    var rootController: OpeningSplashScreenViewController!
    var tabCoordinator: TabCoordinator!
    
    var openingWithAppLink = false
    var appLink: URL?
    
    init(_ window: UIWindow, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        self.window = window
        self.rootController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OpeningSplashScreenViewController") as! OpeningSplashScreenViewController
        
        if let options = launchOptions {
            let userActivityDictionary : [String : Any] = options[UIApplicationLaunchOptionsKey.userActivityDictionary] as! [String : Any]
            let userActivityKey = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"]
            let userActivity : NSUserActivity = userActivityKey as! NSUserActivity
            if let url = appLinkFromUserActivity(userActivity: userActivity) {
                if AppLinkUtils.shouldOpenLinkInApp(link: url) {
                    openingWithAppLink = true
                    appLink = url
                }
            }
        }
    }
    
    func start() {
        window.rootViewController = self.rootController
        window.makeKeyAndVisible()
        loadMainFeed()
    }
    
    func continueUserActivity(userActivity : NSUserActivity) {
        if let url = appLinkFromUserActivity(userActivity: userActivity) {
            if AppLinkUtils.shouldOpenLinkInApp(link: url) {
                guard let tab = self.tabCoordinator else { return }
                tabCoordinator.showPostFromDeepLink(url: url)
            }
        }
    }
    
    func appLinkFromUserActivity(userActivity : NSUserActivity) -> URL? {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                return url
            }
        }
        return nil
    }
    
    func loadMainFeed() {
        let realm = RealmManager.instance.getMemRealm()
        SnipRequests.instance.getMain()
            .timeout(5, scheduler: MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] (catList) in
                try! realm.write {
                    for category in catList {
                        realm.add(category, update: true)
                    }
                }
                print("Pre-loaded \(catList.count) categories")
                if let coordinator = self {
                    coordinator.onPreLoadingFinished()
                }
                
            }) { [weak self] (err) in
                print("Error on feed preload \(err)")
                if let timeoutError = err as? RxError {
                    switch timeoutError {
                    case .timeout:
                        print("Preload of feed failed")
                    default:
                        print("general RxError: \(timeoutError.localizedDescription)")
                    }
                    
                }
                Crashlytics.sharedInstance().recordError(err)
                //Continue anyway, this is just a preload
                if let coordinator = self {
                    coordinator.onPreLoadingFinished()
                }
            }
            .disposed(by: disposeBag)
    }
    
    func onPreLoadingFinished() {
        self.tabCoordinator = TabCoordinator(rootController, openWithAppLink: self.openingWithAppLink, appLinkUrl: self.appLink)
        tabCoordinator.start()
    }
    
    func handleDeepLink(userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            print("Attempting to fetch post from deep link \(url.absoluteString)")
            tabCoordinator.showPostFromDeepLink(url: url)
        }
    }
    
    // Refreshes the main feed after a specific time the app was in background
    func applicationDidBecomeActive(_ fromBackground: Bool, _ longBackground: Bool, _ fromPost: Bool) {
        if fromBackground && longBackground {
            guard let tab = tabCoordinator, let main = tab.mainFeedCoordinator else { return }
            main.refreshMainFeedAfterLongBackground()
        }
    }
    
}
