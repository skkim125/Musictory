//
//  MyPageViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/24/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MyPageViewModel: BaseViewModel {
    private let lslp_API = LSLP_API.shared
    private var originalConvertPosts: [ConvertPost] = []
    private var originalPosts: [PostModel] = []
    let disposeBag = DisposeBag()
    
    struct Input {
        let checkRefreshToken: PublishRelay<Void>
        let loadMyProfile: PublishRelay<Void>
        let loadMyPosts: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
        let prefetching: PublishRelay<Bool>
    }
    
    struct Output {
        let myProfile: PublishRelay<ProfileModel>
        let myPosts: PublishRelay<[PostModel]>
        let myPageData: PublishRelay<[MyPageDataType]>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        var nextCursor = ""
        let checkRefreshToken = PublishRelay<Void>()
        let myProfile = PublishRelay<ProfileModel>()
        let myPosts = PublishRelay<[PostModel]>()
        let showErrorAlert = PublishRelay<Void>()
        let networkError = PublishRelay<NetworkError>()
        let myPageData = PublishRelay<[MyPageDataType]>()
        let outputConvertPosts = PublishRelay<[ConvertPost]>()
        
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
        
        input.loadMyProfile
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .fetchProfile, decodingType: ProfileModel.self) { result in
                    switch result {
                    case .success(let profile):
                        myProfile.accept(profile)
                    case .failure(let error1):
                        switch error1 {
                        case .expiredAccessToken, .expiredRefreshToken:
                            owner.lslp_API.updateRefresh { result in
                                switch result {
                                case .success(let success):
                                    UserDefaultsManager.shared.accessT = success.accessToken
                                    input.loadMyProfile.accept(())
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
        
        input.loadMyPosts
            .bind(with: self) { owner, _ in
                nextCursor = "0"
                owner.lslp_API.callRequest(apiType: .fetchMyPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                    switch result {
                    case .success(let posts):
                        owner.originalPosts = posts.data
                        myPosts.accept(owner.originalPosts)
                        if posts.nextCursor != "0" {
                            nextCursor = posts.nextCursor
                        }
                        
                    case .failure(let error1):
                        switch error1 {
                        case .expiredAccessToken, .expiredRefreshToken:
                            owner.lslp_API.updateRefresh { result in
                                switch result {
                                case .success(let success):
                                    UserDefaultsManager.shared.accessT = success.accessToken
                                    input.loadMyPosts.accept(())
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
        
        myPosts
            .bind(with: self) { owner, value in
                Task {
                    try await convertPostFunction(posts: value)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(myProfile, outputConvertPosts)
            .map { (profile, posts) -> [MyPageDataType] in
                let convertPosts = posts.map { MyPageItem.postItem(item: $0) }
                let result = MyPageDataType.post(items: convertPosts)
                return [MyPageDataType.profile(items: [MyPageItem.profileItem(item: profile)]), result]
            }
            .bind(to: myPageData)
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .bind(with: self) { owner, value in
                var updatedPost = owner.originalPosts[value]
                print(#function, 3, updatedPost.likes)
                
                var isLike = updatedPost.likes.contains(UserDefaultsManager.shared.userID)
                print(#function, 3, isLike)
                
                if isLike {
                    updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                } else {
                    updatedPost.likes.append(UserDefaultsManager.shared.userID)
                }
                isLike.toggle()
                print(#function, 33, isLike)
                owner.originalPosts[value] = updatedPost
                let likeQuery = LikeQuery(like_status: isLike)
                
                owner.lslp_API.callRequest(apiType: .like(owner.originalPosts[value].postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(#function, 3, success)
                        print(#function, 3, owner.originalPosts[value].postID)
                        owner.originalPosts[value] = updatedPost
                        myPosts.accept(owner.originalPosts)
                        
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
                                    owner.originalPosts[value] = updatedPost
                                    myPosts.accept(owner.originalPosts)
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
                                myPosts.accept(owner.originalPosts)
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
        
        return Output(myProfile: myProfile, myPosts: myPosts, myPageData: myPageData, showErrorAlert: showErrorAlert, networkError: networkError)
    }
}
