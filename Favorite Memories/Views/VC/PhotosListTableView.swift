//
//  PhotosListTableView.swift
//  Favorite Memories
//
//  Created by Epsilon User on 17/3/21.
//

import UIKit

class PhotosListTableView: UITableViewController {

    // MARK: - Public Variables
    public var album: AlbumViewModel!
    // MARK: - Private Variables
    private let reuseIdentifier = "photoCell"
    private var albumTitle = ""
    private var albumID = Int16(0)
    private var photos = [PhotoViewModel]()
    private var page = Int16(0)
    private var loadingSpinner: UIActivityIndicatorView!
    private var selectedPhoto: PhotoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumTitle = album.title
        albumID = album.id
        page = album.page
        setupNavigation(albumTitle)
        tableView.setupRefresh(placeholder: "Fetching Photos...")
        tableView.refreshControl?.addTarget(self, action: #selector(syncPhotos), for: .valueChanged)
        setupActivityIndicator()
        setupTableView()
    }

    // MARK: - Delegate Functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PhotoCell
        cell.photoVM = photos[indexPath.row]
        cell.photoVM.getImage(isThumb: true) { (image) in
            DispatchQueue.main.async {
                cell.photoImage.image = image
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPhoto = photos[indexPath.row]
        performSegue(withIdentifier: "showPhoto", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            if let destinationVC = segue.destination as? PhotoView {
                destinationVC.selectedPhoto = selectedPhoto
            }
        }
    }
    
    // MARK: - Setup Functions
    
    private func setupActivityIndicator() {
        loadingSpinner = UIActivityIndicatorView(style: .large)
        loadingSpinner.color = .black
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(loadingSpinner)
        loadingSpinner.startAnimating()
        
        loadingSpinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        loadingSpinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }
    
    private func setupEmptyList() {
        guard let emptyList = Bundle.main.loadNibNamed("EmptyList", owner: self, options: nil)?.first as? EmptyListView else { return }
        emptyList.viewType = .PhotosView
        emptyList.setuplabel()
        tableView.backgroundView = emptyList
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "Photo", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.removeFooterView()
        DatabaseService.shared.readPhotos(albumId: albumID){ [weak self] (dbPhotos) in
            if let returnedPhotos = dbPhotos,
               let unwrappedSelf = self {
                
                if returnedPhotos.isEmpty {
                    unwrappedSelf.refreshTableView(isRefresh: false)
                } else {
                    unwrappedSelf.photos = returnedPhotos.map({ return PhotoViewModel(photo: $0) })
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
    
    // MARK: - Obj-C Functions
    @objc private func syncPhotos() {
        refreshTableView(isRefresh: true)
    }
    
    // MARK: - Update Functions
    private func updateUI(isRefresh: Bool) {
        if isRefresh {
            tableView.refreshControl?.endRefreshing()
        } else {
            loadingSpinner.stopAnimating()
            loadingSpinner.removeFromSuperview()
        }
        tableView.reloadData()
    }
    
    private func refreshTableView(isRefresh: Bool) {
        WebService.shared.fetchPhotos(albumID: albumID, page: page) { (webError, newPage)  in
            DatabaseService.shared.readPhotos(albumId: self.albumID) { [weak self] (dbPhotos) in
                if let returnedPhotos = dbPhotos,
                    let unwrappedSelf = self {
                    
                    unwrappedSelf.photos = returnedPhotos.map({ return PhotoViewModel(photo: $0) })
                    unwrappedSelf.page = newPage
                    DispatchQueue.main.async {
                        if returnedPhotos.isEmpty {
                            unwrappedSelf.setupEmptyList()
                        } else {
                            unwrappedSelf.tableView.backgroundView = nil
                        }
                        unwrappedSelf.updateUI(isRefresh: isRefresh)
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
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.updateUI(isRefresh: isRefresh)
                    }
                }
            }
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        setupActivityIndicator()
        DatabaseService.shared.readPhotos(albumId: albumID){ [weak self] (dbPhotos) in
            if let returnedPhotos = dbPhotos,
                let unwrappedSelf = self {
                unwrappedSelf.photos = returnedPhotos.map({ return PhotoViewModel(photo: $0) })
                    DispatchQueue.main.async {
                        unwrappedSelf.updateUI(isRefresh: false)
                    }
            } else {
                DispatchQueue.main.async {
                    self?.updateUI(isRefresh: false)
                }
            }
        }
    }

}
