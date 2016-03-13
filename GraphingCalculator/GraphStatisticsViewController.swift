//
//  GraphingView.swift
//  GraphingCalculator
//
//  Created by Daniel Man on 03/13/16
//  Copyright © 2016 DanielManApps All rights reserved.
//
import UIKit

class GraphicsStatisticsViewController: UIViewController {

    @IBOutlet weak var statsView: UITextView! {
        didSet {
            statsView.text = stats
        }
    }
    
    var stats: String = "" {
        didSet {
            statsView?.text = stats
        }
    }
    
    override var preferredContentSize: CGSize {
        get {
            if statsView != nil && presentingViewController != nil {
                return statsView.sizeThatFits(presentingViewController!.view.bounds.size)
            } else {
                return super.preferredContentSize
            }
        }
        set { super.preferredContentSize = newValue }
    }

}
