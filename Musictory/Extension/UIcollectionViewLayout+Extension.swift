//
//  UICollectionViewLayout+Extension.swift
//  Musictory
//
//  Created by 김상규 on 8/20/24.
//

import UIKit

extension UICollectionViewLayout {
    static func postCollectionViewLayout(_ type: ViewType) -> UICollectionViewLayout {
        
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.showsSeparators = true
        listConfiguration.separatorConfiguration.topSeparatorVisibility = .hidden
        let isHomeView = (type == .home)
        let insetSize: CGFloat = isHomeView ? 10 : 0
        
        listConfiguration.separatorConfiguration.topSeparatorVisibility = .hidden
        listConfiguration.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: insetSize, bottom: 0, trailing: insetSize)
        
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        
        return layout
    }
      
    static func myPageCollectionView() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            switch section {
            case 0:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1/3)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: -10, trailing: 10)
                return section
                
            default:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/2),
                    heightDimension: .fractionalWidth(2/3)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
//                    heightDimension: .fractionalWidth(1)
                     heightDimension: .absolute(230)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(20)
                
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 20, trailing: 15)
                section.interGroupSpacing = 20
                
                return section
            }
        }
    }
}

enum ViewType {
    case home
    case myPage
}
