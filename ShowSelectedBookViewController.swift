//
//  ShowSelectedBookViewController.swift
//
//  The table view controller responsible for displaying detailed information about a single book.
//  It also allows the user to edit information about a book, and supports undo for editing operations.
//  When editing begins, the controller creates and set an undo manager to track edits.
//  It then registers as an observer of undo manager change notifications,
//  so that if an undo or redo operation is performed, the table view can be reloaded.
//  When editing ends, the controller de-registers from the notification center and removes the undo manager
//
//  Created by Mikhail Zoline on 11/24/18.
//  Copyright © 2018 MZ. All rights reserved.
//

import UIKit


class ShowSelectedBookViewController: UITableViewController {

    var book: Book? = nil
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    // MARK: - ShowSelectedBookViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if( type(of: self) == type(of: ShowSelectedBookViewController()) ){
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
        self.tableView.allowsSelectionDuringEditing = true
        /*
         if the local changes behind our back,
         we need to be notified so we can update
         the date format in the table view cells
        */
        NotificationCenter.default.addObserver(self, selector:#selector(self.localeChanged), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSLocale.currentLocaleDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated )
        self.updateInterface()
        self.updateRightBarButtonItemState()
    }
    
    // Override to support editing the table view.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Hide the back button when editing starts, and show it again when editing finishes.
        self.navigationItem.setHidesBackButton(editing, animated: animated)
        /*
         When editing starts, create and set an undo manager to track edits.
         Then register as an observer of undo manager change notifications,
         so that if an undo or redo operation is performed, the table view can be reloaded.
         When editing ends, de-register from the notification center
         and remove the undo manager then save the changes.
         */
        if (editing) {
            self.setUpUndoManager()
        }
        else {
            self.cleanUpUndoManager()
            // Save the changes.
            do{
                try self.book?.managedObjectContext?.save()
            }
            catch {
                /*
                 fatalError() causes the application to generate a crash log and terminate.
                 It may be useful during development.
                 */
                fatalError("Failed to save after editing: \(error)")
            }
            
        }
    }
    
    func updateInterface() {
        self.authorLabel.text = self.book?.author
        self.titleLabel.text = self.book?.title
        self.copyrightLabel.text = self.dateFormatter.string(from: self.book!.copyright != nil ? self.book!.copyright! : Date())
    }
    
    func updateRightBarButtonItemState() {
        /*
         Conditionally enable the right bar button item
         it should only be enabled if the book is in a valid state for saving.
         */
        self.navigationItem.rightBarButtonItem?.isEnabled = self.book!.isValid
       
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        // Only allow selection if editing.
        if (self.isEditing) {
            return indexPath;
        }
        return nil
    }
    
    /*
     Manage row selection: If a row is selected,
     create a new editing view controller to edit the property associated with the selected row.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.isEditing) {
            self.performSegue(withIdentifier: "EditSelectedItem", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Undo support
    
    func setUpUndoManager() {
        /*
         If the book's managed object context doesn't already have an undo manager,
         then create one and set it for the context and self.
         The view controller needs to keep a reference to the undo manager it creates
         so that it can determine whether to remove the undo manager when editing finishes.
         */
        if (self.book!.managedObjectContext!.undoManager == nil) {
            let anUndoManager: UndoManager = UndoManager()
            anUndoManager.levelsOfUndo = 3
            self.book!.managedObjectContext!.undoManager = anUndoManager
        }
        
        // Register as an observer of the book's context's undo manager.
        let bookUndoManager = self.undoManager
        let dnc: NotificationCenter = NotificationCenter.default
        dnc.addObserver(self, selector:#selector(undoManagerDidUndo), name:
            .NSUndoManagerDidUndoChange, object: bookUndoManager)
        dnc.addObserver(self, selector:#selector(undoManagerDidRedo), name:
            .NSUndoManagerDidRedoChange, object: bookUndoManager)
    }
    
    func cleanUpUndoManager() {
        // Remove self as an observer.
        let bookUndoManager = self.undoManager
        
        NotificationCenter.default.removeObserver(self, name: .NSUndoManagerDidUndoChange, object: bookUndoManager)
        NotificationCenter.default.removeObserver(self, name: .NSUndoManagerDidRedoChange, object: bookUndoManager)
        
        self.book!.managedObjectContext!.undoManager = nil
    }
    
    
    override var undoManager: UndoManager? {
        
        return (self.book!.managedObjectContext!.undoManager)
    }
    
    @objc func undoManagerDidUndo(notification: Notification ) {
        // Redisplay the data.
        self.updateInterface()
        self.updateRightBarButtonItemState()
    }
    
    @objc func undoManagerDidRedo(notification: Notification) {
        // Redisplay the data.
        self.updateInterface()
        self.updateRightBarButtonItemState()
    }

    
    /*
     The view controller must be first responder in order to be able to receive shake events for undo.
     It should resign first responder status when it disappears.
     */
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resignFirstResponder
    }
    
    // MARK: - Date Formatter
    
    static var formatter: DateFormatter? = nil
    
    var dateFormatter: DateFormatter = { () -> DateFormatter in
        if (formatter == nil) {
            formatter = DateFormatter()
            formatter?.locale = Locale(identifier: "US_en")
            formatter?.dateStyle = .medium
            formatter?.timeStyle = .none
        }
        return formatter!
    }()

    // MARK: - Segue management
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "EditSelectedItem") {
            
            let controller: EditingViewController = segue.destination as! EditingViewController
            let indexPath: IndexPath = self.tableView!.indexPathForSelectedRow!
            
            controller.editedObject = self.book
            switch indexPath.row {
                
            case 0:
                controller.editedFieldKey = "title"
                controller.editedFieldName = NSLocalizedString("title", comment:"display name for title")
                
            case 1:
                controller.editedFieldKey = "author"
                controller.editedFieldName = NSLocalizedString("author", comment:"display name for author")
                
            case 2:
                controller.editedFieldKey = "copyright"
                controller.editedFieldName = NSLocalizedString("copyright", comment:"display name for copyright")
                
            default:
                break
                
            }
        }
    }
    
    // MARK:  - Locale changes
    
@objc func localeChanged( notif: NSNotification)
    {
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
        self.updateInterface()
    }
}
