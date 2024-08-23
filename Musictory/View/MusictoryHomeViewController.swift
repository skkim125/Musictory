//
//  MusictoryHomeViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/19/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import MusicKit
import MediaPlayer

final class MusictoryHomeViewController: UIViewController {
    private let postCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout())
    let viewModel = MusictoryHomeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    private func configureView() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont.boldSystemFont(ofSize: 25)]
        navigationItem.title = "Musictory"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map.fill"), style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .systemRed
        
        view.backgroundColor = .systemBackground
        view.addSubview(postCollectionView)
        
        postCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        postCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
    }
    
    private func bind() {
        let fetchPost = PublishRelay<Void>()
        let checkRefreshToken = PublishRelay<Void>()
        let likePostIndex = PublishRelay<Int>()
        let input = MusictoryHomeViewModel.Input(fetchPost: fetchPost, checkRefreshToken: checkRefreshToken, likePostIndex: likePostIndex)
        let output = viewModel.transform(input: input)
        
        fetchPost.accept(())
        checkRefreshToken.accept(())
        
        output.showErrorAlert
            .bind(with: self) { owner, _ in
                self.showAlert(title: NetworkError.expiredRefreshToken.title, message: NetworkError.expiredRefreshToken.alertMessage) {
                    UserDefaultsManager.shared.accessT = ""
                    UserDefaultsManager.shared.refreshT = ""
                    UserDefaultsManager.shared.userID = ""
                    
                    let vc = LogInViewController()
                    self.setRootViewController(vc)
                }
            }
            .disposed(by: disposeBag)
        
        output.posts
            .bind(to: postCollectionView.rx.items(cellIdentifier: PostCollectionViewCell.identifier, cellType: PostCollectionViewCell.self)) { item, value, cell in
                Task {
                    let song = try await MusicManager.shared.requsetMusicId(id: value.content1)
                    
                    cell.configureCell(post: value, song: song)
                    
                    cell.likeButton.rx.tap
                        .map({
                            print(#function, item)
                           return item
                        })
                        .bind(to: likePostIndex)
                        .disposed(by: cell.disposeBag)
                    
                    cell.songView.rx
                        .tapGesture()
                        .when(.recognized)
                        .bind(with: self) { owner, _ in
                            owner.showTwoButtonAlert(title: "\(song.title)을 재생하기 위해 Apple Music으로 이동합니다.", message: nil) {
                                MusicManager.shared.playSong(song: song)
                            }
                        }
                        .disposed(by: cell.disposeBag)
                }
                
                output.newPost
                    .bind(with: self) { owner, model in
                        print("model =", model)
                        cell.configureLikeButtonUI(like: model.isLike)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.layer.cornerRadius = 12
                cell.clipsToBounds = true
            }
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                let vc = UIViewController()
                vc.view.backgroundColor = .systemBackground
                vc.navigationItem.title = owner.viewModel.loginUser?.nick
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                let vc = WriteMusictoryViewController()
                
                vc.bindData = {
                    owner.postCollectionView.reloadData()
                    fetchPost.accept(())
                }
                
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
