//
//  PostTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 02.06.2025.
//

import UIKit
import iOSIntPackage

protocol PostTableViewCellDelegate: AnyObject {
    func didDoubleTap(postId: String)
}

class PostTableViewCell: UITableViewCell {
    
    weak var delegate: PostTableViewCellDelegate?
    private var postId: String?
    
    private let postImageView = UIImageView()
    private let authorLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let likesLabel = UILabel()
    private let viewsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
        setupDoubleTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupDoubleTapGesture()
    }

    func configure(with post: ProfilePost) {
        self.postId = post.id
        
        authorLabel.text = post.author
        descriptionLabel.text = post.description
        likesLabel.text = "Likes: \(post.likes)"
        viewsLabel.text = "Views: \(post.views)"

        if let image = UIImage(named: post.image) {
            let processor = ImageProcessor()
            processor.processImageAsync(sourceImage: image, filter: .chrome) { [weak self] processedCGImage in
                DispatchQueue.main.async {
                    if let cgImage = processedCGImage {
                        self?.postImageView.image = UIImage(cgImage: cgImage)
                    }
                }
            }
        }
    }
    
    private func setupViews() {
        authorLabel.font = UIFont.boldSystemFont(ofSize: 16)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        postImageView.contentMode = .scaleAspectFit
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        
        likesLabel.font = UIFont.systemFont(ofSize: 12)
        likesLabel.textColor = .gray
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        viewsLabel.font = UIFont.systemFont(ofSize: 12)
        viewsLabel.textColor = .gray
        viewsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(authorLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(likesLabel)
        contentView.addSubview(viewsLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            postImageView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 12),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            likesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            likesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            likesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            viewsLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            viewsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            viewsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    private func setupDoubleTapGesture() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
    }

    @objc private func handleDoubleTap() {
        guard let id = postId else { return }
        delegate?.didDoubleTap(postId: id)
    }
}

