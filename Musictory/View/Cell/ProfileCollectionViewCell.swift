//
//  ProfileCollectionViewCell.swift
//  Musictory
//
//  Created by 김상규 on 8/25/24.
//

import UIKit
import SnapKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProfileCollectionViewCell"
    
    private let userProfileImageView = UIImageView()
    private let userNicknameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    private func configureView() {
        addSubview(userProfileImageView)
        addSubview(userNicknameLabel)
        
        userProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(10)
            make.leading.equalTo(safeAreaLayoutGuide).offset(60)
            make.size.equalTo(80)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userProfileImageView.snp.centerY)
            make.height.equalTo(50)
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(15)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(20)
        }
        
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.tintColor = .systemRed
        
        userNicknameLabel.textAlignment = .center
        userNicknameLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    func configureUI(profileImage: String?, nickname: String) {
        if let profile = profileImage, let url = URL(string: profile) {
            print("profile =", profile)
            userProfileImageView.kf.setImage(with: url)
        } else {
            userProfileImageView.image = UIImage(systemName: "person.circle")
        }
        userNicknameLabel.text = nickname
        userNicknameLabel.numberOfLines = 2
        userNicknameLabel.textAlignment = .left
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
