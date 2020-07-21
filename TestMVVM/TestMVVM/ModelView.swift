//
//  ModelView.swift
//  TestMVVM
//
//  Created by Anatoly Ryavkin on 21.02.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ModelView: NSObject{

    let control: UIControl

    let label: UILabel

    let disposableBag = DisposeBag()

    var observableFromButton: Observable<UIControl>!

    private init(cont: UIControl, lab: UILabel){
        self.control = cont
        self.label = lab
    }

    convenience init(controlInput: UIControl, labelInput: UILabel) {
        self.init(cont: controlInput, lab: labelInput)

        let observableFromButton: Observable<UIControl> = self.control.avControl.tap.asObservable()

        let publishSubject: AVPublishSubject<UIControl> = AVPublishSubject<UIControl>()

        publishSubject
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance)
            .subscribe { (event) in
                switch event {
                    case .next:
                    let control = event.element!

                    let rectSuperView = control.superview?.bounds
                    let xNew = CGFloat(arc4random() % UInt32(rectSuperView!.width - control.bounds.width)) + control.bounds.width/2
                    let yNew = CGFloat(arc4random() % UInt32(rectSuperView!.height - control.bounds.height)) + control.bounds.height/2
                    let newCenter = CGPoint.init(x: xNew, y: yNew)

                    UIView.animate(withDuration: 2,
                                   animations: {
                        print("initial frame = ",control.frame)
                        control.center = newCenter
                    },
                                   completion:  { (b: Bool) in
                        if b{
                            print("ending frame = ",control.frame)
                        }
                    })

                    default:
                        print("Default - ",event)
                }

            }.disposed(by: self.disposableBag)



        observableFromButton
            .do(onNext: {_ in
                print("running doOnNext: textlLabel change from: \(self.label.text ?? "nil") to " , terminator: "")
            }, afterNext: { _ in
                print(self.label.text ?? "nil")
            })
            .subscribe(onNext: { [unowned self] controlSelf in
                let number = Int(arc4random()%1000)
                self.label.text = "\(number)"
                let numColor = (CGFloat)(number)/1000
                controlSelf.backgroundColor = UIColor.init(displayP3Red: numColor, green: numColor, blue: numColor, alpha: 1)
            })
            .disposed(by: self.disposableBag)


        observableFromButton
           .throttle(DispatchTimeInterval.seconds(3), latest: true, scheduler: MainScheduler.instance)
           .subscribe({ (event) in
            let view = event.element!
            let arrayView = view.superview!.subviews
            for view in arrayView{
                if let activityIndicator = view as? UIActivityIndicatorView{
                    activityIndicator.startAnimating()
                    _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {_ in
                        print("timer")
                        activityIndicator.stopAnimating()
                    }
                }
            }

                publishSubject.on(event)
            }).disposed(by: self.disposableBag)

        

//        if let button: UIButton = self.control as? UIButton{
//            let _: () = button.rx.tap.asDriver().drive { (b) in
//                print("b=",b)
//            }
//        }
//
//        guard let segment: UISegmentedControl = self.control as? UISegmentedControl else {
//            return
//        }
//        segment.rx.value.bind {
//            print($0)
//        }.disposed(by: self.disposableBag)


        //observableFromButton.bind(to: publishSubject)
        

        

    }
}

















//let clouserObserver: ClouserRun = { [unowned self] controlSelf in
//            if(self.count != 0){
//               let number = Int(arc4random()%1000)
//                self.label.text = "\(number)"
//                let numColor = (CGFloat)(number)/1000
//                self.control.backgroundColor = UIColor.init(displayP3Red: numColor, green: numColor, blue: numColor, alpha: 1)
//            }
//            self.count = self.count + 1
//        }


//.throttle(DispatchTimeInterval.seconds(3), latest: true, scheduler: MainScheduler.instance)


//            .observeOn(MainScheduler.instance)
//            .subscribeOn(MainScheduler.instance)
//            .do(onNext:clouserObserver)
//            //.throttle(DispatchTimeInterval.seconds(3), latest: true, scheduler: MainScheduler.instance)
//            //.buffer(timeSpan: DispatchTimeInterval.milliseconds(100), count: 1, scheduler: MainScheduler.instance)
//            //.subscribe(onNext: clouser)
//            .subscribe({ (self) in
//                publishSubject.on(self)
//            })




