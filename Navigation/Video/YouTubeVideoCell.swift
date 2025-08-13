//
//  YouTubeVideoCell..swift
//  Navigation
//
//  Created by Дмитрий Дудник on 13.08.2025.
//

import UIKit
import WebKit

final class YouTubeVideoCell: UICollectionViewCell {
    
    static let identifier = "YouTubeVideoCell"
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let playIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(playIconView)

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 120),
            
            playIconView.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 40),
            playIconView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with videoID: String) {
        let urlString = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
        if let url = URL(string: urlString) {
            downloadImage(from: url)
        }
    }
    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.thumbnailImageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
