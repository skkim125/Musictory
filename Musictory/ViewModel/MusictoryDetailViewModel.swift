//
//  MusictoryDetailViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class MusictoryDetailViewModel: BaseViewModel {
    deinit {
        print("==== MusictoryDetailViewModel deinit ==== ")
    }
    
    
    init () {
        print("==== MusictoryDetailViewModel init ==== ")
    }
    
    private let lslp_API = LSLP_API.shared
    private let disposeBag = DisposeBag()
    
    struct Input {
        let checkAccessToken: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
        let currentPost: PublishRelay<ConvertPost?>
    }
    
    struct Output {
        let postDetailData: BehaviorRelay<[PostDetailType]>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let inputCurrentPost = input.currentPost
        let checkRefreshToken = PublishRelay<Void>()
        let showErrorAlert = PublishRelay<Void>()
        let networkError = PublishRelay<NetworkError>()
        let postData = BehaviorRelay<[PostDetailType]>(value: [])
        
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
        
        inputCurrentPost
            .map {
                post in
                guard let post = post else { return []}
                let convertComments = post.post.comments.map { PostDetailItem.commentItem(item: $0) }
                
                let result = PostDetailType.post(items: convertComments)
                
                let data = [PostDetailType.post(items: [PostDetailItem.postItem(item: post)]), result]

                return data
            }
            .bind(with: self, onNext: { owner, value in
                postData.accept(value)
            })
            .disposed(by: disposeBag)
        
//        input.likePostIndex
//            .bind(with: self) { owner, value in
//                var updatedPost = owner.originalPosts[value]
//                print(#function, 3, updatedPost.likes)
//                
//                var isLike = updatedPost.likes.contains(UserDefaultsManager.shared.userID)
//                print(#function, 3, isLike)
//                
//                if isLike {
//                    updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
//                } else {
//                    updatedPost.likes.append(UserDefaultsManager.shared.userID)
//                }
//                isLike.toggle()
//                print(#function, 33, isLike)
//                owner.originalPosts[value] = updatedPost
//                let likeQuery = LikeQuery(like_status: isLike)
//                
//                owner.lslp_API.callRequest(apiType: .like(owner.originalPosts[value].postID, likeQuery), decodingType: LikeModel.self) { result in
//                    switch result {
//                    case .success(let success):
//                        print(#function, 3, success)
//                        print(#function, 3, owner.originalPosts[value].postID)
//                        owner.originalPosts[value] = updatedPost
//                        myPosts.accept(owner.originalPosts)
//                        
//                    case .failure(let error):
//                        if isLike {
//                            updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
//                        } else {
//                            updatedPost.likes.append(UserDefaultsManager.shared.userID)
//                        }
//                        owner.originalPosts[value] = updatedPost
//                        myPosts.accept(owner.originalPosts)
//                        networkError.accept(error)
//                        showErrorAlert.accept(())
//                    }
//                }
//            }
//            .disposed(by: disposeBag)
        
        return Output(postDetailData: postData, showErrorAlert: showErrorAlert, networkError: networkError)
    }
}
