//
//  ViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/14/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(searchBar)
        
        searchBar.backgroundColor = .lightGray
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        
        searchBar.delegate = self
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let search = searchBar.text else { return }
        
        Task {
           let data = await searchSong(term: search)
            print(data)
        }
    }
}
