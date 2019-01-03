
#CoreDataSwift

This demo illustrates a number of aspects of working with the Core Data framework in Swift 4.2
* Use of NSPersistentContainer to create and initalize Core Database Stack composed of ManagedObjectModel, ManagedObjectContext and PersistentStoreCoordinator
* Use of an instance of NSFetchedResultsController object to manage a collection of objects to be displayed in a table view.
* Use of a child managed object context to isolate changes during an add operation.
* Undo and redo. 

The demo presents a simple master-detail interface. The master is a list of book titles. Selecting a title navigates to the detail view for that book. The master has a navigation bar (at the top) with a "+" button on the right for creating a new book. This creates the new book and then navigates immediately to the detail view for that book. There is also an "Edit" button. This displays a "-" button next to each book. Touching the minus button shows a "Delete" button which will delete the book from the list. 

The detail view displays three fields: title, copyright date, and author. The user can navigate back to the main list by touching the "Books" button in the navigation bar. If the user taps Edit, they can modify individual fields. Until they tap Save, they can also undo up to three previous changes.
