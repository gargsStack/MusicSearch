//
//  TrackCell.swift
//  MusicSearch
//
//  Created by Vivek on 29/06/18.
//  Copyright © 2018 Vivek. All rights reserved.
//

import UIKit

final class TrackCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var collNameButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    //Whenever set, this model will setup the UI components of the cell and start image download
    var viewModel: TrackCellModel? {
        didSet {
            artistNameLabel.text = viewModel?.artistName
            trackNameLabel.text = viewModel?.trackName
            collNameButton.setTitle(viewModel?.collName, for: .normal)
            priceLabel.text = viewModel?.priceString
            genreLabel.text = viewModel?.genre
            
            viewModel?.delegate = self
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension TrackCell: TrackCellModelDelegate {
    
    //Image download finished. Update imageview
    func imageDataDownloadDidFinished() {
        DispatchQueue.main.async {
            self.thumbnailView.image = UIImage(data: (self.viewModel?.imageData!)!)
        }
    }
}

