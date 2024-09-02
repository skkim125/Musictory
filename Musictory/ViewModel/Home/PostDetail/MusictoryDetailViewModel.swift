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
    private var currentPost: PostModel?
    
    struct Input {
        let updateAccessToken: PublishRelay<Void>
        let likePostIndex: PublishRelay<Int>
        let currentPost: PublishRelay<PostModel?>
        let commentText: ControlProperty<String>
        let sendCommendButtonTap: ControlEvent<Void>
        let backButtonTap: PublishRelay<Void>
    }
    
    struct Output {
        let postDetailData: BehaviorRelay<[PostDetailDataType]>
        let showErrorAlert: PublishRelay<NetworkError>
        let outputButtonEnable: Observable<Bool>
        let finalPost: PublishRelay<PostModel>
        let backButtonTapAction: PublishRelay<Void>
        let commentSendEnd: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        var postID = ""
        let inputCurrentPost = PublishRelay<PostModel?>()
        let showErrorAlert = PublishRelay<NetworkError>()
        let postData = BehaviorRelay<[PostDetailDataType]>(value: [])
        let finalPost = PublishRelay<PostModel>()
        let backButtonTapAction = PublishRelay<Void>()
        let sendEnd = PublishRelay<Void>()
        
        let commentIsEmpty = input.commentText
            .map({ !$0.trimmingCharacters(in: .whitespaces).isEmpty })
        
        input.currentPost
            .bind(with: self) { owner, value in
                guard let post = value else { return }
                
                owner.lslp_API.callRequest(apiType: .fetchPostOfReload(post.postID, PostQuery()), decodingType: PostModel.self) { result in
                    switch result {
                    case .success(let success):
                        var convert = post
                        convert = success
                        inputCurrentPost.accept(convert)
                    case .failure(let error):
                        showErrorAlert.accept(error)
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
                let convertComments = post.comments.map { PostDetailItem.commentItem(item: $0) }
                print(111111,postID)
                postID = post.postID
                print(111111,postID)
                let result = PostDetailDataType.post(items: convertComments)
                
                let data = [PostDetailDataType.post(items: [PostDetailItem.postItem(item: post)]), result]

                return data
            }
            .bind(with: self, onNext: { owner, value in
                postData.accept(value)
            })
            .disposed(by: disposeBag)
        
        
        input.sendCommendButtonTap
            .withLatestFrom(input.commentText)
            .bind(with: self) { owner, value in
                let query = CommentsQuery(content: "\(value)")
                owner.lslp_API.callRequest(apiType: .writeComment(postID, query), decodingType: CommentModel.self) { result in
                    switch result {
                    case .success(let success):
                        guard let before = owner.currentPost else { return }
                        var afterPost = before
                        afterPost.comments.insert(success, at: 0)
                        
                        owner.lslp_API.callRequest(apiType: .fetchPostOfReload(postID, PostQuery()), decodingType: PostModel.self) { result in
                            switch result {
                            case .success(let success):
                                var convert = afterPost
                                convert = success
                                inputCurrentPost.accept(convert)
                            case .failure(let error):
                                showErrorAlert.accept(error)
                            }
                        }
                        
                        sendEnd.accept(())
                        inputCurrentPost.accept(afterPost)
                        
//                        NotificationCenter.default.post(name: Notification.Name("updateOfComment"), object: nil, userInfo: ["updateOfComment": afterPost.post])
                        
                    case .failure(let error1):
                        showErrorAlert.accept(error1)
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
                        showErrorAlert.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.likePostIndex
            .withLatestFrom(finalPost)
            .bind(with: self) { owner, value in
                var updatedPost = value
                print(#function, 3, updatedPost)
                
                let isLike = updatedPost.likes.contains(UserDefaultsManager.shared.userID)
                print(#function, 3, isLike)
                
                if isLike {
                    updatedPost.likes.removeAll { $0 == UserDefaultsManager.shared.userID }
                } else {
                    updatedPost.likes.append(UserDefaultsManager.shared.userID)
                }
                
                inputCurrentPost.accept(updatedPost)
            }
            .disposed(by: disposeBag)
        
        input.backButtonTap
            .withLatestFrom(finalPost)
            .bind(with: self) { owner, value in
                let isLike = value.likes.contains(UserDefaultsManager.shared.userID)
                let likeQuery = LikeQuery(like_status: isLike)
                
                owner.lslp_API.callRequest(apiType: .like(value.postID, likeQuery), decodingType: LikeModel.self) { result in
                    switch result {
                    case .success:
                        owner.lslp_API.callRequest(apiType: .fetchPostOfReload(postID, PostQuery()), decodingType: PostModel.self) { result in
                            switch result {
                            case .success(let success):
                                var convert = value
                                convert = success
                                finalPost.accept(convert)
                                NotificationCenter.default.post(name: Notification.Name("updatePostOfDetailView"), object: nil, userInfo: ["updatePostOfDetailView": success])
                                backButtonTapAction.accept(())
                            case .failure(let error):
                                showErrorAlert.accept(error)
                            }
                        }
                        
                    case .failure(let error):
                        guard let beforePost = owner.currentPost else { return }
                        finalPost.accept(beforePost)
                        showErrorAlert.accept(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(postDetailData: postData, showErrorAlert: showErrorAlert, outputButtonEnable: commentIsEmpty, finalPost: finalPost, backButtonTapAction: backButtonTapAction, commentSendEnd: sendEnd)
    }
}
