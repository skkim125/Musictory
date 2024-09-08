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
    private let lslp_API = LSLP_Manager.shared
    private var originalPosts: [PostModel] = []
    var toUseEditMyProfile: ProfileModel?
    let disposeBag = DisposeBag()
    
    struct Input {
        let checkAccessToken: PublishRelay<Void>
        let loadMyProfile: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
        let prefetching: PublishRelay<Bool>
    }
    
    struct Output {
        let myProfile: PublishRelay<ProfileModel>
        let myPosts: PublishRelay<[PostModel]>
        let myPageData: PublishRelay<[MyPageDataType]>
        let showErrorAlert: PublishRelay<NetworkError>
        let myGetLiked: BehaviorRelay<Int>
    }
    
    func transform(input: Input) -> Output {
        var nextCursor = ""
        let loadMyPosts = PublishRelay<Void>()
        let myProfile = PublishRelay<ProfileModel>()
        let myPosts = PublishRelay<[PostModel]>()
        let showErrorAlert = PublishRelay<NetworkError>()
        let myPageData = PublishRelay<[MyPageDataType]>()
        let outputGetLiked = BehaviorRelay(value: originalPosts.count)
        
        input.checkAccessToken
            .bind(with: self) { owner, _ in
                owner.lslp_API.updateRefresh { result in
                    switch result {
                    case .success(let success):
                        UserDefaultsManager.shared.accessT = success.accessToken
                        print(success.accessToken)
                    case .failure(let error):
                        showErrorAlert.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.loadMyProfile
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .fetchProfile, decodingType: ProfileModel.self) { result in
                    switch result {
                    case .success(let profile):
                        dump(profile)
                        print("마이페이지", profile.posts.count)
                        print("마이페이지 userdefaults id", UserDefaultsManager.shared.userID)
                        myProfile.accept(profile)
                        loadMyPosts.accept(())
                    case .failure(let error1):
                        switch error1 {
                        case .expiredAccessToken, .expiredRefreshToken:
                            owner.lslp_API.updateRefresh { result in
                                switch result {
                                case .success(let success):
                                    UserDefaultsManager.shared.accessT = success.accessToken
                                    loadMyPosts.accept(())
                                case .failure(let error2):
                                    showErrorAlert.accept(error2)
                                }
                            }
                            
                        default:
                            showErrorAlert.accept(error1)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        loadMyPosts
            .bind(with: self) { owner, _ in
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
                                case .failure(let error2):
                                    showErrorAlert.accept(error2)
                                }
                            }
                            
                        default:
                            showErrorAlert.accept(error1)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        myPosts
            .bind(with: self) { owner, value in
                DispatchQueue.main.async {
                    var like = 0
                    value.forEach { post in
                        like += post.likes.count
                    }
                    
                    outputGetLiked.accept(like)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(myProfile, myPosts)
            .map { [weak self] (profile, posts) -> [MyPageDataType] in
                if let self = self {
                    self.toUseEditMyProfile = profile
                }
                let convertPosts = posts.map { MyPageItem.postItem(item: $0) }
                let result = MyPageDataType.post(items: convertPosts)
                print("마이페이지", convertPosts.count)
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
                        NotificationCenter.default.post(name: Notification.Name("changeLikePost"), object: nil, userInfo: ["post": updatedPost])
                        
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
                                    showErrorAlert.accept(error2)
                                }
                            }
                        default:
                            showErrorAlert.accept(error1)
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
        
        return Output(myProfile: myProfile, myPosts: myPosts, myPageData: myPageData, showErrorAlert: showErrorAlert, myGetLiked: outputGetLiked)
    }
}
