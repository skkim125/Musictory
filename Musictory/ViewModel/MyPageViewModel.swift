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
    private var finalPosts: [ConvertPost] = []
    private var originalPosts: [PostModel] = []
    let disposeBag = DisposeBag()
    
    struct Input {
        let loadMyProfile: PublishRelay<Void>
        let loadMyPosts: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
        let prefetching: PublishRelay<Bool>
    }
    
    struct Output {
        let myProfile: PublishRelay<ProfileModel>
        let myPosts: PublishRelay<[PostModel]>
        let myPageData: PublishRelay<[SectionMyPageData]>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        var nextCursor = ""
        let myProfile = PublishRelay<ProfileModel>()
        let myPosts = PublishRelay<[PostModel]>()
        let showErrorAlert = PublishRelay<Void>()
        let networkError = PublishRelay<NetworkError>()
        let myPageData = PublishRelay<[SectionMyPageData]>()
        
        input.loadMyProfile
            .bind(with: self) { owner, _ in
                LSLP_API.shared.callRequest(apiType: .fetchProfile, decodingType: ProfileModel.self) { result in
                    switch result {
                    case .success(let profile):
                        myProfile.accept(profile)
                    case .failure(let error):
                        print("마이페이지", error.localizedDescription)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.loadMyPosts
            .bind(with: self) { owner, _ in
                nextCursor = "0"
                LSLP_API.shared.callRequest(apiType: .fetchMyPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
                    switch result {
                    case .success(let posts):
                        owner.originalPosts = posts.data
                        myPosts.accept(owner.originalPosts)
                        if posts.nextCursor != "0" {
                            nextCursor = posts.nextCursor
                        }
                        
                    case .failure(let error):
                        print("마이 포스트", error.localizedDescription)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(myProfile, myPosts)
            .map { (profile, posts) -> [SectionMyPageData] in
                let convertPosts = posts.map { MyPageData(type: .post, data: $0) }
                
                return [SectionMyPageData(header: "Profile", items: [MyPageData(type: .profile, data: profile)]), SectionMyPageData(header: "MyPosts", items: convertPosts) ]
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
                
                LSLP_API.shared.callRequest(apiType: .like(owner.originalPosts[value].postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(#function, 3, success)
                        print(#function, 3, owner.originalPosts[value].postID)
                        owner.originalPosts[value] = updatedPost
                        myPosts.accept(owner.originalPosts)
                        
                    case .failure(let error):
                        if isLike {
                            updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                        } else {
                            updatedPost.likes.append(UserDefaultsManager.shared.userID)
                        }
                        owner.originalPosts[value] = updatedPost
                        myPosts.accept(owner.originalPosts)
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
                        LSLP_API.shared.callRequest(apiType: .fetchPost(PostQuery(next: nextCursor)), decodingType: fetchPostModel.self) { result in
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
