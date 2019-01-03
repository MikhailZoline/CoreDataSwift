//
//  AppDelegate.swift
/*
 Application delegate to set up the Core Data stack
 and configure the first view and navigation controllers.
*/
//  Created by Mikhail Zoline on 11/23/18.
//  Copyright © 2018 MZ. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Instantiate Root Navigation Controller
        let rootNavigationController: UINavigationController? = storyboard.instantiateInitialViewController() as? UINavigationController
        self.window?.rootViewController = rootNavigationController
        // Configure View Controller
        if( rootNavigationController != nil ){
            guard let rootViewController: MainViewController = rootNavigationController?.topViewController as? MainViewController else{
                // fatalError() causes the application to generate a crash log and terminate.
                // It may be useful during development.
                fatalError("\(#function): \(#line)")
            }
            rootViewController.managedObjectContext = self.persistentContainer.viewContext
        }
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state.
        // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough application state information to restore your application
        // to its current state in case it is terminated later.
        // If your application supports background execution,
        // this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate.
        // Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    lazy var managedObjectModel: NSManagedObjectModel? = {

        let modelURL = Bundle.main.url(forResource: "CoreDataSwift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        
    }()
    
    /*
     Returns the managed object context for the application.
     If the context doesn't already exist,
     it is created and bound to the persistent store coordinator for the application.
     */
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        return self.persistentContainer.viewContext
    
    }()

    
    /*
     Returns the persistent store coordinator for the application.
     If the coordinator doesn't already exist,
     it is created and the application's store added to it.
     */
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        return self.persistentContainer.persistentStoreCoordinator
        
    }()

    /*
     Returns the URL to the application's Documents directory.
     */
    lazy var applicationDocumentsDirectory: URL? =
    {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }()
    
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    lazy var persistentContainer: NSPersistentContainer = {

        let mom = managedObjectModel
        let container = NSPersistentContainer(name: "CoreDataSwift", managedObjectModel: mom!)
        
        // For the sake of illustration, provide a pre-populated default store
        let storeURL = applicationDocumentsDirectory?.appendingPathComponent("CoreDataSwift.CDBStore")
        
        if !FileManager.default.fileExists(atPath: (storeURL?.path)!){
            if let defaultStoreURL: URL = Bundle.main.url(forResource: "CoreDataSwift", withExtension: "CDBStore"){
                do{
                    try FileManager.default.copyItem(at: defaultStoreURL, to: storeURL!)
                }
                catch{
                    // fatalError() causes the application to generate a crash log and terminate.
                    // It may be useful during development.
                    fatalError("\(#function): \(#line)")
                }
            }
        }
        
        if (storeURL != nil) {
            let storeDescription = NSPersistentStoreDescription(url: storeURL!)
            container.persistentStoreDescriptions = [storeDescription]
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 fatalError() causes the application to generate a crash log and terminate.
                 It may be useful during development.
                 */
                fatalError("\(#function): \(#line)")
            }

        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
       let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // fatalError() causes the application to generate a crash log and terminate,
                // it may be useful during development.
                fatalError("\(#function): \(#line)")
            }
        }
    }
}

