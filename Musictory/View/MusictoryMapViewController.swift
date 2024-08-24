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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        navigationItem.title = "Musictory Map"
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalTo(view)
        }
    }
}
