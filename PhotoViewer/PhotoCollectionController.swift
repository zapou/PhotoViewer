//
//  PhotoCollectionController.swift
//  PhotoViewer
//
//  Created by Pierre on 29/09/2020.
//

import Foundation
import UIKit
import Kingfisher
import PhotoAPI

class PhotoCollectionController: UICollectionViewController {
    
    // MARK: -
    // MARK: Private
    private var expandedCell: PhotoCell?
    private var hiddenCells: [PhotoCell] = []
    private var cellID = "CellID"
    private var data: [BaseModel]!
    private var dataManager: ApiManager!
    
    // MARK: -
    // MARK: Life Cycle
    init() {
        let layout = UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets.init(top: 8, leading: 8, bottom: 8, trailing: 8)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataManager = ApiManager(api: .Flickr)
        navigationController?.navigationBar.backgroundColor = .white
        navigationItem.title = self.dataManager.getDescription() + " Viewer"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellID)
        self.dataManager.manager.getData(closure: { [unowned self] data in
            self.data = data
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    
    // MARK: -
    // MARK: CollectionView DataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data == nil ? 0 : self.data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! PhotoCell
        let datum = self.data[indexPath.row]
        let title = datum.title
        let imgUrl = datum.url
        cell.configure(with: title, imageUrl: imgUrl)
        return cell
    }
    
    
    // MARK: -
    // MARK: CollectionView Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dampingRatio: CGFloat = 1
        let initialVelocity: CGVector = CGVector.zero
        let springParameters: UISpringTimingParameters = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: initialVelocity)
        let animator = UIViewPropertyAnimator(duration: 1 , timingParameters: springParameters)
        
        self.collectionViewLayout.invalidateLayout()
        self.view.isUserInteractionEnabled = false
        
        if let selectedCell = expandedCell {
            animator.addAnimations {
                self.expandedCell!.setImageAspectFill()
                selectedCell.collapse()
                
                for cell in self.hiddenCells {
                    cell.show()
                }
            }
            animator.addCompletion { _ in
                collectionView.isScrollEnabled = true
                
                self.expandedCell = nil
                self.hiddenCells.removeAll()
            }
        } else {
            collectionView.isScrollEnabled = false
           
            let selectedCell = collectionView.cellForItem(at: indexPath)! as! PhotoCell
            let frameOfSelectedCell = selectedCell.frame
            
            expandedCell = selectedCell
            hiddenCells = collectionView.visibleCells.map { $0 as! PhotoCell }.filter { $0 != selectedCell }
            
            animator.addAnimations {
                selectedCell.expand(in: collectionView)
                
                self.expandedCell!.setImageAspectFit()
                for cell in self.hiddenCells {
                    cell.hide(in: collectionView, frameOfSelectedCell: frameOfSelectedCell)
                }
            }
        }
    
        animator.addCompletion { _ in
            self.view.isUserInteractionEnabled = true
        }
        
        animator.startAnimation()
    }
}
