//
//  TabViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/24/24.
//

import UIKit

final class TabViewController: UITabBarController {
    var homeViewController: UINavigationController!
    var myPageViewController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        tabBar.tintColor = .systemRed
        
        homeViewController = UINavigationController(rootViewController: MusictoryHomeViewController())
        homeViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)

        let writeView = UIViewController()
        writeView.tabBarItem = UITabBarItem(title: nil, image: nil, tag: 0)

        myPageViewController = UINavigationController(rootViewController: MyPageViewController())
        myPageViewController.view.backgroundColor = .systemBackground
        myPageViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.crop.circle"), tag: 3)

        self.viewControllers = [homeViewController, writeView, myPageViewController]

        let writeButton = UIButton(type: .system)
        writeButton.frame = CGRect(x: (tabBar.frame.width / 2) - 15, y: 5, width: 30, height: 30)
        writeButton.tintColor = .white
        writeButton.backgroundColor = .systemRed
        writeButton.setImage(UIImage(systemName: "plus")?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 20))), for: .normal)
        writeButton.layer.cornerRadius = 15
        writeButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)
        tabBar.addSubview(writeButton)
    }

    @objc func customButtonTapped() {
        let vc = WriteMusictoryViewController()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        self.present(nav, animated: true)
    }
}

extension TabViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.viewControllers?[1] {
            return false
        }
        return true
    }
}
