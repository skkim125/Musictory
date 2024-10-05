# 🎧 Musictory ReadMe

## 🎧 프로젝트 소개
> 일상을 음악과 함께 하는 사람들이 기록을 남기듯 일상을 노래와 함께 공유하는 SNS 앱

<img src="https://github.com/user-attachments/assets/00d5a9f7-88cf-4b2e-9cbb-952ddd8d0161" width="19%"/>
<img src="https://github.com/user-attachments/assets/c9721c15-1de1-4827-a9d8-9b696f208538" width="19%"/>
<img src="https://github.com/user-attachments/assets/8b665c5c-e358-4e6b-b0d5-a1765a75c3f4" width="19%"/>
<img src="https://github.com/user-attachments/assets/09c14dfe-1950-4df8-a9fc-487a72691b27" width="19%"/>
<img src="https://github.com/user-attachments/assets/efccf9e2-9132-42b7-a366-dcd9c34f61a5" width="19%"/>

## 🎧 프로젝트 환경
- 인원: 1명
- 기간: 2024.08.14 ~ 24.09.08
- 개발 환경: Xcode 15
- 최소 버전: iOS 15.0


## 🎧 기술 스택
- UIKit, CodeBaseUI, MVVM, Input/Output, RxSwift, SnapKit
-  MusicKit(MusadoraKit), URLScheme, URLSession, PHPickerView, Kingfisher, iamport, Toast
- Decoder, Singleton, Router Pattern, Access Control, UserDefaults

## 🎧 핵심 기능
- 뮤직토리(음악 필수 추가) 작성 및 보기, 뮤직토리에 좋아요 및 댓글 기능
- 뮤직토리의 노래 애플뮤직에서 듣기
- 프로필 수정 및 내가 좋아요한 글 확인 기능

## 🎧 주요 기술
- MVVM + Input/Output
  - ViewController와 ViewModel로 분리함으로 비즈니스 로직 분리 및 RxSwift Input/Output 패턴으로 구현
- URLSession을 사용한 NetworkManager Singleton Pattern으로 구성
   - Genric을 활용하여 Decodable한 타입들로 디코딩 진행
   - API Networking에 대한 요소들을 Router Pattern으로 추상화
   - multipart/form Data upload를 위해 body에 form-data 작성
- RxSwift로 반응형 프로그래밍 구현
- MusicKit SongData를 Codable타입으로 변환 후 JSON형태로 한번더 Decoding하여 서버에 전송

## 🎧 트러블 슈팅

****1. 노래 데이터 전송**** 

1) 문제 발생
- 처음에는 선택한 노래의 고유 id를 저장하여, 게시물 조회를 할 때마다 게시물 데이터를 가져오면 또다시 MusicKit 메서드로 통신을 하여 노래 정보가 담긴 뷰를 표시
- 그러나 MusicKit의 노래 조회 메서드는 Async/await 메서드여서, 해당 게시물의 노래가 비동기적으로 뷰에 들어가게 되어 게시물의 노래가 정확하게 들어가지 않음
- 또한 노래 이미지 불러오기와 노래 듣기의 목적으로 통신이 되어야 했지만, 게시물이 조회될 때와 새로고침 할 때마다 딜레이와 함께 불필요한 나머지 데이터도 불러오게 되는 통신을 하게됨

2) 해결 방법
-  이를 해결하기 위해 Codable한 데이터 모델을 추가, 선택한 노래를 먼저 데이터 모델에 맞게 담은 후 서버에 post 요청 시 JSONEncoding을 통해 JSON 형태의 문자열 데이터로 변환하여 Query에 추가한 이후 post 요청을 보내도록 구현

<details><summary> 구현한 코드
</summary>

- SongModel
<img src="https://github.com/user-attachments/assets/459e1796-c4a0-4f45-8000-27d10b045b24" width="33%"/>

- Post Logic code
<img src="https://github.com/user-attachments/assets/93c94fa1-90bb-4d02-8768-bda6669f50fe" width="40%"/>

- ConfigureView code
<img src="https://github.com/user-attachments/assets/cccc07c4-cb7a-44e0-867e-36551ebdd898" width="50%"/>
</details>

****2. multipart/form Data Upload**** 

1) 문제 발생
- URLSession으로 네트워크 요청 코드를 작성함에 따라, 게시물 추가 기능 구현을 위해서는 Alamofire 라이브러리의 upload 메서드를 직접 구현해야 하는 문제 발생
- 추가적으로로 프로필 수정 기능 구현을 위해 프로필 이미지(Image)와 닉네임(String)을 동시에 PUT 해야 하는 문제도 발생

2) 해결 방법
- 메세지의 Part를 구분 짓는 boundary를 고유한 UUID 값으로 할당하여 메세지 본문과의 충돌 방지
- 기존에 Router Pattern으로 정의한 headers와 body에 JSON 형태가 아닌 특정 메세지의 형식으로 입력
- 프로필 수정의 경우, Image part와 Nickname part로 나누어 PUT 요청을 보내도록 구현


<details><summary> 구현한 코드
</summary>

- Image Query
<img src="https://github.com/user-attachments/assets/71537614-ad62-416b-817d-dfdd7b5c0aa5" width="40%"/>

- multipart/form Data HeaderFields
<img src="https://github.com/user-attachments/assets/8b6b1d3c-4077-4a07-b7bd-c1efa2858cb3" width="40%"/>

- Router Pattern 게시물 Post의 httpBody
<img src="https://github.com/user-attachments/assets/9ad7fa3a-4765-4b57-827b-75b6330a1d0c" width="45%"/>

- Router Pattern 프로필 수정의 httpBody
<img src="https://github.com/user-attachments/assets/537c6db6-242a-4d84-948e-fc5cf2024823" width="45%"/>

</details>

## 🎧 회고
- MVVM 디자인 패턴에 RxSwift와 Input/Output 패턴을 적용해봄으로 직관적인 반응형 프로그래밍 코드를 구현할 수 있었습니다.
- API요청에 관한 다양한 에러 케이스들을 겪어보고, 그에 해당하는 에러 핸들링을 적용해볼 수 있었습니다.
- 그리고 게시물 작성, 삭제, 댓글 작성 등의 기능 구현을 위해 NotificationCenter를 통해 내부적으로 알림 및 데이터 전달을 진행하도록 구현할 수 있었습니다.
