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
        let refreshPost: PublishRelay<Void>
    }
    
    struct Output {
        let posts: PublishRelay<[PostModel]>
    }
    
    func transform(input: Input) -> Output {
        let refreshPost = input.refreshPost
        var nextCursor = ""
        let result = PublishRelay<[PostModel]>()
        
        refreshPost
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: RequestPostModel.self) { data in
                    result.accept(data.data)
                    nextCursor = data.nextCursor ?? ""
                    print(data.data)
                    print(nextCursor)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(posts: result)
    }
    
}
