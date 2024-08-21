//
//  MusictoryHomeViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import RxSwift
import RxCocoa

final class MusictoryHomeViewModel: BaseViewModel {
    private let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let fetchPost: PublishRelay<Void>
    }
    
    struct Output {
        let posts: PublishRelay<[PostModel]>
    }
    
    func transform(input: Input) -> Output {
        let fetchPost = input.fetchPost
        var nextCursor = ""
        let posts = PublishRelay<[PostModel]>()
        
        fetchPost
            .bind(with: self) { owner, _ in
                
                owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                    switch result {
                    case .success(let success):
                        posts.accept(success.data)
                        nextCursor = success.nextCursor ?? ""
                        print(success.data)
                        print(nextCursor)
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(posts: posts)
    }
    
}
