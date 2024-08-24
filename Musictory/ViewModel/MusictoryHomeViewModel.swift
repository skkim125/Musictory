//
//  MusictoryHomeViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import RxSwift
import RxCocoa

final class MusictoryHomeViewModel: BaseViewModel {
    private var originalPosts: [PostModel] = []
    var loginUser: LoginModel?
    private let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let fetchPost: PublishRelay<Void>
        let checkRefreshToken: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
    }
    
    struct Output {
        let posts: BehaviorRelay<[PostModel]>
        let newPost: PublishRelay<PostModel>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let showErrorAlert = PublishRelay<Void>()
        let fetchPost = input.fetchPost
        var nextCursor = ""
        let posts = BehaviorRelay<[PostModel]>(value: originalPosts)
        let fetchNewPost = PublishRelay<Void>()
        let newPost = PublishRelay<PostModel>()
        let networkError = PublishRelay<NetworkError>()
        
        input.checkRefreshToken
            .bind(with: self) { owner, _ in
                LSLP_API.shared.callRequest(apiType: .refresh, decodingType: RefreshModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(#function)
                        print(#function, 1, UserDefaultsManager.shared.accessT)
                        UserDefaultsManager.shared.accessT = success.accessToken
                        print(#function, 2, UserDefaultsManager.shared.accessT)
                        print(#function, 2, UserDefaultsManager.shared.userID)
                    case .failure(let error):
                        networkError.accept(error)
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
                        owner.originalPosts = success.data
                        posts.accept(owner.originalPosts)
                        nextCursor = success.nextCursor ?? ""
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .bind(with: self) { owner, value in
                var updatedPost = owner.originalPosts[value]
                
                let isLike = updatedPost.likes.contains(where: { $0 == UserDefaultsManager.shared.userID })
                
                if isLike {
                    updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                } else {
                    updatedPost.likes.append(UserDefaultsManager.shared.userID)
                }
                
                owner.originalPosts[value] = updatedPost
                let likeQuery = LikeQuery(like_status: isLike)
                
                LSLP_API.shared.callRequest(apiType: .like(owner.originalPosts[value].postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(#function, 3, owner.originalPosts[value].postID)
                        var currentPosts = owner.originalPosts
                        currentPosts[value] = updatedPost
                        posts.accept(currentPosts)
                        
                    case .failure(let error):
                        if !isLike {
                            updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                        } else {
                            updatedPost.likes.append(UserDefaultsManager.shared.userID)
                        }
                        owner.originalPosts[value] = updatedPost
                        
                        var currentPosts = owner.originalPosts
                        currentPosts[value] = updatedPost
                        posts.accept(currentPosts)
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(posts: posts, newPost: newPost ,showErrorAlert: showErrorAlert, networkError: networkError)
    }
    
}
