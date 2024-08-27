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
    
    init(post: PostModel, song: Song?) {
        self.post = post
        self.song = song
    }
}

final class MusictoryHomeViewModel: BaseViewModel {
    private var originalConvertPosts: [ConvertPost] = []
    private var originalPosts: [PostModel] = []
    private let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let checkAccessToken: PublishRelay<Void>
        let fetchPost: PublishRelay<Bool>
        let likePostIndex: PublishRelay<Int>
        let prefetching: PublishRelay<Bool>
    }
    
    struct Output {
        let convertPosts: PublishRelay<[ConvertPost]>
        let likeTogglePost: PublishRelay<ConvertPost>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let checkRefreshToken = PublishRelay<Void>()
        let showErrorAlert = PublishRelay<Void>()
        let fetchPost = input.fetchPost
        var nextCursor = "0"
        let posts = BehaviorRelay<[PostModel]>(value: [])
        let outputConvertPosts = PublishRelay<[ConvertPost]>()
        let networkError = PublishRelay<NetworkError>()
        let newPost = PublishRelay<ConvertPost>()
        
        input.checkAccessToken
            .bind(with: self) { owner, _ in
                let loginQuery = LoginQuery(email: UserDefaultsManager.shared.email, password: UserDefaultsManager.shared.password)
                owner.lslp_API.callRequest(apiType: .login(loginQuery), decodingType: LoginModel.self) { result  in
                    
                    switch result {
                    case .success(let success):
                        UserDefaultsManager.shared.userNickname = success.nick
                        UserDefaultsManager.shared.userID = success.userID
                        UserDefaultsManager.shared.email = success.email
                        UserDefaultsManager.shared.accessT = success.accessT
                        UserDefaultsManager.shared.refreshT = success.refreshT
                        UserDefaultsManager.shared.password = loginQuery.password
                        print(#function, 1, UserDefaultsManager.shared.accessT)
                        print(#function, 1, "로그인 성공")
                        print(#function, 1, "액세스 토큰 갱신")
                        
                    case .failure(let error):
                        switch error {
                        case .expiredAccessToken:
                            checkRefreshToken.accept(())
                            print(#function, 1, "로그인 실패, 액세스 토큰 만료")
                        default:
                            print(#function, 1, "\(error)")
                            networkError.accept(error)
                            showErrorAlert.accept(())
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        checkRefreshToken
            .bind(with: self) { owner, value in
                owner.lslp_API.callRequest(apiType: .refresh, decodingType: RefreshModel.self) { result in
                    switch result {
                    case .success(let success):
                        UserDefaultsManager.shared.accessT = success.accessToken
                        print(#function, 2, UserDefaultsManager.shared.accessT)
                        print(#function, 2, "토큰 리프래시 완료")
                        input.checkAccessToken.accept(())
                    case .failure(let error):
                        print(#function, 2, "리프래시 토큰 만료")
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        fetchPost
            .bind(with: self) { owner, value in
                checkRefreshToken.accept(())
                guard value else { return }
                nextCursor = "0"
                owner.lslp_API.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                    switch result {
                    case .success(let success):
                        
                        owner.originalPosts.append(contentsOf: success.data)
                        posts.accept(owner.originalPosts)
                        if success.nextCursor != "0" {
                            nextCursor = success.nextCursor
                        }

                    case .failure(let error):
                        networkError.accept(error)
                        showErrorAlert.accept(())
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
                checkRefreshToken.accept(())
                //input.checkAccessToken.accept(())
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
                    case .success(let success):
                        print(#function, 4, owner.originalConvertPosts[value])
                        owner.originalConvertPosts[value].post = updatedPost
                        newPost.accept(owner.originalConvertPosts[value])
                        
                    case .failure(let error):
                        checkRefreshToken.accept(())
                        if isLike {
                            updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                        } else {
                            updatedPost.likes.append(UserDefaultsManager.shared.userID)
                        }
                        owner.originalConvertPosts[value].post = updatedPost
                        newPost.accept(owner.originalConvertPosts[value])
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.prefetching
            .bind(with: self) { owner, value in
                checkRefreshToken.accept(())
//                input.checkAccessToken.accept(())
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
                            case .failure(let error):
                                networkError.accept(error)
                                showErrorAlert.accept(())
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
        
        return Output(convertPosts: outputConvertPosts, likeTogglePost: newPost, showErrorAlert: showErrorAlert, networkError: networkError)
    }
}
