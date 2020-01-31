//
//  SearchViewController.swift
//  Coordinator
//
//  Created by Emil Doychinov on 2020-01-31.
//  Copyright © 2020 Emil Doychinov. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate: class {
    func search(text: String)
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
