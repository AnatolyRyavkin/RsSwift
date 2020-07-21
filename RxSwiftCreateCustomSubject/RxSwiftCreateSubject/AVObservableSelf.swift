//
//  ObservableSelf.swift
//  RxSwiftCreateSubject
//
//  Created by Anatoly Ryavkin on 03.03.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import RxSwift

public class AVObservableSelf<TypeObservable> : ObserverType {

    public typealias Element = TypeObservable

    let disposableBag = DisposeBag()
    var replaySubject: AVReplaySubject<Element>!
    var observable: Observable<Element>!

    public func subscribe(observer: @escaping (Event<Element>) -> Void ) -> Disposable {

        let subscriber = AnyObserver<Element>.init(eventHandler: observer)

        self.observable.subscribe(subscriber).disposed(by: self.disposableBag)

        for elementEarlierEmited in self.replaySubject.arrayStoryEarlierEmitedElements{
            subscriber.on(.next(elementEarlierEmited.element!))
        }
        return Disposables.create{
            print("Disposables")
        }
        
    }

    public func on(_ event: Event<Element>) {} // requirement  protocol's

}

