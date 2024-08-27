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
    let scrollView = UIScrollView()
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
    private let writeMusictoryButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton(configuration: .bordered()).configuration
        configuration?.image = UIImage(systemName: "pin.fill")
        configuration?.baseForegroundColor = .white
        configuration?.title = "뮤직토리 남기기"
        button.configuration = configuration
        
        button.isEnabled = false
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        
        return button
    }()
    
    private let viewModel = WriteMusictoryViewModel()
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
        view.addSubview(scrollView)
        
        let subViews = [postTitleTextField, dividerLine, addSongButton, addLocationButton, addPhotoButton, postContentTextView, postContentTextViewPlaceholder, writeMusictoryButton]
        
        subViews.forEach { subView in
            scrollView.addSubview(subView)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        postTitleTextField.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.top.equalTo(scrollView.snp.top).offset(10)
            make.horizontalEdges.equalTo(scrollView.snp.horizontalEdges).inset(20)
            make.height.equalTo(40)
        }
        
        dividerLine.snp.makeConstraints { make in
            make.top.equalTo(postTitleTextField.snp.bottom).offset(1)
            make.horizontalEdges.equalTo(postTitleTextField)
            make.height.equalTo(1)
        }
        
        addSongButton.snp.makeConstraints { make in
            make.top.equalTo(dividerLine.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(scrollView).inset(20)
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
            make.horizontalEdges.equalTo(scrollView).inset(20)
            make.height.equalTo(180)
        }
        
        postContentTextViewPlaceholder.snp.makeConstraints { make in
            make.top.equalTo(postContentTextView).inset(11)
            make.leading.equalTo(postContentTextView).inset(12)
        }
        
        writeMusictoryButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(postContentTextView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(scrollView).inset(20)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
    }
    
    private func bind() {
        let addSongInfo = PublishRelay<Song>()
        let uploadPost = PublishRelay<Void>()
        
        let input = WriteMusictoryViewModel.Input(song: addSongInfo, title: postTitleTextField.rx.text.orEmpty, content: postContentTextView.rx.text.orEmpty, uploadPost: uploadPost)
        
        let output = viewModel.transform(input: input)
        
        output.postContentHidden
            .bind(to: postContentTextViewPlaceholder.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.writeButtonEnable
            .bind(with: self) { owner, value in
                owner.writeMusictoryButton.rx.backgroundColor.onNext(value ? .systemRed : .clear)
                owner.writeMusictoryButton.rx.tintColor.onNext(value ? .white : .lightGray)
                owner.writeMusictoryButton.rx.isEnabled.onNext(value)
            }
            .disposed(by: disposeBag)
        
        writeMusictoryButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showTwoButtonAlert(title: "뮤직 토리를 남기시겠습니까?", message: "남긴 뮤직토리는 수정할 수 없습니다.") {
                    uploadPost.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        output.showUploadPostErrorAlert
            .bind(with: self) { owner, error in
                owner.showAlert(title: error.title, message: error.alertMessage)
            }
            .disposed(by: disposeBag)
        
        output.postingEnd
            .bind(with: self) { owner, _ in
                owner.showAlert(title: "성공적으로 기록되었습니다.", message: "") {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "updatePost")))
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        addSongButton.rx.tap
            .bind(with: self) { owner, _ in
                let vc = AddSongViewController()
                vc.bindData = { song in
                    owner.addSongButton.configureAddSongUI(song: song, .song)
                    addSongInfo.accept(song)
                }
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

