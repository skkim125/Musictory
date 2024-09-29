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
-  MusicKit(MusadoraKit), URLScheme, URLSession, PHPickerView, Kingfisher
- Decoder, Singleton, Router Pattern, Access Control

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

## 🎧 회고
