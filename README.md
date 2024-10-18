# 🎧 Musictory ReadMe

## 🎧 프로젝트 소개
> 일상을 음악과 함께 하는 사람들이 기록을 남기듯 일상을 노래와 함께 공유하는 SNS 앱

<img src="https://github.com/user-attachments/assets/00d5a9f7-88cf-4b2e-9cbb-952ddd8d0161" width="19%"/>
<img src="https://github.com/user-attachments/assets/c9721c15-1de1-4827-a9d8-9b696f208538" width="19%"/>
<img src="https://github.com/user-attachments/assets/8b665c5c-e358-4e6b-b0d5-a1765a75c3f4" width="19%"/>
<img src="https://github.com/user-attachments/assets/09c14dfe-1950-4df8-a9fc-487a72691b27" width="19%"/>
<img src="https://github.com/user-attachments/assets/efccf9e2-9132-42b7-a366-dcd9c34f61a5" width="19%"/>

<br>

## 🎧 프로젝트 환경
- 인원: 1명
- 기간: 2024.08.14 ~ 2024.09.08
- 개발 환경: Xcode 15
- 최소 버전: iOS 15.0
<br>

## 🎧 기술 스택
- UIKit, CodeBaseUI, MVVM
- RxSwift, SnapKit,  MusicKit(MusadoraKit), Kingfisher, iamport, Toast
- Access Control, Decoder, DTO, PHPickerView,  URLScheme, URLSession, UserDefaults
- Input/Output﹒Singleton﹒Router Pattern
<br>

## 🎧 핵심 기능
- 음악 추가가 필수인 게시물 작성 및 보기, 게시물에 좋아요 및 댓글 기능
- 게시물 작성 시 음악 추가를 위한 음악 검색 기능
- 게시물의 노래를 애플뮤직에서 듣기 기능
- 프로필 수정 및 내가 작성한 게시물 확인 기능
<br>

## 🎧 주요 기술
- MVVM + Input/Output
  - ViewController와 ViewModel로 분리함으로 비즈니스 로직 분리 및 Input/Output 패턴으로 구현
- URLSession을 사용한 NetworkManager Singleton Pattern으로 구성
   - Generic을 활용하여 Decodable한 타입들로 디코딩 진행
   - API Networking에 대한 요소들을 Router Pattern으로 추상화
   - multipart/form Data upload를 위해 body에 form-data 작성
- RxSwift를 사용하여 입력 받은 유저의 이벤트를 토대로 해당하는 기능을 수행하는 반응형 프로그래밍 구현
   - RxDataSource를 활용하여 Section과 데이터별로 CollectionView의 Cell UI를 구성하도록 구현
   - RxGesture를 활용하여 TapGesture 기능(노래 듣기) 구현
- Access Token과 Refresh Token을 활용한 로그인 기능 및 관련 기능 구현
    - 자동 로그인 기능 구현을 위해 UserDefaults를 활용하여 로그인 정보(이메일, 비밀번호, 토큰) 저장
    - Access Token이 필요한 통신에 Access Token이 유효한지 체크하여, Token이 만료된 case에 대해 Refresh Token을 활용하여 Access Token을 갱신하는 로직 구현
- MusicKit의 노래 검색 비동기 메서드를 Async/Await로 사용하며 동시성 프로그래밍 구현
- MusicKit Song 타입의 Data를 Codable타입으로 DTO를 진행하여 API 호출에 활용
- Access Control의 private 키워드와 final 키워드를 활용하여 컴파일 최적화 진행
- Compositional Layout을 활용하여 섹션별 및 뷰별 CollectionView의 group, item을 설정하여 Layout 구성
- NotificationCenter를 통해 특정 이벤트 발생 시 해당 알림을 받아 뷰모델에서의 로직 실행과 광역으로 데이터 전달
- 클래스 인스턴스 간 참조와 클로저의 캡쳐로 인한 강한 참조 방지를 위해 객체의 참조 카운트를 증가시키지 않는 약한 참조 방식으로 Memory Leak 방지
- iamport API를 활용해 PG사 결제모듈에 연동하여 인앱에서 실제 결제가 되어지는 개발자 후원하기 기능 구현
   - 결제 시 API 요청을 통한 영수증 인증 절차를 포함하여 인증이 되었을 경우 결제 알림이 오도록 구현
<br>

## 🎧 트러블 슈팅

****1. 게시물 작성을 위한 노래 데이터 DTO 과정**** 

1) 문제 발생
   - 게시물 작성 중 처음 구현한 방법은 선택한 노래의 고유 id를 저장하여, 게시물 조회를 할 때마다 게시물 데이터를 가져오면 또다시 MusicKit 메서드로 통신을 하여 노래 정보가 담긴 뷰를 표시
   - 그러나 MusicKit의 노래 조회 메서드는 Async/await 메서드여서, 해당 게시물의 노래가 비동기적으로 뷰에 들어가게 되어 게시물의 노래가 해당 게시물에 정확하게 들어가지 않는 문제가 발생함
   - 또한 노래 이미지 불러오기와 노래 듣기의 목적으로 통신이 되어야 했지만, 게시물이 조회될 때와 새로고침 할 때마다 딜레이와 함께 불필요한 나머지 데이터도 불러오게 되는 통신을 하게됨

