//
//  ViewController.swift
//  TestRxSwift
//
//  Created by Anatoly Ryavkin on 14.02.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import Foundation
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    override func viewDidLoad() {
           super.viewDidLoad()

        var action: () -> () = {

            //кложур. определяет что делать с приходящим n = Event.next(int) or .completed...

            let clouserEventHandler: (Event<Int>) -> Void = { n in
//                switch n {
//                case .next:
//                    print ("observerIn=",n.element!)
//                    break
//                case .completed:
//                    print ("completed=",n)
//                    break
//                default:
//                    print("disposobled")
//                    break
//                }
            }

            // создаем обзервер с обработчиком входного сигнала - clouserEventHandler vj;tn gjlg

            let observerIn = AnyObserver<Int>.init(eventHandler: clouserEventHandler)


            let observerEmpty = AnyObserver<Int>.init(eventHandler: { (n:Event) in
               // print(n)
            })

            let observerSubscriber = AnyObserver<Int>.init { (event) in
              //  print("event observerSubscriber = ",event)
            }

            //клоужер, в котором обзервер генерит что-то (последоательность сигналов ) сам наблюдает за ними и удаляется
            //(обзервер может сам себе генерить последовательность)

            let clouserWithObserver: (RxSwift.AnyObserver<Int>) -> Disposable = {(subscriber: RxSwift.AnyObserver<Int>) -> Disposable in
//                  observerEmpty.on(.next(111))
//                  observerIn.on(.next(222))
//                  observerSubscriber.on(.next(333)) не эммитят в обзервабл
                subscriber.on(.next(444))
                  subscriber.on(.next(444))

                return Disposables.create {
                    print("Dispose - observer.observer = ",subscriber.asObserver())
                }
            }

            // создаем обзервабл сигналов из клоужера, в котором есть обзервер, который не наблюдает за данной обзервабл
            // просто этот обзервер создает эти сигналы
            // ничего не происходит, так как еще не подписались



            let observable = Observable.create(clouserWithObserver)

            //подписываемся на обзервабл. Если подписываемся (), то при создании последовательности сабскпайбер(подписавшийся
            //обзервер) пустой

            //let subscriber1: RxSwift.Disposable = observable.subscribe() // empty subscriber

            //let subscriber3: RxSwift.Disposable = observable.subscribe(observerEmpty)

            //let subscriber2: RxSwift.Disposable = observable.subscribe(observerIn)

            let subscriber4: RxSwift.Disposable = observable.subscribe(onNext: { (n) in
                print(n)
            })

        }//end action


        action = {
            let firstSequenceObservable: RxSwift.Observable<Any> = Observable<Any>.of(1,3,5,7)
            let secondSecuenceObservable: RxSwift.Observable<Any> = Observable<Any>.of("2","4","6")
            let observableAtObserable: RxSwift.Observable<Observable<Any>> = Observable<Observable<Any>>.from([firstSequenceObservable,secondSecuenceObservable])

            let obserableCombine = observableAtObserable.merge()
            let disp1: Disposable = obserableCombine.subscribe { (event) in
               print(event)
            }
        }

        //exampleViewDidLoad("exampleViewDidLoad",action: action)

        action = {

            let firstSequenceObservable: RxSwift.Observable<Any> = Observable<Any>.of(1,3,5,7)
            let secondSecuenceObservable: RxSwift.Observable<Any> = Observable<Any>.of("2","4","6")

           let clouserEventHandler: (Event<Observable<Any>>) -> Void = { n in
               switch n {
               case .next:
                   print ("observerIn=",n.element!)
                   break
               case .completed:
                   print ("completed=",n)
                   break
               default:
                   print("disposobled")
                   break
               }
           }


            let observerAtObservervable = AnyObserver<Observable<Any>>.init(eventHandler: clouserEventHandler)

            //firstSequenceObservable.subscribe(ObserverType)

           let clouserWithObserver: (RxSwift.AnyObserver<Observable<Any>>) -> Disposable = {(subscriber: RxSwift.AnyObserver<Observable<Any>>) -> Disposable in
                    subscriber.on(.next(firstSequenceObservable))
                    subscriber.on(.next(secondSecuenceObservable))

                return Disposables.create{
                     print(subscriber)
                }
           }

           let observableAtObserable: RxSwift.Observable<Observable<Any>> = Observable<Observable<Any>>.create(clouserWithObserver)


            let disp: Disposable = observableAtObserable.subscribe { (event) in
                print(event)
            }

            let obserableCombine = observableAtObserable.merge()


            let disp1: Disposable = obserableCombine.subscribe { (event) in
                print(event)
            }


        }//end action


        action = {
            let sequenceInt = Observable<Int>.range(start: 10, count: 5)
            let sequenceInt1 = sequenceInt.asObservable()
            let sequenceInt2 = Observable<Int>.of(1,2,3,10000000)


            var sequence = Observable<Observable<Int>>.create{observer in
                observer.onNext(sequenceInt1)
                observer.on(.next(sequenceInt))
                observer.on(.next(sequenceInt2))
                return Disposables.create()
            }

            var sequenceMerge = sequence.merge()
            
            sequenceMerge.subscribe{event in
                print(event)
            }

            sequence = Observable<Observable<Int>>.create{observer in
              observer.onNext(sequenceMerge)
              observer.on(.next(sequenceInt2))
              return Disposables.create()
           }

            var sequenceMerge1 = sequence.merge()

            print(sequenceMerge1)
            print(sequenceMerge)

            sequenceMerge1.subscribe{event in
                print(event)
            }
        }

        action = {
            let sequence = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            let observableType: (Event<Int>) -> Void = {event in
                print(event.element as Any)
            }
            let s = sequence.subscribe(observableType)

            let timer1 = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { t in
               s.dispose()
                print(t.self)
            }

        }

        action = {

            //var sequence = Observable<Int>.timer(2, period: 1, scheduler: MainScheduler.instance)

            var sequence = Observable.repeatElement(UIView(), scheduler: MainScheduler.instance)

            let observableType: (Event<UIView>) -> Void = {event in
                print(event.element?.bounds as Any)
            }
            let s = sequence.subscribe(observableType)

            let timer1 = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { t in
               s.dispose()
                print(t.self)
            }

        }

        action = {
            var i = 10
            let variable = BehaviorRelay<Int>(value: i)
            let observable = variable.asObservable()
            observable.subscribe(onNext: { (event) in
                print(event)
            }, onError: { (nil) in
                print("error")
            }, onCompleted: {
                print("completed")
            }) {
                print("dispose")
            }
            i = 20


        }

            action = {
            let variable = Variable<Int>(0)
            let behaviorRelay: BehaviorRelay<Int> = BehaviorRelay(value: 10)
            variable.asObservable().subscribe{ e in
                print(e)
            }
            let behaviorRelayObservable: Observable<Int> = behaviorRelay.asObservable()
            let disposable: Disposable = behaviorRelayObservable.subscribe { e in
                print(e)
            }
            disposable.dispose()
            variable.value = 1
            behaviorRelay.accept(11)

            let disposable1: RxSwift.Disposable = behaviorRelayObservable.subscribe(onNext: { (event) in
                print(event)
            }, onError: { (nil) in
                print("error")
            }, onCompleted: {
                print("completed")
            }) {
                print("dispose")
            }


        }

        action = {
            let behaviorRelay: BehaviorRelay<Int> = BehaviorRelay(value: 10)
            let behaviorRelayObservable: Observable<Int> = behaviorRelay.asObservable()
            let disposable: Disposable = behaviorRelayObservable.subscribe { e in
                print(e)
            }
            behaviorRelay.accept(111)

            var i = 0
            BehaviorSubject(value: i).asObservable().subscribe { (event) in
                print(event)
            }
            i = 10

        }

        action = {
            let subject = PublishSubject<Int>()
            subject.subscribe{
                print($0)
            }
            subject.onNext(10)
            subject.onNext(11)
            subject.onNext(12)

            subject.subscribe{
                print("subscribe2 = ",$0)
            }
            var i = 100
            subject.onNext(i)
            i = 1000
            subject.onNext(i)
             i = 11
            subject.onNext(i)
             i = 1111

        }
        func processData(data: String?) -> String {
            guard let result = data else {
                return "data not found"
            }
            return result
        }
        func processData1(data: String?) -> String {
            if let result = data{
                return result
            }else{
                return "data not found"
            }
        }

        action = {
            print("processData1 =",processData1(data: nil))
            print("processData1 =",processData1(data: "data"))
            print("processData =",processData(data: nil))
            print("processData =",processData(data: "data1"))
        }







        var actionThrows: () throws -> () = {

            enum Errors: Error {
              case noData
              case unknownError
            }

//            func progress(data: String?) throws -> String {
//              guard let result = data else {
//                throw Errors.noData
//              }
//              return result
//            }

            func progress(data: String?) throws -> String {
              guard let result = data else {
                throw Errors.unknownError
              }
              return result
            }

            do {
              print(try progress(data: nil))
            } catch {
                print("An error occurred: \(error)")
                throw Errors.noData
            }


        }

        actionThrows = {

            enum E: Error {
              case noData
              case unknownError
            }
            throw E.noData
        }

        //exampleTrows("asObservable",action: actionThrows)

        action = {
            enum E: Swift.Error {
              case noData
              case unknownError
            }

            let firstSequenceObservable: RxSwift.Observable<Any> = Observable<Any>.of(1,3,5,7)
            let secondSecuenceObservable: RxSwift.Observable<Any> = Observable<Any>.of(2,4,6)

            let observableNew: RxSwift.Observable<Observable<Any>> = Observable<Observable<Any>>.create{ observable in
                if arc4random()%2 == 0{
                    observable.on(.next(firstSequenceObservable))
                }else{
                    observable.on(.next(secondSecuenceObservable))
                }
                return Disposables.create{
                    print(observable)
                }
            }

//            observableNew.merge().subscribe { (n) in
//                print("new = ",n)
//            }
//            print("--------")
//            observableNew.concat().subscribe { (n) in
//                print("new = ",n)
//            }
//            print("--------")
//            observableNew.concat().subscribe { (n) in
//                print("new = ",n)
//            }
//            print("--------")
//            observableNew.subscribe { (n) in
//                print("new = ",n)
//            }
            Observable<Observable<Any>>.create { (observer) -> Disposable in
                observer.onNext(firstSequenceObservable)
                observer.onNext(secondSecuenceObservable)
                //observer.onError(E.noData)
                return Disposables.create()
            }
                .merge()
                .do(onNext: {
                    print("\(Thread.current): ",$0)
                })
                .map{($0 as! Int)*100}
                .observeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "queue1"))
                .subscribeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "queue2"))
                .subscribe(onNext: {
                    print("\(Thread.current): ",$0)
                })//,onError: {error in print(error)})
            print("Init thread: \(Thread.current)")
        }

         exampleViewDidLoad("asObservable",action:action)



