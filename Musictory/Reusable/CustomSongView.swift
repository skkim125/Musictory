//
//  CustomSongView.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import UIKit
import SnapKit
import MusicKit

final class CustomSongView: UIView {
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
    
    init(_ type: SongViewType) {
        super.init(frame: .zero)
        
        let songSubView = [songImageView, songTitleLabel, songArtistLabel, songPlayButton]
        
        songSubView.forEach { subView in
            addSubview(subView)
        }
        
        configureView(type)
    }
    
    private func configureView(_ type: SongViewType) {
        songImageView.snp.makeConstraints { make in
            make.leading.verticalEdges.equalTo(self).inset(7)
            make.width.equalTo(songImageView.snp.height)
        }
        
        songTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(songImageView.snp.top).offset(5)
            make.leading.equalTo(songImageView.snp.trailing).offset(10)
        }
        
        songArtistLabel.snp.makeConstraints { make in
            make.leading.equalTo(songTitleLabel)
            make.top.equalTo(songTitleLabel.snp.bottom).offset(3)
        }
        
        songPlayButton.snp.makeConstraints { make in
            make.leading.equalTo(songTitleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(self.snp.trailing).inset(10)
            make.size.equalTo(30)
            make.centerY.equalTo(songImageView)
        }
        
        songPlayButton.isHidden = type == .writeMusictory
    }
    
    func configureUI(song: Song) {
        songTitleLabel.text = song.title
        songArtistLabel.text = song.artistName
        guard let url = song.artwork?.url(width: 80, height: 80) else { return }
        songImageView.kf.setImage(with: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SongViewType {
    case musictoryHome
    case writeMusictory
}
