//
//  AudioRecorderTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 13.08.2025.
//

import UIKit
import AVFoundation

final class AudioRecorderTableViewCell: UITableViewCell {

    static let identifier = "AudioRecorderTableViewCell"

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingURL: URL?
    private var hasMicrophonePermission = false

    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Записать аудио", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        return button
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Воспроизвести", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.isEnabled = false
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        requestMicrophonePermission()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(recordButton)
        contentView.addSubview(playButton)

        recordButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            recordButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            playButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            playButton.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 16),
            playButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])

        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playRecording), for: .touchUpInside)
    }

    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasMicrophonePermission = granted
            }
        }
    }

    @objc private func startRecording() {
        guard hasMicrophonePermission else { return }

        if audioRecorder?.isRecording == true {
            finishRecording()
            return
        }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            let filename = UUID().uuidString + ".m4a"
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            recordingURL = url

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()

            recordButton.setTitle("Остановить", for: .normal)
            playButton.isEnabled = false
        } catch {
            print("Ошибка при записи: \(error)")
        }
    }

    private func finishRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        recordButton.setTitle("Записать аудио", for: .normal)
        playButton.isEnabled = true
    }

    @objc private func playRecording() {
        guard let url = recordingURL else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            audioPlayer?.play()
        } catch {
            print("Ошибка при воспроизведении: \(error)")
        }
    }
}
