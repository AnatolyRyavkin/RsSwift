import UIKit
import SwiftUI
import PlaygroundSupport
import RxSwift
import RxCocoa

PlaygroundPage.current.needsIndefiniteExecution = true

var action: () -> () = {}

//    action = {
//    let variable = Variable<Int>(0)
//    let behaviorRelay: BehaviorRelay<Int> = BehaviorRelay(value: 10)
//    variable.asObservable().subscribe{ e in
//        print(e)
//    }
//    let behaviorRelayObservable: Observable<Int> = behaviorRelay.asObservable()
//    let disposable: Disposable = behaviorRelayObservable.subscribe { e in
//        print(e)
//    }
//    //disposable.dispose()
//    variable.value = 1
//    behaviorRelay.accept(11)
//}
//
//
//    action = {
//        let firstSequenceObservable = Observable<Any>.of(1,3,5)
//        let secondSecuenceObservable = Observable<Any>.of("a","b","c")
//        firstSequenceObservable.subscribe(onNext: { (n) in
//            print(n)
//        })
//        let observableNew = Observable<Observable<Any>>.create{ observable in
//            observable.on(.next(firstSequenceObservable))
//            observable.on(.next(secondSecuenceObservable))
//            return Disposables.create{
//                print(observable)
//            }
//        }
//
//        observableNew.subscribe{e in
//            print(e)
//        }
//
//        var thirdSeqrence: Observable<Any> = observableNew.merge()
//        //var thirdSeqrence: Observable<Any> = observableNew.concat()
//
//        thirdSeqrence.subscribe { (n) in
//            print("new = ",n)
//        }
//
//    }


//var i = 20
//var observable = Observable<Any>.of(1,3,5,"e",i)
//observable.subscribe{ event in
//    print(event)
//}
//i = 30
//observable.subscribe{ event in
//    print(event)
//}
//
//let sequence = Observable<Any>.empty()
//print(sequence)

//var array: Array = []
//
//Observable<Int>.create{observer in
//    observer.on(.next(1))
//    observer.onNext(2)
//    observer.onNext(3)
//    return Disposables.create()
//}.subscribe{n in
//    print(n)
//    array.append(n.element ?? 100)
//}
//
//print(array)

let sequenceInt = Observable<Any>.range(start: 10, count: 5)
let sequenceString = Observable<Any>.of("a","b","c")

let sequence = Observable<Observable<Any>>.create{observer in
    observer.in(.next(sequenceInt))
    observer.in(.next(seqenceString))
    Disposables.create()
}

let seqenceMerge = sequence.merge()

sequenceMerge.subscribe{event in
    print(event)
}


example("Test1",action:action)










