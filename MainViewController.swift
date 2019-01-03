//
//  MainViewController.swift
/*  The table view controller responsible for displaying the list of books,
    supporting additional functionality:
    Display detailed information about a selected book using an instance of ShowSelectedBookViewController
    Add a new book using an instance of AddNewBookViewController
    Deletion of existing books using UITableView's tableView:commitEditingStyle:forRowAtIndexPath: method.

    The MainViewController creates and configures an instance of
    NSFetchedResultsController to manage the collection of books.
    The view controller's managed object context is supplied by the application's delegate.
    When the user adds a new book, the MainViewController creates
    a new managed object context to pass to the AddNewBookViewController
    This ensures that any changes made in the AddNewBookViewController
    do not affect the main managed object context,
    and they can be committed or discarded as a whole
 */
//  Created by Mikhail Zoline on 11/23/18.
//  Copyright © 2018 MZ. All rights reserved.
//

import UIKit
import CoreData

//MARK: -

class MainViewController: UITableViewController, NSFetchedResultsControllerDelegate, AddNewBookViewControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext?
    var rightBarButtonItem: UIBarButtonItem?
    
//MARK:  - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        do {
            try self.fetchedResultsController.performFetch()
        }
        catch{
            /*
             Replace this implementation with code to handle the error appropriately
             fatalError() causes the application to generate a crash log and terminate.
             It may be useful during development.
             */
            fatalError("/(#function): /(line)")
        }
        
    }
    
    // MARK: - Table view data source methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController.sections{
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let sectionsArr  = self.fetchedResultsController.sections{
            if sectionsArr.count > section{
                return sectionsArr[section].numberOfObjects
            }
        }
        return 0
    }
    
    // MARK - Table view delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Configure the cell...
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // Configure the cell
    func configureCell(cell: UITableViewCell?, atIndexPath indexPath: IndexPath) {
        if( cell != nil) {
            // Fetch Record
            let book: Book = self.fetchedResultsController.object(at: indexPath) as! Book
            
            // Update Cell to show the book's title
            if let title = book.value(forKey: "title") as? String {
                cell!.textLabel?.text = title
            }
        }
    }
    
    // Display the authors' names as section headings.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sections![section].name
    }
    
    // MARK - Table view editing
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // The table view should not be re-orderable.
        return false
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        if (editing) {
            self.rightBarButtonItem = self.navigationItem.rightBarButtonItem
            self.navigationItem.rightBarButtonItem = nil
        }
        else {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
            self.rightBarButtonItem = nil
        }
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
                do {
                    self.fetchedResultsController.managedObjectContext.delete( self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
                    try self.fetchedResultsController.managedObjectContext.save()
                    // Delete the row from the data source
                    // tableView.deleteRows(at: [indexPath], with: .fade)
                }
                catch{
                    /*
                     Replace this implementation with code to handle the error appropriately
                     fatalError() causes the application to generate a crash log and terminate.
                     It may be useful during development.
                     */
                    fatalError("/(#function): /(line)")
                }
            case .insert:
                do {
                    self.fetchedResultsController.managedObjectContext.insert(self.fetchedResultsController.object(at: indexPath) as! NSManagedObject)
                    try self.fetchedResultsController.managedObjectContext.save()
                    // Delete the row from the data source
                    // tableView.deleteRows(at: [indexPath], with: .fade)
                }
                catch{
                    /*
                     Replace this implementation with code to handle the error appropriately
                     fatalError() causes the application to generate a crash log and terminate.
                     It may be useful during development.
                     */
                    fatalError("/(#function): /(line)")
                }
            case .none:
                fallthrough
            default:
                break
        }

    }
    
    // MARK: - Fetched results controller
    
    /*
     Returns the fetched results controller.
     Creates and configures the controller if necessary.
     */
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let entity = NSEntityDescription.entity(forEntityName: "Book", in: self.managedObjectContext!)
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "author", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: "author", cacheName: "Root")
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    /*
     NSFetchedResultsController delegate methods to respond to additions,
     removals and so on.
     */
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // The fetch controller is about to start sending change notifications,so prepare the table view for updates.
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        
        case .update:
            self.configureCell(cell: self.tableView.cellForRow(at: indexPath!), atIndexPath: indexPath!)
            
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
            
        default:
            break
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
        self.tableView.endUpdates()
    }
 
    // MARK: - Segue management

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    if (segue.identifier == "AddBook") {
    
    /*
     The destination view controller for this segue is an
     AddNewBookViewController to manage addition of the book.
     This block creates a new managed object context
     as a child of the root view controller's context.
     It then creates a new book using the child context.
     This means that changes made to the book remain discrete from the
     application's managed object context until the book's context is saved.
     The root view controller sets itself as the delegate of the add controller
     so that it can be informed when the user has completed the add operation
     either saving or canceling, see addViewController(controller: AddNewBookViewController, didFinishWithSave: Bool)
     It's not necessary to use a second context but it illustrates a pattern that may sometimes be useful
     where you want to maintain a separate set of edits for read an write for example
     */

     guard let addViewController:
        AddNewBookViewController = (segue.destination as! UINavigationController).topViewController
            as? AddNewBookViewController else {
                /*
                 Replace this implementation with code to handle the error appropriately
                 fatalError() causes the application to generate a crash log and terminate.
                 It may be useful during development.
                 */
                fatalError("\(#function): \(#line)")
        }
        addViewController.delegate = self;
        // Create a new managed object context for the new book
        // set its parent to the fetched results controller's context.
        let addingContext: NSManagedObjectContext = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        addingContext.parent = self.fetchedResultsController.managedObjectContext
        let newBook: Book =  NSEntityDescription.insertNewObject(forEntityName: "Book", into: addingContext) as! Book
        addViewController.book = newBook;
        addViewController.managedObjectContext = addingContext;
        
    }
    
    else if (segue.identifier == "ShowSelectedBook") {
            let indexPath: IndexPath  = self.tableView.indexPathForSelectedRow!
            let selectedBook: Book = self.fetchedResultsController.object(at: indexPath) as! Book
        
            // Pass the selected book to the new view controller.
            let detailViewController: ShowSelectedBookViewController = (segue.destination as? ShowSelectedBookViewController)!
            detailViewController.book = selectedBook
        }
    }
    
    // MARK: - Add controller delegate
    
    /*
     Add controller's delegate method,
     informs the delegate that the add operation has completed,
     and indicates whether the user saved the new book.
     */
    
    func addViewController( controller: AddNewBookViewController, didFinishWithSave save: Bool) {

    if (save) {
    /*
     The new book is associated with the add controller's managed object context.
     This means that any edits that are made don't affect the application's main managed object context,
     it's a way of keeping disjoint edits in a separate scratchpad.
     Saving changes to that context, though, only push changes to the fetched results controller's context.
     To save the changes to the persistent store, you have to save the fetch results controller's context as well.
     */
        guard let addingManagedObjectContext: NSManagedObjectContext = controller.managedObjectContext
            else{
                /*
                 Replace this implementation with code to handle the error appropriately
                 fatalError() causes the application to generate a crash log and terminate.
                 It may be useful during development.
                 */
                fatalError("\(#function): \(#line)")
        }
        do{
                try addingManagedObjectContext.save()
            }
            catch{
                /*
                 Replace this implementation with code to handle the error appropriately
                 fatalError() causes the application to generate a crash log and terminate.
                 It may be useful during development.
                 */
                fatalError("\(#function): \(#line)")
            }
            do{
                try self.managedObjectContext?.save()
            }
            catch{
                /*
                 Replace this implementation with code to handle the error appropriately
                 fatalError() causes the application to generate a crash log and terminate.
                 It may be useful during development.
                 */
                fatalError("\(#function): \(#line)")
            }
        }
        
        // Dismiss the modal view to return to the main list
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
