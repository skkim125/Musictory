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
    deinit {
        print("\(self)deinit됨")
    }
    private let musictoryDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout(.myPage))
    private let commentTFBackgroundView = UIView()
    private let commentTextField = UITextField()
    private let sendCommentButton = UIButton(type: .system)
    private let divider = UIView()
    var viewModel = MusictoryDetailViewModel()
    var currentPostIndex: Int?
    var currentPost: ConvertPost?
    var moveData: ((ConvertPost?)->Void)?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind(currentPost: currentPost)
    }
    
    private func configureView() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: nil)
        navigationItem.title = "Musictory"
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(musictoryDetailCollectionView)
        view.addSubview(commentTFBackgroundView)
        view.addSubview(divider)
        commentTFBackgroundView.addSubview(commentTextField)
        commentTFBackgroundView.addSubview(sendCommentButton)
        
        musictoryDetailCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        commentTFBackgroundView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.top.equalTo(musictoryDetailCollectionView.snp.bottom)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).inset(2)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(commentTFBackgroundView.snp.top)
            make.horizontalEdges.equalToSuperview()
        }
        
        commentTextField.snp.makeConstraints { make in
            make.verticalEdges.equalTo(commentTFBackgroundView).inset(10)
            make.leading.equalTo(commentTFBackgroundView).inset(15)
        }
        
        sendCommentButton.snp.makeConstraints { make in
            make.height.equalTo(commentTextField.snp.height)
            make.width.equalTo(sendCommentButton.snp.height)
            make.centerY.equalTo(commentTextField)
            make.leading.equalTo(commentTextField.snp.trailing).offset(15)
            make.trailing.equalTo(commentTFBackgroundView.snp.trailing).inset(15)
        }
        
        musictoryDetailCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        musictoryDetailCollectionView.register(PostDetailCommentsCollectionViewCell.self, forCellWithReuseIdentifier: PostDetailCommentsCollectionViewCell.identifier)
        
        divider.backgroundColor = .systemGray5
        
        commentTFBackgroundView.backgroundColor = .systemBackground
        
        commentTextField.borderStyle = .none
        commentTextField.layer.cornerRadius = 15
        commentTextField.clipsToBounds = true
        commentTextField.backgroundColor = .systemGray5
        commentTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        commentTextField.leftViewMode = .always
        commentTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        commentTextField.rightViewMode = .always
        commentTextField.font = .systemFont(ofSize: 15)
        
        sendCommentButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendCommentButton.imageView?.contentMode = .scaleAspectFit
        sendCommentButton.tintColor = .white
        sendCommentButton.layer.cornerRadius = sendCommentButton.bounds.width / 2
        sendCommentButton.clipsToBounds = true
        sendCommentButton.backgroundColor = .systemRed
    }
    
    private func bind(currentPost: ConvertPost?) {
        let updateAccessToken = PublishRelay<Void>()
        let likePostIndex = PublishRelay<Int>()
        let post = PublishRelay<ConvertPost?>()
        let backButtonTap = PublishRelay<Void>()
        
        let input = MusictoryDetailViewModel.Input(updateAccessToken: updateAccessToken , likePostIndex: likePostIndex, currentPost: post, commentText: commentTextField.rx.text.orEmpty, sendCommendButtonTap: sendCommentButton.rx.tap, backButtonTap: backButtonTap)
        let output = viewModel.transform(input: input)
        updateAccessToken.accept(())
        post.accept(currentPost)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<PostDetailType> (configureCell: { dataSource, collectionView, indexPath, item in
            
            switch item {
            case .postItem(item: let post):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
                
                cell.configureCell(.home, post: post.post)
                
                if let song = post.song {
                    cell.configureSongView(song: song, viewType: .home) { tapGesture in
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
        
        output.outputButtonEnable
            .bind(to: sendCommentButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self, onNext: { owner, _ in
                backButtonTap.accept(())
            })
            .disposed(by: disposeBag)
        
        output.backButtonTapAction
            .withLatestFrom(output.finalPost)
            .bind(with: self) { owner, value in
                print(value)
                owner.moveData?(value)
                owner.navigationController?.popViewController(animated: true)
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
