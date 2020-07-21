//
//  ViewController.swift
//  RxSwiftUIElements
//
//  Created by Anatoly Ryavkin on 11.03.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var observer: AnyObject!

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!

    var count = -1
    let disposableBag = DisposeBag()
    var i = 0

    public enum ResultType {
        case Infinite
        case Completed
        case Error
    }

    public func createSequenceWithWait<T, U>(array: Array<T>, waitTime: Int64 = 1,
            resultType: ResultType = .Completed, describer: ((_ value: T) -> U)? = nil) -> Observable<U> {

        return Observable<U>.create{ observer  in
            self.observer = observer as AnyObject
            print("array = ",array)
            var idx = 0
            for letter in array{
                idx += 1
                            Timer.scheduledTimer(withTimeInterval: TimeInterval((idx+1) * Int(waitTime)), repeats: false) { (t) in
                                var value: U
                                if let describer = describer{
                                    value = describer(letter)
                                }else{
                                    value = letter as! U
                                }
                                print("value when you subscribing = ",value)
                                observer.onNext(value)
                            }
            }


            if resultType != .Infinite {
                Timer.scheduledTimer(withTimeInterval: TimeInterval(array.count * Int(waitTime) + 10), repeats: false) { (t) in
                    switch resultType {
                    case .Completed:
                        print("genring Completed, array = ",array)
                        observer.onCompleted()
                    case .Error:
                        observer.onError(RxError.unknown)
                        print("genring Error")
                    default:
                        break
                    }
                }
            }
            return Disposables.create {
                print("Observable ending and clean! array = ",array)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        flatMap()


    }

    func exampleWorkObserver(){

        let sequence:Observable<Int> = createSequenceWithWait(array: [0,1,2,3], waitTime: 3) {s in
            print("##################      s = ",s)
            return s
        }

        let observerSelf: AnyObserver<Int> = AnyObserver<Int>.init(eventHandler: {(event) in
                    print("observerSelf -----  : ",event)
        })

        sequence
        .debug("Subscriber is observerSelf", trimOutput: true)
        .subscribe(observerSelf)
        .disposed(by: disposableBag)

        (self.observer as! AnyObserver).onNext(111)

        Timer.scheduledTimer(withTimeInterval: TimeInterval(2), repeats: false) { (t) in
            print("invoke observer's onNext(222)  after unsabscribe")
            (self.observer as! AnyObserver).onNext(222)
        }
    }



    func flatMap(){

        let clouser: (Int) -> Observable<String> = {value in
                   self.count += 1
                   let observableString: Observable<String>
                   switch self.count {
                   case 0:
                       observableString = Observable<String>.create { (observer) in
                           Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (t) in
                               observer.onNext(String(value) + " - %%%%%%%%%%%%%")
                           }
                           observer.onNext(String(value) + " - !!!!!!!!!!!!!!!")
                           return Disposables.create()
                       }
                   case 1:
                    observableString = Observable<String>.just("Just - " + String(value)).delay(2,  scheduler: MainScheduler.instance)
                   case 2:
                       observableString = self.createSequenceWithWait(array: [111,222,333,444,555], waitTime: 5, resultType: .Completed, describer:{(value) in
                           return "createSequenceWithWait - " + String(value)
                       })
                   default:
                       observableString = Observable<String>.just("JustDefault - " + String(value))
                   }
                   return observableString
               }

               let sequence:Observable<Int> = createSequenceWithWait(array: [0], waitTime: 5).debug("sequenceObservable", trimOutput: true)

        // сущность flatMap
               sequence.subscribe(onNext: { (value) in
                   Observable<String>.create { observer in
                       Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { t in
                           observer.onNext(String(value) + " - %%%%%%%%%%%%%")
                       }
                       observer.onNext(String(value) + " - !!!!!!!!!!!!!!!")
                       return Disposables.create()
                   }.subscribe(onNext: {
                        print("++++++++++1  elementString in resultObservable = ",$0)
                   })
               })


                let resultObservable: Observable<String> = sequence.flatMap(clouser).debug("resultObservable", trimOutput: true)

                resultObservable.subscribe{event in
                    print("==========2  elementString in resultObservable = ",event.element ?? "NIL!!!")
                }

    }

}

