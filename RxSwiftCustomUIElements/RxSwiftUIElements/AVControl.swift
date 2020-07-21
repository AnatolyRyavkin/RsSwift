//
//  AVControl.swift
//  TestMVVM
//
//  Created by Anatoly Ryavkin on 26.02.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

typealias ClouserRun = (UIControl) -> ()

extension UIControl{
    var avControl: AVControl{
        let avControlInit: AVControl = AVControl.init()
        avControlInit.controlSelf = self
        return avControlInit
    }
}

class AVControl: UIControl{

    typealias Observer = AnyObserver<UIControl>

    var controlSelf: UIControl!
    var observable: Observable<UIControl>!
    var arraySubscribers: [Observer] = []
    let disposeBag = DisposeBag()
    var tap:Observable<UIControl>{
        return self.tapp()
    }

//MARK: Fixed

    @objc func eventHandler(sender: UIControl){
        for observer in self.arraySubscribers{
            observer.onNext(sender)
        }
    }

    func tapp() -> Observable<UIControl>{

        let controlType = (self.controlSelf.isMember(of: UIButton.self)) ? UIControl.Event.touchUpInside : UIControl.Event.allEvents

        self.controlSelf.addTarget(self, action: #selector(eventHandler(sender:)), for: controlType)

        self.observable = Observable<UIControl>.create {observer in
            self.arraySubscribers.append(observer)
            return Disposables.create()
        }
        return self.observable
    }

}














//import Foundation
//import UIKit
//import RxSwift
//import RxCocoa
//
//typealias ClouserRun = (UIControl) -> ()
//
//extension UIControl{
//    var avControl: AVControl{
//        let avControlInit: AVControl = AVControl.init()
//        avControlInit.controlSelf = self
//        return avControlInit
//    }
//}
//
//class AVControl: UIControl{
//
//    var i = 0
//    var controlSelf: UIControl!
//    var observable: Observable<UIControl>!
//    var observer: AnyObserver<UIControl>!
//    let disposeBag = DisposeBag()
//    var tap:Observable<UIControl>{
//        return self.tapp()
//    }
//
////MARK: Fixed
//
//    @objc func eventHandler(sender: UIControl){
//        self.observer.onNext(self.controlSelf!)
//    }
//
//    func tapp() -> Observable<UIControl>{
//
//        let controlType = (self.controlSelf .isMember(of: UIButton.self)) ? UIControl.Event.touchUpInside : UIControl.Event.allEvents
//
//        self.controlSelf.addTarget(self, action: #selector(eventHandler(sender:)), for: controlType)
//
//        self.observable = Observable<UIControl>.create {observer in
//            self.observer = observer
//            observer.onNext(self.controlSelf)
//            return Disposables.create()
//        }
//        return self.observable
//    }
//
//}




//    public func tapp() -> AVObservableSelf<UIControl> {
//
//        let controlType = (self.controlSelf .isMember(of: UIButton.self)) ? UIControl.Event.touchUpInside : UIControl.Event.allEvents
//
//        self.controlSelf.addTarget(self, action: #selector(eventHandler(sender:)), for: controlType)
//
//        self.observable = Observable<UIControl>.create { subscriber in
//            self.arraySubscribing.append(subscriber)
//            return Disposables.create {
//                self.arraySubscribing.removeAll()
//                print("Disposeables and remove all elements from arraySubscribing ",subscriber.asObserver())
//            }
//        }
//
//
//        let clouserWithObserver: ((RxSwift.AnyObserver<AVReplaySubject.Element>) -> Disposable) = { subscriber in
//            self.arraySubscribing.append(subscriber)
//            return Disposables.create {
//                self.arraySubscribing.removeAll()
//                print("Disposeables and remove all elements from arraySubscribing ",subscriber.asObserver())
//            }
//        }
//
//        if (self.observableSelf == nil){
//
//            let replaySubjectObservable: Observable<Element> = Observable<Element>.create(clouserWithObserver)
//
//            self.observableSelf = AVObservableSelf<Element>() //or TypeObserving
//            self.observableSelf.observable = replaySubjectObservable
//            self.observableSelf.replaySubject = self
//        }
//        return self.observableSelf
//    }
