//
//  MusicTrackPlayerViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit
import AVFoundation

final class MusicTrackPlayerViewController: UIViewController {

    // MARK: - Public

    /// Список треков для проигрывания (получаем из MusicLibraryViewController)
    var tracks: [MusicTrack] = []
    /// Индекс трека, с которого начинаем
    var startIndex: Int = 0

    // MARK: - Private

    private var currentIndex: Int = 0
    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private var isSeeking: Bool = false

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.title2()
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption()
        label.textColor = AppColors.textSecondary
        label.textAlignment = .left
        label.text = "0:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption()
        label.textColor = AppColors.textSecondary
        label.textAlignment = .right
        label.text = "-0:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Полоса прогресса трека
    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColors.accent
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        button.tintColor = AppColors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        button.tintColor = AppColors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "forward.fill"), for: .normal)
        button.tintColor = AppColors.textPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.background
        title = "Плеер"

        setupNavigation()
        setupLayout()
        setupActions()

        currentIndex = min(max(startIndex, 0), tracks.count - 1)
        playTrack(at: currentIndex)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.stop()
        invalidateProgressTimer()
    }

    // MARK: - Setup

    private func setupNavigation() {
        let backItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationItem.leftBarButtonItem = backItem
    }

    private func setupLayout() {
        let timeStack = UIStackView(arrangedSubviews: [currentTimeLabel, remainingTimeLabel])
        timeStack.axis = .horizontal
        timeStack.distribution = .fill
        timeStack.translatesAutoresizingMaskIntoConstraints = false

        let controlsStack = UIStackView(arrangedSubviews: [prevButton, playPauseButton, stopButton, nextButton])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 32
        controlsStack.alignment = .center
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(progressSlider)
        view.addSubview(timeStack)
        view.addSubview(controlsStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            progressSlider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            timeStack.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 4),
            timeStack.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),
            timeStack.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),

            controlsStack.topAnchor.constraint(equalTo: timeStack.bottomAnchor, constant: 32),
            controlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            playPauseButton.widthAnchor.constraint(equalToConstant: 64),
            playPauseButton.heightAnchor.constraint(equalToConstant: 64)
        ])
    }

    private func setupActions() {
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)

        progressSlider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        progressSlider.addTarget(self, action: #selector(sliderTouchUp),
                                 for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - Playback

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true, options: [])
            print("AudioSession настроен: category=\(session.category.rawValue)")
        } catch {
            print("Ошибка настройки AVAudioSession: \(error)")
        }
    }

    private func playTrack(at index: Int) {
        guard tracks.indices.contains(index) else {
            print("playTrack: index \(index) вне диапазона")
            return
        }

        let track = tracks[index]
        currentIndex = index
        titleLabel.text = track.title

        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: "mp3") else {
            print("Не найден файл \(track.fileName).mp3 в бандле")
            return
        }

        configureAudioSession()

        do {
            print("Пробуем проиграть файл: \(url.lastPathComponent)")
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 1.0

            if let duration = player?.duration {
                progressSlider.minimumValue = 0
                progressSlider.maximumValue = Float(duration)
                progressSlider.value = 0
                updateTimeLabels(current: 0, duration: duration)
            }

            let started = player?.play() ?? false
            print("AVAudioPlayer started: \(started), duration: \(player?.duration ?? 0), volume: \(player?.volume ?? -1)")
            updatePlayPauseButton(isPlaying: started)
            if started {
                startProgressTimer()
            } else {
                invalidateProgressTimer()
            }
        } catch {
            print("Ошибка создания AVAudioPlayer: \(error)")
        }
    }

    private func updatePlayPauseButton(isPlaying: Bool) {
        let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
        let image = UIImage(systemName: imageName)
        playPauseButton.setImage(image, for: .normal)
    }

    // MARK: - Progress timer

    private func startProgressTimer() {
        invalidateProgressTimer()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
        RunLoop.main.add(progressTimer!, forMode: .common)
    }

    private func invalidateProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func updateProgress() {
        guard let player = player else { return }

        let current = player.currentTime
        let duration = player.duration

        if !isSeeking {
            progressSlider.value = Float(current)
        }
        updateTimeLabels(current: current, duration: duration)
    }

    private func updateTimeLabels(current: TimeInterval, duration: TimeInterval) {
        currentTimeLabel.text = formatTime(current)

        let remaining = max(duration - current, 0)
        remainingTimeLabel.text = "-\(formatTime(remaining))"
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func playPauseTapped() {
        guard let player = player else { return }
        if player.isPlaying {
            player.pause()
            updatePlayPauseButton(isPlaying: false)
        } else {
            let started = player.play()
            print("playPauseTapped: started=\(started)")
            updatePlayPauseButton(isPlaying: started)
            if started {
                startProgressTimer()
            }
        }
    }

    @objc private func stopTapped() {
        guard let player = player else { return }
        player.stop()
        player.currentTime = 0
        updatePlayPauseButton(isPlaying: false)
        progressSlider.value = 0
        updateTimeLabels(current: 0, duration: player.duration)
        invalidateProgressTimer()
    }

    @objc private func prevTapped() {
        let newIndex = currentIndex - 1
        if newIndex >= 0 {
            playTrack(at: newIndex)
        }
    }

    @objc private func nextTapped() {
        let newIndex = currentIndex + 1
        if newIndex < tracks.count {
            playTrack(at: newIndex)
        }
    }

    // MARK: - Slider seeking

    @objc private func sliderTouchDown() {
        isSeeking = true
    }

    @objc private func sliderValueChanged() {
        guard let player = player else { return }
        let newTime = TimeInterval(progressSlider.value)
        updateTimeLabels(current: newTime, duration: player.duration)
    }

    @objc private func sliderTouchUp() {
        guard let player = player else { return }
        let newTime = TimeInterval(progressSlider.value)
        player.currentTime = newTime
        isSeeking = false
    }
}
