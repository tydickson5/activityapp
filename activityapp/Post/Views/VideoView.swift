//
//  VideoView.swift
//  activityapp
//
//  Created by Ty Dickson on 6/12/26.
//
import SwiftUI
import AVFoundation
import AVKit

struct VideoView: UIViewControllerRepresentable {
    
    @Binding var recordedVideoUrl: URL?
    
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> VideoViewController {
        let vc = VideoViewController()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, VideoViewControllerDelegate {
        
        let parent: VideoView
        init(_ parent: VideoView) {
            self.parent = parent
        }
        
        func didFinishRecording(url: URL) {
            parent.recordedVideoUrl = url
            parent.dismiss()
        }
        
        func didCancel(){
            parent.dismiss()
        }
    }
    
}

protocol VideoViewControllerDelegate: AnyObject {
    func didFinishRecording(url: URL)
    func didCancel()
}

class VideoViewController: UIViewController {

    
    
    weak var delegate: VideoViewControllerDelegate?
    
    private let session = AVCaptureSession()
    private var videoOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var recordButton: UIButton!
    private var progressBar: UIProgressView!
    private var timer: Timer?
    private var elapsedTime: Float = 0.0
    private let maxDuration: Float = 3.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
    }
    
    private func setupSession() {
        
        session.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(videoInput) else {return}
        session.addInput(videoInput)
        
        if let mic = AVCaptureDevice.default(for: .audio),
        let audioInput = try? AVCaptureDeviceInput(device: mic),
        session.canAddInput(audioInput)
        {
            session.addInput(audioInput)
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            
            videoOutput.maxRecordedDuration = CMTime(seconds: 3, preferredTimescale: 1)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
        
    }
    
    private func setupUI(){
        view.backgroundColor = .systemBackground
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.tintColor = .systemBlue
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        progressBar = UIProgressView(progressViewStyle: .default)
        progressBar.progressTintColor = .systemBlue
        progressBar.trackTintColor = .white.withAlphaComponent(0.4)
        progressBar.progress = 0
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        
        recordButton = UIButton(type: .custom)
        recordButton.backgroundColor = .systemBlue
        recordButton.layer.cornerRadius = 40
        recordButton.layer.borderWidth = 4
        recordButton.layer.borderColor = UIColor.white.cgColor
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            progressBar.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -24),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            recordButton.widthAnchor.constraint(equalToConstant: 80),
            recordButton.heightAnchor.constraint(equalToConstant: 80)
            
        ])
            
    }
    
    @objc private func recordTapped() {
        if videoOutput.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    @objc private func cancelTapped(){
        if videoOutput.isRecording {
            
            videoOutput.stopRecording()
        }
        delegate?.didCancel()
    }
    
    private func startRecording() {
        let tempUrl = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        videoOutput.startRecording(to: tempUrl, recordingDelegate: self)
        recordButton.backgroundColor = .gray
        
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true){ [weak self] _ in
                guard let self else { return }
            self.elapsedTime += 0.05
            self.progressBar.progress = self.elapsedTime / self.maxDuration
            if self.elapsedTime >= self.maxDuration {
                
                self.stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        timer?.invalidate()
        timer = nil
        videoOutput.stopRecording()
        recordButton.backgroundColor = .systemBlue
    }
}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error)
            return
        }
        delegate?.didFinishRecording(url: outputFileURL)
    }
}
