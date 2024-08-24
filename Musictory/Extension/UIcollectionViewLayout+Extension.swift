//
//  UICollectionViewLayout+Extension.swift
//  Musictory
//
//  Created by 김상규 on 8/20/24.
//

import UIKit

extension UICollectionViewLayout {
    static func postCollectionViewLayout() -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.showsSeparators = true
        listConfiguration.separatorConfiguration.topSeparatorVisibility = .hidden
        listConfiguration.separatorConfiguration.bottomSeparatorInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        
        return layout
    }
}
