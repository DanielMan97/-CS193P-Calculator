//
//  GraphingView.swift
//  GraphingCalculator
//
//  Created by Daniel Man on 03/13/16
//  Copyright © 2016 DanielManApps All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphingViewDataSource, UIPopoverPresentationControllerDelegate {
    private struct Constants {
        static let ScaleAndOrigin = "scaleAndOrigin"
    }
    
    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            graphingView.dataSource = self
            if let scaleAndOrigin = userDefaults.objectForKey(Constants.ScaleAndOrigin) as? [String: String] {
                graphingView.scaleAndOrigin = scaleAndOrigin
            }
        }
    }
    
    var program: AnyObject?
    var graphLabel: String? {
        didSet {
            title = graphLabel
        }
    }
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func graphPlot(sender: GraphingView) -> [(x: Double, y: Double)]? {
        let minimumXDegree = Double(sender.minX) * (180 / M_PI)
        let maximumXDegree = Double(sender.maxX) * (180 / M_PI)
        
        var plots = [(x: Double, y: Double)]()
        let brain = CalculatorBrain()
        
        if let program = program {
            brain.program = program
            
            let loopSize = (maximumXDegree - minimumXDegree) / sender.availablePixelsInXAxis
            
            for (var i = minimumXDegree; i <= maximumXDegree; i = i + loopSize) {
                let radian = Double(i) * (M_PI / 180)
                brain.variableValues["M"] = radian
                let evaluationResult = brain.evaluateAndReportErrors()
                switch evaluationResult {
                case let .Success(y):
                    if y.isNormal || y.isZero {
                        plots.append((x: radian, y: y))
                    }
                default: break
                }
            }
        }
        
        return plots
    }
    
    @IBAction func zoomGraph(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            graphingView.scale *= gesture.scale
            
            // save the scale
            saveScaleAndOrigin()
            gesture.scale = 1
        }
    }
    
    @IBAction func moveGraph(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(graphingView)

            if graphingView.graphOrigin == nil {
                graphingView.graphOrigin = CGPoint(
                    x: graphingView.center.x + translation.x,
                    y: graphingView.center.y + translation.y)
            } else {
                graphingView.graphOrigin = CGPoint(
                    x: graphingView.graphOrigin!.x + translation.x,
                    y: graphingView.graphOrigin!.y + translation.y)
            }
            
            // save the graphOrigin
            saveScaleAndOrigin()
            
            // set back to zero, otherwise will be cumulative
            gesture.setTranslation(CGPointZero, inView: graphingView)
        default: break
        }
    }
    
    @IBAction func moveOrigin(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            graphingView.graphOrigin = gesture.locationInView(view)
           
            saveScaleAndOrigin()
        default: break
        }
    }
    
    private func saveScaleAndOrigin() {
        userDefaults.setObject(graphingView.scaleAndOrigin, forKey: Constants.ScaleAndOrigin)
        userDefaults.synchronize()
    }
        override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        var xDistanceFromCenter: CGFloat = 0
        var yDistanceFromCenter: CGFloat = 0
        if let graphOrigin = graphingView.graphOrigin {
            xDistanceFromCenter = graphingView.center.x - graphOrigin.x
            yDistanceFromCenter = graphingView.center.y - graphOrigin.y
        }
        
        let widthBefore = graphingView.bounds.width
        let heightBefore = graphingView.bounds.height
        
        coordinator.animateAlongsideTransition(nil) { context in
            
            let widthAfter = self.graphingView.bounds.width
            let heightAfter = self.graphingView.bounds.height
            
            let widthChangeRatio = widthAfter / widthBefore
            let heightRatioChange = heightAfter / heightBefore

            self.graphingView.graphOrigin = CGPoint(
                x: self.graphingView.center.x - (xDistanceFromCenter * widthChangeRatio),
                y: self.graphingView.center.y - (yDistanceFromCenter * heightRatioChange)
            )
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Stats":
                if let svc = segue.destinationViewController as? GraphicsStatisticsViewController {
                    if let ppc = svc.popoverPresentationController {
                        ppc.delegate = self
                    }
                    svc.stats  = "min-X: \(graphingView.minX)\n"
                    svc.stats += "max-X: \(graphingView.maxX)\n"
                    svc.stats += "min-Y: \(graphingView.minY)\n"
                    svc.stats += "max-Y: \(graphingView.maxY)"
                }
            default: break
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}
