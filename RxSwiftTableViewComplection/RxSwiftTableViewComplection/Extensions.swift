//
//  Extensions.swift
//  RxSwiftTableViewComplection
//
//  Created by Anatoly Ryavkin on 11.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base == UILabel{
    var point: Binder<CGPoint?>{
        return Binder(self.base, binding: ( { (label, point) -> Void in
            print("lable.text = ", point!)
            self.base.text = "point = \(point!)"
        }))
    }
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

extension UIView {
    func findCell() -> Cell? {
        if let superView = self.superview as? Cell {
            return superView
        } else if let superView = self.superview {
            return superView.findCell()
        } else {
            return nil
        }
    }
}

extension Reactive where Base == UIImageView{
    static var ArrayImage = [UIImageView]()
    var point: Binder<CGPoint?>?{

        if Reactive.ArrayImage.contains(self.base){
            return nil
        }
        Reactive.ArrayImage.append(self.base)
        
        return Binder(self.base, binding: ( { (imageView, point) -> Void in
            guard let vc: UIViewController = self.base.findViewController() else{
                return
            }
            let frameImageInCoordinatesParentView = self.base.coordinateSpace.convert(self.base.bounds, to: vc.view.coordinateSpace)
            if (frameImageInCoordinatesParentView.contains(point!)){
                if let cell = imageView.findCell(){
                    if let tableView = cell.tableView{
                        if tableView.visibleCells.contains(cell){
                            let presentVC = UIViewController.init(nibName: nil, bundle: Bundle.main)
                            let presentImageView = UIImageView.init(frame: vc.view.bounds)
                            presentImageView.contentMode = .scaleAspectFill
                            presentImageView.image = self.base.image
                            presentVC.view.addSubview(presentImageView)
                            if let nc = vc.navigationController{
                                nc.pushViewController(presentVC, animated: true)
                            }
                            else{
                                vc.present(presentVC, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }))
    }
}

extension Reactive where Base == UILongPressGestureRecognizer{
    var state: Observable<UILongPressGestureRecognizer.State?>{
        let observable: Observable<UILongPressGestureRecognizer.State?> =
            self.observe(UILongPressGestureRecognizer.State.self, "state").share(replay: 1)
        return observable
    }
}


extension Reactive where Base == UILongPressGestureRecognizer{
    static var numSubscriber = 0
    var point: Observable<CGPoint>{
        let observableThePoint = Observable<CGPoint>.create { (observer) -> Disposable in
            let observable = self.base.rx.state
            return observable
                .filter({ (state) -> Bool in
                    state == UIGestureRecognizer.State.began
                })
                .share(replay: 1)
                .subscribe { (event) in
                    switch event{
                    case .next :
                        let view: UIView = self.base.view!
                        let point = self.base.location(in: view)
                        observer.onNext(point)
                    case .error(_):
                        print("ERROR")
                    case .completed:
                        print("completed")
                    }
            }
        }
        Reactive.numSubscriber += 1
        return observableThePoint //.debug("Subcriber - " + String(Reactive.numSubscriber), trimOutput: false)
    }
}




