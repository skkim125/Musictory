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

class CustomButton: UIButton {
    private let buttonTitleLabel = UILabel()
    private let goNextViewImageView = UIImageView()
    private let dataLabel = UILabel()
    
    init(_ type: ButtonType) {
        super.init(frame: .zero)
        
        configureButton()
        configureHierarchy()
        configureLayout()
        configureSubView(type.title)
    }
    
    private func configureButton() {
        var configuration = UIButton.Configuration.bordered()
        configuration.baseBackgroundColor = .systemGray6
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
    
    private func configureLayout() {
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
    }
    
    private func configureSubView(_ title: String) {
        buttonTitleLabel.text = title
        buttonTitleLabel.textColor = .systemRed
        buttonTitleLabel.font = .boldSystemFont(ofSize: 16)
        
        dataLabel.textColor = .systemRed
        dataLabel.textAlignment = .right
        dataLabel.font = .systemFont(ofSize: 14)
        
        goNextViewImageView.image = UIImage(systemName: "plus")
        goNextViewImageView.tintColor = .systemRed
        goNextViewImageView.contentMode = .scaleAspectFit
    }
    
    func configureButtonText(data: String) {
        dataLabel.text = data
    }
    
    func configureAddSongUI(song: Song, _ type: ButtonType) {
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
        default:
            break
        }
        goNextViewImageView.rx.image.onNext(UIImage(systemName: "checkmark"))
        goNextViewImageView.rx.tintColor.onNext(.white)
        buttonTitleLabel.rx.isHidden.onNext(true)
        dataLabel.rx.textAlignment.onNext(.left)
        dataLabel.rx.textColor.onNext(.white)
        
        self.configuration?.baseBackgroundColor = .systemRed
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
                "위치 표시"
            }
        }
    }
}
