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

final class MusictoryHomeViewController: UIViewController {
    private let postTitleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    private let postContentLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    private let postCreateAtLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        
        return label
    }()
    
    let viewModel = MusictoryHomeViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    private func configureView() {
        view.backgroundColor = .white
        let subViews = [postTitleLabel, postContentLabel, postCreateAtLabel]
        
        subViews.forEach { subView in
            view.addSubview(subView)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        postCreateAtLabel.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
    }
    
    private func bind() {
        let refreshPost = PublishRelay<Void>()
        let input = MusictoryHomeViewModel.Input(refreshPost: refreshPost)
        let output = viewModel.transform(input: input)
        refreshPost.accept(())
        
        output.posts
            .bind(with: self) { owner, value in
                let index = 3
                owner.postTitleLabel.rx.text.onNext(value[index].title)
                owner.postContentLabel.rx.text.onNext(value[index].content)
                owner.postCreateAtLabel.rx.text.onNext(value[index].createdAt)
            }
            .disposed(by: disposeBag)
    }
    
}
