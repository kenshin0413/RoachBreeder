//
//  BGMPlayerSheet.swift
//  RoachBreeder
//

import SwiftUI

struct BGMPlayerSheet: View {
    @ObservedObject var player: BGMPlayerManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.16, green: 0.14, blue: 0.10),
                    Color(red: 0.055, green: 0.05, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.72, green: 0.92, blue: 0.36).opacity(0.13))
                .frame(width: 310, height: 310)
                .blur(radius: 54)
                .offset(x: 160, y: -250)

            ScrollView {
                VStack(spacing: 18) {
                    header
                    nowPlayingCard
                    transportControls
                    volumeControl
                    trackList
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 28)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("COLONY AUDIO")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(2.8)
                    .foregroundStyle(Color(red: 0.75, green: 0.93, blue: 0.40))
                Text("BGM MIXER")
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(.white.opacity(0.82))
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.10), in: Circle())
                    .overlay { Circle().stroke(.white.opacity(0.14), lineWidth: 1) }
            }
            .buttonStyle(BGMPressStyle())
        }
    }

    private var nowPlayingCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [
                                    Color(red: 0.84, green: 0.96, blue: 0.48),
                                    Color(red: 0.32, green: 0.46, blue: 0.17),
                                    Color(red: 0.94, green: 0.70, blue: 0.22),
                                    Color(red: 0.84, green: 0.96, blue: 0.48)
                                ],
                                center: .center
                            )
                        )
                        .frame(width: 92, height: 92)
                        .rotationEffect(.degrees(player.isPlaying ? 12 : 0))
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: player.isPlaying)

                    Circle()
                        .fill(Color(red: 0.10, green: 0.09, blue: 0.07))
                        .frame(width: 52, height: 52)

                    Image(systemName: player.isPlaying ? "waveform" : "music.note")
                        .font(.system(size: 23, weight: .black))
                        .foregroundStyle(Color(red: 0.82, green: 0.95, blue: 0.46))
                }
                .shadow(color: Color(red: 0.64, green: 0.86, blue: 0.32).opacity(0.32), radius: 18)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(player.isPlaying ? Color(red: 0.66, green: 0.95, blue: 0.35) : .white.opacity(0.36))
                            .frame(width: 7, height: 7)
                        Text(player.isPlaying ? "NOW PLAYING" : "PAUSED")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .tracking(1.7)
                            .foregroundStyle(.white.opacity(0.58))
                    }
                    Text(player.selectedTrack.title)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text(player.selectedTrack.sequenceLabel)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.76, green: 0.92, blue: 0.44))
                }
                Spacer(minLength: 0)
            }

            VStack(spacing: 6) {
                Slider(
                    value: Binding(
                        get: { player.currentTime },
                        set: { player.seek(to: $0) }
                    ),
                    in: 0...max(player.duration, 1)
                )
                .tint(Color(red: 0.72, green: 0.92, blue: 0.38))

                HStack {
                    Text(player.formattedTime(player.currentTime))
                    Spacer()
                    Text(player.formattedTime(player.duration))
                }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.48))
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.13), Color(red: 0.45, green: 0.58, blue: 0.23).opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color(red: 0.76, green: 0.93, blue: 0.40).opacity(0.24), lineWidth: 1)
        }
    }

    private var transportControls: some View {
        HStack(spacing: 24) {
            transportButton(systemImage: "backward.fill", size: 48, action: player.playPrevious)

            Button(action: player.togglePlayback) {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color(red: 0.11, green: 0.10, blue: 0.07))
                    .frame(width: 66, height: 66)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.90, green: 0.96, blue: 0.52), Color(red: 0.58, green: 0.82, blue: 0.30)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )
                    .shadow(color: Color(red: 0.65, green: 0.90, blue: 0.32).opacity(0.34), radius: 16, y: 7)
            }
            .buttonStyle(BGMPressStyle())
            .accessibilityLabel(player.isPlaying ? "Pause BGM" : "Play BGM")

            transportButton(systemImage: "forward.fill", size: 48, action: player.playNext)
        }
    }

    private var volumeControl: some View {
        HStack(spacing: 12) {
            Image(systemName: player.volume == 0 ? "speaker.slash.fill" : "speaker.wave.1.fill")
                .frame(width: 20)
            Slider(
                value: Binding(
                    get: { Double(player.volume) },
                    set: { player.volume = Float($0) }
                ),
                in: 0...1
            )
            .tint(Color(red: 0.90, green: 0.72, blue: 0.28))
            Image(systemName: "speaker.wave.3.fill")
                .frame(width: 22)
        }
        .font(.system(size: 13, weight: .black))
        .foregroundStyle(.white.opacity(0.66))
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 17))
    }

    private var trackList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SELECT TRACK")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(2.2)
                .foregroundStyle(.white.opacity(0.52))
                .padding(.leading, 4)

            ForEach(BGMTrack.allCases) { track in
                trackRow(track)
            }
        }
    }

    private func trackRow(_ track: BGMTrack) -> some View {
        let isSelected = player.selectedTrack == track
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                player.select(track)
            }
        } label: {
            HStack(spacing: 13) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(isSelected ? Color(red: 0.73, green: 0.91, blue: 0.39) : .white.opacity(0.09))
                        .frame(width: 44, height: 44)
                    Image(systemName: isSelected && player.isPlaying ? "waveform" : "music.note")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(isSelected ? Color(red: 0.12, green: 0.11, blue: 0.08) : .white.opacity(0.66))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(track.sequenceLabel)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(isSelected ? Color(red: 0.76, green: 0.93, blue: 0.42) : .white.opacity(0.38))
                }

                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 19, weight: .black))
                        .foregroundStyle(Color(red: 0.74, green: 0.92, blue: 0.40))
                } else {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(.white.opacity(0.32))
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 62)
            .background(
                isSelected ? Color(red: 0.30, green: 0.38, blue: 0.16).opacity(0.34) : .white.opacity(0.055),
                in: RoundedRectangle(cornerRadius: 19)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 19)
                    .stroke(isSelected ? Color(red: 0.74, green: 0.92, blue: 0.40).opacity(0.38) : .white.opacity(0.08), lineWidth: 1)
            }
        }
        .buttonStyle(BGMPressStyle())
    }

    private func transportButton(systemImage: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(.white.opacity(0.82))
                .frame(width: size, height: size)
                .background(.white.opacity(0.09), in: Circle())
                .overlay { Circle().stroke(.white.opacity(0.12), lineWidth: 1) }
        }
        .buttonStyle(BGMPressStyle())
    }
}

private struct BGMPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.18, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
