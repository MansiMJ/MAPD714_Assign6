//
//  File name: ViewController.swift
//  Assignment:Todo App
//  Assignment 6
//
//  Created by Mansi Majethia on 2020-12-10.
//  Description: ViewController
//
import UIKit
import Firebase

class ViewController: UITableViewController {

    var taskCount: Int! = 0
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }

}

