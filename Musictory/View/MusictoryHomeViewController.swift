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
import RxDataSources
import MusicKit
import MediaPlayer

final class MusictoryHomeViewController: UIViewController {
    let postCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout(.home))
    let viewModel = MusictoryHomeViewModel()
    let disposeBag = DisposeBag()
    
    let fetchPost = PublishRelay<Void>()
    private var refreshControl = UIRefreshControl()
    private let refreshLoading = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
    }
    
    private func configureView() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont.boldSystemFont(ofSize: 25)]
        navigationItem.title = "Musictory"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map.fill"), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .systemRed
        
        view.backgroundColor = .systemBackground
        view.addSubview(postCollectionView)
        
        postCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        postCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView(_: )), name: Notification.Name(rawValue: "updatePost"), object: nil)
    }
    
    private func bind() {
        let checkRefreshToken = PublishRelay<Void>()
        let likePostIndex = PublishRelay<Int>()
        let input = MusictoryHomeViewModel.Input(fetchPost: fetchPost, checkRefreshToken: checkRefreshToken, likePostIndex: likePostIndex)
        let output = viewModel.transform(input: input)
        
        fetchPost.accept(())
        checkRefreshToken.accept(())
        
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
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PostModel>>(configureCell: { _, collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configureCell(.home, post: item)
            
            Task {
                let group = DispatchGroup()
                
                group.enter()
                let song = try await MusicManager.shared.requsetMusicId(id: item.content1)
                group.leave()
                
                group.notify(queue: .main) {
                    cell.songView.configureUI(song: song)
                }
                
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
            
            cell.likeButton.rx.tap
                .map({
                    return indexPath.item
                })
                .bind(to: likePostIndex)
                .disposed(by: cell.disposeBag)
            
            cell.layer.cornerRadius = 12
            cell.clipsToBounds = true
            
            return cell
        })
        
        output.posts
            .map({ [SectionModel(model: "", items: $0)] })
            .bind(to: postCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                let vc = MusictoryMapViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        postCollectionView.rx.refreshControl.onNext(refreshControl)
        
        updateCollectionViewMethod()
    }
    
    @objc func updateCollectionView(_ notification: Notification) {
        updateCollectionViewMethod()
    }
    
    func updateCollectionViewMethod() {
        postCollectionView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.height), animated: true)
        refreshControl.beginRefreshing()
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(with: self) { owner, _ in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
                    owner.fetchPost.accept(())
                    owner.refreshControl.endRefreshing()
                }
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
