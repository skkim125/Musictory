//
//  ProfileCollectionViewCell.swift
//  Musictory
//
//  Created by 김상규 on 8/25/24.
//

import UIKit
import SnapKit
import Kingfisher

final class ProfileCollectionViewCell: UICollectionViewCell {
    let userProfileImageView = UIImageView()
    private let userNicknameLabel = UILabel()
    private let userPostLabel = UILabel()
    private let userLikedLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    private func configureView() {
        addSubview(userProfileImageView)
        addSubview(userNicknameLabel)
        addSubview(userPostLabel)
        addSubview(userLikedLabel)
        
        userProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(safeAreaLayoutGuide).offset(20)
            make.width.equalTo(userProfileImageView.snp.height)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userProfileImageView.snp.centerY).inset(10)
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(30)
            make.trailing.lessThanOrEqualTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        userPostLabel.snp.makeConstraints { make in
            make.leading.equalTo(userNicknameLabel.snp.leading)
            make.top.equalTo(userProfileImageView.snp.centerY)
            make.height.equalTo(30)
        }
        
        userLikedLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userPostLabel)
            make.leading.greaterThanOrEqualTo(userPostLabel.snp.trailing).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(40)
            make.height.equalTo(50)
        }
        
        userProfileImageView.contentMode = .scaleAspectFit
        userProfileImageView.tintColor = .systemRed
        
        userNicknameLabel.textAlignment = .center
        userNicknameLabel.font = .boldSystemFont(ofSize: 20)
    }
    
    func configureUI(profile: ProfileModel)
    {
        if let profile = profile.profileImage, let url = URL(string: APIURL.baseURL + "v1/" + profile) {
            print("profile =", profile)
            print("url = \(url)")
            KingfisherManager.shared.setHeaders()
            userProfileImageView.kf.setImage(with: url)
            userProfileImageView.contentMode = .scaleAspectFill
            userProfileImageView.clipsToBounds = true
        } else {
            userProfileImageView.image = UIImage(systemName: "person.circle")
        }
        userNicknameLabel.text = profile.nick
        userNicknameLabel.numberOfLines = 2
        userNicknameLabel.textAlignment = .left
        userPostLabel.text = "게시물 " + profile.posts.count.formatted(.number)
        userPostLabel.font = .systemFont(ofSize: 14)
    }
    
    func configureLikedLabel(likeCount: Int) {
        userLikedLabel.text = "받은 좋아요 " + likeCount.formatted(.number)
        userLikedLabel.font = .systemFont(ofSize: 14)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.height/2
    }
    
}

extension KingfisherManager {
    func setHeaders() {
        let modifier = AnyModifier { request in
            var req = request
            req.addValue(UserDefaultsManager.shared.accessT, forHTTPHeaderField: APIHeader.authorization.rawValue)
            req.addValue(APIKey.key, forHTTPHeaderField: APIHeader.sesac.rawValue)

            return req
        }

        KingfisherManager.shared.defaultOptions = [
            .requestModifier(modifier)
        ]
    }
}
