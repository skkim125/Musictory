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
    private let appTitleLabel = {
        let label = UILabel()
        label.text = "Musictory"
        label.font = .boldSystemFont(ofSize: 45)
        label.textAlignment = .center
        return label
        
    }()
    private let emailLabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    private let emailTextField = {
        let tf = UITextField()
        tf.text = "qwer123@gmail.com"
        tf.backgroundColor = .systemGray5
        tf.layer.cornerRadius = 4
        tf.clipsToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.rightViewMode = .always
        
        return tf
    }()
    private let passwordLabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = .systemFont(ofSize: 12)
        
        return label
        
    }()
    private let passwordTextField = {
        let tf = UITextField()
        tf.text = "12345678"
        tf.backgroundColor = .systemGray5
        tf.layer.cornerRadius = 4
        tf.clipsToBounds = true
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        tf.rightViewMode = .always
        
        return tf
    }()
    private let loginButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton(configuration: .bordered()).configuration
        button.configuration = configuration
        
        button.backgroundColor = .systemGray5
        button.tintColor = .lightGray
        button.setTitle("로그인", for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        return button
    }()
    
    let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        
        let subViews = [appTitleLabel, emailLabel, emailTextField, passwordLabel, passwordTextField, loginButton]
        
        subViews.forEach { sv in
            view.addSubview(sv)
        }
        
        appTitleLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(100)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(60)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(appTitleLabel.snp.bottom).offset(80)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(20)
        }
        
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(40)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(40)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(60)
            make.bottom.lessThanOrEqualTo(view.keyboardLayoutGuide.snp.top).offset(-20)
            make.height.equalTo(45)
        }
    }
    
    private func bind() {
        let input = LoginViewModel.Input(email: emailTextField.rx.text.orEmpty, password: passwordTextField.rx.text.orEmpty, loginButtonTap: loginButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.loginButtonEnable
            .bind(with: self) { owner, value in
                owner.loginButton.rx.backgroundColor.onNext(value ? .systemPurple : .systemGray5)
                owner.loginButton.rx.tintColor.onNext(value ? .white : .lightGray)
                owner.loginButton.rx.isEnabled.onNext(value)
            }
            .disposed(by: disposeBag)
        
        output.loginModel
            .bind(with: self) { owner, loginModel in
                owner.view.endEditing(true)
                let vc = MusictoryHomeViewController()
                vc.view.backgroundColor = .systemBackground
                vc.navigationItem.title = "\(loginModel.nick)"
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
