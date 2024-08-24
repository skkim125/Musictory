//
//  MyPageViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/24/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel: BaseViewModel {
    let disposeBag = DisposeBag()
    struct Input {
        let loadMyData: PublishRelay<Void>
    }
    
    struct Output {
        let myData: PublishRelay<ProfileModel>
    }
    
    func transform(input: Input) -> Output {
        let myData = PublishRelay<ProfileModel>()
        
        input.loadMyData
            .bind(with: self) { owner, _ in
                LSLP_API.shared.callRequest(apiType: .fetchProfile, decodingType: ProfileModel.self) { result in
                    switch result {
                    case .success(let profile):
                        myData.accept(profile)
                    case .failure(let error):
                        print("마이페이지", error.localizedDescription)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(myData: myData)
    }
}
