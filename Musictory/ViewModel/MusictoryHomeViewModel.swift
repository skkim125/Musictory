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
    private let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let fetchPost: PublishRelay<Void>
        let checkAccessToken: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
        let prefetching: PublishRelay<Bool>
    }
    
    struct Output {
        let posts: BehaviorRelay<[PostModel]>
        let newPost: PublishRelay<PostModel>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let showErrorAlert = PublishRelay<Void>()
        let checkRefreshToken = PublishRelay<Void>()
        let fetchPost = input.fetchPost
        var nextCursor = "0"
        let posts = BehaviorRelay<[PostModel]>(value: originalPosts)
        let fetchNewPost = PublishRelay<Void>()
        let newPost = PublishRelay<PostModel>()
        let networkError = PublishRelay<NetworkError>()
        
        input.checkAccessToken
                    .bind(with: self) { owner, _ in
                        var loginQuery = LoginQuery(email: UserDefaultsManager.shared.email, password: UserDefaultsManager.shared.password)
                        owner.lslp_API.callRequest(apiType: .login(loginQuery), decodingType: LoginModel.self) { result  in
                            
                            switch result {
                            case .success(let success):
                                UserDefaultsManager.shared.userNickname = success.nick
                                UserDefaultsManager.shared.userID = success.userID
                                UserDefaultsManager.shared.email = success.email
                                UserDefaultsManager.shared.accessT = success.accessT
                                UserDefaultsManager.shared.refreshT = success.refreshT
                                UserDefaultsManager.shared.password = loginQuery.password
                                
                            case .failure(let failure):
                                switch failure {
                                case .expiredAccessToken:
                                    checkRefreshToken.accept(())
                                    
                                default:
                                    networkError.accept(failure)
                                    showErrorAlert.accept(())
                                }
                            }
                        }
            }
            .disposed(by: disposeBag)
        
        checkRefreshToken
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .refresh, decodingType: RefreshModel.self) { result in
                    switch result {
                    case .success(let success):
                        UserDefaultsManager.shared.accessT = success.accessToken
                        print(#function, 2, UserDefaultsManager.shared.accessT)
                    case .failure(let error):
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        fetchPost
            .bind(with: self) { owner, _ in
                nextCursor = "0"
                owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(#function, 1, success.data.map({ $0.creator.userID == UserDefaultsManager.shared.userID }))
                        print(#function, 1, success.data.map({ $0.creator.userID == UserDefaultsManager.shared.userID }).count)
                        print(#function, 1, success.data)
                        owner.originalPosts = success.data
                        posts.accept(owner.originalPosts)
                        print(#function, 1, success.nextCursor)
                        print(#function, 2, nextCursor)
                        if success.nextCursor != "0" {
                            nextCursor = success.nextCursor
                            print(#function, 3, nextCursor)
                        }
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .bind(with: self) { owner, value in
                var updatedPost = owner.originalPosts[value]
//                print(#function, 3, updatedPost.likes)
                
                var isLike = updatedPost.likes.contains(UserDefaultsManager.shared.userID)
//                print(#function, 3, isLike)
                
                if isLike {
                    updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                } else {
                    updatedPost.likes.append(UserDefaultsManager.shared.userID)
                }
                isLike.toggle()
//                print(#function, 33, isLike)
                owner.originalPosts[value] = updatedPost
                let likeQuery = LikeQuery(like_status: isLike)
                
                LSLP_API.shared.callRequest(apiType: .like(owner.originalPosts[value].postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(#function, 3, owner.originalPosts[value].postID)
                        owner.originalPosts[value] = updatedPost
                        posts.accept(owner.originalPosts)
                        
                    case .failure(let error):
                        if isLike {
                            updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                        } else {
                            updatedPost.likes.append(UserDefaultsManager.shared.userID)
                        }
                        owner.originalPosts[value] = updatedPost
                        posts.accept(owner.originalPosts)
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.prefetching
            .bind(with: self) { owner, value in
                if nextCursor != "0" {
                    if value {
                        owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                            switch result {
                            case .success(let success):
                                owner.originalPosts.append(contentsOf: success.data)
                                posts.accept(owner.originalPosts)
                                nextCursor = success.nextCursor
                                print(#function, 4, success.nextCursor)
                                print(#function, 5, nextCursor)
                                input.prefetching.accept(false)
                            case .failure(let failure):
                                print(failure)
                            }
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(posts: posts, newPost: newPost ,showErrorAlert: showErrorAlert, networkError: networkError)
    }
    
}
