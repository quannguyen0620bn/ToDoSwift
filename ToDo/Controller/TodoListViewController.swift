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
        loadItem()
        tableView.rowHeight = 80.0
        
    }
    func loadItem(){
        db.collection("ItemToDo").order(by: "Timesended").addSnapshotListener { (querySnapshot, err) in
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
                                let indexPath = IndexPath(row: snapshotDocuments.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
        print(indexPath.row)
        self.tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
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
        let ref = db.collection("ItemToDo").addDocument(data:
                                                            ["Remind":item,
                                                             "Timesended":Date().timeIntervalSince1970,
                                                             "Checked":false
                                                            ])
        let newData = db.collection("ItemToDo").document("\(ref.documentID)")
        newData.updateData(["id" : ref.documentID])
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        db.collection("ItemToDo").whereField("Remind", isEqualTo:searchBar.text! ).getDocuments() { (querySnapshot, err) in
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

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            self.deleteItem(self.itemArray[indexPath.row].id)
            if indexPath.row  == 0{
                self.itemArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .right)
                tableView.endEditing(true)
            }
            
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "Trash-icon")
        return [deleteAction]
    }
}
    


