//
//  ViewController.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 05/07/2018.
//  Copyright © 2018 tucan9389. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

class JointViewController: UIViewController {
    public typealias DetectObjectsCompletion = ([BodyPoint?]?, Error?) -> Void
    
    var flag : Bool = false
    // MARK: - UI Properties
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var jointView: DrawingJointView!
    @IBOutlet weak var labelsTableView: UITableView!
    
    var chosenPose: Pose = Pose()
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    //swipe gestures
//    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
//    swipeRight.direction = UISwipeGestureRecognizerDirection.right
//    self.view.addGestureRecognizer(swipeRight)
//
//    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
//    swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//    self.view.addGestureRecognizer(swipeLeft)
    
    // MARK - Inference Result Data
    private var tableData: [BodyPoint?] = []
    
    // MARK - Performance Measurement Property
    private let 👨‍🔧 = 📏()
    
    // MARK - Core ML model
    typealias EstimationModel = model_cpm
    
    // MARK: - Vision Properties
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    // MARK: - AV Property
    var videoCapture: VideoCapture!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // setup the model
        setUpModel()
        
        // setup camera
        setUpCamera()
        
        // setup tableview datasource on bottom
        labelsTableView.dataSource = self
        
        // setup delegate for performance measurement
        👨‍🔧.delegate = self
        
        
        //swipe initialization
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoCapture.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoCapture.stop()
    }
    
    // MARK: - Setup Core ML
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: EstimationModel().model) {
            self.visionModel = visionModel
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            request?.imageCropAndScaleOption = .scaleFill
        } else {
            fatalError()
        }
    }
    
    // MARK: - SetUp Video
    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 30
        videoCapture.setUp(sessionPreset: .vga640x480) { success in
            
            if success {
                // add preview view on the layer
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // start video preview when setup is done
                self.videoCapture.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    
}

// MARK: - VideoCaptureDelegate
extension JointViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        // the captured image from camera is contained on pixelBuffer
        if let pixelBuffer = pixelBuffer {
            // start of measure
            self.👨‍🔧.🎬👏()
            
            // predict!
            self.predictUsingVision(pixelBuffer: pixelBuffer)
        }
    }
}

extension JointViewController {
    // MARK: - Inferencing
    func predictUsingVision(pixelBuffer: CVPixelBuffer) {
        guard let request = request else { fatalError() }
        // vision framework configures the input size of image following our model's input configuration automatically
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        try? handler.perform([request])
    }
    
    // MARK: - Poseprocessing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        self.👨‍🔧.🏷(with: "endInference")
        if let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let heatmap = observations.first?.featureValue.multiArrayValue {
            
            // convert heatmap to [keypoint]
            let n_kpoints = heatmap.convertHeatmapToBodyPoint()
            
            DispatchQueue.main.sync {
                // draw line
                self.jointView.bodyPoints = n_kpoints
//                let i = [BodyPoint?](n_kpoints)
//                if i != nil {
//                    if let temp : [BodyPoint?] = n_kpoints {
//                            self.chosenPose.bodyPoints = temp
//                            self.chosenPose.testValidity()
//                    }
//                }
                
                
//                if let temp : [BodyPoint?] = n_kpoints {
//                    if(temp != nil){
//                        //self.chosenPose.bodyPoints = temp
//                        //self.chosenPose.testValidity()
//                    }
//
//                }
                
                //self.chosenPose = Pose(input: temp)
                // show key points description
                self.showKeypointsDescription(with: n_kpoints)
                
                // end of measure
                self.👨‍🔧.🎬🤚()
            }
        }
    }
    
    func showKeypointsDescription(with n_kpoints: [BodyPoint?]) {
        self.tableData = n_kpoints
        self.labelsTableView.reloadData()
        
//        if n_kpoints.count != 0{
//            //self.chosenPose.bodyPoints = []
//            let array:[BodyPoint] = n_kpoints.map{ $0 ?? BodyPoint(maxPoint: CGPoint(), maxConfidence: 0) }
//            for n in array {
//                if n != nil && n.maxConfidence != 0 && self.chosenPose.bodyPoints != nil{
//                    self.chosenPose.bodyPoints = n_kpoints
//                }
//            }
//
//        }
        self.chosenPose.bodyPoints = n_kpoints
        self.chosenPose.testPose()
        
        self.jointView.outputPose = self.chosenPose
//        var popup = UIView(frame: CGRect(x: 100, y: 200, width: 200, height: 200))
//
//        let lb = UILabel(frame: CGRect(x: 100, y: 200, width: 200, height: 200))

//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
//        label.center = CGPoint(x: 160, y: 285)
//        label.textAlignment = .center
//        label.text = "I'm a test label"
//        self.view.addSubview(label)
        if !flag{
                if self.chosenPose.outputMsg != nil{
                    let txt = self.chosenPose.outputMsg
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 600, height: 225))
                    label.center = CGPoint(x: 70, y: 85)
                    label.textAlignment = .center
                    label.text = txt
                    label.tag = 69
                    label.textColor = UIColor.white
                    flag = true
                    self.view.addSubview(label)
                }
        }
        else{
            if self.view.viewWithTag(69) != nil {
                if self.chosenPose.outputMsg != nil{
                    let txt = self.chosenPose.outputMsg
                    if (txt?.count == 14) {
                        return;
                    }
                    
                    
                    let label = self.view.viewWithTag(69) as! UILabel
                    label.center = CGPoint(x: 250, y: 50)
                    label.textAlignment = .center
                    label.text = self.chosenPose.outputMsg
                    label.tag = 69
                    self.view.addSubview(label)
                }
            }

        }
        

        }
    
//    if var theLabel = self.view.viewWithTag(123) as? UILabel{
//        theLabel.text = "some text"
//    }
        //self.chosenPose.testValidity()
        
    
    
}

// MARK: - UITableView Data Source
extension JointViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count// > 0 ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        cell.textLabel?.text = Constant.pointLabels[indexPath.row]
        if let body_point = tableData[indexPath.row] {
            let pointText: String = "\(String(format: "%.3f", body_point.maxPoint.x)), \(String(format: "%.3f", body_point.maxPoint.y))"
            cell.detailTextLabel?.text = "(\(pointText)), [\(String(format: "%.3f", body_point.maxConfidence))]"
        } else {
            cell.detailTextLabel?.text = "N/A"
        }
        return cell
    }
}


// MARK: - 📏(Performance Measurement) Delegate
extension JointViewController: 📏Delegate {
    func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
        //print(executionTime, fps)
        self.inferenceLabel.text = "inference: \(Int(inferenceTime*1000.0)) mm"
        self.etimeLabel.text = "execution: \(Int(executionTime*1000.0)) mm"
        self.fpsLabel.text = "fps: \(fps)"
    }
}
