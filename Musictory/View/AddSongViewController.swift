//
//  AddSongViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MusicKit

final class AddSongViewController: UIViewController {
    private let searchViewController = UISearchController(searchResultsController: nil)
    
    private let searchResultCollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .postCollectionViewLayout(.home))
        cv.register(SearchSongCollectionViewCell.self, forCellWithReuseIdentifier: SearchSongCollectionViewCell.identifier)
        
        return cv
    }()
    let viewModel = AddSongViewModel()
    let disposeBag = DisposeBag()
    var bindData: ((Song)-> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    private func configureView() {
        navigationItem.title = "노래 추가"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: nil, action: nil)
        navigationItem.rx.searchController.onNext(searchViewController)
        searchViewController.searchBar.rx.searchBarStyle.onNext(.minimal)
        searchViewController.searchBar.searchTextField.rx.returnKeyType.onNext(.search)
        searchViewController.rx.hidesNavigationBarDuringPresentation.onNext(false)
        searchViewController.searchBar.placeholder = "뮤직토리에 남길 노래를 검색해보세요"
        navigationItem.rx.hidesSearchBarWhenScrolling.onNext(false)
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchResultCollectionView)
        searchResultCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        let input = AddSongViewModel.Input(addSong: searchResultCollectionView.rx.modelSelected(Song.self), searchText: searchViewController.searchBar.rx.text.orEmpty, searchButtonTap: searchViewController.searchBar.rx.searchButtonClicked)
        let output = viewModel.transform(input: input)
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.result
            .bind(to: searchResultCollectionView.rx.items(cellIdentifier: SearchSongCollectionViewCell.identifier, cellType: SearchSongCollectionViewCell.self)) { item, value, cell in
                
                cell.configureCell(song: value)
            }
            .disposed(by: disposeBag)
        
        output.resultIsEmpty
            .bind(with: self) { owner, _ in
                DispatchQueue.main.async {
                    owner.showAlert(title: "검색 결과가 없습니다.", message: nil)
                }
            }
            .disposed(by: disposeBag)
        
        output.showErrorAlert
            .bind(with: self) { owner, value in
                DispatchQueue.main.async {
                    owner.showAlert(title: value.1, message: value.2)
                }
            }
            .disposed(by: disposeBag)
        
        output.showSearchTextIsEmptyAlert
            .bind(with: self) { owner, _ in
                DispatchQueue.main.async {
                    owner.showAlert(title: "한글자 이상 입력해주세요", message: nil)
                }
            }
            .disposed(by: disposeBag)
        
        searchResultCollectionView.rx.modelSelected(Song.self)
            .bind(with: self) { owner, song in
                owner.showTwoButtonAlert(title: "\(song.title)을 선택하시겠습니까?", message: nil) {
                    owner.bindData?(song)
                    owner.navigationController?.popToRootViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
}
