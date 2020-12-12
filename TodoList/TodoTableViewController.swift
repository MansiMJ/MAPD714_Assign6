//
//  TodoTableViewController.swift
//  Assignment 6
//
//  Created by Mansi Majethia on 2020-12-10.
//

import UIKit
import Firebase
import SwipeCellKit

//table cell class to manage table row content
class TodoTableViewCell: UITableViewCell {

    //variable declaration
    @IBOutlet var todoTaskName: UILabel!
    @IBOutlet var todoTaskStatus: UILabel!
    @IBOutlet var todoTaskSwitchButton: UISwitch!
    
}

// display table view
class TodoTableViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var ref: DatabaseReference!
    var taskCount: Int? = 0
    
    //variable declaration
    @IBOutlet var todoTable: UITableView!
    var allTodos = [TodoTask]()
    var todo:TodoTask!
    
    //load view
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI table attributes
        todoTable.delegate = self
        todoTable.dataSource = self
        self.todoTable.rowHeight = 60.0
        self.title = "Todo"
        
        // get firebase database reference
        ref = Database.database().reference()
        getDataFromFirebase()
    }   
    
    // fetech data from firebase database
    func getDataFromFirebase(){
        ref.child("todoList").observe(DataEventType.value, with: { (snapshot) in
            if let postDict = snapshot.value as? Dictionary<String, AnyObject> {
                self.allTodos = [TodoTask]()
                for item in postDict {
                    let myTodo = TodoTask(key: item.key, todo: item.value as! NSDictionary)
                    self.allTodos.append(myTodo)
                    self.todoTable.reloadData()
                }
                self.taskCount = Int(postDict.count)
            }
        })
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getDataFromFirebase()
    }
    // seguw for assign values to variables of anthor view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is TodoEditTaskViewController
        {
            let vc = segue.destination as? TodoEditTaskViewController
            if segue.identifier == "addTaskDetails" {
                
                vc?.editFlag = false
                
            }else if segue.identifier == "editTaskDetail" {
                
                vc?.editFlag = true
                vc?.todoTaskDetails = todo
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    { // update task on left to right swipe
        let edit = UIContextualAction(style: .normal, title: "Edit"){(action,view,nil) in
            let subMenuVC = self.storyboard?.instantiateViewController(identifier: "view") as? TodoEditTaskViewController
            let todo = self.allTodos[indexPath.row]
            subMenuVC?.todoTaskDetails = todo
            subMenuVC?.editFlag = true
            self.navigationController?.pushViewController(subMenuVC!, animated: true)
            print("edit")}
        edit.backgroundColor=UIColor.init(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        // delete todo task when swiped right to left
        let delete = UIContextualAction(style: .destructive, title: "Delete"){(action,view,nil) in
            let todo = self.allTodos[indexPath.row]
            self.ref.child("todoList").child(todo.uniqueId).removeValue()
            self.getDataFromFirebase()
            print("delete")}
        // mark task complete or incompletd
        let iscomplete = UIContextualAction(style: .normal, title: String(todo.isCompleted) == "true" ? "In-Completed" : "Complete"){(action,view,nil) in
            let todo = self.allTodos[indexPath.row]
            let key = self.todo.uniqueId
            let isCompletedFlag = todo.isCompleted == true ? false : true
            let dictionaryTodo = [  "name"        : self.todo.name,
                                    "description" : self.todo.taskDescription ,
                                    "dueDate"     : self.todo.dueDate,
                                    "hasDueDate"  : self.todo.hasDueDate,
                                   "isCompleted" : isCompletedFlag
            ] as [String : Any]
            self.ref.child("todoList").child(key).updateChildValues(dictionaryTodo)
            self.getDataFromFirebase()
            print("iscomplete")}
        iscomplete.backgroundColor=UIColor.init(red: 255/255, green: 216/255, blue: 0/255, alpha: 1)
        return UISwipeActionsConfiguration(actions: [delete,iscomplete])
    }
    
    
    //Tells the data source to return the number of rows in a given section of a table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taskCount!
    }
    
   
    //data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoTableCell", for: indexPath) as! TodoTableViewCell
        todo = allTodos[indexPath.row]
        cell.todoTaskName?.text = todo.name
        //cell.delegate = self
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: (cell.todoTaskName?.text)!)
        // strike task name on task completion
        if(todo.isCompleted == false){
            attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
           // cell.todoTaskSwitchButton.setOn(true, animated: true)
            cell.todoTaskName.attributedText = attributeString
        } else{
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
           // cell.todoTaskSwitchButton.setOn(false, animated: false)
            cell.todoTaskName.attributedText = attributeString
        }
        
        // change color of date on over due
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
            let date = formater.date(from: todo.dueDate) ?? Date()
            let currentDate = Date()
            if date < currentDate {
                cell.todoTaskStatus?.textColor = UIColor.red
            }
            else {
                cell.todoTaskStatus?.textColor = UIColor(red: 125/256, green: 90/256, blue: 90/256, alpha: 1.0)
            }
            cell.todoTaskStatus?.text = todo.dueDate
            
          //  cell.todoTaskSwitchButton.isEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subMenuVC = storyboard?.instantiateViewController(identifier: "view") as? TodoEditTaskViewController
        let todo = allTodos[indexPath.row]
        subMenuVC?.todoTaskDetails = todo
        subMenuVC?.editFlag = true
        self.navigationController?.pushViewController(subMenuVC!, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
