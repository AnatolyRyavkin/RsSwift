//
//  AVPublishSubject.swift
//  RxSwiftCreateSubject
//
//  Created by Anatoly Ryavkin on 27.02.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import RxSwift

public class AVPublishSubject <TypeObservableElement>: ObservableType{

    let disposableBag = DisposeBag()

    public typealias Element = TypeObservableElement
    public typealias ObserverT = AnyObserver<Element>
    var observableSelf: Observable<Element>!
    var arraySubscribers: [ObserverT] = []

    public func subscribe<Observer>(_ observer: Observer) -> Disposable{ Disposables.create()} // requirement protocol's ObservableType

    public func asObservable() -> Observable<Element> {

        if (self.observableSelf == nil){

            let clouserWithObserver: ((RxSwift.AnyObserver<AVPublishSubject.Element>) -> Disposable) = { subscriber in
                print("asObservable going proccess subscribe!")
                self.arraySubscribers.append(subscriber)
                return Disposables.create {
                    self.arraySubscribers.removeAll()
                    print("Dispose - observer = ",subscriber.asObserver())
                }
            }

            let publishSubjectObservable: Observable<Element> = Observable<Element>.create(clouserWithObserver)
            self.observableSelf = publishSubjectObservable
        }

        return self.observableSelf
    }

    
    func on(_ event: Event<Element>) -> Void{

        for subscriber  in self.arraySubscribers {
            subscriber.on(event)
        }

    }


    public func subscribeMy(_ observer: @escaping (Event<Element>) -> Void) -> Void {

        let subscriber = AnyObserver<Element>.init(eventHandler: observer)
        self.observableSelf = (self.observableSelf == nil) ? self.asObservable() : self.observableSelf
        self.observableSelf.subscribe(subscriber).disposed(by: disposableBag)

    }

}