//-------------------------------------------------------------------------------------------------------------------------------------------











        
//import Foundation
//import UIKit
//import RxSwift
//import RxCocoa
//import SwiftUI
//
//typealias ClouserRun = (UIButton) -> ()
//
//extension UIButton{
//    var avControl: AVButton{
//        let avButton1: AVButton = AVButton.init()
//        avButton1.buttonSelf = self
//        return avButton1
//    }
//}
//
//
//class AVButton: UIButton{
//
//        typealias ClouserRun = (UIButton) -> ()
//
//
//        var i = 0
//
//        var buttonSelf: UIButton! = nil
//        var clouserWork: ((UIButton) -> ())! = nil
//
//        var observable: Observable<Any>! = nil
//        var observer: AnyObserver<Any>! = nil
//
//        let disposeBag = DisposeBag()
//        var tap:Observable<Any>{
//            return self.tapp()
//        }
//
//        @objc func eventHandler(sender: UIButton){
//            _ = self.observable.subscribe(self.observer).disposed(by: self.disposeBag)
//        }
//
//
//        func tapp() -> Observable<Any>{
//
//
//            self.buttonSelf!.addTarget(self, action: #selector(eventHandler(sender:)), for: .touchUpInside)
//
//
//            let observableInput: Observable<Any> = Observable<Any>.create {observer in
//                self.observer = observer
//
//                self.observable = Observable<Any>.create{observer in
//                    observer.onNext(0)
//                    return Disposables.create()
//                }
//
//                observer.onNext(0)
//
//                return Disposables.create()
//            }
//
//            return observableInput
//        }
//}
//
//
//class ModelView: NSObject{
//
//    let button: UIButton
//    let label: UILabel
//    let disposeBag = DisposeBag()
//    var observable: Observable<Any>! = nil
//    var avButton: AVButton
//
//    var text: String! = nil
//    var colorButton: UIColor! = nil
//
//    var count = 0
//
//    init(b: UIButton, l: UILabel){
//        self.button = b
//        self.label = l
//        self.avButton = b.avButton
//
//    }
//
//    convenience init(button: UIButton, label: UILabel, n: Int) {
//        self.init(b: button, l: label)
//
//        self.text = self.label.text ?? "zero"
//        self.colorButton = self.button.backgroundColor!
//
//        let clouser: (Any) -> () = { [unowned self] _ in
//            if(self.count != 0){
//               let number = Int(arc4random()%1000)
//                self.label.text = "\(number)"
//                let color = (CGFloat)(number)/1000
//                button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//            }
//            self.count = self.count + 1
//
//        }
//
//        _ = self.avButton.taap.asObservable()
//            .observeOn(MainScheduler.instance)
//            .subscribeOn(MainScheduler.instance)
//            //.throttle(DispatchTimeInterval.seconds(3), latest: true, scheduler: MainScheduler.instance)
//            .buffer(timeSpan: DispatchTimeInterval.milliseconds(100), count: 1, scheduler: MainScheduler.instance)
//            .map { _ in
//                return print("map")
//        }
//            .subscribe(onNext: clouser)
//



//-------------------------------------------------------------------------------------------------------------------------------------------








        


        //_ = self.avButton.taap.subscribe(clouser)


//        let clouser: (Event<Any>) -> () = { _ in
//            print(button)
//            let number = Int(arc4random()%1000)
//            self.label.text = "\(number)"
//            let color = (CGFloat)(number)/1000
//            button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        }
//
//        _ = self.avButton.taap.subscribe(clouser)






//        _ = self.observable.subscribe(onNext: { event in
//            print(event)
//            let number = Int(arc4random()%1000)
//            self.label.text = "\(number)"
//            let color = (CGFloat)(number)/1000
//            button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        })






//        _ = button.rx.tap.subscribe(onNext: { event in
//            print(event) //   --- ()
//            let number = Int(arc4random()%1000)
//            self.label.text = "\(number)"
//            let color = (CGFloat)(number)/1000
//            button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        })


//        let clouser: ClouserRun  = { button in
//            print(button)
//            let number = Int(arc4random()%1000)
//            self.label.text = "\(number)"
//            let color = (CGFloat)(number)/1000
//            button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        }






