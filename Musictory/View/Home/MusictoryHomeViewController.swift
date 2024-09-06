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
import RxDataSources
import MusicKit
import MediaPlayer

final class MusictoryHomeViewController: UIViewController {
    private let postCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout(.home))
    private var viewModel: MusictoryHomeViewModel = MusictoryHomeViewModel()
    private let disposeBag = DisposeBag()
    
    private let updateAccessToken = PublishSubject<Void>()
    private let fetchPost = PublishSubject<Void>()
    private var refreshControl = UIRefreshControl()
    private let updatePostActionOfNoti = PublishSubject<PostModel>()
    private let updateMyProfileOfNoti = PublishSubject<ProfileModel>()
    var rxCellHeights = PublishSubject<[IndexPath: CGFloat]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        
        fetchPost.onNext(())
    }
    
    private func configureView() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label, .font: UIFont.boldSystemFont(ofSize: 25)]
        navigationItem.title = "Musictory"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "map.fill"), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .systemRed
        
        view.backgroundColor = .systemBackground
        view.addSubview(postCollectionView)
        
        postCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        postCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        
        notificationCenterObserver()
        
        Task {
            do {
                await MusicAuthorization.request()
            } catch {
                
            }
        }
    }
    
    private func notificationCenterObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView(_: )), name: Notification.Name(rawValue: "updatePost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLikePost(_: )), name: Notification.Name("changeLikePost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCommentPost(_: )), name: Notification.Name("updateOfComment"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePostOfDetailView(_: )), name: Notification.Name("updatePostOfDetailView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMyProfile(_: )), name: Notification.Name("updateProfile"), object: nil)
        
    }
    
    private func bind() {
        let likePostIndex = PublishRelay<Int>()
        let indexPaths = PublishRelay<Int>()
        let updatePost = PublishRelay<(Int, PostModel)>()
        let input = MusictoryHomeViewModel.Input(updateAccessToken: updateAccessToken ,fetchPost: fetchPost, likePostIndex: likePostIndex, prefetchIndex: indexPaths, updatePost: updatePost, updatePostActionOfNoti: updatePostActionOfNoti, updateMyProfileOfNoti: updateMyProfileOfNoti)
        let output = viewModel.transform(input: input)
        
        output.showErrorAlert
            .bind(with: self) { owner, error in
                owner.showAlert(title: error.title, message: error.alertMessage) {
                    owner.goLoginView()
                }
            }
            .disposed(by: disposeBag)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PostModel>>(configureCell: { [weak self] _, collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configureCell(.home, post: item)
            
            let songData = Data(item.content1.utf8)
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
            
            return cell
        })
        
        Observable.zip(postCollectionView.rx.itemSelected, postCollectionView.rx.modelSelected(PostModel.self))
            .bind(with: self) { owner, value in
                let vc = MusictoryDetailView()
                vc.currentPost = value.1
                vc.moveData = { post in
                    guard let post = post else { return }
                    guard let cell = owner.postCollectionView.cellForItem(at: IndexPath(item: value.0.item, section: 0)) as? PostCollectionViewCell else { return }
                    updatePost.accept((value.0.item, post))
                    cell.configureCell(.home, post: post)
                }
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        postCollectionView.rx.prefetchItems
            .compactMap({ $0.last?.row })
            .bind(to: indexPaths)
            .disposed(by: disposeBag)
        
        output.posts
            .map({ [SectionModel(model: "", items: $0)] })
            .bind(to: postCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable.zip(input.likePostIndex, output.likeTogglePost)
            .bind(with: self) { owner, value in
                guard let cell = owner.postCollectionView.cellForItem(at: IndexPath(item: value.0, section: 0)) as? PostCollectionViewCell else {
                    return
                }
                
                cell.configureCell(.home, post: value.1)
            }
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
        
        output.paginating
            .bind(with: self) { owner, value in
                if value {
                    hideLoadingIndicator()
                } else {
                    showLoadingIndicator()
                }
            }
            .disposed(by: disposeBag)
        
        func showLoadingIndicator() {
            DispatchQueue.main.async {
                let loadIndicator = UIActivityIndicatorView(style: .medium)
                loadIndicator.startAnimating()
                
                self.postCollectionView.backgroundView = loadIndicator
            }
        }

        func hideLoadingIndicator() {
            postCollectionView.backgroundView = nil
        }
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(with: self) { owner, _ in
                owner.updateCollectionViewMethod()
            }
            .disposed(by: disposeBag)
    }
    
    @objc func updateLikePost(_ notification: Notification) {
        guard let post = notification.userInfo?["post"] as? PostModel else {
                return
            }
        print(post)
        updatePostActionOfNoti.onNext(post)
    }
    
    @objc private func updateCollectionView(_ notification: Notification) {
        makeToast(message: "뮤직토리를 남겼습니다!", presentTime: 2)
        
        postCollectionView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.height), animated: true)
        updateCollectionViewMethod()
        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
    }
    
    @objc private func updateCommentPost(_ notification: Notification) {
        guard let post = notification.userInfo?["updateOfComment"] as? PostModel else {
                return
            }
        updatePostActionOfNoti.onNext(post)
    }
    
    @objc private func updatePostOfDetailView(_ notification: Notification) {
        guard let post = notification.userInfo?["updatePostOfDetailView"] as? PostModel else {
                return
            }
        updatePostActionOfNoti.onNext(post)
    }
    
    @objc func updateMyProfile(_ notification: Notification) {
        guard let profile = notification.userInfo?["updateProfile"] as? ProfileModel else {
                return
            }
        print(profile)
        updateMyProfileOfNoti.onNext(profile)
    }
    
    func updateCollectionViewMethod() {
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.5) {
            self.refreshControl.endRefreshing()
            self.fetchPost.onNext(())
        }
    }
}
