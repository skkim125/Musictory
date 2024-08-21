//
//  CustomButton.swift
//  Musictory
//
//  Created by 김상규 on 8/21/24.
//

import UIKit
import SnapKit

class CustomButton: UIButton {
    let buttonTitleLabel = UILabel()
    let goNextViewImageView = UIImageView()
    let dataLabel = UILabel()
    
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
            make.trailing.equalTo(goNextViewImageView.snp.leading).inset(-5)
            make.leading.equalTo(self.snp.centerX)
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
        
        goNextViewImageView.image = UIImage(systemName: "plus")
        goNextViewImageView.tintColor = .systemRed
        goNextViewImageView.contentMode = .scaleAspectFit
    }
    
    func configureButtonText(data: String) {
        dataLabel.text = data
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
