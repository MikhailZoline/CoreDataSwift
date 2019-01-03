//
//  AddNewBookViewController.swift
//
//  The table view controller responsible managing addition of a new book to the application.
//  When editing ends, the controller sends a message to its delegate
//  (in this case, the root view controller) to tell it that it finished editing
//  and whether the user saved their changes.
//  It's up to the delegate to actually commit the changes.
//  The view controller needs a strong reference to the managed object context
//  to make sure it doesn't disappear while being used
//  (a managed object doesn't have a strong reference to its context).
//
//  Created by Mikhail Zoline on 12/28/18.
//  Copyright © 2018 MZ. All rights reserved.
//

import CoreData

@objc protocol AddNewBookViewControllerDelegate {
    func addViewController(controller: AddNewBookViewController, didFinishWithSave save: Bool)
}

class AddNewBookViewController: ShowSelectedBookViewController {

    weak var delegate: AddNewBookViewControllerDelegate?
    var managedObjectContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the undo manager and set editing state to YES.
        self.setUpUndoManager()
        self.isEditing = true
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.delegate?.addViewController(controller: self, didFinishWithSave: false)
    }
    
    @IBAction func save(_ sender: Any) {
        self.delegate?.addViewController(controller: self, didFinishWithSave: true)
    }
    
    deinit {
        self.cleanUpUndoManager()
    }

}
