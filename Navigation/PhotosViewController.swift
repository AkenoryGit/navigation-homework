//
//  PhotosViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 09.06.2025.
//

import UIKit
import iOSIntPackage

final class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private var receivedImages: [UIImage] = []
    
    private let imageNames = (1...18).map { "photo\($0)" }
    private let imageProcessor = ImageProcessor()

    override func viewDidLoad() {
        super.viewDidLoad()
        let sourceImages = imageNames.compactMap { UIImage(named: $0) }

        let start = Date()

        imageProcessor.processImagesOnThread(
            sourceImages: sourceImages,
            filter: .posterize,
            qos: .userInitiated
        ) { [weak self] processedImages in
            let end = Date()
            let duration = end.timeIntervalSince(start)
            print("Обработка изображений заняла: \(duration) секунд")

            DispatchQueue.main.async {
                self?.receivedImages = processedImages.compactMap { $0.map { UIImage(cgImage: $0) } }
                self?.collectionView.reloadData()
            }
        }

        view.backgroundColor = .systemBackground
        title = "Photo Gallery"
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receivedImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifier, for: indexPath) as! PhotosCollectionViewCell
        let image = receivedImages[indexPath.item]
        cell.configure(with: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let padding: CGFloat = 12
        let spacing: CGFloat = 8

        let totalSpacing = (itemsPerRow - 1) * spacing + padding * 2
        let itemWidth = (collectionView.bounds.width - totalSpacing) / itemsPerRow

        return CGSize(width: floor(itemWidth), height: floor(itemWidth))
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier)

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}
