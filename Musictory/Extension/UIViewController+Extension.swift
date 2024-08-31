//
//  UIViewController+Extension.swift
//  Musictory
//
//  Created by 김상규 on 8/21/24.
//

import UIKit
import RxSwift

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
        view.isUserInteractionEnabled = false
        view.makeToast(message, duration: presentTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + presentTime) {
            self.view.isUserInteractionEnabled = true
        }
    }
}
