//
//  LoginViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/17/24.
//

import RxSwift
import RxCocoa

final class LoginViewModel: BaseViewModel {
    let disposeBag = DisposeBag()
    
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let loginButtonEnable: PublishRelay<Bool>
        let loginButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let loginButtonTap = input.loginButtonTap
        let loginButtonEnable = PublishRelay<Bool>()
        
        Observable.combineLatest(input.email, input.password)
            .map({ $0.0.trimmingCharacters(in: .whitespaces).count > 8 && $0.1.trimmingCharacters(in: .whitespaces).count > 8 })
            .bind(with: self) { owner, value in
                loginButtonEnable.accept(value)
            }
            .disposed(by: disposeBag)
        
        return Output(loginButtonEnable: loginButtonEnable, loginButtonTap: loginButtonTap)
    }
    
}