//        _ = button.rx.tap.subscribe(onNext: { (e) in
//            clouser(button)
//        })



    //    func tapp(clouserWork: @escaping (UIButton) -> ()) -> Observable<UIButton>{
    //
    //        self.clouserWork = clouserWork
    //
    //        self.buttonSelf!.addTarget(self, action: #selector(eventHandler(sender:)), for: .touchUpInside)
    //
    //        self.observable = Observable<UIButton>.create {observer in
    //                print(observer)
    //            observer.onNext(self.buttonSelf!)
    //                return Disposables.create {
    //                    print("dispose")
    //                }
    //        }
    //        return self.observable.asObservable()
    //    }





//        _ = self.button.avButton.tapp { (button) in
//            print(button)
//            let number = Int(arc4random()%1000)
//            self.label.text = "\(number)"
//            let color = (CGFloat)(number)/1000
//            button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        }

























//class AVButton: UIButton{
//
//    var buttonSelf: UIButton! = nil
//    var clouserWork: ((UIButton) -> ())! = nil
//    var observable: Observable<UIButton>! = nil
//    let disposeBag = DisposeBag()
//
//    @objc func eventHandler(sender: UIButton){
//        _ = self.observable.subscribe(onNext: self.clouserWork).disposed(by: self.disposeBag)
//    }
//
//    func tapp(clouserWork: @escaping (UIButton) -> ()) -> (){
//        self.clouserWork = clouserWork
//        self.buttonSelf!.addTarget(self, action: #selector(eventHandler(sender:)), for: .touchUpInside)
//        self.observable = Observable<UIButton>.create {observer in
//                print(observer)
//            observer.onNext(self.buttonSelf!)
//                return Disposables.create {
//                    print("dispose")
//                }
//        }
//
//    }
//
//}

//class ModelView: NSObject{
//
//    let button: UIButton
//    let label: UILabel
//    let disposeBag = DisposeBag()
//
//    init(b: UIButton, l: UILabel){
//        self.button = b
//        self.label = l
//    }
//
//    convenience init(button: UIButton, label: UILabel, n: Int) {
//        self.init(b: button, l: label)
//
//        print(button)
//        let avb = self.button.avButton
//        print(avb.buttonSelf!)
//
//        _ = self.button.avButton.tapp { (button) in
//            print(button)
//            let number = Int(arc4random()%1000)
//            self.label.text = "\(number)"
//            let color = (CGFloat)(number)/1000
//            button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        }
//
//    }
//
//
//}








//        let clouserWork: (UIButton) -> () = {button in
//             print(button)
//             let number = Int(arc4random()%1000)
//             self.label.text = "gvkjhv"
//             let color = (CGFloat)(number)/1000
//             button.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//         }
//
//        self.button.rx.tap.do(onNext: { (event) in
//            print("do = ",event)
//        }).subscribe(onNext: { (event) in
//            print("subscribe =", event)
//        }).disposed(by: self.disposeBag)


//class ModelView: NSObject{
//
//    let button: UIButton
//    let label: UILabel
//    let disposeBag = DisposeBag()
//
//    var callback: ((UIButton) -> ())! = nil
//
//    var observable: Observable<UIButton.Event>! = nil
//
//    init(b: UIButton, l: UILabel){
//        self.button = b
//        self.label = l
//    }
//
//    convenience init(button: UIButton, label: UILabel, n: Int) {
//        self.init(b: button, l: label)
//        self.oB()
//    }
//
//    deinit {
//        print("deinit")
//    }
//
//
//    @objc func eventHandler(sender: UIButton){
//
//        self.observable.subscribe(onNext: { (touch) in
//            print(touch)
//            print(sender)
//            let number = Int(arc4random()%1000)
//            self.label.text = "\(number)"
//            let color = (CGFloat)(number)/1000
//            sender.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        }).disposed(by: self.disposeBag)
//
//
//    }
//
//    func oB(){
//
//        self.button.addTarget(self, action: #selector(eventHandler(sender:)), for: .touchUpInside)
//
//        self.callback = {[unowned self] sender in
//            self.label.text = "0" //создавало ретайн цикл!!!! без unowned
//        }
//
//        self.observable = Observable<UIButton.Event>.create {observer in
//            print(observer)
//            observer.onNext(UIButton.Event.touchUpInside)
//            return Disposables.create {
//                print("dispose")
//            }
//        }
//
//
//    }
//
//
//
//
//}








