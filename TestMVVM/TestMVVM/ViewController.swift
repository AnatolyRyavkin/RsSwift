//
//  ViewController.swift
//  TestMVVM
//
//  Created by Anatoly Ryavkin on 21.02.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Darwin

public protocol ViewControllerIncreasing : UIViewController{
    var button: UIButton! { get }
    var label: UILabel! { get }
}

class ViewController: UIViewController, ViewControllerIncreasing {

    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var labelForSegment: UILabel!

    @IBOutlet var button: UIButton!
    @IBOutlet var label: UILabel!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var modelView1: ModelView!
    var modelView2: ModelView!



    override func viewDidLoad(){
        super.viewDidLoad()
        self.modelView1 = ModelView(controlInput: self.button, labelInput: self.label)
        self.modelView2 = ModelView(controlInput: self.segment, labelInput: self.labelForSegment)

        for i in 1...10
        {// begin
            print("result sqr i^2 = ", i*i)
            print("ekwfiuh = ", i/2)

        }//end

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        self.checkFrameGoesBeyondBordersForSize(size: size, viewChecking: self.button)
        self.checkFrameGoesBeyondBordersForSize(size: size, viewChecking: self.segment)
    }

    private func checkFrameGoesBeyondBordersForSize(size: CGSize, viewChecking: UIView){
        let boundsSize = CGRect.init(origin: CGPoint.zero, size: size)
        if !boundsSize.contains(viewChecking.frame){
            let deltaX = boundsSize.width - viewChecking.frame.maxX
            let deltaY = boundsSize.height - viewChecking.frame.maxY
            switch (deltaX,deltaY) {
            case _ where deltaX < 0:
                viewChecking.frame = viewChecking.frame.offsetBy(dx: deltaX, dy: 0)
            case _ where deltaY < 0:
                viewChecking.frame = viewChecking.frame.offsetBy(dx: 0, dy: deltaY)
            default:
                print("deltas = 0")
            }
        }
    }

}

