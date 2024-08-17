//
//  BaseViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/17/24.
//

import Foundation

protocol BaseViewModel {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input)-> Output
}
