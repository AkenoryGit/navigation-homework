//
//  MusicPlayerTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 13.08.2025.
//

import UIKit
import AVFoundation

final class MusicPlayerTableViewCell: UITableViewCell {

    static let identifier = "MusicPlayerCell"

    private let trackNameLabel = UILabel()
    private let playButton = UIButton()
    private let stopButton = UIButton()
    private let nextButton = UIButton()
    private let prevButton = UIButton()

    private var player: AVAudioPlayer?
    private var tracks = ["Queen - The Show Must Go On", "Валентин Стрыкало", "Кровосток - Цветы в вазе", "Бабульки", "Качок"]
    private var currentTrackIndex = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        loadTrack(index: currentTrackIndex)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        trackNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        trackNameLabel.textAlignment = .center
        trackNameLabel.text = "No track playing"

        [prevButton, playButton, nextButton, stopButton].forEach {
            $0.tintColor = .systemBlue
        }

        prevButton.setImage(UIImage(systemName: "backward.end.fill"), for: .normal)
        nextButton.setImage(UIImage(systemName: "forward.end.fill"), for: .normal)
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        stopButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)

        prevButton.addTarget(self, action: #selector(prevTrack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTrack), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)

        let buttonStack = UIStackView(arrangedSubviews: [prevButton, playButton, nextButton, stopButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually

        let mainStack = UIStackView(arrangedSubviews: [trackNameLabel, buttonStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    private func loadTrack(index: Int) {
        let name = tracks[index]
        trackNameLabel.text = name
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("Нет файла: \(name)")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.prepareToPlay()
        } catch {
            print("Ошибка загрузки аудио: \(error)")
        }
    }

    @objc private func prevTrack() {
        currentTrackIndex = (currentTrackIndex - 1 + tracks.count) % tracks.count
        loadTrack(index: currentTrackIndex)
        player?.play()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }

    @objc private func nextTrack() {
        currentTrackIndex = (currentTrackIndex + 1) % tracks.count
        loadTrack(index: currentTrackIndex)
        player?.play()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }

    @objc private func playPause() {
        guard let player = player else { return }
        if player.isPlaying {
            player.pause()
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    @objc private func stop() {
        guard let player = player else { return }
        player.stop()
        player.currentTime = 0
        playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player.prepareToPlay()
    }
}
