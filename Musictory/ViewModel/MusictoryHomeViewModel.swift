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
        let posts: PublishRelay<[PostModel]>
        let newPost: PublishRelay<PostModel>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let showErrorAlert = PublishRelay<Void>()
        let fetchPost = input.fetchPost
        var nextCursor = ""
        let posts = PublishRelay<[PostModel]>()
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
                        posts.accept(success.data)
                        nextCursor = success.nextCursor ?? ""
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .bind(with: self) { owner, value in
                print(#function, 1, owner.originalPosts[value].isLike)
                var postLike = owner.originalPosts[value].isLike
                postLike.toggle()
                print(#function, 2, postLike)
                let likeQuery = LikeQuery(like_status: postLike)
                
                LSLP_API.shared.callRequest(apiType: .like(owner.originalPosts[value].postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success(let success):
                        fetchNewPost.accept(())
                    case .failure(let error):
                        postLike.toggle()
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        fetchNewPost
            .withLatestFrom(input.likePostIndex)
            .bind(with: self) { owner, value in
                LSLP_API.shared.callRequest(apiType: .fetchPostOfReload(owner.originalPosts[value].postID, PostQuery(next: nil)), decodingType: PostModel.self) { result in
                    switch result {
                    case .success(let post):
                        print(#function, 4, post.postID)
                        owner.originalPosts[value] = post
                        posts.accept(owner.originalPosts)
                    case .failure(let error):
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(posts: posts, newPost: newPost ,showErrorAlert: showErrorAlert, networkError: networkError)
    }
    
}
