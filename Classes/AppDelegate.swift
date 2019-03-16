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
    
    private(set) public var mom: NSManagedObjectModel?
    private(set) public var moc: NSManagedObjectContext?
    private(set) public var psc: NSPersistentStoreCoordinator?
    private(set) public var CONTAINER: Bool =  false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        /* retrieve envir variable CONTAINER,
         if CONTAINER == true, init with NSPersistentContainer
         else init with MOC
         */
        let dic = ProcessInfo.processInfo.environment
        if dic["CONTAINER"] != nil {
            CONTAINER =  true
        }
        
        // Override point for customization after application launch
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Instantiate Root Navigation Controller
        let rootNavigationController: UINavigationController? = storyboard.instantiateInitialViewController() as? UINavigationController
        self.window?.rootViewController = rootNavigationController
        // Configure View Controller
        if( rootNavigationController != nil ){
            guard let rootViewController: MasterViewController = rootNavigationController?.topViewController as? MasterViewController else{
                // fatalError() causes the application to generate a crash log and terminate.
                // It may be useful during development.
                fatalError("\(#function): \(#line)")
            }
            // NSPersistentContainer vs NSManagedObjectContext
            rootViewController.managedObjectContext = CONTAINER == true ?persistentContainer.viewContext : managedObjectContext
            
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
        if (self.mom != nil){
            return self.mom!
        }
        
        let modelURL = Bundle.main.url(forResource: "CoreData", withExtension: "momd")!
        self.mom = NSManagedObjectModel(contentsOf: modelURL)!
        return self.mom!
        
    }()
    
    /*
     Returns the managed object context for the application.
     If the context doesn't already exist,
     it is created and bound to the persistent store coordinator for the application.
     */
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        if ( CONTAINER == true ){
            return persistentContainer.viewContext
        }
        
        if (self.moc != nil){
            return self.moc!
        }
        var coordinator: NSPersistentStoreCoordinator? = self.persistentStoreCoordinator!
        if (coordinator != nil) {
            self.moc = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
            self.moc!.persistentStoreCoordinator = self.persistentStoreCoordinator
        }
        return self.moc!
    }()
    
    /*
     Returns the persistent store coordinator for the application.
     If the coordinator doesn't already exist,
     it is created and the application's store added to it.
     */

    lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator? = {
        if(CONTAINER == true){
            return persistentContainer.persistentStoreCoordinator
        }
        
        if (self.psc != nil){
            return self.psc!
        }

        // Set up the store, provide a pre-populated default store
        let storeURL = applicationDocumentsDirectory?.appendingPathComponent("CoreData.CDBStore")

        if !FileManager.default.fileExists(atPath: (storeURL?.path)!){

            if let defaultStoreURL: URL = Bundle.main.url(forResource: "CoreData", withExtension: "CDBStore"){
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
        /*
         Core Data Migrations:
         A persistent store is tied to a particular version of the data model.
         It keeps a reference to the identifier of the data model.
         If the data model changes, we need to tell Core Data how to migrate the
         data of the persistent store to the new data model version.
        */
        var autoMigrationOptions:[String: Bool] =  [ NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]

        self.psc = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
        do {
            /*
                Add persistent a store to Coordinator.
                One coordinator could posess several persistent stores.
                Each store could have only one MoM.
                So it's possible to have several MoMs for one Coordianator
            */
 
            try self.psc?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: autoMigrationOptions)
 
        }
        catch{
            /*
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.

             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}

             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             */

            fatalError("Unresolved error during Persistent Store Loading:\(String(describing: error._userInfo))")
        }

        return self.psc
    }()

    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    
    lazy var persistentContainer
        : NSPersistentContainer = {
            
            let mom = managedObjectModel
            let container =
                NSPersistentContainer(name
                    : "CoreData", managedObjectModel: mom!)
            
            // For the sake of illustration, provide a pre-populated default store
            let storeURL = applicationDocumentsDirectory?.appendingPathComponent("CoreData.CDBStore")
            
            if !FileManager.default.fileExists(
                atPath: (storeURL?.path)!){

                if let defaultStoreURL : URL =
                        Bundle.main.url(forResource
                            : "CoreData", withExtension
                            : "CDBStore"){
                    do {
                        try FileManager.default.copyItem(
                            at: defaultStoreURL, to: storeURL!)
                    } catch {
                                // fatalError() causes the application to
                                // generate a crash log and terminate.
                                // It may be useful during development.
                                fatalError("\(#function): \(#line)")}}
            }
            
            if (storeURL != nil){
                let storeDescription =
                NSPersistentStoreDescription(url: storeURL!)
                container.persistentStoreDescriptions = [storeDescription]
            }
            
            container.loadPersistentStores(
                completionHandler: { (storeDescription, error) in
                    if let error = error as NSError? {
                            /*
                             Typical reasons for an error here include:
                             * The parent directory does not exist, cannot be
                             created, or disallows writing.
                             * The persistent store is not accessible, due to
                             permissions or data protection when the device is
                             locked.
                             * The device is out of space.
                             * The store could not be migrated to the current
                             model version. Check the error message to
                             determine what the actual problem was.
                             fatalError() causes the application to generate a
                             crash log and terminate. It may be useful during
                             development.
                             */
                            fatalError("\(#function): \(#line), \(error.userInfo)")
                    }
            })
            return container
    }()
    
    /*
     Returns the URL to the application's Documents directory.
     */
    lazy var applicationDocumentsDirectory: URL? =
    {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
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

