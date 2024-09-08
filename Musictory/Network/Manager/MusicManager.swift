//
//  MusicManager.swift
//  Musictory
//
//  Created by 김상규 on 9/8/24.
//

import UIKit
import MusicKit
import MusadoraKit
import MediaPlayer

final class MusicManager {
    static let shared = MusicManager()
    private init() { }
    
    func searchMusics(search: String, offset: Int, completionHandler: @escaping ((Result<MusicItemCollection<Song>, MusicKitError>)-> Void)) async {
        
        switch MusicAuthorization.currentStatus {
            
        case .denied:
            completionHandler(.failure(MusicKitError.denied))
        case .authorized:
            Task {
                do {
                    let songs = try await MusicManager.shared.requsetSearchMusic(term: search, offset: offset)
                    
                    completionHandler(.success(songs))
                } catch MusicKitError.networkError {
                    
                    completionHandler(.failure(.networkError))
                } catch MusicKitError.noResponse {

                    completionHandler(.failure(.noResponse))
                } catch {
                    completionHandler(.failure(.noResult))
                    print("알수 없는 에러: \(error)")
                }
            }
            
        default:
            break
        }
    }
    
    func requsetSearchMusic(term: String, offset: Int) async throws -> MusicItemCollection<Song> {
        await MusicAuthorization.request()
        
        var songs: MusicItemCollection<Song> = []
        
        do {
            songs = try await MCatalog.searchSongs(for: term, limit: 20, offset: offset).equivalents(for: "kr")
            
            guard !songs.isEmpty else {
                throw MusicKitError.noResult
            }
            
            
        } catch let error as URLError {
            
            throw MusicKitError.networkError
        } catch {
            print(error.localizedDescription)
            throw MusicKitError.noResponse
        }
        
        return songs
    }
    
    func requsetMusicId(id: String) async throws -> Song {
        await MusicAuthorization.request()
        var song: Song
        
        do {
            song = try await MCatalog.song(id: MusicItemID(stringLiteral: id)).equivalent(for: "kr")
            
        } catch let error as URLError {
            throw MusicKitError.networkError
        } catch {
            throw MusicKitError.noResult
        }
        
        return song
    }
    
    func playSong(song: SongModel) {
        if let url = URL(string: song.songURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                Task {
                    print(song.id)
                    for await subscribes in MusicSubscription.subscriptionUpdates {
                        if subscribes.canPlayCatalogContent {
                            print("애플뮤직 구독 O")
                            let musicPlayer = MPMusicPlayerController.systemMusicPlayer
                            musicPlayer.setQueue(with: ["\(song.id)"])
                            musicPlayer.play()
                        } else {
                            print("애플뮤직 구독 X")
                        }
                    }
                }
            } else {
                print("애플 뮤직을 실행할 수 없습니다")
            }
        } else {
            print("잘못된 링크입니다.")
        }
    }
}
