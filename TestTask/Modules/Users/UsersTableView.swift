//
// UsersTableView.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

protocol UsersTableViewDelegate: AnyObject {
    func usersTableViewDidReachBottom(_ tableView: UsersTableView)
}

final class UsersTableView: UITableView {
    
    weak var loadingDelegate: UsersTableViewDelegate?
    
    private lazy var loadingFooter: UIView = {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 54))
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.center = footer.center
        spinner.startAnimating()
        footer.addSubview(spinner)
        return footer
    }()
    
    private var users: [UserModel] = []
    private var isLoadingMore = false
    
    private var hasReachedBottom = false
    private var isDraggingDown = false
    private var bottomReachedOffsetY: CGFloat = 0
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ users: [UserModel]) {
        self.users = users
        reloadData()
    }
    
    func setLoadingMore(_ loading: Bool) {
        guard isLoadingMore != loading else { return }
        isLoadingMore = loading
        tableFooterView = loading ? loadingFooter : nil
    }
}

private extension UsersTableView {
    func setupUI() {
        delegate = self
        dataSource = self
        showsVerticalScrollIndicator = false
        register(UsersTVCell.self, forCellReuseIdentifier: UsersTVCell.identifier())
        translatesAutoresizingMaskIntoConstraints = false
        tableFooterView = nil
    }
}

extension UsersTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: UsersTVCell.identifier(), for: indexPath) as? UsersTVCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.configure(users[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let lastSection = tableView.numberOfSections - 1
            if indexPath.section == lastSection {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 66, bottom: 0, right: 0)
            }
        }
}

extension UsersTableView: UIScrollViewDelegate {
    
    private var threshold: CGFloat { 50 }
    private var requiredPullDistance: CGFloat { 50 }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isLoadingMore else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height

        let maxOffsetY = contentHeight - frameHeight

        if !hasReachedBottom && offsetY >= maxOffsetY - threshold {
            hasReachedBottom = true
            bottomReachedOffsetY = offsetY
        }

        if hasReachedBottom {
            let pullDistance = offsetY - bottomReachedOffsetY
            isDraggingDown = pullDistance >= requiredPullDistance
            if offsetY < maxOffsetY - 200 {
                hasReachedBottom = false
                bottomReachedOffsetY = 0
                isDraggingDown = false
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !isLoadingMore, hasReachedBottom, isDraggingDown else { return }
        
        loadingDelegate?.usersTableViewDidReachBottom(self)
        hasReachedBottom = false
        bottomReachedOffsetY = 0
        isDraggingDown = false
    }
}
