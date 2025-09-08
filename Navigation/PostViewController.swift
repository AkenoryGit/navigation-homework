//
//  PostViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit
import CoreData

class PostViewController: UIViewController {

    private let post: Post
    private let tableView = UITableView()

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не был реализован")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = post.title

        setupTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        view.addSubview(tableView)
    }

    @objc func showInfo() {
        let infoVC = InfoViewController()
        let navVC = UINavigationController(rootViewController: infoVC)
        present(navVC, animated: true, completion: nil)
    }

    private func savePostToCoreData(_ post: ProfilePost) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let context = appDelegate.persistentContainer.viewContext
        let savedPost = SavedPost(context: context)

        savedPost.id = post.id
        savedPost.author = post.author
        savedPost.text = post.description
        savedPost.imageName = post.image
        savedPost.likes = Int64(post.likes)
        savedPost.views = Int64(post.views)

        do {
            try context.save()
            print("Пост сохранён: \(post.description)")
        } catch {
            print("Ошибка сохранения поста: \(error.localizedDescription)")
        }
    }
}

extension PostViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]
        cell.configure(with: post)
        cell.delegate = self
        return cell
    }
}

extension PostViewController: PostTableViewCellDelegate {
    func didDoubleTap(postId: String) {
        if let tappedPost = posts.first(where: { $0.id == postId }) {
            savePostToCoreData(tappedPost)
        }
    }
}
