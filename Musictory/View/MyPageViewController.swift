//
//  MyPageViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import RxDataSources

final class MyPageViewController: UIViewController {
    private let myPostCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .myPageCollectionView())
    private let disposeBag = DisposeBag()
    private let viewModel = MyPageViewModel()
    private let checkRefreshToken = PublishRelay<Void>()
    private let loadMyProfile = PublishRelay<Void>()
    private let loadMyPost = PublishRelay<Void>()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        bind()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "마이페이지"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis"), menu: configureMenuButton())
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        view.addSubview(myPostCollectionView)
        
        myPostCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        myPostCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        myPostCollectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.identifier)
    }
    
    private func bind() {
        let likePostIndex = PublishRelay<Int>()
        let prefetching = PublishRelay<Bool>()
        let input = MyPageViewModel.Input(checkRefreshToken: checkRefreshToken, loadMyProfile: loadMyProfile, loadMyPosts: loadMyPost, likePostIndex: likePostIndex, prefetching: prefetching)
        let output = viewModel.transform(input: input)
        
        checkRefreshToken.accept(())
        loadMyProfile.accept(())
        loadMyPost.accept(())
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<MyPageDataType> (configureCell: { dataSource, collectionView, indexPath, item in
            
            switch item {
            case .profileItem(item: let profile):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.identifier, for: indexPath) as? ProfileCollectionViewCell else { return UICollectionViewCell() }
                
                
                let nickname = profile.nick + "님,\n반가워요!"
                cell.configureUI(profileImage: profile.profileImage ?? "", nickname: nickname)
                
                return cell
            case .postItem(item: let post):
                self.view.addSubview(UIImageView(image: UIImage(systemName: "pin")))
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
                
                cell.configureCell(.myPage, post: post.post)
                
                if let song = post.song {
                    cell.configureSongView(song: song, viewType: .myPage) { tapGesture in
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
                
                cell.backgroundColor = .systemBackground
                cell.layer.cornerRadius = 12
                cell.layer.shadowRadius = 1.5
                cell.layer.shadowColor = UIColor.opaqueSeparator.cgColor
                cell.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.layer.shadowOpacity = 0.9
                
                return cell
            }

        })
        
        myPostCollectionView.rx.modelSelected(MyPageDataType.Item.self)
            .bind(with: self) { owner, value in
                switch value {
                case.postItem(item: let item):
                    let vc = MusictoryDetailView()
                    vc.currentPost = item
                    
                    owner.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        output.myPageData
            .bind(to: myPostCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let indexPaths = PublishRelay<[IndexPath]>()
        myPostCollectionView.rx.prefetchItems
            .bind(to: indexPaths)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(indexPaths, output.myPosts)
            .map { (indexPaths, posts) in
                for indexPath in indexPaths {
                    if posts.count - 6 == indexPath.item {
                        return true
                    } else {
                        return false
                    }
                }
                return false
            }
            .bind(to: prefetching)
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
    
    private func configureMenuButton() -> UIMenu {
        let editProfile = UIAction(title: "프로필 수정", image: UIImage(systemName: "pencil"), handler: { _ in
            print("프로필 수정")
        })
        
        let withdraw = UIAction(title: "탈퇴하기", image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), handler: { _ in
            print("탈퇴")
        })
        return UIMenu(title: "설정", options: .displayInline, children: [editProfile, withdraw])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkRefreshToken.accept(())
    }
}

enum MyPageDataType {
    case profile(items: [MyPageItem])
    case post(items: [MyPageItem])
}

extension MyPageDataType: SectionModelType {
    typealias Item = MyPageItem
    
    var items: [MyPageItem] {
        switch self {
        case .profile(items: let items):
            return items.map { $0 }
        case .post(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: MyPageDataType, items: [Item]) {
        switch original {
        case .profile(items: let items):
            self = .post(items: items)
        case .post(items: let items):
            self = .post(items: items)
        }
    }
}

enum MyPageItem {
    case profileItem(item: ProfileModel)
    case postItem(item: ConvertPost)
}
