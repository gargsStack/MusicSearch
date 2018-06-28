//
//  ViewController.swift
//  MusicSearch
//
//  Created by Vivek on 29/06/18.
//  Copyright © 2018 Vivek. All rights reserved.
//

import UIKit
import AVFoundation
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    
    let dataSource = iTunesDS()
    
    var searchTerm: String = ""
    var tracks = [Track]()
    
    var player:AVPlayer?
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchController()
    }
    
    @objc func searchCollectionAction(sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: listTableView)
        if let indexPath = listTableView.indexPathForRow(at: hitPoint) {
            let track = tracks[indexPath.row]
            if !track.collectionId.isEmpty {
                self.searchCollection(for: track.collectionId, collectionName: track.collectionName)
            }
        }
    }
    
    private func setUpSearchController() {
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        listTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    
    //MARK:- Playback audio
    func playPreview(songUrl: String) {
        if let url = URL(string: songUrl) {
            let playerItem: AVPlayerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            self.player?.play()
        }
    }
}

//MARK:- UITableViewDataSource methods
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
        
        cell.viewModel = TrackCellModel(track: tracks[indexPath.row], dataSource: dataSource)
        cell.collNameButton.addTarget(self, action: #selector(ViewController.searchCollectionAction(sender:)), for: .touchUpInside)
        
        return cell
    }
}

//MARK:- UITableViewDelegate methods
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tracks[indexPath.row].previewUrl.isEmpty {
            self.playPreview(songUrl: tracks[indexPath.row].previewUrl)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK:- UISeacrBarDelegate methods
extension ViewController: UISearchBarDelegate {
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            SVProgressHUD.show()
            self.searchTerm = text
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            dataSource.search(for: text, completion: { [weak self] tracks, error  in
                SVProgressHUD.dismiss()
                self?.navigationItem.title = self?.searchTerm
                
                DispatchQueue.main.async(execute: {
                    if error == nil {
                        self?.tracks = tracks!
                        self?.searchController.isActive = false
                        self?.listTableView.reloadData()
                    } else {
                        let alert = UIAlertController(title: nil, message: "Error fetching tracks", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in })
                        self?.present(alert, animated: true)
                    }
                })
            })
        }
    }
    
    func searchCollection(for collectionId: String, collectionName: String) {
        SVProgressHUD.show()
        self.navigationItem.title = collectionName
        
        dataSource.searchCollection(for: collectionId, completion: { [weak self] tracks, error  in
            SVProgressHUD.dismiss()
            
            DispatchQueue.main.async(execute: {
                if error == nil {
                    self?.tracks = tracks!
                    self?.searchController.isActive = false
                    self?.listTableView.reloadData()
                } else {
                    let alert = UIAlertController(title: nil, message: "Error fetching tracks", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { action in })
                    self?.present(alert, animated: true)
                }
            })
        })
    }
}
