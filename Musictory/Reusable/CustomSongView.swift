//
//  CustomSongView.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import UIKit
import SnapKit
import MusicKit
import RxSwift
import RxCocoa

final class CustomSongView: UIView {
    let songImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        
        imageView.layer.borderColor = UIColor.label.withAlphaComponent(0.5).cgColor
        imageView.layer.borderWidth = 1
        
        return imageView
    }()
    
    let songTitleLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    let songArtistLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        
        return label
    }()
    
    let songPlayButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .label
        button.isUserInteractionEnabled = false
        
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        
        let songSubView = [songImageView, songTitleLabel, songArtistLabel, songPlayButton]
        
        songSubView.forEach { subView in
            addSubview(subView)
        }
    }
    
    private func configureView(viewType: ViewType) {
        
        switch viewType {
        case .home:
            songImageView.snp.makeConstraints { make in
                make.leading.verticalEdges.equalTo(self).inset(7)
                make.width.equalTo(songImageView.snp.height)
            }
            
            songTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(songImageView.snp.top).offset(5)
                make.leading.equalTo(songImageView.snp.trailing).offset(10)
            }
            
            songPlayButton.snp.makeConstraints { make in
                make.leading.equalTo(songTitleLabel.snp.trailing).offset(10)
                make.trailing.equalTo(self.snp.trailing).inset(10)
                make.size.equalTo(30)
                make.centerY.equalTo(songImageView)
            }
            
            songArtistLabel.snp.makeConstraints { make in
                make.leading.equalTo(songTitleLabel)
                make.trailing.equalTo(songPlayButton.snp.leading).inset(-10)
                make.top.equalTo(songTitleLabel.snp.bottom).offset(3)
            }
        case .myPage:
            songPlayButton.snp.makeConstraints { make in
                make.edges.equalTo(self)
            }
        }
    }
    
    func configureUI(song: Song, viewType: ViewType) {
        configureView(viewType: viewType)
        
        switch viewType {
        case .home:
            guard let url = song.artwork?.url(width: 150, height: 150) else { return }
            songImageView.kf.setImage(with: url)
        case .myPage:
            songTitleLabel.isHidden = true
            songArtistLabel.isHidden = true
            
            var image = UIImage(systemName: "play.circle.fill")?.withRenderingMode(.alwaysOriginal)
            image = image?.applyingSymbolConfiguration(.init(font: .boldSystemFont(ofSize: 18), scale: .large))
            image = image?.applyingSymbolConfiguration(.init(paletteColors: [.white, .systemRed]))
            
            songPlayButton.setImage(image, for: .normal)
            songPlayButton.tintColor = .systemRed
            songPlayButton.imageView?.contentMode = .scaleAspectFill

        }
        songTitleLabel.text = song.title
        songArtistLabel.text = song.artistName
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum SongViewType {
    case musictoryHome
    case writeMusictory
}
