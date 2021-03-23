//
//  AlbumsCollection.swift
//  Favorite Memories
//
//  Created by Epsilon User on 11/3/21.
//

import UIKit

private let reuseIdentifier = "albumCell"

class AlbumsCollection: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Private Variables
    private var albums = [AlbumViewModel]()
    private var loadingSpinner: UIActivityIndicatorView!
    private var selectedAlbum: AlbumViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation("Albums")
        setupActivityIndicator()
        collectionView.setupRefresh(placeholder: "Fetching Albums...")
        collectionView.refreshControl?.addTarget(self, action: #selector(syncAlbums), for: .valueChanged)
        setupCollectionView()
        
    }
    
    // MARK: - Delegate Functions

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return albums.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCell
        cell.albumVM = albums[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let itemVM = albums[indexPath.row]
        selectedAlbum = itemVM
        
        performSegue(withIdentifier: "showPhotoList", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        // Add padding between items
        return UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoList" {
            if let destinationVC = segue.destination as? PhotosListTableView {
                destinationVC.album = selectedAlbum
            }
        }
    }
    
    // MARK: - Setup Functions
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "Album", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        DatabaseService.shared.readAlbums { [weak self] (dbAlbums) in
            if let returnedAlbums = dbAlbums,
               let unwrappedSelf = self {
                
                if returnedAlbums.isEmpty {
                    unwrappedSelf.refreshCollection(isRefresh: false)
                } else {
                    unwrappedSelf.albums = returnedAlbums.map({ return AlbumViewModel(album: $0) })
                    DispatchQueue.main.async {
                        unwrappedSelf.updateUI(isRefresh: false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.updateUI(isRefresh: false)
                }
            }
        }
    }
    
    private func setupActivityIndicator() {
        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner.color = .black
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(loadingSpinner)
        loadingSpinner.startAnimating()
        
        loadingSpinner.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
    }
    
    private func setupEmptyList() {
        guard let emptyList = Bundle.main.loadNibNamed("EmptyList", owner: self, options: nil)?.first as? EmptyListView else { return }
        emptyList.viewType = .AlbumView
        emptyList.setuplabel()
        collectionView.backgroundView = emptyList
    }
    
    // MARK: - Obj-C Functions
    
    @objc private func syncAlbums() {
        refreshCollection(isRefresh: true)
    }
    
    // MARK: - Update Functions
    
    private func updateUI(isRefresh: Bool) {
        if isRefresh {
            collectionView.refreshControl?.endRefreshing()
        } else {
            loadingSpinner.stopAnimating()
            loadingSpinner.removeFromSuperview()
        }
        collectionView.reloadData()
    }
    
    private func refreshCollection(isRefresh: Bool) {
        WebService.shared.fetchAlbums { (webError) in
            DatabaseService.shared.readAlbums { [weak self] (dbAlbums) in
                if let returnedAlbums = dbAlbums,
                   let unwrappedSelf = self {
                    unwrappedSelf.albums = returnedAlbums.map({ return AlbumViewModel(album: $0) })
                    
                    DispatchQueue.main.async {
                        if returnedAlbums.isEmpty {
                            unwrappedSelf.setupEmptyList()
                        } else {
                            unwrappedSelf.collectionView.backgroundView = nil
                        }
                        if webError != nil {
                            switch webError {
                            case .connectionRefused:
                                unwrappedSelf.showAlert(with: "Error", message: "Your connection appears to be offline.")
                                break
                            default:
                                unwrappedSelf.showAlert(with: "Error", message: "Something went wrong.\nTry again later.")
                                break
                            }
                        }
                        unwrappedSelf.updateUI(isRefresh: isRefresh)
                    }
                } else {
                    self?.updateUI(isRefresh: isRefresh)
                }
            }
        }
    }

}
