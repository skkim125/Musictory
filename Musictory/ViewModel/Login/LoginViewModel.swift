//
//  LoginViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/17/24.
//

import RxSwift
import RxCocoa

final class LoginViewModel: BaseViewModel {
    private let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let loginButtonEnable: PublishRelay<Bool>
        let loginModel: PublishRelay<LoginModel>
        let showErrorAlert: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let loginButtonTap = input.loginButtonTap
        let loginButtonEnable = PublishRelay<Bool>()
        let loginModel = PublishRelay<LoginModel>()
        let showErrorAlert = PublishRelay<NetworkError>()
        
        var loginQuery = LoginQuery(email: "", password: "")
        
        let emailValidation = input.email
            .map({ $0.trimmingCharacters(in: .whitespaces).count > 7 })
            .share(replay: 1)
        
        let passwordValidation = input.password
            .map({ $0.trimmingCharacters(in: .whitespaces).count > 7 })
            .share(replay: 1)
        
        Observable.combineLatest(emailValidation, passwordValidation)
            .map ({ $0 && $1 })
            .bind(with: self) { owner, value in
                loginButtonEnable.accept(value)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.email, input.password)
            .bind { value in
                loginQuery.email = value.0
                loginQuery.password = value.1
            }
            .disposed(by: disposeBag)
        
        loginButtonTap
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .login(loginQuery), decodingType: LoginModel.self) { result  in
                    
                    switch result {
                    case .success(let success):
                        loginModel.accept(success)
                        UserDefaultsManager.shared.userNickname = success.nick
                        UserDefaultsManager.shared.userID = success.userID
                        UserDefaultsManager.shared.email = success.email
                        UserDefaultsManager.shared.accessT = success.accessT
                        UserDefaultsManager.shared.refreshT = success.refreshT
                        UserDefaultsManager.shared.password = loginQuery.password
                        
                    case .failure(let error):
                        showErrorAlert.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(loginButtonEnable: loginButtonEnable, loginModel: loginModel, showErrorAlert: showErrorAlert)
    }
    
    private func tokenRefresh() {
        LSLP_API.shared.callRequest(apiType: .refresh, decodingType: RefreshModel.self) { result in
            switch result {
            case .success(let success):
                UserDefaultsManager.shared.accessT = success.accessToken
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
}
