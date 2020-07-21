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
    var replaySubject: AVReplaySubject<Element>! = nil
    var observable: Observable<Element>! = nil

    public func subscribe(subscriber: @escaping (Event<Element>) -> Void ) -> Disposable {

        let observer = AnyObserver<Element>.init(eventHandler: subscriber)

        self.observable.subscribe(observer).disposed(by: self.disposableBag)

        for elementEarlierEmited in self.replaySubject.arrayStoryEarlierEmitedElements{
            observer.on(.next(elementEarlierEmited.element!))
        }
        return Disposables.create{
            print("Disposables")
        }
        
    }

    public func on(_ event: Event<Element>) {} // requirement  protocol's

}

