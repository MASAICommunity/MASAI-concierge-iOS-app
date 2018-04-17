//
//  GooglePlacesCollectionViewCell.swift
//  masai
//
//  Created by Bartomiej Burzec on 08.03.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher


class GooglePlacesCollectionViewCell: UICollectionViewCell, ChatCell {

    static let singlePlaceWidth: CGFloat = 295.0
    static let identifier = "GooglePlacesCollectionViewCell"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var places = List<GooglePlace>()
    weak var delegateForCell: GooglePlaceDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        registerNibForCollectionView()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    static func calculateHeight(for message: ChatMessage) -> CGFloat {
        return calculateHeight()
    }
    
    static func calculateHeight() -> CGFloat {
        return 220.0
    }
    
    private func registerNibForCollectionView() {
        self.collectionView.register(UINib(nibName: SingleGooglePlaceCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SingleGooglePlaceCollectionViewCell.identifier)
    }

}

extension GooglePlacesCollectionViewCell : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = self.places[indexPath.row]
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: SingleGooglePlaceCollectionViewCell.identifier, for: indexPath) as! SingleGooglePlaceCollectionViewCell
        
        cell.model = data        
        cell.nameLabel.text = data.name
        cell.typeLabel.text = data.type
        cell.ratingLabel.text = "\(data.rating)"
        cell.ratingStars.rating = data.rating
        cell.imageView.kf.setImage(with: URL(string: data.photoAddress()))
        cell.delegate = delegateForCell
        
        return cell
    }

}

extension GooglePlacesCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return  0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = GooglePlacesCollectionViewCell.singlePlaceWidth
        let height: CGFloat = GooglePlacesCollectionViewCell.calculateHeight()
        
        return CGSize(width: fullWidth, height: height)
    }
}
