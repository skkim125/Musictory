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
import MusicKit

final class WriteMusictoryViewController: UIViewController {
    private let postTitleTextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 16)
        tf.placeholder = "뮤직토리의 타이틀을 입력하세요"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 0))
        tf.rightViewMode = .always
        
        return tf
    }()
    private let dividerLine = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        return view
    }()
    private let postContentTextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 14)
        tv.backgroundColor = .clear
        tv.layer.borderColor = UIColor.systemRed.cgColor
        tv.layer.borderWidth = 2
        tv.layer.cornerRadius = 4
        tv.clipsToBounds = true
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        
        return tv
    }()
    private let postContentTextViewPlaceholder = {
        let label = UILabel()
        label.text = "지금의 뮤직토리를 입력해보세요"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        
        return label
        
    }()
    private let addSongButton = CustomButton(.song)
    private let addPhotoButton = CustomButton(.photo)
    private let addLocationButton = CustomButton(.location)
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
        
        let subViews = [postTitleTextField, dividerLine, addSongButton, addLocationButton, addPhotoButton, postContentTextView, postContentTextViewPlaceholder]
        subViews.forEach { subView in
            view.addSubview(subView)
        }
        
        postTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        dividerLine.snp.makeConstraints { make in
            make.top.equalTo(postTitleTextField.snp.bottom).offset(1)
            make.horizontalEdges.equalTo(postTitleTextField)
            make.height.equalTo(1)
        }
        
        addSongButton.snp.makeConstraints { make in
            make.top.equalTo(dividerLine.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(addSongButton.snp.bottom).offset(15)
            make.leading.equalTo(addSongButton.snp.leading)
            make.trailing.equalTo(view.snp.centerX).offset(-10)
            make.height.equalTo(50)
        }
        
        addLocationButton.snp.makeConstraints { make in
            make.top.equalTo(addPhotoButton)
            make.trailing.equalTo(addSongButton.snp.trailing)
            make.leading.equalTo(view.snp.centerX).offset(10)
            make.height.equalTo(50)
        }
        
        postContentTextView.snp.makeConstraints { make in
            make.top.equalTo(addPhotoButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        postContentTextViewPlaceholder.snp.makeConstraints { make in
            make.top.equalTo(postContentTextView).inset(11)
            make.leading.equalTo(postContentTextView).inset(12)
        }
    }
    
    private func bind() {
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        let addSongInfo = PublishRelay<Song>()
        
        addSongButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = AddSongViewController()
                vc.bindData = { song in
                    owner.addSongButton.configureAddSongUI(song: song)
                    addSongInfo.accept(song)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

