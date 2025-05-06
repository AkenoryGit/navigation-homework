//
//  PostViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class PostViewController: UIViewController {
    private let post: Post
    
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = post.title
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
    }
    
    @objc func showInfo() {
            let infoVC = InfoViewController()
            let navVC = UINavigationController(rootViewController: infoVC)
            present(navVC, animated: true, completion: nil)
        
        
    }
    
}
