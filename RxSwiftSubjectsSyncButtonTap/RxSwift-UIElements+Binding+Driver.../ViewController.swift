//
//  ViewController.swift
//  RxSwift-UIElements+Binding+Driver...
//
//  Created by Anatoly Ryavkin on 14.03.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var observer: AnyObject!

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var launchingButton: UIButton!


    let disposableBag = DisposeBag()

    let behaviorSubject = BehaviorSubject<String?>(value: "begining Meaning BehaviorSubject")

    let publishSubject = PublishSubject<Void>()

    let replaySubject = ReplaySubject<Int>.create(bufferSize: 3)
    var timeInterval: Int = 0
    var countTimeIntervalZiro = 0
    var firstYes = true

    var date: Date = Date()

    let asyncSubject = AsyncSubject<String?>()

    let publishRelay = PublishRelay<String?>()

    let behaviorRelay = BehaviorRelay<String?>(value: "begining Meaning BehaviorRelay")

    var i = 0
    var a = 0
    var array = [1,2,3,4,5]
    var obser: AnyObserver<String?>?
    var colorLabel: UIColor!
    var disposableLaunchingButton: Disposable!


    override func viewDidLoad() {
        super.viewDidLoad()

        //behaviorTextViewSndWorkFlatMap()
        //replaySubjectExample()
        //behaviorSubjectExample()
        //asyncSubjectExample()
        //behaviorRelayExample()

//        self.colorLabel = self.label.backgroundColor ?? UIColor.green
//        publishRelayExample()

    }

//MARK: BehaviorPublishRelay

    func publishRelayExample(){

        if let disposableLaunchingButton = self.disposableLaunchingButton{
            disposableLaunchingButton.dispose()
        }

        let clouser: () -> Observable<Int> = {
            self.array.append((self.array.last ?? 0) + 1)
            return Observable<Int>.from(self.array)
        }

        let disposableButton =
            self.button.rx.tap.asObservable()
                //.debounce(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)
                .flatMap(clouser)
                .map { i in
                    let string: String? = "Int = " + String(i)
                    return string
            }
            .debounce(RxTimeInterval.seconds(0), scheduler: MainScheduler.instance)
            .subscribe(onNext:{string in
                self.publishRelay.accept(string ?? "empty")
            })

        disposableButton.disposed(by: disposableBag)

        _ =
            self.publishRelay
                .asObservable()
                .subscribe(self.textView.rx.text)
                //.disposed(by: self.disposableBag)


        let random = Int(arc4random_uniform(30))

        let observableUntil: Observable<Int> = Observable.of(random)
            .delaySubscription(RxTimeInterval.seconds(random), scheduler: MainScheduler.instance)

        let disposableObservableUntil =
            observableUntil
                .subscribe(onNext: { event in
                    print("event = ",event)

                    self.behaviorRelay.accept("END!!! - Random = " + String(event))
                    self.behaviorRelay.subscribe(self.label.rx.text).disposed(by: self.disposableBag)
                    self.label.backgroundColor = UIColor.red
                })
        //.disposed(by: self.disposableBag)

        let disposableCaunter =
            Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                .map{String($0)}
                .takeUntil(observableUntil)
                .subscribe(self.label.rx.text)
        //.disposed(by: self.disposableBag)

        let disposableTextView =
            self.textView.rx.text.asObservable()
                .skipUntil(observableUntil)
                .subscribe(self.textField.rx.text)
        //.disposed(by: self.disposableBag)

        let disposableBehaviorRelay =
            self.behaviorRelay
                .asObservable()
                .subscribe(onNext: { string in
                    print("string = !!! = ",string ?? "empty")
                })
        //.disposed(by: self.disposableBag)

        self.disposableLaunchingButton =
            self.launchingButton.rx.tap.asDriver().drive(onNext: {_ in
                disposableButton.dispose()
                //disposablePublishRelay.dispose()
                self.publishRelay.accept("TextView")
                Observable<String?>.just("TextField").subscribe(self.textField.rx.text)
                    .disposed(by: self.disposableBag)
                disposableCaunter.dispose()
                disposableTextView.dispose()
                disposableObservableUntil.dispose()
                disposableBehaviorRelay.dispose()
                self.label.backgroundColor = self.colorLabel
                Observable<String?>.just("Label").subscribe(self.label.rx.text)
                    .disposed(by: self.disposableBag)
                self.i = 0
                self.a = 0
                self.array = [1,2,3,4,5]
                self.publishRelayExample()
            })
        //.disposed(by: self.disposableBag)

    }


//MARK: Behavior behaviorRelay

    func behaviorRelayExample(){

       let clouser: () -> Observable<String?> = {
             return Observable<String?>.create{observer in
                  self.i += 1
                 Timer.scheduledTimer(withTimeInterval: TimeInterval(/*self.i*/1), repeats: false) { [unowned self] t in
                     self.a += 1
                     observer.onNext("TextView meaning = " + String(self.a))
                 }
                 return Disposables.create()
             }
         }


        self.button.rx.tap.asObservable().asObservable()
        .flatMap(clouser)
        .subscribe(onNext: { string in
            self.behaviorRelay.accept(string)
        }).disposed(by:disposableBag)

         Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [unowned self] t in
             self.behaviorRelay.asObservable()
             .subscribe(self.textView.rx.text).disposed(by: self.disposableBag)
         }

    }