//        var rxButton: Reactive = Reactive(button)
//        let tap: ControlEvent = rxButton.tap
//        let observer = tap.subscribe{ event in
//            self.number = Int(arc4random()%1000)
//            self.label.text = "\(self.number)"
//        }

// self.label.text = "gvkjhv"
//         self.callback = {sender in
//             //print(sender)
//             //let number = Int(arc4random()%1000)
//             self.label.text = "gvkjhv"
////             let color = (CGFloat)(number)/1000
////             sender.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//         }

//var callback: ((UIButton) -> ())! = nil

//import Foundation
//import UIKit
//import RxSwift
//import RxCocoa
//import SwiftUI
//
//typealias Control = UIKit.UIControl
//
//class RxTarget2 : NSObject
//               , Disposable {
//
//    private var retainSelf: RxTarget2?
//
//    override init() {
//        super.init()
//        self.retainSelf = self
//
//#if TRACE_RESOURCES
//        _ = Resources.incrementTotal()
//#endif
//
//#if DEBUG
//        MainScheduler.ensureRunningOnMainThread()
//#endif
//    }
//
//    func dispose() {
//#if DEBUG
//        MainScheduler.ensureRunningOnMainThread()
//#endif
//        self.retainSelf = nil
//    }
//
//#if TRACE_RESOURCES
//    deinit {
//        _ = Resources.decrementTotal()
//    }
//#endif
//}
//
//
//class ModelView: RxTarget2{
//
//    var button: UIButton
//
//    var label: UILabel
//
//    var number = 0
//
//    var disposeBag = DisposeBag()
//
//    typealias Callback = (Control) -> Void
//
//    let selector: Selector = #selector(eventHandler(_:))
//
//    weak var control: Control?
//
//    var controlEvents: UIControl.Event! = nil
//
//    var callback: Callback?
//
//    @objc func eventHandler(_ sender: Control!){
//        if let callback = self.callback, let control = self.control {
//            callback(control)
//        }
//    }
//
//    init(b: UIButton, l: UILabel){
//        self.button = b
//        self.label = l
//    }
//
//    convenience init(button: UIButton, label: UILabel, n: Int) {
//        self.init(b: button, l: label)
//        self.oB()
//    }
//
//    func oB(){
//        let sourceObservable: Observable<UIButton.Event> = Observable<UIButton.Event>.create {observer in
//            print("ifewgoiu")
//            observer.onNext(UIButton.Event.touchUpInside)
//            return Disposables.create {
//                print("dispose")
//            }
//        }
//
//        let controlEventObservable: ControlEvent = ControlEvent(events: sourceObservable)
//
////        public init<Ev: ObservableType>(events: Ev) where Ev.Element == Element {
////            self._events = events.subscribeOn(ConcurrentMainScheduler.instance)
////        }
//
//        sourceObservable.asObservable().subscribe{
//            print("sourseObservable",$0)
//        }
//
//        controlEventObservable.asObservable().subscribe{
//            print("control",$0)
//        }
//
//        controlEventObservable.asObservable().subscribe(onNext: { (event) in
//            print("control",event)
//        }, onCompleted: {
//            print("control onCompleted")
//        }) {
//            print("control dispose")
//        }
//
//        let clouser: (Control) -> Void = { observer in
//            print(observer)
//            self.number = Int(arc4random()%1000)
//            self.label.text = "\(self.number)"
//            let color = (CGFloat)(self.number)/1000
//            observer.backgroundColor = UIColor.init(displayP3Red: color, green: color, blue: color, alpha: 1)
//        }
//        self.control = self.button
//        self.controlEvents = .touchUpInside
//        self.callback = clouser
//        self.control!.addTarget(self, action: selector, for: controlEvents)
//    }
//}
//
//
//
//        var rxButton: Reactive = Reactive(button)
//        let tap: ControlEvent = rxButton.tap
//        let observer = tap.subscribe{ event in
//            self.number = Int(arc4random()%1000)
//            self.label.text = "\(self.number)"
//        }

