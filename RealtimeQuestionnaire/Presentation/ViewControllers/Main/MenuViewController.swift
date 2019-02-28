//
//  MenuViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/20.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import FirebaseAuth

final class MenuViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    enum Menu: Int, CaseIterable {
        case createCommunity
        case logout
        
        var text: String {
            switch self {
            case .createCommunity:
                return L10n.Menu.createCommunity
            case .logout:
                return L10n.Menu.logout
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: MenuTableViewCell.self)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            showAlert(type: .okCancel, title: L10n.Alert.logout, message: L10n.Alert.Logout.message) { [weak self] in
                guard let vc = self else { return }
                vc.switchLoginViewController()
            }
        } catch {
            print("*** failed to sign out ***")
        }
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menu.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MenuTableViewCell.self)
        cell.configure(text: Menu.allCases[indexPath.row].text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = Menu(rawValue: indexPath.row) else { return }
        switch menu {
        case .createCommunity:
            closeLeft()
            guard let mainVC = slideMenuController()?.mainViewController as? MainViewController else { return }
            mainVC.pushCreateCommunity()
        case .logout:
            logout()
        }
    }
}