//MARK: Behavior asyncSubject

    func asyncSubjectExample(){

        var s1 = "s1"
        var s2 = "s2"
        var s3 = "s3"

        let clouser: () -> Observable<String?> = {
            s1 += "0"
            s2 += "0"
            s3 += "%"
            print("s1 = ",s1,"s2 = ",s2,"s3 = ",s3)
            return Observable<String?>.of(s1,s2,s3)
        }

        self.button.rx.tap
        .asObservable()
        .elementAt(3)
        .flatMap(clouser)
        //.elementAt(18)
        .subscribe(self.asyncSubject).disposed(by: self.disposableBag)

        self.button.rx.tap
        .asObservable()
        .flatMap(clouser)
        //.observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default)) //(MainScheduler.instance )
        .subscribe(onNext: { s in
            print("all element : s = ",s!)
        }).disposed(by:disposableBag)

        //sleep(3)
        self.asyncSubject.asObservable()
        .subscribe(self.textView.rx.text).disposed(by: self.disposableBag)

    }

//MARK: Behavior behaviorSubject

    func behaviorSubjectExample(){

        let clouser: () -> Observable<String?> = {
            return Observable<String?>.create{observer in
                 self.i += 2
                Timer.scheduledTimer(withTimeInterval: TimeInterval(/*self.i*/ 0), repeats: false) { [unowned self] t in
                    self.a += 1
                    observer.onNext("TextView meaning = " + String(self.a))
                }
                return Disposables.create()
            }
        }

        self.button.rx.tap.asObservable().asObservable()
        .flatMap(clouser)
        .subscribe(self.behaviorSubject).disposed(by: self.disposableBag)

        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [unowned self] t in
            self.behaviorSubject.asObservable()
            .subscribe(self.textView.rx.text).disposed(by: self.disposableBag)
        }
    }

//MARK: Behavior replaySubject and synhronize Tap Button !!!!!

    func replaySubjectExample(){

        self.button.rx.tap.asObservable()
        .map({ (i) -> Int in
            self.a += 1
            self.countTimeIntervalZiro = 0
            return self.a
        })
        .subscribe(self.replaySubject)
        .disposed(by: self.disposableBag)

        self.replaySubject.asObservable()
        .delaySubscription(RxTimeInterval.seconds(4), scheduler: MainScheduler.instance)
        .flatMap({ (num) in
            return Observable<Int>.create { (observer) -> Disposable in
                self.timeInterval = Int(self.date.distance(to: Date()))
                if self.firstYes{
                    self.firstYes = false
                    self.countTimeIntervalZiro += 1
                    self.timeInterval = 0
                    self.date = Date()
                }else if self.timeInterval < 1 && self.countTimeIntervalZiro > 0{
                    self.timeInterval = self.countTimeIntervalZiro
                    self.countTimeIntervalZiro += 1
                    self.date = Date()
                }else{
                    self.timeInterval = 1
                }
                Timer.scheduledTimer(withTimeInterval: TimeInterval(self.timeInterval), repeats: false) { (_) in
                    observer.onNext(num)
                }
                return Disposables.create()
            }
        })
        .map{String($0)}
        .subscribe(self.textView.rx.text).disposed(by: self.disposableBag)

        self.replaySubject
        .subscribe(onNext: { (num) in
            print("num = ",num)
        })
        .disposed(by: self.disposableBag)

    }

    //MARK: textView observer and symulfan observable (textFild another behavior!!! - without delegat)

    func behaviorTextViewSndWorkFlatMap(){

        let observableButton: Observable<Void> = button.rx.tap.asObservable()

        let clouser: () -> Observable<String?> = {
            self.i += 1
            return Observable<String?>.create{observer in
                observer.onNext("TextView meaning = " + String(self.i))
                return Disposables.create()
            }
        }

        let clouser1: (String?) -> Observable<String?> = {string in
            return Observable<String?>.create{observer in
                observer.onNext("get from TextView : " + String(string ?? "empty"))
                return Disposables.create()
            }
        }

        observableButton
        .flatMap(clouser)
        .subscribe(self.textView.rx.text)
        .disposed(by: self.disposableBag)

        textView.rx.text.asObservable()
        .flatMap(clouser1)
        .subscribe(self.textField.rx.text)
        .disposed(by: disposableBag)

        textView.rx.text.asObservable()
        .delay(RxTimeInterval.seconds(5),scheduler: MainScheduler.instance)
        .flatMap(clouser1)
        .subscribe(self.label.rx.text)
        .disposed(by: disposableBag)

        let observable: Observable<String?> = Observable<String?>.create{ [unowned self] obs  in
            self.obser = obs
            obs.on(.next("aaaaaa"))
            return Disposables.create()
        }

        observable.subscribe(self.textView.rx.text).disposed(by: self.disposableBag)


        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [unowned self] t in
            self.obser!.onNext("string from timer = " + String(self.a))
            self.a += 1
        }

    }

}



