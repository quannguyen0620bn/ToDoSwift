//
//  ViewController.swift
//  ToDo
//
//  Created by Quan on 08/07/2021.
//

import UIKit
import Firebase

class ToDoListViewController: UITableViewController {
    let db = Firestore.firestore()
    var itemArray = [Item]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItem()
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
                        if let title = data["Remind"] as? String,let check = data["Checked"] as? Bool {
                            let newItem = Item(title: title, checked: check)
                            self.itemArray.append(newItem)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.itemArray.count - 1 , section: 0)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.checked ? .checkmark : .none
        return cell
    }
    
//Mark :TableView Delegate method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
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
        let userData = db.collection("ItemToDo").addDocument(data:
        ["Remind":item,
         "Timesended":Date().timeIntervalSince1970,
         "Checked":false]
        )
    }
}
    




