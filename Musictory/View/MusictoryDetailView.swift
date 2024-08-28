//
//  MusictoryDetailView.swift
//  Musictory
//
//  Created by 김상규 on 8/28/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import MusicKit

final class MusictoryDetailView: UIViewController {
    private let musictoryDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout(.myPage))
    var viewModel = MusictoryDetailViewModel()
    var currentPost: ConvertPost?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind(currentPost: currentPost)
    }
    
    private func configureView() {
        navigationItem.title = "뮤직 토리"
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(musictoryDetailCollectionView)
        
        musictoryDetailCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        musictoryDetailCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        musictoryDetailCollectionView.register(PostDetailCommentsCollectionViewCell.self, forCellWithReuseIdentifier: PostDetailCommentsCollectionViewCell.identifier)
    }
    
    private func bind(currentPost: ConvertPost?) {
        let checkAccessToken = PublishRelay<Void>()
        let likePostIndex = PublishRelay<Int>()
        let post = PublishRelay<ConvertPost?>()
        
        let input = MusictoryDetailViewModel.Input(checkAccessToken: checkAccessToken , likePostIndex: likePostIndex, currentPost: post)
        let output = viewModel.transform(input: input)
        checkAccessToken.accept(())
        
        post.accept(currentPost)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<PostDetailType> (configureCell: { dataSource, collectionView, indexPath, item in
            
            switch item {
            case .postItem(item: let post):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
                
                cell.configureCell(.home, post: post.post)
                
                if let song = post.song {
                    cell.configureSongView(song: song) { tapGesture in
                        tapGesture
                            .bind(with: self) { owner, _ in
                                owner.showTwoButtonAlert(title: "\(song.title)을 재생하기 위해 Apple Music으로 이동합니다.", message: nil) {
                                    MusicManager.shared.playSong(song: song)
                                }
                            }
                            .disposed(by: cell.disposeBag)
                    }
                }
                
                cell.configureLikeButtonTap { likeButtonTap in
                    likeButtonTap
                        .map({
                            return indexPath.item
                        })
                        .bind(with: self) { owner, value in
                            likePostIndex.accept(value)
                        }
                        .disposed(by: cell.disposeBag)
                }
                
                cell.layer.cornerRadius = 12
                cell.clipsToBounds = true
                
                return cell
                
            case .commentItem(item: let comment):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostDetailCommentsCollectionViewCell.identifier, for: indexPath) as? PostDetailCommentsCollectionViewCell else { return UICollectionViewCell() }
                
                cell.configureCell(comment: comment)
                
                return cell
            }

        })
        
        output.postDetailData
            .bind(to: musictoryDetailCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        if let currentPost = currentPost {
//            let test = BehaviorRelay<[PostDetailType]>(value: [])
//            let convertComments = currentPost.post.comments.map { PostDetailItem.commentItem(item: $0) }
//            let result = PostDetailType.post(items: convertComments)
//            
//            let testData = [PostDetailType.post(items: [PostDetailItem.postItem(item: currentPost)]), result]
//            test.accept(testData)
//            
//            test
//                .bind(to: musictoryDetailCollectionView.rx.items(dataSource: dataSource))
//                .disposed(by: disposeBag)
//            
//            
//        }
        
        let indexPaths = PublishRelay<[IndexPath]>()
        musictoryDetailCollectionView.rx.prefetchItems
            .bind(to: indexPaths)
            .disposed(by: disposeBag)
        
        output.showErrorAlert
            .withLatestFrom(output.networkError)
            .bind(with: self) { owner, error in
                self.showAlert(title: error.title, message: error.alertMessage) {
                    if error == NetworkError.expiredRefreshToken {
                        UserDefaultsManager.shared.accessT = ""
                        UserDefaultsManager.shared.refreshT = ""
                        UserDefaultsManager.shared.userID = ""
                        
                        let vc = LogInViewController()
                        self.setRootViewController(vc)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

enum PostDetailType {
    case post(items: [PostDetailItem])
    case comments(items: [PostDetailItem])
}

extension PostDetailType: SectionModelType {
    typealias Item = PostDetailItem
    
    var items: [PostDetailItem] {
        switch self {
        case .post(items: let items):
            return items.map { $0 }
        case .comments(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: PostDetailType, items: [Item]) {
        switch original {
        case .post(items: let items):
            self = .post(items: items)
        case .comments(items: let items):
            self = .comments(items: items)
        }
    }
}

enum PostDetailItem {
    case postItem(item: ConvertPost)
    case commentItem(item: CommentModel)
}
