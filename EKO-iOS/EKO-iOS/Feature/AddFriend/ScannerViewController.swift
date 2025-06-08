//
//  ScannerViewController.swift
//  EKO-iOS
//
//  Created by 성현 on 6/7/25.
//

import UIKit
import AVFoundation

protocol QRCodeScannerDelegate: AnyObject {
    func didFind(code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRCodeScannerDelegate?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        if let input = try? AVCaptureDeviceInput(device: videoCaptureDevice) {
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            captureSession.stopRunning()
            delegate?.didFind(code: stringValue)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
extension ScannerViewController {
    func restartScanning() {
        print("🎬 [ScannerViewController] restartScanning() called")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.captureSession.isRunning {
                print("▶️ [ScannerViewController] captureSession.startRunning()")
                self.captureSession.startRunning()
            } else {
                print("⏸ [ScannerViewController] captureSession already running")
            }
        }
    }
}
