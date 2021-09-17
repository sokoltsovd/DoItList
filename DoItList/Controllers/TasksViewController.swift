//
//  TasksViewController.swift
//  DoItList
//
//  Created by Dmitry Sokoltsov on 06.09.2021.
//

import UIKit
import Firebase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: AppUsers!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    @IBOutlet weak var tableViuw: UITableView!
    
    override func viewDidLoad() {
        guard let currentUser = Auth.auth().currentUser else { return }
        user = AppUsers(user: currentUser)
        ref = Database.database(url: "https://doitlist-d7339-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: "users").child(String(user.uid)).child("tasks")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { [weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableViuw.reloadData()
        })
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.completed
        cell.textLabel?.text = taskTitle
        toggleCompletion(cell, isCompleted: isCompleted)

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed": isCompleted])
    }
    
    func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    @IBAction func AddTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "New Tsk", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField()
        
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard  let textFiled = alertController.textFields?.first, textFiled.text != "" else { return }
            let task = Task(title: textFiled.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(save)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)

    }
    
    @IBAction func SignOutTapped(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
        
    }
}
