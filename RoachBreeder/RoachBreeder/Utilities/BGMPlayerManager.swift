//
//  BGMPlayerManager.swift
//  RoachBreeder
//

import AVFoundation
import Combine
import Foundation

enum BGMTrack: String, CaseIterable, Identifiable {
    case basementGuide = "BasementGuide"
    case streetlights = "BetweenStreetlights"
    case poltergeist = "Poltergeist"
    case transparentTragedy = "TransparentTragedy"

    var id: String { rawValue }
    var fileName: String { rawValue }
    var fileExtension: String { "mp3" }

    var title: String {
        switch self {
        case .basementGuide: return "地下室の案内人"
        case .streetlights: return "Between Streetlights"
        case .poltergeist: return "Poltergeist"
        case .transparentTragedy: return "透明な悲劇"
        }
    }

    var sequenceLabel: String {
        let index = Self.allCases.firstIndex(of: self) ?? 0
        return String(format: "TRACK %02d", index + 1)
    }
}

@MainActor
final class BGMPlayerManager: NSObject, ObservableObject {
    @Published private(set) var selectedTrack: BGMTrack
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    @Published var volume: Float {
        didSet {
            let clamped = min(max(volume, 0), 1)
            if clamped != volume {
                volume = clamped
                return
            }
            player?.volume = clamped
            UserDefaults.standard.set(clamped, forKey: Self.volumeKey)
        }
    }

    private static let selectedTrackKey = "RoachBreeder.BGM.SelectedTrack.v1"
    private static let volumeKey = "RoachBreeder.BGM.Volume.v1"

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?

    override init() {
        let savedTrack = UserDefaults.standard.string(forKey: Self.selectedTrackKey)
            .flatMap(BGMTrack.init(rawValue:))
        selectedTrack = savedTrack ?? .basementGuide
        volume = UserDefaults.standard.object(forKey: Self.volumeKey) == nil
            ? 0.42
            : UserDefaults.standard.float(forKey: Self.volumeKey)
        super.init()
        loadSelectedTrack()
    }

    deinit {
        progressTimer?.invalidate()
    }

    func togglePlayback() {
        isPlaying ? pause() : play()
    }

    func play() {
        if player == nil {
            loadSelectedTrack()
        }
        guard let player else { return }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            player.volume = volume
            player.play()
            isPlaying = true
            startProgressUpdates()
        } catch {
            isPlaying = false
            print("BGM playback failed: \(error.localizedDescription)")
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopProgressUpdates()
        updateProgress()
    }

    func select(_ track: BGMTrack) {
        guard track != selectedTrack else {
            if !isPlaying { play() }
            return
        }

        let shouldResume = isPlaying
        selectedTrack = track
        UserDefaults.standard.set(track.rawValue, forKey: Self.selectedTrackKey)
        loadSelectedTrack()
        if shouldResume { play() }
    }

    func playNext() {
        moveSelection(by: 1)
    }

    func playPrevious() {
        moveSelection(by: -1)
    }

    func seek(to time: TimeInterval) {
        guard let player else { return }
        player.currentTime = min(max(time, 0), player.duration)
        updateProgress()
    }

    func formattedTime(_ time: TimeInterval) -> String {
        guard time.isFinite else { return "0:00" }
        let seconds = max(0, Int(time.rounded(.down)))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func moveSelection(by offset: Int) {
        let tracks = BGMTrack.allCases
        guard let currentIndex = tracks.firstIndex(of: selectedTrack) else { return }
        let nextIndex = (currentIndex + offset + tracks.count) % tracks.count
        select(tracks[nextIndex])
    }

    private func loadSelectedTrack() {
        stopProgressUpdates()
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0

        guard let url = Bundle.main.url(
            forResource: selectedTrack.fileName,
            withExtension: selectedTrack.fileExtension
        ) else {
            print("BGM file not found: \(selectedTrack.fileName).\(selectedTrack.fileExtension)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = volume
            player.prepareToPlay()
            self.player = player
            duration = player.duration
        } catch {
            print("BGM load failed: \(error.localizedDescription)")
        }
    }

    private func startProgressUpdates() {
        stopProgressUpdates()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateProgress()
            }
        }
    }

    private func stopProgressUpdates() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func updateProgress() {
        guard let player else { return }
        currentTime = player.currentTime
        duration = player.duration
        if isPlaying, !player.isPlaying {
            isPlaying = false
            stopProgressUpdates()
        }
    }
}
