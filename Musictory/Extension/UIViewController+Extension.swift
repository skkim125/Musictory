//
//  UIViewController+Extension.swift
//  Musictory
//
//  Created by 김상규 on 8/21/24.
//

import UIKit
import RxSwift
import MusicKit
import Toast

extension UIViewController {
    func showAlert(title: String?, message: String?, completionHandelr: (()->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let open = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandelr?()
        }
        alert.addAction(open)
        
        present(alert, animated: true)
    }
    
    func showTwoButtonAlert(title: String?, message: String?, completionHandelr: (()->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "취소", style: .destructive)
        let open = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandelr?()
        }
        
        alert.addAction(cancel)
        alert.addAction(open)
        
        present(alert, animated: true)
    }
    
    func setRootViewController(_ viewController: UIViewController) {
 
        if let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
        let window = scene.window {
             
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
        }
    }
    
    func makeToast(message: String, presentTime: TimeInterval) {
        ToastManager.shared.style.backgroundColor = .systemRed
        ToastManager.shared.style.titleColor = .white
        view.isUserInteractionEnabled = false
        view.makeToast(message, duration: presentTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + presentTime) {
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func goLoginView() {
        UserDefaultsManager.shared.accessT = ""
        UserDefaultsManager.shared.refreshT = ""
        UserDefaultsManager.shared.userID = ""
        
        let vc = LogInViewController()
        setRootViewController(vc)
    }
    
    func checkMusicAuthorization(completionHandler: (() -> Void)? = nil) {
        Task {
            let status = await MusicAuthorization.request()
            
            switch status {
            case .denied:
                self.showAlert(title: "원활한 앱 사용을 위해 미디어 권한을 허용해주세요", message: "설정으로 이동합니다.") {
                    if let deviceSetting = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(deviceSetting)
                    }
                }
            case .authorized:
                completionHandler?()
            default:
                break
            }
        }
    }
    
}
