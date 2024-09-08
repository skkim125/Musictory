//
//  AddSongViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import Foundation
import RxSwift
import RxCocoa
import MusicKit

final class AddSongViewModel: BaseViewModel {
    let disposeBag = DisposeBag()
    
    struct Input {
        let addSong: ControlEvent<Song>
        let searchText: ControlProperty<String>
        let searchButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let result: PublishRelay<MusicItemCollection<Song>>
        let resultIsEmpty: PublishRelay<Void>
        let showSearchTextIsEmptyAlert: PublishRelay<Void>
        let showErrorAlert: PublishRelay<MusicKitError>
    }
    
    func transform(input: Input) -> Output {
        let songs = PublishRelay<MusicItemCollection<Song>>()
        let search = PublishRelay<String>()
        let resultIsEmpty = PublishRelay<Void>()
        let showSearchTextIsEmptyAlert =  PublishRelay<Void>()
        let showErrorAlert = PublishRelay<MusicKitError>()
        
        input.searchButtonTap
            .withLatestFrom(input.searchText)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespaces).isEmpty {
                    showSearchTextIsEmptyAlert.accept(())
                } else {
                    search.accept(value)
                }
            }
            .disposed(by: disposeBag)
        
        search
            .bind(with: self) { owner, value in
                    songs.accept([])
                Task {
                    await MusicManager.shared.searchMusics(search: value, offset: 0) { result in
                        switch result {
                        case .success(let success):
                            if success.isEmpty {
                                resultIsEmpty.accept(())
                            } else {
                                songs.accept(success)
                            }
                        case .failure(let failure):
                            showErrorAlert.accept(failure)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(result: songs, resultIsEmpty: resultIsEmpty, showSearchTextIsEmptyAlert: showSearchTextIsEmptyAlert, showErrorAlert: showErrorAlert)
    }
}
