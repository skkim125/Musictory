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
    private let myPostCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout(.myPage))
//    static let titleElementKind = "title-element-kind"
    let disposeBag = DisposeBag()
    let viewModel = MyPageViewModel()
    
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
        let loadMyProfile = PublishRelay<Void>()
        let loadMyPost = PublishRelay<Void>()
        let likePostIndex = PublishRelay<Int>()
        let prefetching = PublishRelay<Bool>()
        let input = MyPageViewModel.Input(loadMyProfile: loadMyProfile, loadMyPosts: loadMyPost, likePostIndex: likePostIndex, prefetching: prefetching)
        let output = viewModel.transform(input: input)

        loadMyProfile.accept(())
        loadMyPost.accept(())
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionMyPageData> (configureCell: { dataSource, collectionView, indexPath, item in
            
            switch item.type {
            case .profile:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.identifier, for: indexPath) as? ProfileCollectionViewCell else { return UICollectionViewCell() }
                
                guard let profile = item.data as? ProfileModel else { return UICollectionViewCell() }
                
                let nickname = profile.nick + "님, 반가워요!"
                cell.configureUI(profileImage: "person.circle", nickname: nickname)
                
                return cell
                
            case .post:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
                
                guard let post = item.data as? PostModel else { return UICollectionViewCell() }
                
                cell.configureCell(.myPage, post: post)

                Task {
                    let group = DispatchGroup()

                    group.enter()
                    let song = try await MusicManager.shared.requsetMusicId(id: post.content1)
                    group.leave()

                    group.notify(queue: .main) {
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
                }
                
                cell.configureLikeButtonTap { likeButtonTap in
                    likeButtonTap
                        .map({
                            return indexPath.item
                        })
                        .bind(to: likePostIndex)
                        .disposed(by: cell.disposeBag)
                }
                
                return cell
            }

        })
        
        output.myPageData
            .bind(to: myPostCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let indexPaths = PublishRelay<[IndexPath]>()
        myPostCollectionView.rx.prefetchItems
            .bind(to: indexPaths)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(indexPaths, output.myPosts)
            .map { (indexPaths, posts) in
                print("row = ", indexPaths.first?.row)
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
}

struct SectionMyPageData {
    var header: String
    var items: [Item]
}

extension SectionMyPageData: SectionModelType {
    typealias Item = MyPageData
    
    init(original: SectionMyPageData, items: [Item]) {
        self = original
        self.items = items
    }
}

struct MyPageData {
    let type: DataType
    let data: Any
}

enum DataType {
    case profile
    case post
}
