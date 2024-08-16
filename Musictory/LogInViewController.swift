//
//  LogInViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LogInViewController: UIViewController {
    private let appTitleLabel = UILabel()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
    }
    
    func configureHierarchy() {
        view.backgroundColor = .white
        
        let subViews = [appTitleLabel, emailTextField, passwordTextField]
        
        subViews.forEach { sv in
            view.addSubview(sv)
        }
        
        appTitleLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(60)
        }
        appTitleLabel.text = "Musictory"
        appTitleLabel.font = .boldSystemFont(ofSize: 45)
        appTitleLabel.textAlignment = .center
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(appTitleLabel.snp.bottom).offset(100)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(40)
        }
        emailTextField.layer.cornerRadius = 8
        emailTextField.clipsToBounds = true
        emailTextField.backgroundColor = .systemGray5
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(40)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        passwordTextField.layer.cornerRadius = 8
        passwordTextField.clipsToBounds = true
        passwordTextField.backgroundColor = .systemGray5
    }
    
}
