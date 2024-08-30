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
import RxCocoa
import RxGesture

final class PostCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostCollectionViewCell"
    
    private let userImageView = UIImageView()
    private let userNicknameLabel = UILabel()
    private let postTitleLabel = UILabel()
    private let postContentLabel = UILabel()
    private let postCreateAtLabel = UILabel()
    private let songImageView = UIImageView()
    private let songView = CustomSongView()
    private let likeButton = {
        let button = UIButton()
        button.tintColor = .label
        button.imageView?.contentMode = .scaleAspectFill
        button.isUserInteractionEnabled = true
        
        return button
    }()
    private let likeCountLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        
        return label
    }()
    private let commentImageView = {
        let imageView = UIImageView()
        let imageConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .semibold))
        imageView.image?.withConfiguration(imageConfiguration)
        imageView.tintColor = .label
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let commentCountLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        
        return label
    }()
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureUI()
    }
    
    private func configureView(type: ViewType) {
        let subViews = [userImageView, userNicknameLabel, postTitleLabel, postContentLabel, postCreateAtLabel, likeButton, likeCountLabel, commentImageView, commentCountLabel, songImageView, songView]

        subViews.forEach { subView in
            contentView.addSubview(subView)
        }
        
        switch type {
        case .home:
            songImageView.isHidden = true
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
                make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(10)
                make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
                make.size.equalTo(30)
            }
            
            likeCountLabel.snp.makeConstraints { make in
                make.centerY.equalTo(likeButton)
                make.leading.equalTo(likeButton.snp.trailing).offset(5)
            }
            
            commentImageView.snp.makeConstraints { make in
                make.top.equalTo(songView.snp.bottom).offset(5)
                make.leading.equalTo(likeCountLabel.snp.trailing).offset(20)
                make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
                make.size.equalTo(25)
            }
            
            commentCountLabel.snp.makeConstraints { make in
                make.centerY.equalTo(commentImageView)
                make.leading.equalTo(commentImageView.snp.trailing).offset(5)
                make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            }
            
        case .myPage:
            userImageView.isHidden = true
            userNicknameLabel.isHidden = true
            
            songImageView.snp.makeConstraints { make in
                make.top.equalTo(safeAreaLayoutGuide).offset(10)
                make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
                make.height.equalTo(songImageView.snp.width)
            }
            
            postTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(songImageView.snp.bottom).offset(10)
                make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
                make.height.equalTo(20)
            }
            
            postCreateAtLabel.snp.makeConstraints { make in
                make.top.equalTo(postTitleLabel.snp.bottom)
                make.height.equalTo(15)
                make.leading.equalTo(postTitleLabel.snp.leading)
            }
            
            songView.snp.makeConstraints { make in
                make.bottom.equalTo(postTitleLabel.snp.top)
                make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(5)
                make.size.equalTo(30)
            }
            
            commentCountLabel.snp.makeConstraints { make in
                make.top.equalTo(postTitleLabel.snp.bottom).offset(10)
                make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(10)
                make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(10)
            }
            
            commentImageView.snp.makeConstraints { make in
                make.centerY.equalTo(commentCountLabel)
                make.size.equalTo(25)
                make.trailing.equalTo(commentCountLabel.snp.leading).offset(-3)
            }
            
            likeCountLabel.snp.makeConstraints { make in
                make.centerY.equalTo(commentCountLabel)
                make.trailing.equalTo(commentImageView.snp.leading).offset(-5)
            }
            
            likeButton.snp.makeConstraints { make in
                make.centerY.equalTo(likeCountLabel)
                make.leading.greaterThanOrEqualTo(safeAreaLayoutGuide).offset(10)
                make.trailing.equalTo(likeCountLabel.snp.leading).offset(-1)
                make.size.equalTo(30)
            }
        }
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell( _ viewType: ViewType, post: PostModel) {
        configureView(type: viewType)
        
        switch viewType {
            
        case .home:
            songImageView.isHidden = true
            userImageView.image = UIImage(systemName: "person.circle")
            userImageView.tintColor = .systemRed
            userNicknameLabel.text = post.creator.nickname
            
        case .myPage:
            userImageView.isHidden = true
            userNicknameLabel.isHidden = true
            postCreateAtLabel.font = .systemFont(ofSize: 13)
        }
        
        postTitleLabel.text = post.title
        postContentLabel.text = post.content
        postCreateAtLabel.text = DateFormatter.convertDateString(post.createdAt)
        likeCountLabel.text = post.likes.count.formatted(.number)
        commentCountLabel.text = post.comments.count.formatted(.number)
        
        configureLikeButton(isLike: post.likes.contains(UserDefaultsManager.shared.userID))
    }
    
    func configureSongView(song: Song, viewType: ViewType, completionHandler: @escaping (Observable<UITapGestureRecognizer>)-> ()) {
        songView.configureUI(song: song, viewType: viewType)
        
        guard let albumImageUrl = song.artwork?.url(width: 300, height: 300) else { return }
        songImageView.kf.setImage(with: albumImageUrl)
        songImageView.clipsToBounds = true
        songImageView.layer.borderWidth = 0.3
        songImageView.layer.borderColor = UIColor.systemGray6.cgColor
        
        completionHandler(songView.rx.tapGesture().when(.recognized))
    }
    
    func configureLikeButtonTap(completionHandler: (ControlEvent<Void>)-> Void) {
        completionHandler(likeButton.rx.tap)
    }
    
    private func configureLikeButton(isLike: Bool) {
        likeButton.isSelected = isLike
        
        let imageConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20, weight: .semibold))
        likeButton.tintColor = likeButton.isSelected ? .systemRed : .label
        likeButton.setImage(UIImage(systemName: likeButton.isSelected ? "heart.fill" : "heart")?.withConfiguration(imageConfiguration), for: .normal)
    }
    
    private func configureUI() {
        userImageView.contentMode = .scaleAspectFill
        userNicknameLabel.font = .boldSystemFont(ofSize: 16)
        postTitleLabel.font = .boldSystemFont(ofSize: 15)
        postContentLabel.font = .systemFont(ofSize: 13)
        
        postCreateAtLabel.font = .systemFont(ofSize: 12)
        postCreateAtLabel.textColor = .systemGray
        postCreateAtLabel.textAlignment = .left
        
        commentImageView.image = UIImage(systemName: "bubble.right")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        songImageView.layer.cornerRadius = songImageView.bounds.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        songView.songImageView.image = UIImage(systemName: "")
        songView.songTitleLabel.text = nil
        songView.songArtistLabel.text = nil
        userNicknameLabel.text = nil
        postTitleLabel.text = nil
        postContentLabel.text = nil
        postCreateAtLabel.text = nil
        
        disposeBag = DisposeBag()
    }
}
