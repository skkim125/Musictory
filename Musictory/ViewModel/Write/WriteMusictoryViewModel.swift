//
//  WriteMusictoryViewModel.swift
//  Musictory
//
//  Created by 김상규 on 8/22/24.
//

import Foundation
import RxSwift
import RxCocoa
import MusicKit

final class WriteMusictoryViewModel: BaseViewModel {
    let lslp_API = LSLP_API.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let title: ControlProperty<String>
        let content: ControlProperty<String>
        let song: PublishRelay<SongModel>
        let uploadPost: PublishRelay<Void>
    }
    
    struct Output {
        let postContentHidden: PublishRelay<Bool>
        let writeButtonEnable: PublishRelay<Bool>
        let postingEnd: PublishRelay<Void>
        let showUploadPostErrorAlert: PublishRelay<NetworkError>
    }
    
    func transform(input: Input) -> Output {
        let postContentHidden = PublishRelay<Bool>()
        let writeButtonEnable = PublishRelay<Bool>()
        let showUploadPostErrorAlert = PublishRelay<NetworkError>()
        let postingEnd = PublishRelay<Void>()
        var writePostQuery = WritePostQuery(title: "", content: "", content1: "", content2: "", content3: "", files: [])
        
        input.content
            .map({ !$0.trimmingCharacters(in: .whitespaces).isEmpty })
            .bind(to: postContentHidden)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.title, input.content, input.song)
            .map({ $0.0.trimmingCharacters(in: .whitespaces).count > 5 && $0.1.trimmingCharacters(in: .whitespaces).count > 5 && !$0.2.id.isEmpty } )
            .bind(with: self) { owner, value in
                writeButtonEnable.accept(value)
            }
            .disposed(by: disposeBag)
        
        Observable.combineLatest(input.title, input.content, input.song)
            .bind { value in
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(value.2)
                    writePostQuery = WritePostQuery(title: value.0, content: value.1, content1: String(data: data, encoding: .utf8) ?? "", content2: "", content3: "", files: [])
                } catch {
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.uploadPost
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .writePost(writePostQuery), decodingType: PostModel.self) { result in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        switch result {
                        case .success(let success):
                            print(success)
                            postingEnd.accept(())
                            
                        case .failure(let failure):
                            showUploadPostErrorAlert.accept(failure)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(postContentHidden: postContentHidden, writeButtonEnable: writeButtonEnable, postingEnd: postingEnd, showUploadPostErrorAlert: showUploadPostErrorAlert)
    }
    
}
