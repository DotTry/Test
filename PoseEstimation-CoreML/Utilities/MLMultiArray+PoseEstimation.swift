//
//  MLMultiArray+Heatmap.swift
//  PoseEstimation-CoreML
//
//  Created by GwakDoyoung on 31/01/2019.
//  Copyright © 2019 tucan9389. All rights reserved.
//

import CoreML

struct BodyPoint {
    let maxPoint: CGPoint
    let maxConfidence: Double
    
//    init(){
//        self.maxPoint = CGPoint()
//        self.maxConfidence = 0
//    }
}

class Pose {
    public var isTrue : Bool?
    public var allPointsDefined : Bool?
    public var stance : String?
    public var outputMsg : String?
    public var bodyPoints: [BodyPoint?] = []
    
    init(){
        self.isTrue = false
        self.isTrue = false
        self.stance = "T-Pose"
        self.bodyPoints = []
        
        let test : BodyPoint? = BodyPoint(maxPoint: CGPoint(), maxConfidence: Double(0))
        self.bodyPoints.append(test)
    }
//    init(input: [BodyPoint]) {
//        self.bodyPoints = input
//        self.testValidity()
//    }
    
    func testValidity() -> Bool {
        self.isTrue = true
        for n in bodyPoints {
            if n == nil{
              self.isTrue = false
            }
            
        }
        
        return true
    }
    
    func testPose() -> Bool {
        var message = String("Current Pose: ")
        switch self.stance {
        case "T-Pose":
            if bodyPoints[0]?.maxConfidence != nil &&
               bodyPoints[1]?.maxConfidence != nil &&
               bodyPoints[2]?.maxConfidence != nil &&
               bodyPoints[3]?.maxConfidence != nil &&
               bodyPoints[5]?.maxConfidence != nil &&
               bodyPoints[6]?.maxConfidence != nil {
                let a = bodyPoints[0]?.maxConfidence ?? .nan
                let b = bodyPoints[1]?.maxConfidence ?? .nan
                let c = bodyPoints[2]?.maxConfidence ?? .nan
                let d = bodyPoints[3]?.maxConfidence ?? .nan
                let e = bodyPoints[5]?.maxConfidence ?? .nan
                let f = bodyPoints[6]?.maxConfidence ?? .nan
                if a > 0.4 && b > 0.4 && c > 0.4 && d > 0.4 && e > 0.4 && f > 0.4{
                    //message.append(String("Valid"))
                    //print("we got a match")
                    let head = (bodyPoints[0]?.maxPoint ?? CGPoint()) as CGPoint
                    let neck = (bodyPoints[1]?.maxPoint ?? CGPoint()) as CGPoint
                    let R_shoulder = (bodyPoints[2]?.maxPoint ?? CGPoint()) as CGPoint
                    let R_elbow = (bodyPoints[3]?.maxPoint ?? CGPoint()) as CGPoint
                    let L_Shoulder = (bodyPoints[5]?.maxPoint ?? CGPoint()) as CGPoint
                    let L_elbow = (bodyPoints[6]?.maxPoint ?? CGPoint()) as CGPoint
                    
                    let R_wrist = (bodyPoints[4]?.maxPoint ?? CGPoint()) as CGPoint
                    let L_wrist = (bodyPoints[7]?.maxPoint ?? CGPoint()) as CGPoint
                    if head.y < neck.y{
                        //message.append(String("Upright! "))
                    }
                    
//                    if (abs(neck.y - R_shoulder.y) < 0.06) && (abs(R_shoulder.y - R_elbow.y) < 0.04) && (abs(neck.y - L_Shoulder.y) < 0.06) && (abs(L_Shoulder.y - L_elbow.y) < 0.04){
//                        message.append(String("T Pose! "))
//                    }
                    
                    if (R_wrist.y < R_elbow.y) && (L_wrist.y < L_elbow.y){
                        //message.append(String("Hands Up! "))
                    }
                    
                    if (R_elbow.y < R_shoulder.y) && (L_elbow.y < L_Shoulder.y){
                        //message.append(String("Arms Up! "))
                    }
                    
                    if (R_wrist.y < R_elbow.y) && (R_wrist.x <= R_elbow.x || (R_wrist.x <= R_shoulder.x)){
                        message.append(String("Dab Right! "))
                    }
                    
                    //if (R_wrist.y < R_elbow.y) && (L_wrist.y < L_elbow.y) && (L_wrist.x <= L_elbow.x) && (R_wrist.x <= L_elbow.x){
                    if (L_wrist.y < L_elbow.y) && ((L_wrist.x >= L_elbow.x) || (L_wrist.x >= L_Shoulder.x)){
                        message.append(String("Dab Left! "))
                    }
                    outputMsg = message
                }
            }
            
            print(message)
            
            break
        case "z":
            //print("The last letter of the alphabet")
            break
        default:
            //print("Some other character")
            break
        }
        
        return true
    }
    
}

extension MLMultiArray {
    func convertHeatmapToBodyPoint() -> [BodyPoint?] {
        guard self.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(self.shape)")
            return []
        }
        let keypoint_number = self.shape[0].intValue
        let heatmap_w = self.shape[1].intValue
        let heatmap_h = self.shape[2].intValue
        
        var n_kpoints = (0..<keypoint_number).map { _ -> BodyPoint? in
            return nil
        }
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = self[index].doubleValue
                    guard confidence > 0 else { continue }
                    if n_kpoints[k] == nil ||
                        (n_kpoints[k] != nil && n_kpoints[k]!.maxConfidence < confidence) {
                        n_kpoints[k] = BodyPoint(maxPoint: CGPoint(x: CGFloat(j), y: CGFloat(i)), maxConfidence: confidence)
                    }
                }
            }
        }
        
        
        // transpose to (1.0, 1.0)
        n_kpoints = n_kpoints.map { kpoint -> BodyPoint? in
            if let kp = kpoint {
                return BodyPoint(maxPoint: CGPoint(x: (kp.maxPoint.x+0.5)/CGFloat(heatmap_w),
                                                   y: (kp.maxPoint.y+0.5)/CGFloat(heatmap_h)),
                                 maxConfidence: kp.maxConfidence)
            } else {
                return nil
            }
        }
        
        return n_kpoints
    }
    
    func convertHeatmapTo3DArray() -> Array<Array<Double>> {
        guard self.shape.count >= 3 else {
            print("heatmap's shape is invalid. \(self.shape)")
            return []
        }
        let keypoint_number = self.shape[0].intValue
        let heatmap_w = self.shape[1].intValue
        let heatmap_h = self.shape[2].intValue
        
        var convertedHeatmap: Array<Array<Double>> = Array(repeating: Array(repeating: 0.0, count: heatmap_h), count: heatmap_w)
        
        for k in 0..<keypoint_number {
            for i in 0..<heatmap_w {
                for j in 0..<heatmap_h {
                    let index = k*(heatmap_w*heatmap_h) + i*(heatmap_h) + j
                    let confidence = self[index].doubleValue
                    guard confidence > 0 else { continue }
                    convertedHeatmap[j][i] += confidence
                }
            }
        }
        
        convertedHeatmap = convertedHeatmap.map { row in
            return row.map { element in
                if element > 1.0 {
                    return 1.0
                } else if element < 0 {
                    return 0.0
                } else {
                    return element
                }
            }
        }
        
//        if let max = (convertedHeatmap.map({ $0.max() }).compactMap({ $0 })).max(), max < 1.0 {
//            convertedHeatmap = convertedHeatmap.map { row in
//                return row.map { element in
//                    return element/max
//                }
//            }
//        }
        
        return convertedHeatmap
    }
}
