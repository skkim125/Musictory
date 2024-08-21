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
        let fetchPost = PublishRelay<Void>()
        let input = MusictoryHomeViewModel.Input(fetchPost: fetchPost)
        let output = viewModel.transform(input: input)
        fetchPost.accept(())
        
        output.posts
            .bind(to: postCollectionView.rx.items(cellIdentifier: PostCollectionViewCell.identifier, cellType: PostCollectionViewCell.self)) { [weak self] item, value, cell in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    Task {
                        let song = try await MusicManager.shared.requsetMusicId(id: value.content1)
                        cell.configureCell(post: value, song: song)
                        cell.songView.rx
                            .tapGesture()
                            .when(.recognized)
                            .bind(with: self) { owner, tap in
                                owner.showTwoButtonAlert(title: "\(song.title)을 재생하기 위해 Apple Music으로 이동합니다.", message: nil) {
                                    MusicManager.shared.playSong(song: song)
                                }
                            }
                            .disposed(by: self.disposeBag)
                    }
                }
                cell.layer.cornerRadius = 12
                cell.clipsToBounds = true
            }
            .disposed(by: disposeBag)
    }
}
