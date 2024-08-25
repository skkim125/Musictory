//
//  MusictoryMapViewController.swift
//  Musictory
//
//  Created by 김상규 on 8/25/24.
//

import UIKit
import SnapKit
import MapKit
import RxSwift
import RxCocoa

final class MusictoryMapViewController: UIViewController {
    private let mapView = MKMapView()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    func configureView() {
        navigationItem.title = "Musictory Map"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = .label
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalTo(view)
        }
    }
    
    func bind() {
        navigationItem.leftBarButtonItem?.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
    }
}
