//
//  ViewController.swift
//  RxSwiftDriver
//
//  Created by Anatoly Ryavkin on 18.03.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private func dateFromString(stringInput: String?) -> Date{
    if let string = stringInput{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }else{
        return Date()
    }
}

private func stringFromDate(dateInput: Date?) -> String{
    if let date = dateInput{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }else{
        return "0000-00-00"
    }
}



private extension UILabel{

    var bindWithSegmentedControl: AnyObserver<UISegmentedControl>{
        return Binder<UISegmentedControl>(self){ label, segment in
            switch segment.selectedSegmentIndex{
                case 0 : label.backgroundColor = UIColor.red
                case 1 : label.backgroundColor = UIColor.blue
                case 2 : label.backgroundColor = UIColor.green
            default:
                label.backgroundColor = UIColor.gray
            }
            label.text = String(segment.selectedSegmentIndex)
            print("numberOfSegments = ",segment.numberOfSegments)
            print("selectedSegmentIndex = ",segment.selectedSegmentIndex)
        }.asObserver()
    }

}

public extension Reactive where Base == UILabel{

    public var textBindInt: UIBindingObserver<Base,Int>{
        return UIBindingObserver(UIElement: self.base){label, num in
            let numRandom = num % 3
            switch numRandom{
                case 0 : label.backgroundColor = UIColor.red
                case 1 : label.backgroundColor = UIColor.blue
                case 2 : label.backgroundColor = UIColor.green
            default:
                label.backgroundColor = UIColor.gray
            }
            label.text = String(num)
            print("num = ",num)
        }
    }
}

public extension Reactive where Base == UIProgressView{
    var bindingSlider: Binder<Float>{
        return Binder(self.base) { (progressView, progress) in
            progressView.progress = progress
        }
    }
}

extension UIActivityIndicatorView{
    var bindingWithSwitch: Binder<Bool>{
        return Binder(self) { (binder, isOn) in
            //binder.hidesWhenStopped = false
            isOn ? binder.startAnimating() : binder.stopAnimating()
        }
    }
}

extension UIStepper{
    var selfOwn: Binder<Double>{
        return Binder(self) { (stepper, number) in
            let num = (number == 0 || number > 254) ? 50 : number
            stepper.backgroundColor = UIColor.init(displayP3Red: CGFloat(num*10/255), green: CGFloat(num*3/255), blue: CGFloat(num*3/255), alpha: 1)
            print("stepper =",num )
        }
    }
}


class ViewController: UIViewController {

    enum ErrorMy: String, Error {
        case onErrorJustReturn = "onErrorJustReturn"
    }

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var switchMy: UISwitch!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    let disposableBag = DisposeBag()
    var selectedSegmentIndexBehaviorRelay: BehaviorRelay<Int>!

    override func viewDidLoad() {
        super.viewDidLoad()

        bindingDatePickerWithTextField()
        tapAsDriverExample()
        bindingSegmentWithLabel()
        bindingAnother()

        //safeSequenceAsDriverExample()
    }





    //MARK: binding slider with progressView and another

    func bindingAnother(){

        self.slider.rx.value.bind(to: self.progressView.rx.bindingSlider).disposed(by: self.disposableBag)

        self.switchMy.rx.isOn.asObservable().bind(to: self.activityIndicator.bindingWithSwitch).disposed(by: self.disposableBag)

        self.stepper.rx.value.asObservable().bind(to: self.stepper.selfOwn).disposed(by: self.disposableBag)

    }






    //MARK: binding segment with label

    func bindingSegmentWithLabel(){

        self.segment.rx.value.bind(to: self.label.rx.textBindInt).disposed(by: self.disposableBag)


        //additional:

        //        self.segment.rx.value.asDriver()
        //        .map{
        //            String($0)
        //            }
        //        .drive(self.label.rx.text)
        //        .disposed(by: self.disposableBag)


        //        let obs: Observable<UISegmentedControl> = Observable<UISegmentedControl>.generate(initialState: self.segment, condition: { cond in
        //            print("cond = ",cond)
        //            return true
        //        }, scheduler: MainScheduler.instance) {event in
        //            print("event = ", event)
        //            return self.segment
        //        }
         //       obs.subscribe(self.label.bindBindingObserverWithSegmentedControl).disposed(by: self.disposableBag)


        //        self.segment.rx.value.asDriver().drive(onNext: { (value) in
        //            self.label.bindWithSegmentedControl.onNext(self.segment)
        //            print("value = ",value)
        //        }).disposed(by: self.disposableBag)

    }

    //MARK: binding datePicer with textField

    private func bindingDatePickerWithTextField(){
        self.textField.autocorrectionType = .no
        self.datePicker.datePickerMode = .date
        let datePicker_rx_date: ControlProperty<Date> = datePicker.rx.date
        let textField_rx_text: ControlProperty<String?> = textField.rx.text

        textField_rx_text
        .map{string in dateFromString(stringInput: string)}
        .bind(to: datePicker_rx_date)
            .disposed(by: self.disposableBag)

        datePicker_rx_date
        .map{date in stringFromDate(dateInput: date)}
        .bind(to: textField_rx_text)
            .disposed(by: self.disposableBag)
    }



    //MARK: safeSequence: driver exeption errors!!! change error to next!!!

    private func tapAsDriverExample(){

            self.button.rx.tap
            .flatMap{ value -> Observable<String> in
                return Observable<String>.create{ observer in
                  observer.on(.next("EVENT-STRING"))
                  observer.onError(ErrorMy.onErrorJustReturn)
                  return Disposables.create{
                      print(/*"disposable - 1!"*/)
                  }
                }
            }//.debug("safeSequence", trimOutput: true)
            .asDriver(onErrorJustReturn: "stringError!")
            .drive(onNext: { (string) in
                if string == "stringError!"{
                    let bool = self.imageView.image == UIImage.init(named: "en4")
                    if(bool){
                        self.imageView.image = UIImage.init(named: "en3")!
                    }else{
                        self.imageView.image = UIImage.init(named: "en4")!
                    }
                    self.tapAsDriverExample()
                }
                self.imageView.setNeedsLayout()
                print("next = ",string)
            }).disposed(by: self.disposableBag)

    }




    //MARK: safeSequence: Observable = driver !!!

    private func safeSequenceAsDriverExample(){

           self.button.rx.tap
          .retry(2)  // если ошибка исходит из кнопки
          .flatMap{ value -> Observable<String> in
              return Observable<String>.create{ observer in
                  observer.on(.next("1"))
                  observer.onError(ErrorMy.onErrorJustReturn)
                  return Disposables.create{
                      print("disposable - 1!")
                  }
              }
          }.debug("safeSequence", trimOutput: true)
              .retry(2) // дальше не идет, переподписывается n-раз
          .catchError({ (error) -> Observable<String> in
              Observable<String>.create{ observer in
                  observer.on(.next("2"))
                  observer.onError(ErrorMy.onErrorJustReturn)
                  return Disposables.create{
                      print("disposable - 2!")
                  }
              }.debug("Sequence --- 2", trimOutput: true)
          })
          .retry(3) // дальше не идет, переподписывается n-раз
          .catchErrorJustReturn("tap")
          .share(replay: 2, scope: SubjectLifetimeScope.whileConnected)
          .bind { (string) in
                  print("string = ",string)
          }.disposed(by: self.disposableBag)
    }

}

