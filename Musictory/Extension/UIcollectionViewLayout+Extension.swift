//
//  UIcollectionViewLayout+Extension.swift
//  Musictory
//
//  Created by 김상규 on 8/20/24.
//

import UIKit

extension UICollectionViewLayout {
    static func postCollectionViewLayout() -> UICollectionViewLayout {
        
//        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//        
//        let item = NSCollectionLayoutItem(layoutSize: size)
//        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        group.interItemSpacing = .fixed(10)
//        
//        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//        section.interGroupSpacing = 10
//        let layout = UICollectionViewCompositionalLayout(section: section)
        
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.separatorConfiguration.topSeparatorVisibility = .hidden
        listConfiguration.showsSeparators = true
        listConfiguration.separatorConfiguration.bottomSeparatorInsets = .init(top: 1, leading: 10, bottom: 1, trailing: 10)
        listConfiguration.separatorConfiguration.color = .systemGray
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        
        return layout
    }
}
