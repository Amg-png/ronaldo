import SwiftUI
import AVFoundation

@main
struct RonaldoApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    let maxSize: CGFloat = 250   // max image width/height (like MAX_SIZE)
    let speed: CGFloat = 4       // points per frame (like SPEED)

    @State private var pos = CGPoint.zero
    @State private var vel = CGSize.zero
    @State private var started = false
    @State private var player: AVAudioPlayer?

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    // Load image.png once
    let uiImage: UIImage? = {
        guard let path = Bundle.main.path(forResource: "image", ofType: "png") else { return nil }
        return UIImage(contentsOfFile: path)
    }()

    // Final drawn size, keeps aspect ratio like thumbnail()
    var imgSize: CGSize {
        guard let img = uiImage else { return CGSize(width: 200, height: 120) }
        let scale = min(maxSize / img.size.width, maxSize / img.size.height)
        return CGSize(width: img.size.width * scale, height: img.size.height * scale)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                Group {
                    if let img = uiImage {
                        Image(uiImage: img).resizable()
                    } else {
                        Rectangle().fill(Color(red: 1, green: 0.31, blue: 0.31))
                    }
                }
                .frame(width: imgSize.width, height: imgSize.height)
                .position(pos)
            }
            .ignoresSafeArea()
            .onReceive(timer) { _ in step(in: geo.size) }
        }
        .ignoresSafeArea()
        .onAppear { startMusic() }
    }

    func step(in size: CGSize) {
        guard size.width > imgSize.width, size.height > imgSize.height else { return }
        let hw = imgSize.width / 2
        let hh = imgSize.height / 2

        // Random start position and direction on the first frame
        if !started {
            pos = CGPoint(x: CGFloat.random(in: hw...(size.width - hw)),
                          y: CGFloat.random(in: hh...(size.height - hh)))
            vel = CGSize(width: Bool.random() ? speed : -speed,
                         height: Bool.random() ? speed : -speed)
            started = true
            return
        }

        var p = pos
        p.x += vel.width
        p.y += vel.height

        if p.x <= hw { p.x = hw; vel.width = abs(vel.width) }
        if p.x >= size.width - hw { p.x = size.width - hw; vel.width = -abs(vel.width) }
        if p.y <= hh { p.y = hh; vel.height = abs(vel.height) }
        if p.y >= size.height - hh { p.y = size.height - hh; vel.height = -abs(vel.height) }

        pos = p
    }

    func startMusic() {
        guard let url = Bundle.main.url(forResource: "song", withExtension: "mp3") else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1
        player?.play()
    }
}