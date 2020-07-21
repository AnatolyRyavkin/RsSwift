//
//  ReplaySabject.swift
//  RxSwiftCreateSubject
//
//  Created by Anatoly Ryavkin on 02.03.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//


import Foundation
import RxSwift

public class AVReplaySubject <TypeObserving>: ObservableType{

    let disposableBag = DisposeBag()
    public typealias Element = TypeObserving
    public typealias ObserverT = AnyObserver<AVReplaySubject.Element>
    var observableSelf: AVObservableSelf<TypeObserving>! = nil
    var arraySubscribing: [ObserverT] = []
    var arrayStoryEarlierEmitedElements: [Event<Element>] = []
    var countElementsStory: Int = 0

    public init(countElementsStory: Int){
        self.countElementsStory = countElementsStory
    }

    public func subscribe<Observer>(_ observer: Observer) -> Disposable {Disposables.create()} // requirement  protocol's

    public func asObservable() -> AVObservableSelf<Element> {

        let clouserWithObserver: ((RxSwift.AnyObserver<AVReplaySubject.Element>) -> Disposable) = { subscriber in
            self.arraySubscribing.append(subscriber)
            return Disposables.create {
                self.arraySubscribing.removeAll()
                print("Disposeables and remove all elements from arraySubscribing ",subscriber.asObserver())
            }
        }

        if (self.observableSelf == nil){
            
            let replaySubjectObservable: Observable<Element> = Observable<Element>.create(clouserWithObserver)

            self.observableSelf = AVObservableSelf<Element>() //or TypeObserving
            self.observableSelf.observable = replaySubjectObservable
            self.observableSelf.replaySubject = self   
        }
        return self.observableSelf

    }

    public func on(_ event: Event<Element>) -> Void{

        self.arrayStoryEarlierEmitedElements.append(event)
        for subscriber  in self.arraySubscribing {
            subscriber.on(event)
        }
        if self.arrayStoryEarlierEmitedElements.count > self.countElementsStory{
            self.arrayStoryEarlierEmitedElements.remove(at: 0)
        }
        
    }

}



















//
//public class ObservableSelf<Observer> : ProtocolAVReplaySubject where Observer: ObserverType, Element == Observer.Element{
//
//    public typealias Element = Observer.Element
//
////    public typealias Element == Observer.Element
////    public typealias Observer = <#type#>
//
//
//
//    public var arrayStoryEmmitsComputed: [Event<ObservableSelf.Element>]
//
//    public typealias Element = <#type#>
//
//
//    var arrayStoryEmmits: [Event<Element>] = []
//
//    public typealias Observer = AnyObserver<Element>
//
//    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Element == Observer.Element {
//            if arrayStoryEmmits.count > 0{
//                for eventForArrayStoryEmmits: Event<Element> in arrayStoryEmmits{
//                    observer.on(eventForArrayStoryEmmits)
//                }
//            }
//        return Disposables.create{
//            print("Disposables.create - funk subscribe from AVPublihSubject")
//        }
//    }
//}

















//
//
//extension RxSwift.ObservableType{
//
//    var arrayStoryEmmitsComputed: [Event<Element>]{
//
//    }
//
//    public func subscribeMadeInI(event: Event<Element>) -> Disposable {
//
//        switch event {
//        case .next:
//            let handler:(Event<Self.Element>) -> Void = {event in
//                print("event.element = ",event.element!)
//            }
//            let observerIn = AnyObserver<Element>.init(eventHandler: handler)
//
//            observerIn.onNext(event.element!)
//
//        default:
//            print(event)
//        }
//
//            return Disposables.create{
//                print("Disposables.create - funk subscribe from AVPublihSubject")
//            }
//    }

//    public func subscribeMadeInI(handler: @escaping (Event<Element>) -> Void)
//        -> Disposable {
//
//            let observerIn = AnyObserver<Element>.init(eventHandler: handler)
//
//            observerIn.onNext(handler)
//
//            print("observer from Extensions")
//
//            return Disposables.create{
//                print("Disposables.create - funk subscribe from AVPublihSubject")
//            }
//    }


//    public func subscribeMadeInI<Observer>(_ observer: Observer) -> Disposable where Observer : ProtocolAVReplaySubject, Observer.Element == Element {
//        if observer.arrayStoryEmmitsComputed.count > 0{
//            for eventForArrayStoryEmmits: Event<Element> in observer.arrayStoryEmmitsComputed{
//                observer.on(eventForArrayStoryEmmits)
//            }
//        }
//        return Disposables.create{
//            print("Disposables.create - funk subscribe from AVPublihSubject")
//        }
//    }

//    public func subscribeMadeInI(handler: @escaping (Event<Element>) -> Void)
//        -> Disposable {
//
//            let observerIn = AnyObserver<Element>.init(eventHandler: handler)
//
//            //observerIn.on(.next())
//
//            print("observer from Extensions")
//
//            return Disposables.create{
//                print("Disposables.create - funk subscribe from AVPublihSubject")
//            }
//    }




//    public func subscribe(onNext: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil)
//        -> Disposable {
//            if observer.arrayStoryEmmitsComputed.count > 0{
//                for eventForArrayStoryEmmits: Event<Element> in observer.arrayStoryEmmitsComputed{
//                    observer.on(eventForArrayStoryEmmits)
//                }
//            }
//            return Disposables.create{
//                print("Disposables.create - funk subscribe from AVPublihSubject")
//            }
//    }


//    typealias Observer = (Event<Element>) -> Void

    //public func subscribe(_ on: @escaping (Event<Element>) -> Void)

//    func subscribe<Observer>(_ on: @escaping (Event<Element>) -> Void) -> Disposable where Observer : ProtocolAVReplaySubject, Observer.Element == Element {
//    if observer.arrayStoryEmmitsComputed.count > 0{
//        for eventForArrayStoryEmmits: Event<Element> in observer.arrayStoryEmmitsComputed{
//            observer.on(eventForArrayStoryEmmits)
//        }
//    }
//    return Disposables.create{
//        print("Disposables.create - funk subscribe from AVPublihSubject")
//    }

//        func subscribe<Observer>(_ observer:  Observer) -> Disposable where Observer : ProtocolAVReplaySubject, Observer.Element == Element {
//        if observer.arrayStoryEmmitsComputed.count > 0{
//            for eventForArrayStoryEmmits: Event<Element> in observer.arrayStoryEmmitsComputed{
//                observer.on(eventForArrayStoryEmmits)
//            }
//        }
//        return Disposables.create{
//            print("Disposables.create - funk subscribe from AVPublihSubject")
//        }
//    }
//}




