//
//  WriteMusictoryViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/21/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WriteMusictoryViewController: UIViewController {
    private let contentField = UITextView()
    let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    
    private func configureView() {
        navigationItem.title = "뮤직토리 남기기"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .systemRed
        
        view.backgroundColor = .systemBackground
    }
    
    private func bind() {
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

