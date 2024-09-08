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
    let lslp_API = LSLP_Manager.shared
    let disposeBag = DisposeBag()
    
    struct Input {
        let title: ControlProperty<String>
        let content: ControlProperty<String>
        let song: PublishRelay<SongModel>
        let postImage: PublishRelay<Data?>
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
        let uploadWithImage = PublishRelay<ImageModel>()
        let uploadEnd = PublishRelay<Void>()
        let uploadStart = PublishRelay<Void>()
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
        
        input.postImage
            .bind(with: self) { owner, data in
                if let data = data {
                    owner.lslp_API.uploadRequest(apiType: .uploadImage(ImageQuery(imageData: data)), decodingType: ImageModel.self) { result in
                        
                        switch result {
                        case .success(let imageURLs):
                            uploadWithImage.accept(imageURLs)
                            uploadStart.accept(())
                        case .failure(let error):
                            showUploadPostErrorAlert.accept(error)
                        }
                    }
                } else {
                    uploadStart.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        input.title
            .bind(with: self) { owner, value in
                writePostQuery.title = value
                print("titile: \(writePostQuery.title)")
            }
            .disposed(by: disposeBag)
        
        input.content
            .bind(with: self) { owner, value in
                writePostQuery.content = value
                print("content: \(writePostQuery.content)")
            }
            .disposed(by: disposeBag)
        
        input.song
            .bind(with: self) { owner, value in
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(value)
                    writePostQuery.content1 = String(data: data, encoding: .utf8) ?? ""
                    
                    print("content1: \(writePostQuery.content1))")
                } catch {
                    
                }
            }
            .disposed(by: disposeBag)
        
        uploadWithImage
            .bind(with: self) { owner, value in
                writePostQuery.files = value.files
                print("writePostQuery.files: \(writePostQuery.files)")
            }
            .disposed(by: disposeBag)
        
//        Observable.combineLatest(input.title, input.content, input.song, uploadWithImage)
//            .bind { value in
//                do {
//                    let encoder = JSONEncoder()
//                    let data = try encoder.encode(value.2)
//                    print("write222:", value)
//                    writePostQuery = WritePostQuery(title: value.0, content: value.1, content1: String(data: data, encoding: .utf8) ?? "", content2: "", content3: "", files: value.3.files)
//                } catch {
//                    print(error)
//                }
//            }
//            .disposed(by: disposeBag)
        
        uploadStart
            .bind(with: self) { owner, _ in
                owner.lslp_API.callRequest(apiType: .writePost(writePostQuery), decodingType: PostModel.self) { result in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        switch result {
                        case .success(let success):
                            print("uploading:", success)
                            uploadEnd.accept(())
                            
                        case .failure(let failure):
                            showUploadPostErrorAlert.accept(failure)
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
        
        return Output(postContentHidden: postContentHidden, writeButtonEnable: writeButtonEnable, postingEnd: uploadEnd, showUploadPostErrorAlert: showUploadPostErrorAlert)
    }
    
}
