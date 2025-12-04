//
//  PostTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 02.06.2025.
//

import UIKit

protocol PostTableViewCellDelegate: AnyObject {
    func didDoubleTap(postId: String)
}

final class PostTableViewCell: UITableViewCell {

    static let identifier = "PostCell"

    // MARK: - Public

    weak var delegate: PostTableViewCellDelegate?

    /// Колбэк на нажатие по треку в посте
    var onTrackTapped: (() -> Void)?

    /// Разрешать ли лайк/анимацию по двойному тапу (на стене — true, в избранном — false)
    var isLikeInteractionEnabled: Bool = true

    // MARK: - Private

    private var postId: String?
    /// Локальный счётчик лайков (для отображения в ячейке)
    private var likesCount: Int = 0

    private let authorLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 16)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .label
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let trackButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitleColor(.systemBlue, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.contentHorizontalAlignment = .left
        b.translatesAutoresizingMaskIntoConstraints = false
        b.isHidden = true
        return b
    }()

    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private var imageHeightConstraint: NSLayoutConstraint!

    private let likesLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let viewsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    /// Большое сердечко по центру ячейки
    private let likeHeartView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemRed
        iv.image = UIImage(systemName: "heart.fill")
        iv.alpha = 0              // изначально невидимо
        return iv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        contentView.addSubview(authorLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(trackButton)
        contentView.addSubview(postImageView)
        contentView.addSubview(likesLabel)
        contentView.addSubview(viewsLabel)
        contentView.addSubview(likeHeartView)   // сердечко поверх всего

        imageHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 0)
        imageHeightConstraint.isActive = true

        setupConstraints()
        setupGestures()

        trackButton.addTarget(self, action: #selector(trackButtonPressed), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postId = nil
        postImageView.image = nil
        trackButton.setTitle(nil, for: .normal)
        trackButton.isHidden = true
        likesCount = 0
        likeHeartView.alpha = 0
        likeHeartView.transform = .identity
        isLikeInteractionEnabled = true
    }

    // MARK: - Configure

    func configure(with post: ProfilePost) {
        postId = post.id

        authorLabel.text = post.author
        descriptionLabel.text = post.description

        likesCount = post.likes
        likesLabel.text = "Likes: \(likesCount)"
        viewsLabel.text = "Views: \(post.views)"

        // Картинка: сначала ассет, потом Documents
        if let image = loadImage(named: post.image) {
            postImageView.image = image
            imageHeightConstraint.constant = 200
        } else {
            postImageView.image = nil
            imageHeightConstraint.constant = 0
        }

        // Трек (если есть)
        if let trackId = post.trackId,
           let track = MusicStorage.shared.track(withId: trackId) {
            trackButton.setTitle("▶︎ \(track.title)", for: .normal)
            trackButton.isHidden = false
        } else {
            trackButton.isHidden = true
        }
    }

    /// Конфиг из SavedPost / FavoritePost
    func configure(with savedPost: SavedPost) {
        let profilePost = ProfilePost(
            id: savedPost.id ?? UUID().uuidString,
            author: savedPost.author ?? "",
            description: savedPost.text ?? "",
            image: savedPost.imageName ?? "",
            likes: Int(savedPost.likes),
            views: Int(savedPost.views),
            trackId: savedPost.trackId
        )
        configure(with: profilePost)
    }

    // MARK: - Private

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            authorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),

            trackButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            trackButton.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            trackButton.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),

            postImageView.topAnchor.constraint(equalTo: trackButton.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),

            likesLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 8),
            likesLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            likesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            viewsLabel.centerYAnchor.constraint(equalTo: likesLabel.centerYAnchor),
            viewsLabel.trailingAnchor.constraint(equalTo: authorLabel.trailingAnchor),

            // Сердечко по центру всей ячейки
            likeHeartView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            likeHeartView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            likeHeartView.widthAnchor.constraint(equalToConstant: 80),
            likeHeartView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func setupGestures() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTap)
    }

    private func loadImage(named name: String) -> UIImage? {
        guard !name.isEmpty else { return nil }

        // Пытаемся найти в ассетах
        if let image = UIImage(named: name) {
            return image
        }

        // Пытаемся загрузить из Documents
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = docs.appendingPathComponent(name)

        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            return image
        }

        return nil
    }

    private func animateLikeHeart() {
        // Гарантируем, что сердечко выше всего
        contentView.layoutIfNeeded()
        contentView.bringSubviewToFront(likeHeartView)

        likeHeartView.alpha = 0
        likeHeartView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)

        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
            self.likeHeartView.alpha = 1
            self.likeHeartView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25,
                           delay: 0.1,
                           options: [.curveEaseIn],
                           animations: {
                self.likeHeartView.alpha = 0
                self.likeHeartView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: { _ in
                self.likeHeartView.transform = .identity
            })
        })
    }

    // MARK: - Actions

    @objc private func handleDoubleTap() {
        // В избранном отключаем лайки и анимацию через флаг
        guard isLikeInteractionEnabled, let id = postId else { return }

        // Локально увеличиваем лайки
        likesCount += 1
        likesLabel.text = "Likes: \(likesCount)"

        // Анимация сердечка
        animateLikeHeart()

        // Уведомляем делегата (дальше — сохранение в избранное)
        delegate?.didDoubleTap(postId: id)
    }

    @objc private func trackButtonPressed() {
        onTrackTapped?()
    }
}
