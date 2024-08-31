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
    private var currentPost: ConvertPost?
    
    struct Input {
        let updateAccessToken: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
        let currentPost: PublishRelay<ConvertPost?>
        let commentText: ControlProperty<String>
        let sendCommendButtonTap: ControlEvent<Void>
        let backButtonTap: PublishRelay<Void>
    }
    
    struct Output {
        let postDetailData: BehaviorRelay<[PostDetailType]>
        let showErrorAlert: PublishRelay<Void>
        let networkError: PublishRelay<NetworkError>
        let outputButtonEnable: Observable<Bool>
        let finalPost: PublishRelay<ConvertPost>
        let backButtonTapAction: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        var postID = ""
        let inputCurrentPost = input.currentPost
        let showErrorAlert = PublishRelay<Void>()
        let networkError = PublishRelay<NetworkError>()
        let postData = BehaviorRelay<[PostDetailType]>(value: [])
        let finalPost = PublishRelay<ConvertPost>()
        let backButtonTapAction = PublishRelay<Void>()
        
        let commentIsEmpty = input.commentText
            .map({ !$0.trimmingCharacters(in: .whitespaces).isEmpty })
        
        input.sendCommendButtonTap
            .withLatestFrom(input.commentText)
            .bind(with: self) { owner, value in
                let query = CommentsQuery(content: "\(value)")
                owner.lslp_API.callRequest(apiType: .writeComment(postID, query), decodingType: CommentModel.self) { result in
                    switch result {
                    case .success(let success):
                        print(success)
                    case .failure(let error1):
                        owner.lslp_API.updateRefresh { result in
                            switch result {
                            case .success:
                                owner.lslp_API.callRequest(apiType: .writeComment(value, query), decodingType: CommentModel.self)
                            case .failure(let error2):
                                networkError.accept(error2)
                                showErrorAlert.accept(())
                            }
                        }
                        networkError.accept(error1)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.updateAccessToken
            .bind(with: self) { owner, _ in
                owner.lslp_API.updateRefresh { result in
                    switch result {
                    case .success(let success):
                        UserDefaultsManager.shared.accessT = success.accessToken
                        print(#function, "UserDefaultsManager.shared.accessT = \(UserDefaultsManager.shared.accessT)")
                    case .failure(let error):
                        showErrorAlert.accept(())
                        networkError.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        inputCurrentPost
            .map { [weak self]
                post in
                guard let post = post, let self = self else { return [] }
                self.currentPost = post
                finalPost.accept(post)
                let convertComments = post.post.comments.map { PostDetailItem.commentItem(item: $0) }
                print(111111,postID)
                postID = post.post.postID
                print(111111,postID)
                let result = PostDetailType.post(items: convertComments)
                
                let data = [PostDetailType.post(items: [PostDetailItem.postItem(item: post)]), result]

                return data
            }
            .bind(with: self, onNext: { owner, value in
                postData.accept(value)
            })
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .withLatestFrom(finalPost)
            .bind(with: self) { owner, value in
                var updatedPost = value
                print(#function, 3, updatedPost.post)
                
                let isLike = updatedPost.post.likes.contains(UserDefaultsManager.shared.userID)
                print(#function, 3, isLike)
                
                if isLike {
                    updatedPost.post.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                } else {
                    updatedPost.post.likes.append(UserDefaultsManager.shared.userID)
                }
                
                inputCurrentPost.accept(updatedPost)
            }
            .disposed(by: disposeBag)
        
        input.backButtonTap
            .withLatestFrom(finalPost)
            .bind(with: self) { owner, value in
                let isLike = value.post.likes.contains(UserDefaultsManager.shared.userID)
                let likeQuery = LikeQuery(like_status: isLike)
                
                owner.lslp_API.callRequest(apiType: .like(value.post.postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success:
                        finalPost.accept(value)
                        backButtonTapAction.accept(())
                        
                    case .failure(let error):
                        guard let beforePost = owner.currentPost else { return }
                        finalPost.accept(beforePost)
                        networkError.accept(error)
                        showErrorAlert.accept(())
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(postDetailData: postData, showErrorAlert: showErrorAlert, networkError: networkError, outputButtonEnable: commentIsEmpty, finalPost: finalPost, backButtonTapAction: backButtonTapAction)
    }
}
