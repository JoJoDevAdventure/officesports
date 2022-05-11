//
//  MainViewController.swift
//  Office Sports
//
//  Created by Øyvind Hauge on 10/05/2022.
//

import UIKit

final class MainViewController: UIViewController {
    
    private lazy var profileView: ProfileView = {
        let profileView = ProfileView(account: OSAccount.current)
        profileView.backgroundColor = .red
        return profileView
    }()
    
    private lazy var scrollView: UIScrollView = {
        return UIScrollView.createScrollView(.clear)
    }()
    
    private lazy var stackView: UIStackView = {
        return UIStackView.createStackView(.clear, axis: .horizontal)
    }()
    
    private lazy var floatingMenu: FloatingMenu = {
        return FloatingMenu()
    }()
    
    private lazy var foosballViewController: SportViewController = {
        let viewModel = ResultListViewModel(sport: .foosball)
        return SportViewController(viewModel: viewModel)
    }()
    
    private lazy var tableTennisViewController: SportViewController = {
        let viewModel = ResultListViewModel(sport: .tableTennis)
        return SportViewController(viewModel: viewModel)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViews()
        setupChildViewControllers()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureTableViewInsets()
    }
    
    private func setupChildViews() {
        view.addSubview(profileView)
        NSLayoutConstraint.pinToView(view, scrollView)
        
        scrollView.addSubview(stackView)
        
        view.addSubview(floatingMenu)
        
        NSLayoutConstraint.activate([
            profileView.leftAnchor.constraint(equalTo: view.leftAnchor),
            profileView.rightAnchor.constraint(equalTo: view.rightAnchor),
            profileView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            floatingMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            floatingMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -64),
            floatingMenu.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            floatingMenu.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    private func setupChildViewControllers() {
        foosballViewController.didMove(toParent: self)
        tableTennisViewController.didMove(toParent: self)
        
        let foosballView = foosballViewController.view!
        let tableTennisView = tableTennisViewController.view!
        
        stackView.addArrangedSubview(foosballView)
        stackView.addArrangedSubview(tableTennisView)
        
        NSLayoutConstraint.activate([
            foosballView.widthAnchor.constraint(equalTo: view.widthAnchor),
            foosballView.heightAnchor.constraint(equalTo: view.heightAnchor),
            tableTennisView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableTennisView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.OfficeSports.background
    }
    
    private func configureTableViewInsets() {
        let padding: CGFloat = 16
        let profileMaxY = profileView.bounds.maxY + padding
        let menuMinY = floatingMenu.bounds.maxY + padding
        let contentInset = UIEdgeInsets(top: profileMaxY, left: 0, bottom: menuMinY, right: 0)
        foosballViewController.applyContentInsetToTableView(contentInset)
        tableTennisViewController.applyContentInsetToTableView(contentInset)
    }
}
