//
//  SearchSongCollectionViewCell.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import UIKit
import MusicKit
import SnapKit
import Kingfisher
import RxSwift

final class SearchSongCollectionViewCell: UICollectionViewCell {
    static let identifier = "SearchSongCollectionViewCell"
    
    private let songView = UIView()
    private let songImageView = UIImageView()
    private let songTitleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    private let artistNameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    private let checkButton = {
        let button = UIButton(configuration: .plain())
        var configuration = button.configuration
        let imgConfig = UIImage.SymbolConfiguration(paletteColors: [.systemGray6, .systemRed])
        configuration?.image = UIImage(systemName: "plus.circle.fill", withConfiguration: imgConfig)
        button.configuration = configuration
        
        return button
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
    }
    
    private func configureHierarchy() {
        contentView.addSubview(songView)
        
        let songSubViews = [songImageView, songTitleLabel, artistNameLabel, checkButton]
        songSubViews.forEach { songView.addSubview($0) }
    }
    private func configureLayout() {
        songView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.height.equalTo(70)
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
        
        songImageView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(songView)
            make.leading.equalTo(songView.snp.leading).inset(10)
            make.width.equalTo(songImageView.snp.height)
        }
        
        songTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(songImageView.snp.trailing).offset(10)
            make.centerY.equalTo(songImageView.snp.centerY).offset(-10)
        }
        
        checkButton.snp.makeConstraints { make in
            make.leading.equalTo(songTitleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(songView.snp.trailing).inset(10)
            make.centerY.equalTo(songImageView)
            make.size.equalTo(50)
        }
        
        artistNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(songTitleLabel)
            make.top.equalTo(songTitleLabel.snp.bottom).offset(3)
            make.trailing.greaterThanOrEqualTo(checkButton.snp.leading).inset(10)
        }
    }
    
    func configureCell(song: Song) {
        guard let url = song.artwork?.url(width: 150, height: 150) else { return }
        songImageView.kf.setImage(with: url)
        songImageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        songImageView.layer.borderWidth = 0.5
        songImageView.clipsToBounds = true
        
        songTitleLabel.text = song.title
        
        artistNameLabel.text = song.artistName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        songImageView.layer.cornerRadius = 8
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
