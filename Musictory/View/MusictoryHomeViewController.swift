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
    private let postCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.postCollectionViewLayout())
    
    let viewModel = MusictoryHomeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    private func configureView() {
        view.backgroundColor = .white
        view.addSubview(postCollectionView)
        
        postCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        postCollectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
    }
    
    private func bind() {
        let refreshPost = PublishRelay<Void>()
        let input = MusictoryHomeViewModel.Input(refreshPost: refreshPost)
        let output = viewModel.transform(input: input)
        refreshPost.accept(())
        
        output.posts
            .bind(to: postCollectionView.rx.items(cellIdentifier: PostCollectionViewCell.identifier, cellType: PostCollectionViewCell.self)) { [weak self] item, value, cell in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    Task {
                        do {
                            let song = try await MusicManager.shared.requsetMusicId(id: value.content1)
                            cell.configureCell(post: value, song: song)
                            cell.songView.rx
                                .tapGesture()
                                .when(.recognized)
                                .bind(with: self) { owner, tap in
                                    owner.showAlert(title: "\(song.title)의 앨범으로 이동합니다.", message: nil) {
                                        print(song.url?.absoluteString)
                                        if let url = URL(string: "\(song.url!.absoluteString)") {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                let musicPlayer = MPMusicPlayerController.systemMusicPlayer
                                                print(song.id)
                                                musicPlayer.setQueue(with: ["\(song.id.rawValue)"])
                                                musicPlayer.play()
                                            } else {
                                                // Handle case where app cannot be opened
                                                print("Cannot open Apple Music app")
                                            }
                                        } else {
                                            // Handle case where URL is invalid
                                            print("Invalid URL for Apple Music app")
                                        }
                                    }
                                }
                                .disposed(by: self.disposeBag)
                        }
                        catch {
                            print(error)
                        }
                        
                    }
                }
                cell.layer.cornerRadius = 12
                cell.clipsToBounds = true
            }
            .disposed(by: disposeBag)
    }
    
    func showAlert(title: String?, message: String?, completionHandelr: (()->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let open = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandelr?()
        }
        alert.addAction(open)
        
        present(alert, animated: true)
    }
    
}
