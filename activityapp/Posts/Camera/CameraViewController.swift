//
//  CameraViewController.swift
//  caravyn
//
//  Created by Ty Dickson on 8/2/26.
//

import UIKit
import AVFoundation

final class CameraViewController: UIViewController {
    
    var onCapture: ((CameraResult) -> Void)?
    
    let session = AVCaptureSession()
    
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var cameraDevice: AVCaptureDevice?
    var currentPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Capture button UI state
    private var captureButton: UIButton!
    private let progressRing = CAShapeLayer()
    private let timerLabel = UILabel()
    private var recordingTimer: Timer?
    private var recordingStart: Date?
    private let maxRecordingDuration: TimeInterval = 4.0
    
    private var didSetupUI = false   // ADD THIS
    
    private var rawZoomFactorPerDisplayX: CGFloat = 1.0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupCamera()
        setupPreview()
        // REMOVE setupUI() from here
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global(qos: .userInitiated).async{
            self.session.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        
        // ADD THIS BLOCK
        if !didSetupUI {
            setupUI()
            didSetupUI = true
        }
    }
}

extension CameraViewController {
    
    func setupCamera() {
            
            let deviceTypesInPriorityOrder: [AVCaptureDevice.DeviceType] = [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ]
            
            var selectedDevice: AVCaptureDevice?
            
            for type in deviceTypesInPriorityOrder {
                if let device = AVCaptureDevice.default(type, for: .video, position: .back) {
                    selectedDevice = device
                    break
                }
            }
            
            guard let device = selectedDevice else {
                print("⚠️ No camera device found")
                return
            }
            
            cameraDevice = device
            
            // The first switch-over factor is where the wide lens (display "1x") kicks in.
            // If there's no switchover (single-lens device), 1x just is raw 1.0.
            if let firstSwitchOver = device.virtualDeviceSwitchOverVideoZoomFactors.first {
                rawZoomFactorPerDisplayX = CGFloat(truncating: firstSwitchOver)
            } else {
                rawZoomFactorPerDisplayX = 1.0
            }
            
            print("Using device: \(device.deviceType.rawValue)")
            print("Switch-over factors: \(device.virtualDeviceSwitchOverVideoZoomFactors)")
            print("Raw factor per display 1x: \(rawZoomFactorPerDisplayX)")
            
            do {
                
                let input = try AVCaptureDeviceInput(device: device)
                
                session.beginConfiguration()
                
                if(session.canAddInput(input)){
                    session.addInput(input)
                }
                
                if(session.canAddOutput(photoOutput)){
                    session.addOutput(photoOutput)
                }
                
                if(session.canAddOutput(movieOutput)){
                    session.addOutput(movieOutput)
                }
                
                if let mic = AVCaptureDevice.default(for: .audio),
                   let micInput = try? AVCaptureDeviceInput(device: mic),
                   session.canAddInput(micInput) {
                    session.addInput(micInput)
                }
                
                session.commitConfiguration()
            } catch {
                print(error)
            }
        }
    
    func setupPreview(){
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
    }
}

extension CameraViewController {

    func setupUI() {

        let buttonFrame = CGRect(
            x: (view.bounds.width - 80) / 2,
            y: view.bounds.height - 120,
            width: 80,
            height: 80
        )

        captureButton = UIButton(type: .custom)
        captureButton.frame = buttonFrame
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 40
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor

        view.addSubview(captureButton)

        // Progress ring, hidden until a long-press begins
        let ringPath = UIBezierPath(
            arcCenter: CGPoint(x: buttonFrame.width / 2, y: buttonFrame.height / 2),
            radius: buttonFrame.width / 2 + 6,
            startAngle: -.pi / 2,
            endAngle: -.pi / 2 + 2 * .pi,
            clockwise: true
        )

        progressRing.path = ringPath.cgPath
        progressRing.strokeColor = UIColor.systemRed.cgColor
        progressRing.fillColor = UIColor.clear.cgColor
        progressRing.lineWidth = 4
        progressRing.lineCap = .round
        progressRing.strokeEnd = 0
        progressRing.frame = captureButton.bounds
        captureButton.layer.addSublayer(progressRing)

        // Countdown label, positioned above the button
        timerLabel.frame = CGRect(
            x: 0,
            y: buttonFrame.minY - 36,
            width: view.bounds.width,
            height: 24
        )
        timerLabel.textAlignment = .center
        timerLabel.textColor = .white
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        timerLabel.alpha = 0
        view.addSubview(timerLabel)

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(takePhoto)
        )

        let hold = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        hold.minimumPressDuration = 0.2

        // Prevents the tap and long-press from firing on the same touch
        tap.require(toFail: hold)

        captureButton.addGestureRecognizer(tap)
        captureButton.addGestureRecognizer(hold)

        addZoomButton(title: "0.5x", x: 60, zoom: 0.5)
        addZoomButton(title: "1x", x: 120, zoom: 1)
        addZoomButton(title: "2x", x: 180, zoom: 2)
        addZoomButton(title: "3x", x: 240, zoom: 3)

        let flip = UIButton(type: .system)

        flip.setTitle("↺", for: .normal)
        flip.tintColor = .white

        flip.frame = CGRect(
            x: view.bounds.width - 70,
            y: 60,
            width: 50,
            height: 50
        )

        flip.addTarget(
            self,
            action: #selector(flipCamera),
            for: .touchUpInside
        )

        view.addSubview(flip)
        
        
        let recordHintLabel = UILabel()
        
