//
//  UIViewController+Extension.swift
//  Musictory
//
//  Created by 김상규 on 8/21/24.
//

import UIKit

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
}
