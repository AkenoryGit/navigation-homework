//
//  ProfileViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let tableView = UITableView()
    private let profileHeaderView = ProfileHeaderView()
    private var avatarOriginalFrame: CGRect = .zero
    private var avatarSnapshotView: UIImageView?
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground
        setupTableView()
        
        view.addSubview(overlayView)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        profileHeaderView.onAvatarTap = { [weak self] in
            self?.animateAvatarExpansion()
        }
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        setupTableViewConstraints()
        configureTableView()
    }
    
    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: PhotosTableViewCell.identifier)
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func animateAvatarExpansion() {
        guard let avatarImage = profileHeaderView.avatarImage else { return }
        guard let window = view.window else { return }

        let avatarFrameInWindow = profileHeaderView.convert(profileHeaderView.avatarFrame, to: window)
        avatarOriginalFrame = avatarFrameInWindow

        let avatarView = UIImageView(image: avatarImage)
        avatarView.frame = avatarFrameInWindow
        avatarView.layer.cornerRadius = profileHeaderView.avatarCornerRadius
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.masksToBounds = true
        avatarSnapshotView = avatarView

        window.addSubview(avatarView)
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(closeButton)

        let targetWidth = window.bounds.width
        let targetHeight = avatarImage.size.height * (targetWidth / avatarImage.size.width)
        let targetY = (window.bounds.height - targetHeight) / 2

        UIView.animate(withDuration: 0.5, animations: {
            avatarView.frame = CGRect(x: 0, y: targetY, width: targetWidth, height: targetHeight)
            let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
            radiusAnimation.fromValue = avatarView.layer.cornerRadius
            radiusAnimation.toValue = 0
            radiusAnimation.duration = 0.5
            avatarView.layer.add(radiusAnimation, forKey: "cornerRadius")
            avatarView.layer.cornerRadius = 0
            self.overlayView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.closeButton.alpha = 1
            }
        })
    }
    
    @objc private func closeButtonTapped() {
        guard let avatarView = avatarSnapshotView else { return }

        UIView.animate(withDuration: 0.3, animations: {
            self.closeButton.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                avatarView.frame = self.avatarOriginalFrame
                let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
                radiusAnimation.fromValue = avatarView.layer.cornerRadius
                radiusAnimation.toValue = self.profileHeaderView.avatarCornerRadius
                radiusAnimation.duration = 0.5
                avatarView.layer.add(radiusAnimation, forKey: "cornerRadius")
                avatarView.layer.cornerRadius = self.profileHeaderView.avatarCornerRadius
                self.overlayView.alpha = 0
            }, completion: { _ in
                avatarView.removeFromSuperview()
                self.avatarSnapshotView = nil
            })
        })
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return profileHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        return profileHeaderView.systemLayoutSizeFitting(targetSize).height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PhotosTableViewCell.identifier, for: indexPath) as! PhotosTableViewCell
            cell.onArrowTapped = { [weak self] in
                let photosVC = PhotosViewController()
                self?.navigationController?.pushViewController(photosVC, animated: true)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
            cell.configure(with: posts[indexPath.row - 1])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

