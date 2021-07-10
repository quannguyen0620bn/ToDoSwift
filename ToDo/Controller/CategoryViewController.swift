//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Quan on 09/07/2021.
//

import UIKit
import Firebase
class CategoryViewController: UITableViewController {
    var db = Firestore.firestore()
    var categoryArray = [Category]()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
    }
    func loadCategory(){
            db.collection("Category").order(by: "Timesended").addSnapshotListener { (querySnapshot, err) in
                self.categoryArray = []
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let Name = data["Name"] as? String{
                                let newCategory = Category(Name: Name)
                                self.categoryArray.append(newCategory)
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.categoryArray.count - 1 , section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                            }
                        }
                    }
                }
            }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"CategoryCell", for: indexPath)
        let category1 = categoryArray[indexPath.row]
        cell.textLabel?.text = category1.Name
        return cell
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Thêm Item?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Thêm Item", style: .default) { (action) in
            if let title = textField.text{
                var category = Category()
                category.Name = title
                self.db.collection("Category").addDocument(data: ["CategoryName" :title,
                                                                  "Timesended":Date().timeIntervalSince1970])
                self.categoryArray.append(category)
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Viết Lời Nhắc"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  
    tableView.deselectRow(at: indexPath, animated: true)

}
    }
 