2) 해결 방법
   - 이를 해결하기 위해 Codable한 데이터 모델을 추가, 선택한 노래를 먼저 데이터 모델에 맞게 담은 후 서버에 post 요청 시 JSONEncoding을 통해 JSON 형태의 문자열 데이터로 변환하여 Query에 추가한 이후 post 요청을 보내도록 구현

<details><summary> 구현한 코드
</summary>
<br>

****- SongModel**** 
```swift
struct SongModel: Codable {
    let id: String
    let title: String
    let artistName: String
    let albumCoverUrl: String
    let songURL: String
}
```
<br>

****- Post Logic code**** 
```swift
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
```
<br>

****- ConfigureView code**** 
```swift
let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, PostModel>>(configureCell: { [weak self] _, collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
  ...
let songData = Data(item.content1.utf8)
            do {
                let song = try JSONDecoder().decode(SongModel.self, from: songData)
                
                cell.configureSongView(song: song, viewType: .home) { tapGesture in
                    tapGesture
                        .bind(with: self) { owner, _ in
                            owner.checkMusicAuthorization {
                                owner.showTwoButtonAlert(title: "\(song.title)을 재생하기 위해 Apple Music으로 이동합니다.", message: nil) {
                                    MusicManager.shared.playSong(song: song)
                                }
                            }
                        }
                        .disposed(by: cell.disposeBag)
                }
            } catch {
                ...
            }
  ...
}
```
</details>
<br>

****2. multipart/form Data Upload 및 프로필 수정 기능 구현 과정**** 

1) 문제 발생
   - URLSession으로 네트워크 요청 코드를 작성함에 따라, 게시물 추가 기능 구현을 위해서는 Alamofire 라이브러리의 upload 메서드를 직접 구현해야 하는 문제 발생
   - 추가적으로로 프로필 수정 기능 구현을 위해 프로필 이미지(Image)와 닉네임(String)을 동시에 PUT 해야 하는 문제도 발생

2) 해결 방법
   - 메세지의 Part를 구분 짓는 boundary를 고유한 UUID 값으로 할당하여 메세지 본문과의 충돌 방지
   - 기존에 Router Pattern으로 정의한 headers와 body에 JSON 형태가 아닌 특정 메세지의 형식으로 입력
   - 프로필 수정의 경우, Image part와 Nickname part로 나누어 PUT 요청을 보내도록 구현


<details><summary> 구현한 코드
</summary>
<br>

****- Image Query**** 
```swift
struct ImageQuery {
    let boundary = UUID().uuidString
    let imageData: Data?
}
```
<br>

****- multipart/form Data HeaderFields**** 
```swift
func uploadRequest<T: Decodable>(apiType: LSLPRouter, decodingType: T.Type, completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
  ...
        guard let boundary = apiType.boundary else { return }
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        request.allHTTPHeaderFields = [
            APIHeader.sesac.rawValue: APIKey.key,
            APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
            "Content-Type": contentType
        ]
  ...
}
```
<br>

****- Router Pattern uploadImage httpBody**** 
```swift
var httpBody: Data? {
        let encoder = JSONEncoder()
        
        switch self {
    ...
        case .uploadImage(let imageQuery):
            var body = Data()
            
            body.append("--\(imageQuery.boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageQuery.imageData ?? Data())
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(imageQuery.boundary)--\r\n".data(using: .utf8)!)
            
            return body

    ...
    }
}
```
<br>

****- Router Pattern editMyProfile httpBody**** 
```swift
var httpBody: Data? {
        let encoder = JSONEncoder()
        
        switch self {
    ...
        case .editMyProfile(let editProfile):
            
            var body = Data()
            
            body.append("--\(editProfile.boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"nick\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(editProfile.nick.data(using: .utf8)!)
            body.append("\r\n".data(using: .utf8)!)
            
            body.append("--\(editProfile.boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profile\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            body.append(editProfile.profile)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(editProfile.boundary)--\r\n".data(using: .utf8)!)
            
            return body
  ...
    }
}
```

</details>
<br>

****3. 게시물 상세뷰 & 마이페이지 뷰의 ScrollView 불가 이슈**** 

1) 문제 발생
   - 마이페이지 뷰에서 유저의 정보와 유저가 작성한 게시물을 표시하도록 하기 위해 ScrollView에 나의 정보와 나의 게시물 CollectionView를 추가
   - 그러나 나의 게시물 갯수가 정해져 있지 않기에 CollectionView의 높이 지정이 되지 않아 ScrollView가 제대로 동작하지 않는 것을 확인하게 됨
   - 나의 정보와 나의 게시물 collectionView를 구분할 경우 나의 정보 뷰가 고정된 채로 collectionView만이 스크롤되어짐
   - 게시물 상세뷰에서도 게시물 정보와 댓글 CollectionView를 표시하는 경우에도 동일한 이슈 발생

