//
//  EditProfileViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/30/24.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa
import RxGesture
import PhotosUI

final class EditProfileViewController: UIViewController {
    private let editMyProfileImageView = UIImageView()
    private let editMyProfileImageButton = UIButton(type: .system)
    private let editMyProfileNicknameTextField = UITextField()
    private let divider = UIView()
    private let sendEditMyProfileButton = UIButton(configuration: .borderedProminent())
    
    private let disposeBag = DisposeBag()
    var image: UIImage?
    var profile: ProfileModel?
    var moveData: ((ProfileModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureUI()
        bind()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: nil)
        navigationItem.title = "Edit Profile"
        
        view.addSubview(editMyProfileImageView)
        view.addSubview(editMyProfileNicknameTextField)
        view.addSubview(divider)
        view.addSubview(editMyProfileImageButton)
        view.addSubview(sendEditMyProfileButton)
        
        editMyProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
                .offset(30)
            make.centerX.equalTo(view)
            make.width.equalTo(150)
            make.height.equalTo(editMyProfileImageView.snp.width)
        }
        
        editMyProfileImageButton.snp.makeConstraints { make in
            make.centerX.equalTo(editMyProfileImageView)
            make.top.equalTo(editMyProfileImageView.snp.bottom)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }
        
        editMyProfileNicknameTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(editMyProfileImageButton.snp.bottom).offset(50)
            make.width.equalTo(250)
            make.height.equalTo(40)
        }
        
        divider.snp.makeConstraints { make in
            make.bottom.equalTo(editMyProfileNicknameTextField.snp.bottom)
            make.height.equalTo(1)
            make.horizontalEdges.equalTo(editMyProfileNicknameTextField)
        }
        
        sendEditMyProfileButton.snp.makeConstraints { make in
            make.top.equalTo(editMyProfileNicknameTextField.snp.bottom).offset(30)
            make.centerX.equalTo(view)
            make.height.equalTo(40)
            make.width.equalTo(250)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    func configureUI() {
        guard let myProfile = profile else { return }
        
        editMyProfileImageView.image = image
        editMyProfileImageView.tintColor = .systemRed
        editMyProfileImageView.contentMode = .scaleAspectFill
        
        editMyProfileImageView.clipsToBounds = true
        editMyProfileImageButton.setTitle("프로필 사진 변경하기", for: .normal)
        editMyProfileImageButton.setTitleColor(.systemBlue, for: .normal)
        
        DispatchQueue.main.async {
            self.editMyProfileImageView.layer.borderColor = UIColor.systemGray.cgColor
            self.editMyProfileImageView.layer.borderWidth = 0.5
        }
        
        editMyProfileNicknameTextField.text = myProfile.nick
        editMyProfileNicknameTextField.placeholder = myProfile.nick
        divider.backgroundColor = .systemRed
        
        sendEditMyProfileButton.setTitle("수정하기", for: .normal)
        sendEditMyProfileButton.tintColor = .systemRed
    }
    
    func bind() {
        editMyProfileImageButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)

        editMyProfileImageView.rx.tapGesture().when(.recognized)
            .bind(with: self) { owner, _ in
                owner.presentPicker()
            }
            .disposed(by: disposeBag)
        
        sendEditMyProfileButton.rx.tap
            .withLatestFrom(editMyProfileNicknameTextField.rx.text.orEmpty)
            .bind(with: self) { owner, nickname in
                if !nickname.trimmingCharacters(in: .whitespaces).isEmpty && !nickname.hasSuffix(" ") {
                    owner.showTwoButtonAlert(title: "프로필을 수정하시겠습니까?", message: nil) {
                        
                        guard let imageData = owner.editMyProfileImageView.image?.jpegData(compressionQuality: 0.5) else { return }
                        
                        let query = EditProfileQuery(nick: nickname, profile: imageData)

                        LSLP_API.shared.uploadRequest(apiType: .editMyProfile(query), decodingType: ProfileModel.self) { result in
                            switch result {
                            case .success(let editedProfile):
                                owner.moveData?(editedProfile)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    owner.navigationController?.popViewController(animated: true)
                                }
                                
                            case .failure(let error):
                                if error == .expiredRefreshToken {
                                    owner.goLoginView()
                                }
                            }
                        }
                    }
                } else {
                    owner.showAlert(title: "작성하신 닉네임이 조건에 맞지 않습니다.", message: "다시 작성해주세요")
                }
            }
            .disposed(by: disposeBag)
        
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func presentPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        editMyProfileImageView.layer.cornerRadius = editMyProfileImageView.bounds.width / 2
    }
    
}

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        dismiss(animated: true)
        
        guard let select = results.first else { return }
        select.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            guard let self = self else { return }
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self.editMyProfileImageView.image = image
                    self.editMyProfileImageView.layer.cornerRadius = self.editMyProfileImageView.bounds.width / 2
                    self.editMyProfileImageView.clipsToBounds = true
                    self.editMyProfileImageView.contentMode = .scaleAspectFill
                    
                    picker.dismiss(animated: true)
                }
            }
        }
    }
}
