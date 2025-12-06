//
//  NewPostViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit

final class NewPostViewController: UIViewController {

    // MARK: - External
    var userLogin: String!
    var authorName: String!
    var onPostCreated: (() -> Void)?

    // MARK: - Data
    private var selectedImage: UIImage?
    private var selectedTrack: MusicTrack?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .secondarySystemBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let chooseImageButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Выбрать фото", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let trackLabel: UILabel = {
        let l = UILabel()
        l.text = "Трек не выбран"
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chooseTrackButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Выбрать трек", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.clipsToBounds = true
        tv.layer.cornerRadius = 10
        tv.backgroundColor = .secondarySystemBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Опубликовать", for: .normal)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Новый пост"

        // тап по фону – скрыть клавиатуру
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        setupLayout()
        setupActions()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        contentView.addSubview(imageView)
        contentView.addSubview(chooseImageButton)
        contentView.addSubview(trackLabel)
        contentView.addSubview(chooseTrackButton)
        contentView.addSubview(textView)
        contentView.addSubview(saveButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 200),

            chooseImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            chooseImageButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),

            trackLabel.topAnchor.constraint(equalTo: chooseImageButton.bottomAnchor, constant: 16),
            trackLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            trackLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            chooseTrackButton.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: 8),
            chooseTrackButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),

            textView.topAnchor.constraint(equalTo: chooseTrackButton.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 200),

            saveButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 52),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupActions() {
        chooseImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        chooseTrackButton.addTarget(self, action: #selector(selectTrack), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(savePost), for: .touchUpInside)
    }

    // MARK: - Keyboard

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let kbHeight = frame.height - view.safeAreaInsets.bottom
        let inset = max(kbHeight, 0)

        UIView.animate(withDuration: 0.25) {
            self.scrollView.contentInset.bottom = inset + 16
            self.scrollView.verticalScrollIndicatorInsets.bottom = inset + 16
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }

    // MARK: - Actions

    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func selectTrack() {
        let vc = MusicLibraryViewController()
        vc.userLogin = userLogin
        vc.onTrackSelected = { [weak self] track in
            self?.selectedTrack = track
            self?.trackLabel.text = "Трек: \(track.title)"
            self?.trackLabel.textColor = .label
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func savePost() {
        guard let login = userLogin,
              let author = authorName else { return }

        let text = textView.text ?? ""

        if text.isEmpty && selectedImage == nil && selectedTrack == nil {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Нельзя создать пустой пост",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Сохраняем изображение (если есть)
        var imageName = ""
        if let img = selectedImage,
           let data = img.jpegData(compressionQuality: 0.9) {

            let id = UUID().uuidString
            imageName = "post_img_\(id).jpg"

            let docs = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!
            let url = docs.appendingPathComponent(imageName)
            try? data.write(to: url)
        }

        let trackId = selectedTrack?.id

        let newPost = ProfilePost(
            author: author,
            description: text,
            image: imageName,
            likes: 0,
            views: 0,
            trackId: trackId
        )

        PostStorage.shared.addPost(newPost, for: login)

        onPostCreated?()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        if let img = info[.originalImage] as? UIImage {
            selectedImage = img
            imageView.image = img
        }
    }
}
