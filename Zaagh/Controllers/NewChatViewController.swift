//
//  NewChatViewController.swift
//  Zaagh
//
//  Created by Mati Shirzad on 11/21/21.
//

import UIKit
import JGProgressHUD
class NewChatViewController: UIViewController {
    
    public var completion: (([String: String]) -> Void)?

    private let spinner = JGProgressHUD(style: .dark)
    private var usersCollection = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users"
        
        return searchBar
    }()
    
    private let noResultLabel: UILabel = {
       let label = UILabel()
        label.isHidden = true
        label.text = "No Result Found"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18, weight: .bold)
        
        return label
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = true
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissNewConversationView))
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
    }
    
    @objc private func dismissNewConversationView(){
        dismiss(animated: true, completion: nil)
    }
    
}

extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start the new conversation
        let targetUser = results[indexPath.row]
        dismiss(animated: true, completion: {[weak self] in
            self?.completion?(targetUser)
        })
    }
}

extension NewChatViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        self.spinner.show(in: view)
        self.results.removeAll()
        self.createUserCollections(quary: text)
        self.searchBar.resignFirstResponder()
    }
    
    func createUserCollections(quary: String){
        if hasFetched {
            self.filterUsers(with: quary)
        } else {
            DatabaseManager.shared.fetchAllUsers(completion: {[weak self] result in
                switch result {
                    case .success(let value):
                        self?.usersCollection = value
                        self?.hasFetched = true
                        self?.filterUsers(with: quary)
                    case .failure(let error):
                        print(error)
                }
            })
        }
    }
    
    func filterUsers(with term: String){
        guard hasFetched else { return }
        
        let results : [[String: String]] = self.usersCollection.filter({
            guard let name = $0["name"]?.lowercased(), let phone = $0["phone"] else { return false }
            
            return name.hasPrefix(term.lowercased()) || phone.hasPrefix(term)
        })
        
        self.results = results
        
//        print(self.results)
        updateUI()
    }
    
    func updateUI(){
        self.spinner.dismiss()
        
        if self.results.isEmpty {
            self.noResultLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
