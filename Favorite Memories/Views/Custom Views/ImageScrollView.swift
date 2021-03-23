//
//  ImageScrollView.swift
//  Favorite Memories
//
//  Created by Epsilon User on 21/3/21.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {
    
    // MARK: - Subviews
    var imageView: UIImageView!
    
    // MARK: - Private Variables
    private var initialImage: UIImage?
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureDelegate()
        initialImage = nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureDelegate()
        initialImage = nil
    }
    
    // MARK: - Delegate Functions
    override func layoutSubviews() {
        super.layoutSubviews()
        
        centerImage()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /// Setup photo and call configureSize
    /// - Parameter image: The photo
    func set(image: UIImage) {
        initialImage = image
        imageView = UIImageView(image: image)
        addSubview(imageView)
        
        configureSize(image: image)
    }
    
    
    /// Give content size and scale levels
    /// - Parameter image: The photo
    private func configureSize(image: UIImage) {
        contentSize = image.size
        
        setupMaxMin()
    }
    
    /// Set minimum & maximum scale to image. Using minimum and maximum required scales with obtain he minScale and set this scale to active scale
    private func setupMaxMin() {
        
        let imageSize = imageView.bounds.size
        
        let widthScale = bounds.width / imageSize.width
        let heightScale = bounds.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        minimumZoomScale = minScale
        zoomScale = minScale
        // Keep max scale to 1, in order to keep image quality
        maximumZoomScale = 1.0
        
    }
    
    
    /// Center the image on the scroll view. We get the diff between sizes to calculate the origin of the image
    private func centerImage() {
        if imageView == nil {
            return
        }
        var imageFrame = imageView.frame
        
        if imageFrame.size.width < bounds.size.width {
            imageFrame.origin.x = (bounds.size.width - imageFrame.size.width) / 2
        } else {
            imageFrame.origin.x = 0
        }
        
        if imageFrame.size.height < bounds.size.height {
            imageFrame.origin.y = (bounds.size.height - imageFrame.size.height) / 2
        } else {
            imageFrame.origin.y = 0
        }
        
        imageView.frame = imageFrame
    }
    
    
    /// Setup the UIScrollViewDelegate
    private func configureDelegate() {
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        decelerationRate = .fast
    }
    
    
    /// Use  the CI properties to add grayscale filter to image
    public func setGrayscale() {
        let context = CIContext(options: nil)
        guard let image = imageView.image else {
            return
        }
        let ciImage = CIImage(image: image)
        if let imageFilter = CIFilter(name: "CIPhotoEffectNoir") {
            imageFilter.setValue(ciImage, forKey: kCIInputImageKey)
            if let grayscaledCIImage = imageFilter.outputImage {
                if let grayCGImage = context.createCGImage(grayscaledCIImage, from: grayscaledCIImage.extent) {
                    imageView.image = UIImage(cgImage: grayCGImage)
                }
            }
        }
    }
    
    public func resetImage() {
        imageView.image = initialImage
    }

}
