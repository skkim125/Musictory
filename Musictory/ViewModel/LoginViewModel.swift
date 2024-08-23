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
    }
    
    func transform(input: Input) -> Output {
        let loginButtonTap = input.loginButtonTap
        let loginButtonEnable = PublishRelay<Bool>()
        let loginModel = PublishRelay<LoginModel>()
        
        var loginQuery = LoginQuery(email: "", password: "")
        
        Observable.combineLatest(input.email, input.password)
            .map({ $0.0.trimmingCharacters(in: .whitespaces).count > 7 && $0.1.trimmingCharacters(in: .whitespaces).count > 7 })
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
                        UserDefaultsManager.shared.userID = success.userID
                        UserDefaultsManager.shared.password = loginQuery.password
                        UserDefaultsManager.shared.email = success.email
                        UserDefaultsManager.shared.accessT = success.accessT
                        UserDefaultsManager.shared.refreshT = success.refreshT
                    case .failure(let failure):
                        switch failure {
                        case .expiredAccessToken:
                            owner.tokenRefresh()
                            
                        default:
                            print(failure)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(loginButtonEnable: loginButtonEnable, loginModel: loginModel)
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