        recordHintLabel.text = "Hold to record"
        recordHintLabel.textAlignment = .center
        recordHintLabel.textColor = .white
        recordHintLabel.font = .systemFont(ofSize: 14, weight: .medium)
        recordHintLabel.frame = CGRect(
            x: 0,
            y: buttonFrame.minY - 45,
            width: view.bounds.width,
            height: 20
        )
        view.addSubview(recordHintLabel)
    }

    func addZoomButton(
        title: String,
        x: CGFloat,
        zoom: CGFloat
    ) {

        let button = UIButton(type: .system)

        button.setTitle(title, for: .normal)
        button.tintColor = .white

        button.frame = CGRect(
            x: x,
            y: view.bounds.height - 200,
            width: 50,
            height: 40
        )

        button.tag = Int(zoom * 10)

        button.addTarget(
            self,
            action: #selector(zoomPressed(_:)),
            for: .touchUpInside
        )

        view.addSubview(button)
    }
}

extension CameraViewController {

    @objc func takePhoto() {

        let settings = AVCapturePhotoSettings()

        photoOutput.capturePhoto(
            with: settings,
            delegate: self
        )

        flashCaptureButton()
    }

    /// Quick white-flash + scale pulse to confirm a photo was taken
    private func flashCaptureButton() {

        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.captureButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                self.captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    self.captureButton.transform = .identity
                    self.captureButton.backgroundColor = .white
                }
            }
        )

        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0
        view.addSubview(flashView)

        UIView.animate(
            withDuration: 0.08,
            animations: { flashView.alpha = 0.4 },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.15,
                    animations: { flashView.alpha = 0 },
                    completion: { _ in flashView.removeFromSuperview() }
                )
            }
        )
    }
}

extension CameraViewController {

    @objc func handleLongPress(
        _ gesture: UILongPressGestureRecognizer
    ) {

        switch gesture.state {

        case .began:
            startRecording()

        case .ended,
             .cancelled,
             .failed:

            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }

        default:
            break
        }
    }

    func startRecording() {

        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")

        movieOutput.startRecording(
            to: url,
            recordingDelegate: self
        )

        beginRecordingUI()

        DispatchQueue.main.asyncAfter(
            deadline: .now() + maxRecordingDuration
        ) {

            if self.movieOutput.isRecording {
                self.movieOutput.stopRecording()
            }
        }
    }

    /// Switches the button to "recording" state and starts the countdown ring + label
    private func beginRecordingUI() {

        recordingStart = Date()

        UIView.animate(withDuration: 0.2) {
            self.captureButton.backgroundColor = .systemRed
            self.captureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.timerLabel.alpha = 1
        }

        progressRing.strokeEnd = 0
        timerLabel.text = String(format: "%.1fs", maxRecordingDuration)

        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0 / 30.0,
            repeats: true
        ) { [weak self] timer in

            guard let self = self, let start = self.recordingStart else {
                timer.invalidate()
                return
            }

            let elapsed = Date().timeIntervalSince(start)
            let remaining = max(0, self.maxRecordingDuration - elapsed)
            let progress = min(1, elapsed / self.maxRecordingDuration)

            self.progressRing.strokeEnd = CGFloat(progress)
            self.timerLabel.text = String(format: "%.1fs", remaining)

            if elapsed >= self.maxRecordingDuration {
                timer.invalidate()
            }
        }
    }

    /// Resets the button back to its default "photo" appearance
    private func endRecordingUI() {

        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingStart = nil

        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.captureButton.backgroundColor = .white
                self.captureButton.transform = .identity
                self.timerLabel.alpha = 0
            },
            completion: { _ in
                self.progressRing.strokeEnd = 0
            }
        )
    }
}

extension CameraViewController {

    @objc func zoomPressed(_ sender: UIButton) {

        // sender.tag stores display zoom * 10, e.g. 5 = 0.5x, 10 = 1x, 30 = 3x
        let displayZoom = CGFloat(sender.tag) / 10

        guard let device = cameraDevice else {
            return
        }

        // Convert the display zoom (what the button label shows) into
        // this device's actual raw videoZoomFactor scale.
        let requestedRawZoom = displayZoom * rawZoomFactorPerDisplayX

        do {
            try device.lockForConfiguration()

            let clamped = min(
                max(requestedRawZoom, device.minAvailableVideoZoomFactor),
                device.maxAvailableVideoZoomFactor
            )

            print("Display \(displayZoom)x -> raw \(requestedRawZoom), clamped: \(clamped)")

            device.videoZoomFactor = clamped

            device.unlockForConfiguration()

        } catch {
            print(error)
        }
    }
}

extension CameraViewController {

    @objc func flipCamera() {

        currentPosition =
            currentPosition == .back
            ? .front
            : .back

        session.beginConfiguration()

        session.inputs.forEach {
            session.removeInput($0)
        }

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: currentPosition
        ) else {
            session.commitConfiguration()
            return
        }

        guard let input =
            try? AVCaptureDeviceInput(device: device)
        else {
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        cameraDevice = device

        session.commitConfiguration()
    }
}

extension CameraViewController:
AVCapturePhotoCaptureDelegate {

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {

        guard
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else {
            return
        }

        onCapture?(.photo(image))
    }
}

extension CameraViewController:
AVCaptureFileOutputRecordingDelegate {

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {

        endRecordingUI()

        guard error == nil else {
            return
        }

        onCapture?(.video(outputFileURL))
    }
}
