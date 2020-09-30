//
//  PhotoCell.swift
//  PhotoViewer
//
//  Created by Pierre on 29/09/2020.
//

import Foundation
import UIKit
import Kingfisher
protocol Expandable {
    func collapse()
    func expand(in collectionView: UICollectionView)
}

extension PhotoCell: Expandable {
    
    func expand(in collectionView: UICollectionView) {
        initialFrame = self.frame
        initialCornerRadius = self.contentView.layer.cornerRadius
        
        self.contentView.layer.cornerRadius = 0
        self.frame = CGRect(x: 0, y: collectionView.contentOffset.y + 60, width: collectionView.frame.width, height: collectionView.frame.height - 60)
        layoutIfNeeded()
    }
    
    func collapse() {
        self.contentView.layer.cornerRadius = initialCornerRadius ?? self.contentView.layer.cornerRadius
        self.frame = initialFrame ?? self.frame
        
        initialFrame = nil
        initialCornerRadius = nil
        layoutIfNeeded()
    }
    
    
}
class PhotoCell: UICollectionViewCell {
    private var initialFrame: CGRect?
    private var initialCornerRadius: CGFloat?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    
    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 8
        clipsToBounds = true
        
        self.nameLabel = UILabel()
        self.imageView = UIImageView()
        addSubview(imageView)
        addSubview(nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.font = .systemFont(ofSize: 16)
        self.nameLabel.textColor = .white
        self.nameLabel.textAlignment = .center
        self.nameLabel.numberOfLines = 0
        self.nameLabel.text = ""
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.layer.cornerRadius = 8
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.imageView.image = UIImage(systemName: "photo")
        nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 68).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -8).isActive = true
    }
    
    
    func hide(in collectionView: UICollectionView, frameOfSelectedCell: CGRect) {
        initialFrame = self.frame
        let currentY = self.frame.origin.y
        let newY: CGFloat
        
        if currentY < frameOfSelectedCell.origin.y {
            let offset = frameOfSelectedCell.origin.y - currentY
            newY = collectionView.contentOffset.y - offset - 200
        } else {
            let offset = currentY - frameOfSelectedCell.maxY
            newY = collectionView.contentOffset.y + collectionView.frame.height + offset + 200
        }
        
        self.frame.origin.y = newY
        self.imageView.isHidden = true
        self.nameLabel.isHidden = true
        layoutIfNeeded()
    }
    
    func show() {
        self.frame = initialFrame ?? self.frame
        initialFrame = nil
        
        self.imageView.isHidden = false
        self.nameLabel.isHidden = false
        layoutIfNeeded()
    }
    
    // MARK: -
    // MARK: Public Properties
    
    public func configure(with title: String, imageUrl: String?) {
        if let imgUrl = imageUrl, let url = URL(string: imgUrl) {
            
            DispatchQueue.main.async {
                let cacheResult = ImageCache.default.isCached(forKey: imgUrl)
                if  cacheResult == true {
                    ImageCache.default.retrieveImage(forKey: imgUrl, options: nil, completionHandler: { [unowned self] result in
                        switch result {
                        case .success(let value):
                            self.imageView.image = value.image
                        case .failure(let error):
                            print(error)
                        }
                    })
                } else {
                    let resource = ImageResource(downloadURL: url, cacheKey: imgUrl)
                    self.imageView.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil) { (result: Result<RetrieveImageResult, KingfisherError>) in
                        switch result {
                        case .success(_):
                            return
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                }
            }
            
        }
        guard self.nameLabel != nil else {
            return
        }
        self.nameLabel.text = title
    }
    
    public func setImageAspectFit() {
        imageView.contentMode = .scaleAspectFit
    }
    public func setImageAspectFill() {
        imageView.contentMode = .scaleAspectFill
    }
    public func cancelDownloadTask() {
        guard self.imageView != nil else {
            return
        }
        self.imageView.kf.cancelDownloadTask()
    }
    
}
