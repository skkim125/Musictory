//
//  CustomButton.swift
//  Musictory
//
//  Created by 김상규 on 8/21/24.
//

import UIKit
import SnapKit
import MusicKit
import RxSwift

struct SongModel: Codable {
    let id: String
    let title: String
    let artistName: String
    let albumCoverUrl: String
    let songURL: String
}

class CustomButton: UIButton {
    private let buttonTitleLabel = UILabel()
    private let goNextViewImageView = UIImageView()
    private let dataLabel = UILabel()
    
    init(_ type: ButtonType) {
        super.init(frame: .zero)
        
        configureButton()
        configureHierarchy()
        configureLayout(type)
        configureSubView(type)
        
        if type == .location {
            buttonTitleLabel.textColor = .gray
            goNextViewImageView.tintColor = .gray
        }
    }
    
    private func configureButton() {
        var configuration = UIButton.Configuration.bordered()
        configuration.baseBackgroundColor = .systemGray5
        configuration.titleAlignment = .leading
        
        self.configuration = configuration
        tintColor = .white
        clipsToBounds = true
        layer.cornerRadius = 8
    }
    
    private func configureHierarchy() {
        addSubview(buttonTitleLabel)
        addSubview(goNextViewImageView)
        addSubview(dataLabel)
    }
    
    private func configureLayout(_ type: ButtonType) {
        switch type {
        case .song:
            buttonTitleLabel.snp.makeConstraints { make in
                make.leading.equalTo(self.snp.leading).offset(10)
                make.centerY.equalTo(self)
            }
            
            goNextViewImageView.snp.makeConstraints { make in
                make.trailing.equalTo(self.snp.trailing).inset(10)
                make.size.equalTo(20)
                make.centerY.equalTo(self)
            }
            
            dataLabel.snp.makeConstraints { make in
                make.leading.equalTo(self.snp.centerX)
                make.trailing.equalTo(goNextViewImageView.snp.leading).inset(-5)
                make.centerY.equalTo(goNextViewImageView.snp.centerY)
                make.height.equalTo(25)
            }
        case .photo:
            buttonTitleLabel.snp.makeConstraints { make in
//                make.leading.greaterThanOrEqualTo(self.snp.leading).inset(10)
                make.center.equalTo(self)
            }
            
//            goNextViewImageView.snp.makeConstraints { make in
//                make.leading.equalTo(buttonTitleLabel.snp.trailing)
//                make.trailing.lessThanOrEqualTo(self.snp.trailing)
//                make.size.equalTo(20)
//                make.centerY.equalTo(self)
//            }
            
//            dataLabel.snp.makeConstraints { make in
//                make.leading.equalTo(self.snp.centerX)
//                make.trailing.equalTo(goNextViewImageView.snp.leading).inset(-5)
//                make.centerY.equalTo(goNextViewImageView.snp.centerY)
//                make.height.equalTo(25)
//            }
        case .location:
            break
        }
    }
    
    private func configureSubView(_ type: ButtonType) {
        
        switch type {
        case .photo:
            dataLabel.textAlignment = .center
            configuration?.baseBackgroundColor = .systemGray5.withAlphaComponent(0.5)

        default:
            buttonTitleLabel.textAlignment = .center
            dataLabel.textAlignment = .right
        }
        
        buttonTitleLabel.text = type.title
        buttonTitleLabel.textColor = .systemRed
        buttonTitleLabel.font = .boldSystemFont(ofSize: 16)
        
        dataLabel.textColor = .systemRed
        dataLabel.font = .systemFont(ofSize: 14)
        
        goNextViewImageView.image = UIImage(systemName: "plus")
        goNextViewImageView.tintColor = .systemRed
        goNextViewImageView.contentMode = .scaleAspectFit
    }
    
    func configureButtonText(data: String) {
        dataLabel.text = data
    }
    
    func configureAddSongUI(song: SongModel, _ type: ButtonType) {
        switch type {
        case .song:
            dataLabel.rx.text.onNext("\(song.title) - \(song.artistName)")
            
            dataLabel.rx.font.onNext(.boldSystemFont(ofSize: 16))
            dataLabel.snp.remakeConstraints { make in
                make.leading.equalTo(self.snp.leading).offset(10)
                make.trailing.equalTo(goNextViewImageView.snp.leading).inset(-5)
                make.centerY.equalTo(goNextViewImageView.snp.centerY)
                make.height.equalTo(25)
            }
            configuration?.baseBackgroundColor = .systemRed
        default:
            break
        }
        goNextViewImageView.rx.image.onNext(UIImage(systemName: "checkmark"))
        goNextViewImageView.rx.tintColor.onNext(.white)
        buttonTitleLabel.rx.isHidden.onNext(true)
        dataLabel.rx.textAlignment.onNext(.left)
        dataLabel.rx.textColor.onNext(.white)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum ButtonType {
        case song
        case photo
        case location
        
        var title: String {
            switch self {
            case .song:
                "노래 추가"
            case .photo:
                "사진 추가"
            case .location:
                "현재 위치 추가"
            }
        }
    }
}
