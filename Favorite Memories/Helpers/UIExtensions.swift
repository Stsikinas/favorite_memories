//
//  UIExtensions.swift
//  Favorite Memories
//
//  Created by Epsilon User on 11/3/21.
//

import Foundation
import UIKit


// MARK: - UIColor
extension UIColor {
    
    class var primaryColor: UIColor {
        get {
            return UIColor(red: 0.948, green: 0.790, blue: 0.524, alpha: 1.0)
        }
    }
    
    class var randomColor: UIColor {
        get {
            return UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1.0)
        }
    }
}

// MARK: - UINavigationItem
extension UINavigationItem {
    
    func setupBarButtons(left: [UIBarButtonItem], right: [UIBarButtonItem]) {
        if !left.isEmpty {
            leftBarButtonItems = left
        }
        if !right.isEmpty {
            rightBarButtonItems = right
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    func setupNavigation(_ withTitle: String) {
        title = withTitle
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Chalkduster", size: 24.0)!
        ]
        navigationController?.navigationBar.tintColor = .black
    }
    
    func showAlert(with title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showDismissableAlert(with title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UITableView
extension UITableView {
    
    func setupRefresh(placeholder: String) {
        refreshControl = UIRefreshControl()
        refreshControl!.tintColor = .primaryColor
        refreshControl!.attributedTitle = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryColor])
        addSubview(refreshControl!)
    }
    
    func removeFooterView() {
        tableFooterView = UIView()
    }
}

// MARK: - UICollectionView
extension UICollectionView {
    
    func setupRefresh(placeholder: String) {
        refreshControl = UIRefreshControl()
        refreshControl!.tintColor = .primaryColor
        refreshControl!.attributedTitle = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryColor])
        addSubview(refreshControl!)
    }
    
}

// MARK: - UIImageView
extension UIImageView {
    func setZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomImage))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
    }
    
    @objc private func zoomImage(_ sender: UIPinchGestureRecognizer) {
        let scaleBy = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleBy,
              scale.a > 1,
              scale.b > 1 else {
            return
        }
        sender.view?.transform = scale
        sender.scale = 1
    }
}
