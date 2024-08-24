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

final class MyPageViewController: UIViewController {
    private let userProfileImageView = UIImageView()
    private let userNicknameLabel = UILabel()
    
    let disposeBag = DisposeBag()
    let viewModel = MyPageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        bind()
    }
    
    func configureView() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "마이페이지"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis"), menu: configureMenuButton())
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        let subViews = [userProfileImageView, userNicknameLabel]
        subViews.forEach { subView in
            view.addSubview(subView)
        }
        
        userProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(80)
            make.height.equalTo(userProfileImageView.snp.width)
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(userProfileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(userProfileImageView)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(80)
            make.height.equalTo(40)
        }
        
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.image = UIImage(systemName: "person.circle")
        userProfileImageView.tintColor = .systemRed
        
        userNicknameLabel.textAlignment = .center
        userNicknameLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    func bind() {
        let loadMyProfile = PublishRelay<Void>()
        let input = MyPageViewModel.Input(loadMyData: loadMyProfile)
        let output = viewModel.transform(input: input)

        loadMyProfile.accept(())
        
        output.myData
            .bind(with: self) { owner, profile in
                owner.userNicknameLabel.rx.text.onNext(profile.nick + "님, 반가워요!")
            }
            .disposed(by: disposeBag)
        
    }
    
    func configureMenuButton() -> UIMenu {
        let editProfile = UIAction(title: "프로필 수정", image: UIImage(systemName: "pencil"), handler: { _ in
            print("프로필 수정")
        })
        
        let withdraw = UIAction(title: "탈퇴하기", image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), handler: { _ in
            print("탈퇴")
        })
        return UIMenu(title: "설정", options: .displayInline, children: [editProfile, withdraw])
    }
}
