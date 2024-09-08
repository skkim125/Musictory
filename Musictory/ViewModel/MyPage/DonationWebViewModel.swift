//
//  DonationWebViewModel.swift
//  Musictory
//
//  Created by 김상규 on 9/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class DonationWebViewModel: BaseViewModel {
    let disposeBag = DisposeBag()
    
    struct Input {
        let impuid: PublishRelay<String>
    }
    
    struct Output {
        let dismissAction: PublishRelay<Void>
        let showErrorAlert: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let showErrorAlert = PublishRelay<NetworkError>()
        let dismissAction = PublishRelay<Void>()
        
        input.impuid
            .bind(with: self) { owner, impuid in
                let donationQuery = DonationQuery(imp_uid: impuid)
                dump(donationQuery)
                print(impuid)
                LSLP_Manager.shared.callRequest(apiType: .donation(donationQuery), decodingType: DonationModel.self) { result in
                    switch result {
                    case .success(let donation):
                        print("도네이션:", donation)
                        dismissAction.accept(())
                    case .failure(let error):
                        showErrorAlert.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(dismissAction: dismissAction, showErrorAlert: showErrorAlert)
    }
}
