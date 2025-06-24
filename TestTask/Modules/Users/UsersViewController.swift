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
                usersData?.users = resetUsers ? newUsers : oldUsers + newUsers
                resetUsers = false
            }
            updateData()
        }
    }
    
    private var resetUsers: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavTitle("Working with GET request")
        setupUI()
        getUsers(page: 1)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUsers), name: .registrationSuccess, object: nil)
    }
}

private extension UsersViewController {
    func setupUI() {
        view.backgroundColor = .white
        showNoUsersView(true)
    }
    
    func getUsers(page: Int, retryCount: Int = 3, delay: TimeInterval = 2) {
        guard NetworkMonitor.shared.isConnected else {
            NetworkMonitor.shared.runWhenConnected {
                self.getUsers(page: page, retryCount: retryCount, delay: delay)
            }
            return
        }
        
        let requestModel = UsersRequestModel(page: page, count: 6)
        
        Network.shared.getUsers(requestModel) { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let model):
                    guard model.success else {
                        AlertView.showError("Failed to get users", on: self)
                        return
                    }
                    self.usersData = model

                case .failure(let error):
                    if retryCount > 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.getUsers(page: page, retryCount: retryCount - 1, delay: delay)
                        }
                    } else {
                        AlertView.showError(error.localizedDescription, on: self)
                    }
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
    
    @objc
    func updateUsers() {
        print("call function")
        resetUsers = true
        getUsers(page: 1)
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
