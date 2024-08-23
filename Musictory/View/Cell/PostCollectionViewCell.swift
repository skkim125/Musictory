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
import RxSwift

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
    
    let songView = CustomSongView(.musictoryHome)
    private let likeButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .semibold))
        button.setImage(UIImage(systemName: "heart")?.withConfiguration(imageConfiguration), for: .normal)
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFill
        button.isUserInteractionEnabled = true
        
        return button
    }()
    private let commentButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .semibold))
        button.setImage(UIImage(systemName: "message")?.withConfiguration(imageConfiguration), for: .normal)
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFill
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    var disposdBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureView()
    }
    
    private func configureView() {
        let subViews = [userImageView, userNicknameLabel, postTitleLabel, postContentLabel, postCreateAtLabel, songView, likeButton, commentButton]

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
            make.leading.equalTo(userNicknameLabel.snp.trailing).offset(10)
            make.width.equalTo(120)
            make.trailing.lessThanOrEqualTo(contentView.safeAreaLayoutGuide).inset(15)
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
            make.height.equalTo(70)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(songView.snp.bottom).offset(5)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(15)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.size.equalTo(30)
        }
        
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(songView.snp.bottom).offset(5)
            make.leading.equalTo(likeButton.snp.trailing).offset(20)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            make.size.equalTo(30)
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
        
        songView.configureUI(song: song)
    }
    
    func bind() {
        likeButton.rx.tap
            .bind(with: self) { owner, _ in
                print("라이크 버튼 탭됨")
            }
            .disposed(by: disposdBag)
        
        commentButton.rx.tap
            .bind(with: self) { owner, _ in
                print("코멘트 버튼 탭됨")
            }
            .disposed(by: disposdBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposdBag = DisposeBag()
    }
}
