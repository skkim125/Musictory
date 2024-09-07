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

final class MusictoryDetailViewController: UIViewController {
    deinit {
        print("\(self) deinit")
    }
    private let musictoryDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout(.myPage))
    private let commentTFBackgroundView = UIView()
    private let commentTextField = UITextField()
    private let sendCommentButton = UIButton(type: .system)
    private let divider = UIView()
    let viewModel = MusictoryDetailViewModel()
    var currentPostIndex: Int?
    var currentPost: PostModel?
    var moveData: ((PostModel?)->Void)?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind(currentPost: currentPost)
    }
    
    private func configureView() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis"), menu: configureMenuButton())
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
    
    private func bind(currentPost: PostModel?) {
        let updateAccessToken = PublishRelay<Void>()
        let likePostIndex = PublishRelay<Int>()
        let post = PublishRelay<PostModel?>()
        let backButtonTap = PublishRelay<Void>()
        
        let input = MusictoryDetailViewModel.Input(updateAccessToken: updateAccessToken , likePostIndex: likePostIndex, currentPost: post, commentText: commentTextField.rx.text.orEmpty, sendCommendButtonTap: sendCommentButton.rx.tap, backButtonTap: backButtonTap)
        let output = viewModel.transform(input: input)
        updateAccessToken.accept(())
        post.accept(currentPost)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<PostDetailDataType> (configureCell: { [weak self] _, collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case .postItem(item: let post):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
                
                cell.configureCell(.home, post: post)
                
                let songData = Data(post.content1.utf8)
                do {
                    let song = try JSONDecoder().decode(SongModel.self, from: songData)
                    
                    cell.configureSongView(song: song, viewType: .home) { tapGesture in
                        tapGesture
                            .bind(with: self) { owner, _ in
                                owner.showTwoButtonAlert(title: "\(song.title)을 재생하기 위해 Apple Music으로 이동합니다.", message: nil) {
                                    MusicManager.shared.playSong(song: song)
                                }
                            }
                            .disposed(by: cell.disposeBag)
                    }
                } catch {
                    
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
            .bind(with: self) { owner, error in
                owner.showAlert(title: error.title, message: error.alertMessage) {
                    switch error {
                    case .custom(let error1):
                        print(error1)
                        owner.dismiss(animated: true)
                    case .expiredRefreshToken:
                        owner.goLoginView()
                    default:
                        owner.dismiss(animated: true)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        output.outputButtonEnable
            .bind(to: sendCommentButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                backButtonTap.accept(())
            }
            .disposed(by: disposeBag)
        
        output.backButtonTapAction
            .withLatestFrom(output.finalPost)
            .bind(with: self) { owner, value in
                print(value)
                owner.moveData?(value)
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.commentSendEnd
            .bind(with: self) { owner, _ in
                owner.commentTextField.rx.text.onNext(nil)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureMenuButton() -> UIMenu {
        guard let post = currentPost else { return UIMenu() }
        
        let reportPost = UIAction(title: "게시물 신고", image: UIImage(systemName: "exclamationmark.bubble.fill"), handler: { [weak self] _ in
            guard let self = self else { return }
            self.showAlert(title: "신고가 완료되었습니다.", message: "")
        })
        
        if UserDefaultsManager.shared.userID == post.creator.userID {
            let deletePost = UIAction(title: "게시물 삭제", image: UIImage(systemName: "pencil"), handler: { [weak self] _ in
                guard let self = self else { return }
                self.showTwoButtonAlert(title: "게시물을 삭제하시겠습니까?", message: "삭제 이후 되돌릴 수 없습니다. ") {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            
            return UIMenu(title: "설정", options: .displayInline, children: [deletePost, reportPost])
        } else {
            return UIMenu(title: "설정", options: .displayInline, children: [reportPost])
        }
    }
}
