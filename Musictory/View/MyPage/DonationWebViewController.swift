//
//  DonationWebViewController.swift
//  Musictory
//
//  Created by 김상규 on 9/1/24.
//

import UIKit
import WebKit
import SnapKit
import iamport_ios
import RxSwift
import RxCocoa

final class DonationWebViewController: UIViewController {
    lazy var donationWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    private let disposeBag = DisposeBag()
    private let impuid = PublishRelay<String>()
    private let viewModel = DonationWebViewModel()
    var userNickname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        showPortone()
        bind()
    }
    
    private func configureView() {
        view.addSubview(donationWebView)
        donationWebView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    private func showPortone() {
        guard let user = userNickname else { return }
        print(user)
        let payment = IamportPayment(
                pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                merchant_uid: "ios_\(APIKey.key)_\(Int(Date().timeIntervalSince1970))",
                amount: "100").then {
        $0.pay_method = PayMethod.card.rawValue
        $0.name = "개발자에게 소소한 후원하기"
        $0.buyer_name = user
        $0.app_scheme = "musictory"
        }
        
        Iamport.shared.paymentWebView(
            webViewMode: donationWebView,
            userCode: APIKey.portOneUserCode,
            payment: payment) { [weak self] iamportResponse in
                
                print(String(describing: iamportResponse))
                
                guard let self = self else { return }
                
                if let imp_uid = iamportResponse?.imp_uid, let isDonationed = iamportResponse?.success {
                    if isDonationed {
                        self.impuid.accept(imp_uid)
                    } else {
                        self.dismiss(animated: true)
                    }
                }
            }
    }
    
    private func bind() {
        let input = DonationWebViewModel.Input(impuid: impuid)
        let output = viewModel.transform(input: input)
        
        output.dismissAction
            .bind(with: self) { owner, _ in
                NotificationCenter.default.post(name: Notification.Name("DonationSuccess"), object: nil)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.showErrorAlert
            .bind(with: self) { owner, error in
                owner.showAlert(title: error.title, message: error.alertMessage)
            }
            .disposed(by: disposeBag)
    }
}
