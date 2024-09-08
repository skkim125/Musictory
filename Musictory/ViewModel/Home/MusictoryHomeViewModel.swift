//
//  MusictoryHomeViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import Foundation
import RxSwift
import RxCocoa
import MusicKit

final class MusictoryHomeViewModel: BaseViewModel {
    private var originalPosts: [PostModel] = []
    private let lslp_API = LSLP_Manager.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let updateAccessToken: PublishSubject<Void>
        let fetchPost: PublishSubject<Void>
        let likePostIndex: PublishRelay<Int>
        let prefetchIndex: PublishRelay<Int>
        let updatePost: PublishRelay<(Int, PostModel)>
        let updatePostActionOfNoti: PublishSubject<PostModel>
        let updateMyProfileOfNoti: PublishSubject<ProfileModel>
        let updateDeletePostOfNoti: PublishSubject<String>
    }
    
    struct Output {
        let posts: BehaviorRelay<[PostModel]>
        let likeTogglePost: PublishRelay<PostModel>
        let showErrorAlert: PublishRelay<NetworkError>
        let paginating: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let prefetching = PublishRelay<Void>()
        var nextCursor = "0"
        let posts = BehaviorRelay<[PostModel]>(value: [])
        let showErrorAlert = PublishRelay<NetworkError>()
        let newPost = PublishRelay<PostModel>()
        let paginating = PublishRelay<Bool>()
        
        input.updateAccessToken
            .bind(with: self) { owner, _ in
                owner.lslp_API.updateRefresh { result in
                    switch result {
                    case .success(let success):
                        UserDefaultsManager.shared.accessT = success.accessToken
                        print(#function, "UserDefaultsManager.shared.accessT = \(UserDefaultsManager.shared.accessT)")
                    case .failure(let error):
                        showErrorAlert.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        input.fetchPost
            .bind(with: self) { owner, _ in
                nextCursor = "0"
                owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                    switch result {
                    case .success(let success):
                        
                        owner.originalPosts = success.data
                        posts.accept(owner.originalPosts)
                        print(#function, "nextCursor = \(nextCursor)")
                        if success.nextCursor != "0" {
                            nextCursor = success.nextCursor
                            print(#function, "nextCursor = \(nextCursor)")
                        }
                        
                    case .failure(let error):
                        showErrorAlert.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .bind(with: self) { owner, value in
                var updatedPost = owner.originalPosts[value]
                
                var isLike = updatedPost.likes.contains(UserDefaultsManager.shared.userID)
                print(#function, 4.0, isLike)
                if isLike {
                    updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                } else {
                    updatedPost.likes.append(UserDefaultsManager.shared.userID)
                }
                isLike.toggle()

                owner.originalPosts[value] = updatedPost
                let likeQuery = LikeQuery(like_status: isLike)
                print(#function, 4.1, isLike)
                
                LSLP_Manager.shared.callRequest(apiType: .like(owner.originalPosts[value].postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success:
                        print(#function, 4, owner.originalPosts[value])
                        owner.originalPosts[value] = updatedPost
                        newPost.accept(owner.originalPosts[value])
                    case .failure(let error1):
                        showErrorAlert.accept(error1)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        prefetching
            .bind(with: self) { owner, _ in
                if nextCursor != "0" {
                    owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                        switch result {
                        case .success(let success):
                            owner.originalPosts.append(contentsOf: success.data)
                            posts.accept(owner.originalPosts)
                            nextCursor = success.nextCursor
                            print(#function, 5, success.nextCursor)
                            print(#function, 6, nextCursor)
                            
                        case .failure(let error):
                            showErrorAlert.accept(error)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.prefetchIndex
            .bind(with: self) { owner, value in
                print(value)
                guard owner.originalPosts.count - value == 5 else { return }
                if nextCursor != "0" {
                    print("indexPath", value)
                    prefetching.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        input.updateDeletePostOfNoti
            .bind(with: self) { owner, value in
                guard let index = owner.originalPosts.firstIndex(where: { $0.postID == value }) else { return }
                owner.originalPosts.remove(at: index)
                posts.accept(owner.originalPosts)
            }
            .disposed(by: disposeBag)
        
        input.updatePost
            .bind(with: self) { owner, value in
                owner.originalPosts[value.0] = value.1
                posts.accept(owner.originalPosts)
            }
            .disposed(by: disposeBag)
        
        input.updatePostActionOfNoti
            .bind(with: self) { owner, value in
                guard let index = owner.originalPosts.firstIndex(where: { $0.postID == value.postID }) else { return }
                owner.originalPosts[index] = value
                print(value)
                posts.accept(owner.originalPosts)
            }
            .disposed(by: disposeBag)
        
        input.updateMyProfileOfNoti
            .bind(with: self) { owner, value in
                
                for (index, post) in owner.originalPosts.enumerated() {
                    if post.creator.userID == value.user_id {
                        owner.originalPosts[index].creator = User(userID: value.nick, nickname: value.nick, profileImage: value.profileImage)
                    }
                }
                
                posts.accept(owner.originalPosts)
            }
            .disposed(by: disposeBag)
        
        return Output(posts: posts, likeTogglePost: newPost, showErrorAlert: showErrorAlert, paginating: paginating)
    }
}

