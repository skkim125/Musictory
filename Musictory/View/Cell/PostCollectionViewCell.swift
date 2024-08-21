//
//  PostCollectionViewCell.swift
//  Musictory
//
//  Created by 김상규 on 8/20/24.
//

import UIKit
import SnapKit
import MusicKit
import Kingfisher

final class PostCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCollectionViewCell"
    
    private let userImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let userNicknameLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let postTitleLabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    private let postContentLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    
    private let postCreateAtLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.textAlignment = .left
        
        return label
    }()
    
    let songView = UIView()
    
    private let songImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        imageView.layer.borderColor = UIColor.label.withAlphaComponent(0.5).cgColor
        imageView.layer.borderWidth = 1
        
        return imageView
    }()
    
    private let songTitleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    private let songArtistLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    
    private let songPlayButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .label
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureView()
    }
    
    private func configureView() {
        let subViews = [userImageView, userNicknameLabel, postTitleLabel, postContentLabel, postCreateAtLabel, songView]
        let songSubView = [songImageView, songTitleLabel, songArtistLabel, songPlayButton]
        
        songSubView.forEach { subView in
            songView.addSubview(subView)
        }
        
        subViews.forEach { subView in
            contentView.addSubview(subView)
        }
        
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(15)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).inset(15)
            make.size.equalTo(30)
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(5)
        }
        
        postCreateAtLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userNicknameLabel)
//            make.width.equalTo(90)
            make.leading.equalTo(userNicknameLabel.snp.trailing)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(15)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(10)
            make.leading.equalTo(userImageView.snp.leading).offset(5)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(postTitleLabel.snp.leading)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.height.equalTo(15)
        }
        
        songView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(70)
        }
        
        songImageView.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(songView).inset(7)
            make.width.equalTo(songImageView.snp.height)
        }
        
        songTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(songImageView.snp.top).offset(5)
            make.leading.equalTo(songImageView.snp.trailing).offset(10)
        }
        
        songPlayButton.snp.makeConstraints { make in
            make.leading.equalTo(songTitleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(songView.snp.trailing).inset(10)
            make.size.equalTo(30)
            make.centerY.equalTo(songImageView)
        }
        
        songArtistLabel.snp.makeConstraints { make in
            make.leading.equalTo(songTitleLabel)
            make.top.equalTo(songTitleLabel.snp.bottom).offset(3)
            make.trailing.equalTo(songPlayButton.snp.leading).inset(10)
        }
            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(post: PostModel, song: Song) {
        if let url = URL(string: post.creator.profileImage ?? "") {
            userImageView.kf.setImage(with: url)
        } else {
            userImageView.image = UIImage(systemName: "person.circle")
            userImageView.tintColor = .systemRed
        }
        
        userNicknameLabel.text = post.creator.nickname
        postTitleLabel.text = post.title
        postContentLabel.text = post.content
        postCreateAtLabel.text = DateFormatter.convertDateString(post.createdAt)
        
        songTitleLabel.text = song.title
        songArtistLabel.text = song.artistName
        guard let url = song.artwork?.url(width: 80, height: 80) else { return }
        songImageView.kf.setImage(with: url)
    }
}
