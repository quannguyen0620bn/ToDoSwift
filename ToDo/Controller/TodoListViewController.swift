//
//  ViewController.swift
//  ToDo
//
//  Created by Quan on 08/07/2021.
//

import UIKit
import Firebase
import SwipeCellKit

class ToDoListViewController: UITableViewController,UISearchBarDelegate{
    let db = Firestore.firestore()
    var itemArray = [Item]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        loadItem()
        tableView.rowHeight = 80.0
        
    }
    
    func loadItem(){
        if let userEmail = Auth.auth().currentUser?.email{
            db.collection("ItemToDo").order(by: "Timesended").whereField("ToDoSender", isEqualTo:userEmail).addSnapshotListener { (querySnapshot, err) in
                self.itemArray = []
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let title = data["Remind"] as? String,let check = data["Checked"] as? Bool,let id = data["id"] as? String {
                                let newItem = Item(title: title, checked: check, id: id)
                                self.itemArray.append(newItem)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.itemArray.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.checked ? .checkmark : .none
        return cell
    }
    
    //Mark :TableView Delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newData = db.collection("ItemToDo").document(itemArray[indexPath.row ].id)
        if itemArray[indexPath.row].checked == true{
            newData.updateData(["Checked":false])
        }else{
            newData.updateData(["Checked":true])
        }
        self.tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Thêm Item?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Thêm Item", style: .default) { (action) in
            if let item = textField.text{
                self.addItem(item)
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Viết Lời Nhắc"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func addItem(_ item:String){
        if let sender = Auth.auth().currentUser?.email{
            let ref = db.collection("ItemToDo").addDocument(data:
                                                                ["Remind":item,
                                                                 "Timesended":Date().timeIntervalSince1970,
                                                                 "Checked":false,
                                                                 "ToDoSender" :sender
                                                                ])
            let newData = db.collection("ItemToDo").document("\(ref.documentID)")
            newData.updateData(["id" : ref.documentID])
        }
        
    }
    
    func deleteItem(_ id:String)  {
        db.collection("ItemToDo").document(id).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        if itemArray.count == 0{
            itemArray = []
        }
    }
    
    func modify(_ index:Int,_ text:String){
        let newData = db.collection("ItemToDo").document(itemArray[index].id)
        newData.updateData(["Remind":text])
        self.tableView.reloadData()
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let userEmail = Auth.auth().currentUser?.email{
            db.collection("ItemToDo").whereField("Remind", isEqualTo:searchBar.text! ).whereField("ToDoSender", isEqualTo:userEmail).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.itemArray = []
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        let data = document.data()
                        if let title = data["Remind"] as? String,let check = data["Checked"] as? Bool,let id = data["id"] as? String {
                            let newItem = Item(title: title, checked: check, id: id)
                            self.itemArray.append(newItem)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.itemArray.count-1  , section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItem()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            
        }
    }
}

//MARK: - SwipeCellDelegate

extension ToDoListViewController:SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Xoá") { action, indexPath in
            
            self.deleteItem(self.itemArray[indexPath.row].id)
            if indexPath.row  == 0{
                self.itemArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .right)
                tableView.endEditing(true)
            }
            
        }
        let flag = SwipeAction(style: .default, title: "Sửa"){action, indexPath in
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Sửa Item?", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Sửa Item", style: .default) { (action) in
                if let item = textField.text{
                    self.modify(indexPath.row,item)
                }
            }
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Viết lại Lời Nhắc"
                textField = alertTextField
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        flag.hidesWhenSelected = true
        
        
        
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "Trash-icon")
        flag.image = UIImage(named:"Flag-icon")
        return [deleteAction,flag]
    }
}



