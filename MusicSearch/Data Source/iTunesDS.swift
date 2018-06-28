//
//  iTunesDS.swift
//  MusicSearch
//
//  Created by Vivek on 29/06/18.
//  Copyright © 2018 Vivek. All rights reserved.
//

import Foundation

final class iTunesDS {
    
    //Key mapping for parsing iTunes API response
    struct iTunesKeys {
        static let baseSongSearch = "https://itunes.apple.com/search?term="
        static let baseCollectionSearch = "https://itunes.apple.com/lookup?entity=song&id="
        
        static let kind = "kind"
        static let kindTypeSong = "song"
        
        static let artistName = "artistName"
        static let collectionName = "collectionName"
        static let trackName = "trackName"
        static let previewUrl = "previewUrl"
        static let artworkUrl = "artworkUrl100"
        static let trackPrice = "trackPrice"
        static let releaseDate = "releaseDate"
        static let currency = "currency"
        static let collectionId = "collectionId"
        static let genre = "primaryGenreName"
        
    }
    
    private let sessionConfig: URLSessionConfiguration
    private let session: URLSession
    
    private lazy var dateFormatter: DateFormatter = {
        //1998-12-28T08:00:00Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()
    
    var imageDownloadTask: URLSessionTask?
    
    init() {
        sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig)
    }
    
    
    //MARK:- Search content
    //Search for songs by name
    func search(for searchTerm: String, completion: @escaping (_ tracks: [Track]?, _ errorMessage: String?) -> Void) {
        
        let encodedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = iTunesKeys.baseSongSearch.appending(encodedTerm!)
        
        print("urlString \(urlString)")
        
        let url = URL(string: urlString)
        guard url != nil else {
            completion(nil, nil)
            return
        }
        
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            //print("Response: \(response)")
            if error == nil {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode == 200 {
                    guard data != nil else {
                        completion(nil, "No data received")
                        return
                    }
                    let tracks = self?.parseSearchResults(with: data!)
                    completion(tracks, nil)
                } else {
                    print("Error: \(error)")
                    completion(nil, error?.localizedDescription)
                }
            } else {
                
            }
        })
        
        task.resume()
    }
    
    //Search for songs in a collection
    func searchCollection(for collectionId: String, completion: @escaping (_ tracks: [Track]?, _ errorMessage: String?) -> Void) {
        
        let urlString = iTunesKeys.baseCollectionSearch.appending(collectionId)
        
        print("urlString \(urlString)")
        
        let url = URL(string: urlString)
        guard url != nil else {
            completion(nil, nil)
            return
        }
        
        let request = URLRequest(url: url!)
        
        let task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
            //print("Response: \(response)")
            if error == nil {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode == 200 {
                    guard data != nil else {
                        completion(nil, "No data received")
                        return
                    }
                    let tracks = self?.parseSearchResults(with: data!)
                    completion(tracks, nil)
                } else {
                    print("Error: \(error)")
                    completion(nil, error?.localizedDescription)
                }
            } else {
                
            }
        })
        
        task.resume()
    }
    
    
    //MARK:- Parse search results
    private func parseSearchResults(with data: Data) -> [Track]? {
        
        var tracks = [Track]()
        
        do {
            let response = try JSONSerialization.jsonObject(with: data,
                                                            options: .allowFragments) as! [String: Any]
            let results = response["results"] as! [[String: Any]]
            
            for item in results {
                guard let kind = item[iTunesKeys.kind] as? String, kind == iTunesKeys.kindTypeSong else {
                    continue
                }
                
                let trackName = item[iTunesKeys.trackName] as! String
                let artistName = item[iTunesKeys.artistName] as? String ?? ""
                let collectionName = item[iTunesKeys.collectionName] as? String ?? ""
                let artworkUrl = item[iTunesKeys.artworkUrl] as? String ?? ""
                let releaseDate = date(from: item[iTunesKeys.releaseDate] as! String)
                let price =  item[iTunesKeys.trackPrice] as? NSNumber ?? NSNumber(integerLiteral: 0)
                let currency = item[iTunesKeys.currency] as? String ?? ""
                let genre = item[iTunesKeys.genre] as? String ?? ""
                let previewUrl = item[iTunesKeys.previewUrl] as? String ?? ""
                
                var collectionId = ""
                if let collId = item[iTunesKeys.collectionId] as? NSNumber {
                    collectionId = String(describing: collId)
                }
                
                let track = Track(trackName: trackName,
                                  artistName: artistName,
                                  price: price,
                                  currency: currency,
                                  collectionName: collectionName,
                                  artworkUrl: artworkUrl,
                                  collectionId: collectionId,
                                  releaseDate: releaseDate,
                                  genre: genre,
                                  previewUrl: previewUrl)
                
                tracks.append(track)
            }
            
            return tracks
        }
        catch let error as NSError {
            print("Error in json: \(error)")
        }
        
        return nil
    }
    
    
    private func date(from string: String) -> Date {
        return dateFormatter.date(from: string)!
    }
    
    //MARK:- Image download
    func downloadImage(from url: String, completion: @escaping (_ imageData: Data?) -> Void) {
        let imageUrl = URL(string: url)
        
        guard imageUrl != nil else {
            completion(nil)
            return
        }
        
        imageDownloadTask = session.dataTask(with: imageUrl!, completionHandler: { (data, response, error) in
            if error == nil {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode == 200 {
                    guard data != nil else {
                        completion(nil)
                        return
                    }
                    completion(data)
                }
            } else {
                print("Couldn't load image from url: \(imageUrl)")
                completion(nil)
            }
        })
        
        imageDownloadTask?.resume()
    }
}