2) 해결 방법
   - RxDataSource를 활용하여 MyPageDataType의 나의 정보, 나의 게시물 2개의 case로 구분
   - 유저 정보 조회하기 API를 요청하여 결과를 받아온 이후 SectionModelType의 item에 따라 mapping 진행
   - Mapping된 데이터를 Output으로 출력하여, RxCollectionViewSectionedReloadDataSource에 전달하여 CollectionView를 구성
   - item을 switch하여 셀 UI를 구성하도록 하여 전체 스크롤이 가능한 뷰로 구성
   - 게시물 상세뷰 또한 같은 방식으로 구현하여 해결

<details><summary> 구현한 코드</summary>
<br>

****- MyPageDataType****

```swift
enum MyPageDataType {
    case profile(items: [MyPageItem])
    case post(items: [MyPageItem])
}

extension MyPageDataType: SectionModelType {
    typealias Item = MyPageItem
    
    var items: [MyPageItem] {
        switch self {
        case .profile(items: let items):
            return items.map { $0 }
        case .post(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: MyPageDataType, items: [Item]) {
        switch original {
        case .profile(items: let items):
            self = .post(items: items)
        case .post(items: let items):
            self = .post(items: items)
        }
    }
}

enum MyPageItem {
    case profileItem(item: ProfileModel)
    case postItem(item: PostModel)
}

```

<br>


****- RxDataSource에 사용하기 위한 변환 및 Array 생성 과정****

```swift
final class MyPageViewModel: BaseViewModel {
  ...
func transform(input: Input) -> Output {
  Observable.zip(myProfile, myPosts)
            .map { [weak self] (profile, posts) -> [MyPageDataType] in
                if let self = self {
                    self.toUseEditMyProfile = profile
                }
                let convertPosts = posts.map { MyPageItem.postItem(item: $0) }
                let result = MyPageDataType.post(items: convertPosts)
                print("마이페이지", convertPosts.count)
                return [MyPageDataType.profile(items: [MyPageItem.profileItem(item: profile)]), result]
            }
            .bind(to: myPageData)
            .disposed(by: disposeBag)
  ...
}
```

<br>


****- Datasource****

```swift
let dataSource = RxCollectionViewSectionedReloadDataSource<MyPageDataType> (configureCell: { [weak self] _ , collectionView, indexPath, item in
    ...
  switch item {
    case .profileItem(item: let profile):
    ...
    case .postItem(item: let post):
    ...
    })

...

output.myPageData
            .bind(to: myPostCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
```
</details>

<br>

## 🎧 회고
****- MVVM 디자인 패턴과 Input/Output 디자인 패턴에 대한 고찰****
- MVVM 디자인 패턴에 RxSwift와 I/O 패턴을 적용해봄으로 더 직관적이고 MVVM에 충실한 반응형 프로그래밍 코드를 구현할 수 있었습니다. 그러나 점차 Input과 Output에 들어갈 요소들이 많아질수록 뷰모델이 점점 Massive해지고 로직 또한 복잡해짐을 느꼈으며, 이를 좀 더 해결할 수 있는 디자인 패턴들을 공부하고 다음 프로젝트에 적용해봐야겠다고 느꼈습니다. 그리고 extension을 많이 활용하지 않아 코드의 가독성이 떨어짐을 확인하였고, 추후 리팩토링과 다음 프로젝트에서 extension을 자주 활용하려고 합니다.

****- 네트워크 통신의 에러 헨들링에 대한 효율적인 코드****
- API요청에 관한 다양한 에러 케이스들을 겪어보고 그에 해당하는 에러 핸들링을 적용해볼 수 있었지만, 기간 내의 구현을 위해 에러 핸들링 케이스를 생성하여 추가해주어 ErrorManager의 코드의 길이가 매우 길어지게 되었습니다. 각 API에 대한 에러 케이스는 정해져 있었기 때문에, 다음 프로젝트에서는 라우터 패턴에 에러 핸들링에 관한 요소를 추가하여 가독성이 개선된 코드를 작성하려고 합니다.

****- NotificationCenter를 통한 데이터 전달****
- 평소 데이터 전달을 클로저와 델리게이트 패턴을 주로 사용하였습니다. 그러나 게시물 작성과 삭제, 댓글 작성 등의 기능 구현을 위해 이번 프로젝트에서는 또다른 방법인 NotificationCenter에 대해 학습하여 내부적으로 알림 및 데이터 전달을 진행하도록 구현하였습니다. NotificationCenter가 데이터의 광역적인 범위의 전달이 필요한 기능을 구현하기에 적합한 기술이라고 느꼈고, 다음 프로젝트에서는 더 다양한 용도로 활용해보려고 합니다.
