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

struct ConvertPost {
    var post: PostModel
    let song: Song?
}

final class MusictoryHomeViewModel: BaseViewModel {
    private var originalConvertPosts: [ConvertPost] = []
    private var originalPosts: [PostModel] = []
    private let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let checkAccessToken: PublishSubject<Void>
        let checkRefreshToken: PublishSubject<Void>
        let fetchPost: PublishSubject<Void>
        let likePostIndex: PublishRelay<Int>
        let prefetching: PublishRelay<Bool>
        let prefetchIndexPatch: PublishRelay<[IndexPath]>
    }
    
    struct Output {
        let convertPosts: BehaviorRelay<[ConvertPost]>
        let likeTogglePost: PublishRelay<ConvertPost>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let showErrorAlert = PublishRelay<Void>()
        var nextCursor = "0"
        let posts = BehaviorRelay<[PostModel]>(value: [])
        let outputConvertPosts = BehaviorRelay<[ConvertPost]>(value: [])
        let networkError = PublishRelay<NetworkError>()
        let newPost = PublishRelay<ConvertPost>()
        
        input.checkRefreshToken
            .bind(with: self) { owner, _ in
                owner.lslp_API.updateRefresh { result in
                    switch result {
                    case .success(let success):
                        UserDefaultsManager.shared.accessT = success.accessToken
                    case .failure(let error2):
                        networkError.accept(error2)
                        showErrorAlert.accept(())
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
                        if success.nextCursor != "0" {
                            nextCursor = success.nextCursor
                            print("nextCursor = \(nextCursor)")
                        }

                    case .failure(let error1):
                        switch error1 {
                        case .expiredAccessToken, .expiredRefreshToken:
                            owner.lslp_API.updateRefresh { result in
                                switch result {
                                case .success(let success):
                                    UserDefaultsManager.shared.accessT = success.accessToken
                                    input.fetchPost.onNext(())
                                case .failure(let error2):
                                    networkError.accept(error2)
                                    showErrorAlert.accept(())
                                }
                            }
                            
                        default:
                            networkError.accept(error1)
                            showErrorAlert.accept(())
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        posts
            .bind(with: self) { owner, value in
                Task {
                    try await convertPostFunction(posts: value)
                }
            }
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .bind(with: self) { owner, value in
                input.checkAccessToken.onNext(())
                var updatedPost = owner.originalConvertPosts[value].post
                
                var isLike = updatedPost.likes.contains(UserDefaultsManager.shared.userID)
                print(#function, 4.0, isLike)
                if isLike {
                    updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                } else {
                    updatedPost.likes.append(UserDefaultsManager.shared.userID)
                }
                isLike.toggle()

                owner.originalConvertPosts[value].post = updatedPost
                let likeQuery = LikeQuery(like_status: isLike)
                print(#function, 4.1, isLike)
                
                LSLP_API.shared.callRequest(apiType: .like(owner.originalConvertPosts[value].post.postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success:
                        print(#function, 4, owner.originalConvertPosts[value])
                        owner.originalConvertPosts[value].post = updatedPost
                        newPost.accept(owner.originalConvertPosts[value])
                        outputConvertPosts.accept(owner.originalConvertPosts)
                    case .failure(let error1):
                        switch error1 {
                        case .expiredAccessToken, .expiredRefreshToken:
                            owner.lslp_API.updateRefresh { result in
                                switch result {
                                case .success(let success):
                                    UserDefaultsManager.shared.accessT = success.accessToken
                                    input.likePostIndex.accept(value)
                                case .failure(let error2):
                                    if isLike {
                                        updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                                    } else {
                                        updatedPost.likes.append(UserDefaultsManager.shared.userID)
                                    }
                                    owner.originalConvertPosts[value].post = updatedPost
                                    newPost.accept(owner.originalConvertPosts[value])
                                    outputConvertPosts.accept(owner.originalConvertPosts)
                                    networkError.accept(error2)
                                    showErrorAlert.accept(())
                                }
                            }
                        default:
                            networkError.accept(error1)
                            showErrorAlert.accept(())
                        }
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
                                print(#function, 5, success.nextCursor)
                                print(#function, 6, nextCursor)
                                input.prefetching.accept(false)
                            case .failure(let error1):
                                switch error1 {
                                case .expiredAccessToken, .expiredRefreshToken:
                                    owner.lslp_API.updateRefresh { result in
                                        switch result {
                                        case .success(let success):
                                            UserDefaultsManager.shared.accessT = success.accessToken
                                            input.fetchPost.onNext(())
                                        case .failure(let error2):
                                            networkError.accept(error2)
                                            showErrorAlert.accept(())
                                        }
                                    }
                                    
                                default:
                                    networkError.accept(error1)
                                    showErrorAlert.accept(())
                                }
                            }
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
     
        @Sendable func convertPostFunction(posts: [PostModel]) async throws {
            await withThrowingTaskGroup(of: ConvertPost.self) {  group in
                var array: [ConvertPost] = []
                for post in posts {
                    group.addTask {
                        do {
                            let song = try await MusicManager.shared.requsetMusicId(id: post.content1)
                            return ConvertPost(post: post, song: song)
                        } catch {
                            return ConvertPost(post: post, song: nil)
                        }
                    }
                }
                
                do {
                    for try await post in group {
                        array.append(post)
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
                
                let recentArray = array.sorted(by: { $0.post.createdAt > $1.post.createdAt })
                originalConvertPosts = recentArray
                
                outputConvertPosts.accept(originalConvertPosts)
            }
        }
        
        Observable.combineLatest(input.prefetchIndexPatch, outputConvertPosts)
            .bind(with: self, onNext: { owner, value in
                
                print("indexPaths", value.0)
                value.0.forEach { indexPath in
                    if value.1.count - 5 == indexPath.item && nextCursor != "0" {
                        print("indexPath", indexPath.item)
                        input.prefetching.accept(true)
                    } else {
                        input.prefetching.accept(false)
                    }
                }
                
                input.prefetching.accept(true)
            })
            .disposed(by: disposeBag)
        
        return Output(convertPosts: outputConvertPosts, likeTogglePost: newPost, showErrorAlert: showErrorAlert, networkError: networkError)
    }
}

