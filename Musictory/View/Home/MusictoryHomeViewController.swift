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
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        
        fetchPost.onNext(())
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
        let likePostIndex = PublishRelay<Int>()
        let indexPaths = PublishRelay<[IndexPath]>()
        let input = MusictoryHomeViewModel.Input(updateAccessToken: updateAccessToken ,fetchPost: fetchPost, likePostIndex: likePostIndex, prefetchIndexPatch: indexPaths)
        let output = viewModel.transform(input: input)
        
        output.showErrorAlert
            .bind(with: self) { owner, error in
                self.showAlert(title: error.title, message: error.alertMessage) {
                    UserDefaultsManager.shared.accessT = ""
                    UserDefaultsManager.shared.refreshT = ""
                    UserDefaultsManager.shared.userID = ""
                    
                    let vc = LogInViewController()
                    self.setRootViewController(vc)
                }
            }
            .disposed(by: disposeBag)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, ConvertPost>>(configureCell: { _, collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configureCell(.home, post: item.post)
            if let song = item.song {
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
        })
        
        postCollectionView.rx.modelSelected(ConvertPost.self)
            .bind(with: self) { owner, value in
                let vc = MusictoryDetailView(/*post: value.0*/)
                vc.currentPost = value
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        postCollectionView.rx.prefetchItems
            .bind(to: indexPaths)
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
    
    @objc func updateCollectionView(_ notification: Notification) {
        makeToast(message: "뮤직토리를 기록하였습니다", presentTime: 2)
        
        postCollectionView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.height), animated: true)
        updateCollectionViewMethod()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("updatePost"), object: nil)
    }
    
    func updateCollectionViewMethod() {
        refreshControl.beginRefreshing()
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.5) {
            self.fetchPost.onNext(())
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAccessToken.onNext(())
        
    }
}