//        action = {
//            let variable = Variable<Int>(0)
//            let behaviorRelay: BehaviorRelay<Int> = BehaviorRelay(value: 10)
//            variable.asObservable().subscribe{ e in
//                print(e)
//            }
//            let behaviorRelayObservable: Observable<Int> = behaviorRelay.asObservable()
//            let disposable: Disposable = behaviorRelayObservable.subscribe { e in
//                print(e)
//            }
//            disposable.dispose()
//            variable.value = 1
//            behaviorRelay.accept(11)
//        }



//        action = {
//            let firstSequenceObservable: RxSwift.Observable<Any> = Observable<Any>.of(1,3,5)
//            let secondSecuenceObservable: RxSwift.Observable<Any> = Observable<Any>.of("a","b","c")
//
//            //let observableNew: Observable<Any>  = Observable.of(firstSequenceObservable,secondSecuenceObservable)
//
//            let observableNew: Observable<Any>  = Observable.of([1,2,3],[6,7,8])
//            observableNew.subscribe { (event) in
//                print(event)
//            }
//
//
////            let thirdSeqrence = observableNew.merge
////
////            thirdSeqrence.subscribe { (n) in
////                print("new = ",n)
////            }
//
//        }



        //exampleViewDidLoad("asObservable",action:action)




    }//end viewDidLoad


    public func exampleViewDidLoad(_ rxOperator: String, action: () -> ()) {
        print("\n--- exampleViewDidLoad of:", rxOperator, "---")
        action()
    }

    public func exampleTrows(_ rxOperator: String, action: () throws -> ()) {
        print("\n--- exampleAll of:", rxOperator, "---")
        do {
          try action()
        } catch {
          print("An error occurred: \(error)")
        }
    }

}

