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
        let updateAccessToken: PublishSubject<Void>
        let fetchPost: PublishSubject<Void>
        let likePostIndex: PublishRelay<Int>
        let prefetchIndexPatch: PublishRelay<[IndexPath]>
        let updatePosts: PublishRelay<(Int, ConvertPost)>
        let updatePostActionOfNoti: PublishSubject<PostModel>
    }
    
    struct Output {
        let convertPosts: BehaviorRelay<[ConvertPost]>
        let likeTogglePost: PublishRelay<ConvertPost>
        let showErrorAlert: PublishRelay<NetworkError>
        let paginating: PublishRelay<Bool>
    }
    
    func transform(input: Input) -> Output {
        let prefetching = PublishRelay<Void>()
        var nextCursor = "0"
        let posts = BehaviorRelay<[PostModel]>(value: [])
        let outputConvertPosts = BehaviorRelay<[ConvertPost]>(value: [])
        let showErrorAlert = PublishRelay<NetworkError>()
        let newPost = PublishRelay<ConvertPost>()
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
                        print("nextCursor = \(nextCursor)")
                        if success.nextCursor != "0" {
                            nextCursor = success.nextCursor
                            print("nextCursor = \(nextCursor)")
                        }
                        
                    case .failure(let error):
                        showErrorAlert.accept(error)
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
     
        @Sendable func convertPostFunction(posts: [PostModel]) async throws {
            await withThrowingTaskGroup(of: ConvertPost.self) {  group in
                paginating.accept(false)
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
                
                DispatchQueue.main.async {
                    outputConvertPosts.accept(self.originalConvertPosts)
                    paginating.accept(true)
                }
            }
        }
        
        Observable.combineLatest(input.prefetchIndexPatch, outputConvertPosts)
            .bind(with: self, onNext: { owner, value in
                guard let lastIndex = value.0.last else { return }
                print("value1.count", value.1.count-5)
                print("indexPaths", lastIndex.row)
                if value.1.count - 3 == lastIndex.row && nextCursor != "0" {
                    print("indexPath", lastIndex.item)
                    prefetching.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.updatePosts
            .bind(with: self) { owner, value in
                owner.originalConvertPosts[value.0] = value.1
                outputConvertPosts.accept(owner.originalConvertPosts)
            }
            .disposed(by: disposeBag)
        
        input.updatePostActionOfNoti
            .bind(with: self) { owner, value in
                guard let index = owner.originalPosts.firstIndex(where: { $0.postID == value.postID }) else { return }
                owner.originalPosts[index] = value
                owner.originalConvertPosts[index].post = owner.originalPosts[index]
                outputConvertPosts.accept(owner.originalConvertPosts)
            }
            .disposed(by: disposeBag)
        
        return Output(convertPosts: outputConvertPosts, likeTogglePost: newPost, showErrorAlert: showErrorAlert, paginating: paginating)
    }
}

