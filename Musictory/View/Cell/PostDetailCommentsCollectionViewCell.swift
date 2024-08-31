//
//  PostDetailCollectionViewCell.swift
//  Musictory
//
//  Created by 김상규 on 8/28/24.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

final class PostDetailCommentsCollectionViewCell: UICollectionViewCell {
    static let identifier = "PostDetailCommentsCollectionViewCell"
    
    private let userImageView = UIImageView()
    private let userNicknameLabel = UILabel()
    private let commentsLabel = UILabel()
    private let postCreateAtLabel = UILabel()
    
    var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureView()
    }
    
    private func configureView() {
        let subViews = [userImageView, userNicknameLabel, commentsLabel, postCreateAtLabel]

        subViews.forEach { subView in
            contentView.addSubview(subView)
        }
        
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(15)
            make.leading.equalTo(contentView.safeAreaLayoutGuide).inset(20)
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
        
        commentsLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(10)
            make.leading.equalTo(userImageView.snp.centerX)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).inset(25)
        }
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(comment: CommentModel) {
        
//            if let url = URL(string: post.creator.profileImage ?? "") {
//                userImageView.kf.setImage(with: url)
//            } else {
        userImageView.image = UIImage(systemName: "person.circle")
        userImageView.tintColor = .systemRed
        
        userNicknameLabel.text = comment.creator.nickname
            
        commentsLabel.text = comment.content
        postCreateAtLabel.text = DateFormatter.convertDateString(comment.createdAt)
    }
    
    private func configureUI() {
        userImageView.contentMode = .scaleAspectFill
        userNicknameLabel.font = .boldSystemFont(ofSize: 16)
        commentsLabel.font = .systemFont(ofSize: 14)
        
        postCreateAtLabel.font = .systemFont(ofSize: 12)
        postCreateAtLabel.textColor = .systemGray
        postCreateAtLabel.textAlignment = .left
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userNicknameLabel.text = nil
        commentsLabel.text = nil
        postCreateAtLabel.text = nil
        
        disposeBag = DisposeBag()
    }
}
