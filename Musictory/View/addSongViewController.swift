//
//  SelectSongViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MusicKit

final class addSongViewController: UIViewController {
    private let searchBar = {
        let sv = UISearchController(searchResultsController: nil)
        sv.searchBar.placeholder = "뮤직토리에 남길 노래를 검색해보세요"
        
        return sv
    }()
    private let searchResultCollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout())
        cv.register(SearchSongCollectionViewCell.self, forCellWithReuseIdentifier: SearchSongCollectionViewCell.identifier)
        
        return cv
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    private func configureView() {
        navigationItem.title = "노래 추가"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: nil, action: nil)
        navigationItem.searchController = searchBar
        navigationItem.searchController?.searchBar.searchBarStyle = .minimal
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        
        view.addSubview(searchResultCollectionView)
        searchResultCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        let songs = PublishRelay<MusicItemCollection<Song>>()
        
        songs
            .map({ $0.isEmpty })
            .bind(with: self) { owner, value in
                owner.searchResultCollectionView.rx.isHidden.onNext(value)
            }
            .disposed(by: disposeBag)
        
        searchBar.searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.searchBar.rx.text.orEmpty)
            .bind(with: self) { owner, value in
                Task {
                    await MusicManager.shared.searchMusics(search: value, offset: 0) { result in
                        songs.accept(result)
                    }
                }
                
                songs
                    .bind(to: owner.searchResultCollectionView.rx.items(cellIdentifier: SearchSongCollectionViewCell.identifier, cellType: SearchSongCollectionViewCell.self)) { item, value, cell in
                        
                        cell.configureCell(song: value)
                    }
                    .disposed(by: owner.disposeBag)
                    
            }
            .disposed(by: disposeBag)
            
    }
}
