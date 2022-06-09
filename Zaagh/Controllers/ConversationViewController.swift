//
//  ViewController.swift
//  Zaagh
//
//  Created by Mati Shirzad on 11/21/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversations]()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        table.isHidden = true
        
        return table
    }()
    
    private let noConversationLabel: UILabel = {
       let label = UILabel()
        label.isHidden = true
        label.text = "No Conversation"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18, weight: .bold)
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(composeNewConversationTapped)
        )
        
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        
        validateUserLogin()
        setupTableView()
        fetchConversations()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        validateUserLogin()
//        setupTableView()
//
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    private func validateUserLogin(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    private func setupTableView(){
        tableView.isHidden = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print("inside the fetch convos")
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: {
            [weak self] results in
            switch results {
            case .success(let convs):
                guard !convs.isEmpty else {
                    return
                }
                print("inside the succss of fetchconversations")
                self?.conversations = convs
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("error in fetching convs \(error)")
            }
        })
    }
    
    @objc private func composeNewConversationTapped(){
        let vc = NewChatViewController()
        vc.completion = {[weak self] result in
//            print(result)
            self?.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        
        present(navVC, animated: true, completion: nil)
    }
    
    private func createNewConversation(result: [String: String]){
        
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        
        let vc = ChatViewController(with: email, targetName: name, id: nil)
        vc.isnewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never

        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController(with: model.targetUserEmail, targetName: model.targetName, id: model.id)
        vc.title = model.targetName
        vc.navigationItem.largeTitleDisplayMode = .never

        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
