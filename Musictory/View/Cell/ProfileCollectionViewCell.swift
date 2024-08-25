//
//  ProfileCollectionViewCell.swift
//  Musictory
//
//  Created by 김상규 on 8/25/24.
//

import UIKit
import SnapKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProfileHeaderView"
    
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
            make.centerX.equalTo(self)
            make.width.equalTo(100)
            make.height.equalTo(userProfileImageView.snp.width)
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(userProfileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(userProfileImageView)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(80)
            make.height.equalTo(40)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.tintColor = .systemRed
        
        userNicknameLabel.textAlignment = .center
        userNicknameLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    func configureUI(profileImage: String, nickname: String) {
        userProfileImageView.image = UIImage(systemName: profileImage)
        userNicknameLabel.text = nickname
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
