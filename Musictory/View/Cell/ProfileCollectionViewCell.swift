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
    static let identifier = "ProfileCollectionViewCell"
    
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
            make.top.equalTo(safeAreaLayoutGuide).offset(15)
            make.leading.equalTo(safeAreaLayoutGuide).offset(30)
            make.width.equalTo(120)
            make.height.equalTo(userProfileImageView.snp.width)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(15)
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userProfileImageView.snp.centerY).inset(20)
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        userPostLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
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
    
    func configureUI(profile: ProfileModel)//  profileImage: String?, nickname: String)
    {
        if let profile = profile.profileImage, let url = URL(string: APIURL.baseURL + "v1/" + profile) {
            print("profile =", profile)
            print("url = \(url)")
            KingfisherManager.shared.setHeaders()
            userProfileImageView.kf.setImage(with: url)
            userProfileImageView.contentMode = .scaleToFill
            userProfileImageView.clipsToBounds = true
        } else {
            userProfileImageView.image = UIImage(systemName: "person.circle")
        }
        userNicknameLabel.text = profile.nick
        userNicknameLabel.numberOfLines = 2
        userNicknameLabel.textAlignment = .left
        userPostLabel.text = "게시물 " + profile.posts.count.formatted(.number)
    }
    
    func configureLikedLabel(likeCount: Int) {
        userLikedLabel.text = "받은 좋아요 " + likeCount.formatted(.number)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
        
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
