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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupCamera()
        setupPreview()
        setupUI()
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
    }
}

extension CameraViewController {
    func setupCamera() {
        
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInTripleCamera,
                .builtInDualWideCamera,
                .builtInDualCamera,
                .builtInWideAngleCamera
            ],
            mediaType: .video,
            position: .back
        )
        
        guard let device = discovery.devices.first else {
            return
        }
        
        cameraDevice = device
        
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

        let captureButton = UIButton(type: .custom)

        captureButton.frame = CGRect(
            x: (view.bounds.width - 80) / 2,
            y: view.bounds.height - 120,
            width: 80,
            height: 80
        )

        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 40

        view.addSubview(captureButton)

        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(takePhoto)
        )

        captureButton.addGestureRecognizer(tap)

        let hold = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )

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

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 4
        ) {

            if self.movieOutput.isRecording {
                self.movieOutput.stopRecording()
            }
        }
    }
}

extension CameraViewController {

    @objc func zoomPressed(
        _ sender: UIButton
    ) {

        let zoom = CGFloat(sender.tag) / 10

        guard let device = cameraDevice else {
            return
        }

        do {

            try device.lockForConfiguration()

            let clamped = min(
                max(
                    zoom,
                    device.minAvailableVideoZoomFactor
                ),
                device.maxAvailableVideoZoomFactor
            )

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

        guard error == nil else {
            return
        }

        onCapture?(.video(outputFileURL))
    }
}
