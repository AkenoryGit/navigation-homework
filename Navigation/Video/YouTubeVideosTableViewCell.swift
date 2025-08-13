//
//  YouTubeVideosTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 13.08.2025.
//

import UIKit
import WebKit

final class YouTubeVideosTableViewCell: UITableViewCell {
    
    weak var parentViewController: UIViewController?
    
    static let identifier = "YouTubeVideosTableViewCell"
    
    private let videoIDs = [
        "TNvFAfoM95Y",
        "duvlWEJJmU0",
        "Yf1wpCeOms0"
    ]
    
    private var collectionView: UICollectionView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(YouTubeVideoCell.self, forCellWithReuseIdentifier: YouTubeVideoCell.identifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            collectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}

extension YouTubeVideosTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoIDs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let videoID = videoIDs[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YouTubeVideoCell.identifier, for: indexPath) as! YouTubeVideoCell
        cell.configure(with: videoID)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoID = videoIDs[indexPath.item]
        let vc = YouTubeWebViewController()
        vc.videoID = videoID
        vc.modalPresentationStyle = .automatic
        parentViewController?.present(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: 120)
    }
}
