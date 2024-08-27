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
    private var viewModel: MusictoryHomeViewModel!
    private let disposeBag = DisposeBag()
    
    let checkAccessToken = PublishRelay<Void>()
    let fetchPost = PublishRelay<Bool>()
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
        
        Task {
            do {
                await MusicAuthorization.request()
            } catch {
                
            }
        }
    }
    
    private func bind() {
        viewModel = MusictoryHomeViewModel()
        let likePostIndex = PublishRelay<Int>()
        let prefetching = PublishRelay<Bool>()
        let input = MusictoryHomeViewModel.Input(checkAccessToken: checkAccessToken, fetchPost: fetchPost, likePostIndex: likePostIndex, prefetching: prefetching)
        let output = viewModel.transform(input: input)
        
        checkAccessToken.accept(())
        fetchPost.accept(true)
        
        output.showErrorAlert
            .withLatestFrom(output.networkError)
            .bind(with: self) { owner, error in
                self.showAlert(title: error.title, message: error.alertMessage) {
                    
                    switch error {
                    case .expiredAccessToken:
                        print(error, 1)
                        
                    case .expiredRefreshToken:
                        UserDefaultsManager.shared.accessT = ""
                        UserDefaultsManager.shared.refreshT = ""
                        UserDefaultsManager.shared.userID = ""
                        
                        let vc = LogInViewController()
                        self.setRootViewController(vc)
                        
                    default:
                        print(error)
                    }
                }
            }
            .disposed(by: disposeBag)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, ConvertPost>>(configureCell: { _, collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configureCell(.home, post: item.post)
            if let song = item.song {
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
        })
        
        let indexPaths = PublishRelay<[IndexPath]>()
        postCollectionView.rx.prefetchItems
            .bind(to: indexPaths)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(indexPaths, output.convertPosts)
            .map { (indexPaths, posts) in
                for indexPath in indexPaths {
                    if posts.count - 6 == indexPath.item {
                        print(indexPath.item)
                        return true
                    } else {
                        return false
                    }
                }
                return false
            }
            .bind(to: prefetching)
            .disposed(by: disposeBag)
        
        output.convertPosts
            .map({ [SectionModel(model: "", items: $0)] })
            .bind(to: postCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable.zip(input.likePostIndex, output.likeTogglePost)
            .bind(with: self) { owner, value in
                guard let cell = owner.postCollectionView.cellForItem(at: IndexPath(item: value.0, section: 0)) as? PostCollectionViewCell else {
                    return
                }
                
                cell.configureCell(.home, post: value.1.post)
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
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(with: self) { owner, _ in
                owner.updateCollectionViewMethod()
            }
            .disposed(by: disposeBag)
    }
    
    @objc func updateCollectionView(_ notification: Notification) {
        updateCollectionViewMethod()
    }
    
    func updateCollectionViewMethod() {
        refreshControl.beginRefreshing()
        postCollectionView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.height), animated: true)
        checkAccessToken.accept(())
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) {
            self.fetchPost.accept(true)
            self.refreshControl.endRefreshing()
        }
    }
}
