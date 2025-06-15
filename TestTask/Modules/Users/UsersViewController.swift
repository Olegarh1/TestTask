//
// ViewController.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025


import UIKit

class UsersViewController: BaseViewController {
    
    private lazy var noUsersView = NoUsersView()
    
    private lazy var usersTableView = UsersTableView()
    
    private var usersData: UsersModel? {
        didSet {
            if let oldUsers = oldValue?.users,
               let newUsers = usersData?.users {
                usersData?.users = oldUsers + newUsers
            }
            updateData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavTitle("Working with GET request")
        setupUI()
        getUsers(page: 1)
    }
}

private extension UsersViewController {
    func setupUI() {
        view.backgroundColor = .white
        showNoUsersView(true)
    }
    
    func getUsers(page: Int) {
        Network.shared.getUsers(UsersRequestModel(page: page, count: 10)) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let model):
                    guard model.success else {
                        AlertView.showError("Failed to get users", on: self)
                        return
                    }
                    self.usersData = model
                   
                case .failure(let error):
                    AlertView.showError(error.localizedDescription, on: self)
                }
            }
        }
    }
    
    func updateData() {
        guard let usersData = usersData,
              let users = usersData.users,
              !users.isEmpty else {
            showNoUsersView(true)
            return
        }
        
        showUsersTableView(users)
        showNoUsersView(false)
    }
    
    func showNoUsersView(_ show: Bool) {
        guard show else {
            noUsersView.animateOut()
            return
        }
        
        view.addSubview(noUsersView)
        noUsersView.animateIn()
        usersTableView.animateOut()
        
        NSLayoutConstraint.activate([
            noUsersView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noUsersView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func showUsersTableView(_ users: [UserModel]) {
        usersTableView.configure(users)
        usersTableView.setLoadingMore(false)
        guard !view.contains(usersTableView) else {
            return
        }
        
        usersTableView.loadingDelegate = self
        view.addSubview(usersTableView)
        usersTableView.animateIn()
        
        NSLayoutConstraint.activate([
            usersTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26), // Navigation title
            usersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            usersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            usersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension UsersViewController: UsersTableViewDelegate {
    func usersTableViewDidReachBottom(_ tableView: UsersTableView) {
        guard let page = usersData?.page,
              let pages = usersData?.pages,
              page < pages else { return }
        
        usersTableView.setLoadingMore(true)
        getUsers(page: page + 1)
    }
}
