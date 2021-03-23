//
//  PhotoView.swift
//  Favorite Memories
//
//  Created by Epsilon User on 21/3/21.
//

import UIKit

class PhotoView: UIViewController {
    
    
    // MARK: - Outlets
    @IBOutlet weak var imageScrollView: ImageScrollView!
    // MARK: - Public Variables
    var selectedPhoto: PhotoViewModel!
    // MARK - Private Variables
    private var newTitle = ""
    private var isGrayscale = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation(selectedPhoto.title)
        navigationItem.setupBarButtons(
            left: [UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))],
            right: [UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPhoto))]
        )
        setupImage()
    }
    
    // MARK: - Setup Functions
    
    private func setupEditTitleAlert() {
        let alert = UIAlertController(title: "Edit Title", message: "Edit the title of the image:", preferredStyle: .alert)
        alert.addTextField { [weak self] (textField) in
            if let unwrappedSelf = self {
                textField.text = unwrappedSelf.selectedPhoto.title
            }
            textField.placeholder = "Photo title"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
            if let imageName = alert?.textFields?[0].text {
                self.newTitle = imageName
                DatabaseService.shared.update(photoID: self.selectedPhoto.id, with: self.newTitle) { [weak self] (success) in
                    if let unwrappedSelf = self,
                       success {
                        DispatchQueue.main.async {
                            unwrappedSelf.setupNavigation(unwrappedSelf.newTitle)
                        }
                    } else {
                        print("Could not update photo title")
                    }
                }
            }
        })
        present(alert, animated: true, completion: nil)
    }
    
    private func setupImage() {
        selectedPhoto.getImage(isThumb: false) { [weak self] image in
            guard let unwrappedSelf = self,
                  let zoomImage = image else {
                DispatchQueue.main.async {
                    self?.showDismissableAlert(with: "Error", message: "The image could not be loaded.\nTry again later.")
                }
                return
            }
            DispatchQueue.main.async {
                unwrappedSelf.imageScrollView.set(image: zoomImage)
            }
        }
    }
    
    // MARK: - Obj-C Functions
    @objc private func editPhoto(_ sender: UIBarButtonItem) {
        let actionSheetAlert = UIAlertController(title: "Photo Options", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let editTitleAction = UIAlertAction(title: "Edit Title", style: .default) { [weak self] _ in
            guard let unwrappedSelf = self else {
                return
            }
            unwrappedSelf.setupEditTitleAlert()
        }
        let rotateAction = UIAlertAction(title: isGrayscale ? "Colored" : "Black and White", style: .default) { [weak self] _ in
            guard let unwrappedSelf = self else {
                return
            }
            unwrappedSelf.isGrayscale = !unwrappedSelf.isGrayscale
            unwrappedSelf.setColorFilter()
        }
        actionSheetAlert.addAction(cancelAction)
        actionSheetAlert.addAction(editTitleAction)
        actionSheetAlert.addAction(rotateAction)
        if let popoverController = actionSheetAlert.popoverPresentationController {
            popoverController.barButtonItem = sender
        }
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc private func goBack(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "unwindToList", sender: self)
    }
    
    // MARK: - Update Functions
    private func setColorFilter() {
        if (isGrayscale) {
            imageScrollView.setGrayscale()
        } else {
            imageScrollView.resetImage()
        }
    }

}
