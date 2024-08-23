//
//  MusictoryHomeViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import RxSwift
import RxCocoa

final class MusictoryHomeViewModel: BaseViewModel {
    var loginUser: LoginModel?
    private let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let fetchPost: PublishRelay<Void>
        let checkRefreshToken: PublishRelay<Void>
    }
    
    struct Output {
        let posts: PublishRelay<[PostModel]>
        let showErrorAlert: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let showErrorAlert = PublishRelay<Void>()
        let fetchPost = input.fetchPost
        var nextCursor = ""
        let posts = PublishRelay<[PostModel]>()
        
        input.checkRefreshToken
            .bind(with: self) { owner, _ in
                LSLP_API.shared.callRequest(apiType: .refresh, decodingType: RefreshModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(#function)
                        print(#function, 1, UserDefaultsManager.shared.accessT)
                        UserDefaultsManager.shared.accessT = success.accessToken
                        print(#function, 2, UserDefaultsManager.shared.accessT)
                    case .failure(let error):
                        print(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        fetchPost
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                    switch result {
                    case .success(let success):
                        posts.accept(success.data)
                        nextCursor = success.nextCursor ?? ""
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(posts: posts, showErrorAlert: showErrorAlert)
    }
    
}
