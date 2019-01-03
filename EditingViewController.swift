//
//  EditingViewController.swift
/*
 The table view controller responsible for editing a field of data, either text or a date.
*/
//  Created by Mikhail Zoline on 12/29/18.
//  Copyright © 2018 MZ. All rights reserved.
//

import UIKit
import CoreData

class EditingViewController: UIViewController {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var textField: UITextField!
    
    var editedObject: NSManagedObject?
    var editedFieldKey: String?
    var editedFieldName: String?
    var hasDeterminedWhetherEditingDate: Bool = false
    var editingDate: Bool = false
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title to the user-visible name of the field.
        self.title = self.editedFieldName;
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        
        // Configure the user interface according to state.
        if (self.isEditingDate == true) {
            
            self.textField.isHidden = true
            self.datePicker.isHidden = false
            if let date : Date = self.editedObject!.value(forKey : self.editedFieldKey!) as? Date {
                self.datePicker.date = date;
            }
            else {
                self.datePicker.date =  Date()
            }
        }
        else {
            
            self.textField.isHidden = false
            self.datePicker.isHidden = true
            self.textField.text = self.editedObject!.value(forKey : self.editedFieldKey!) as? String
            self.textField.placeholder = self.title
            self.textField.becomeFirstResponder()
        }
    }
    
    // MARK: - Save and cancel operations
    
    @IBAction func save(_ sender: Any) {
        
        // Set the action name for the undo operation.
        let undoManager: UndoManager = (self.editedObject?.managedObjectContext?.undoManager)!
        
        undoManager.setActionName(self.editedFieldName!)
        
        // Pass current value to the edited object, then pop.
        if (self.editingDate == true) {
            self.editedObject?.setValue(self.datePicker.date, forKey: self.editedFieldKey!)
        }
        else {
            self.editedObject?.setValue(self.textField.text, forKey: self.editedFieldKey!)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Manage whether editing a date
    
    func setEditedFieldKey(editedFieldKey: String){
        
        if (self.editedFieldKey != editedFieldKey) {
            
            self.hasDeterminedWhetherEditingDate = false
            self.editedFieldKey = editedFieldKey
        }
    }
    
    var isEditingDate: Bool{
        
        if (self.hasDeterminedWhetherEditingDate == true) {
            return self.editingDate
        }
        
        let entity: NSEntityDescription = (self.editedObject?.entity)!
        let attribute: NSAttributeDescription = entity.attributesByName[self.editedFieldKey!]!
        let attributeClassName: String = attribute.attributeValueClassName!
        
        if (attributeClassName == "NSDate") {
            self.editingDate = true
        }
        else {
            self.editingDate = false
        }
        
        self.hasDeterminedWhetherEditingDate = true
        return self.editingDate
        
    }
}
