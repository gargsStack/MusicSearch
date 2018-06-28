//
//  TrackCellModel.swift
//  MusicSearch
//
//  Created by Vivek on 29/06/18.
//  Copyright © 2018 Vivek. All rights reserved.
//

import Foundation

protocol TrackCellModelDelegate: class {
    
    func imageDataDownloadDidFinished()
}


final class TrackCellModel {
    
    weak var delegate: TrackCellModelDelegate?
    
    let artistName: String!
    let trackName: String!
    let thumbnailUrl: String!
    let collName: String!
    let collId: String
    let priceString: String!
    let genre: String!
    
    var imageData: Data? {
        didSet {
            if imageData != nil {
                delegate?.imageDataDownloadDidFinished()
            }
        }
    }
    
    private let dataSource: iTunesDS
    
    init(track: Track, dataSource: iTunesDS) {
        artistName = track.artistName
        trackName = track.trackName
        thumbnailUrl = track.artworkUrl
        collName = track.collectionName
        collId = track.collectionId
        priceString = track.currency + " \(track.price)"
        genre = track.genre
        
        self.dataSource = dataSource
        
        downloadImageData()
    }
    
    
    private func downloadImageData() {
        
        dataSource.downloadImage(from: thumbnailUrl, completion: { [weak self] data in
            if data != nil {
                self?.imageData = data
            }
        })
    }
    
}
