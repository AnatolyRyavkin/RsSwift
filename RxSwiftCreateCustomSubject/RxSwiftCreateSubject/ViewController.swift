//
//  ViewController.swift
//  RxSwiftCreateSubject
//
//  Created by Anatoly Ryavkin on 27.02.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//


import UIKit
import RxSwift
import Foundation



class ViewController: UIViewController {

    let disposableBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

                  //TODO: ReplaySubject

        print("\n ----------   ReplaySubject    ----------\n")

        //MARK: replaySubject with Buffer = 0

        print("\n ----------   replaySubject with Buffer = 0   ----------\n")

        let replaySubjectWithBuffer0: AVReplaySubject<Int> = AVReplaySubject<Int>(countElementsStory: 0)

        let observableForReplaySubjectWithBuffer0: AVObservableSelf = replaySubjectWithBuffer0.asObservable()

        print("\n make observable1 with Buffer = 0 \n")

        print("\nreplaySubjectWithBuffer0.on(.next(10))")
        replaySubjectWithBuffer0.on(.next(10))
        print("\nreplaySubjectWithBuffer0.on(.next(20))")
        replaySubjectWithBuffer0.on(.next(20))
        print("\nreplaySubjectWithBuffer0.on(.next(30))")
        replaySubjectWithBuffer0.on(.next(30))
        print("\nreplaySubjectWithBuffer0.on(.next(40))")
        replaySubjectWithBuffer0.on(.next(40))
        print("\nreplaySubjectWithBuffer0.on(.next(50))\n")
        replaySubjectWithBuffer0.on(.next(50))

        print("\n will be subscribed 1 to observable1 with Buffer = 0 \n")

        observableForReplaySubjectWithBuffer0.subscribe{
           switch $0{
            case .next:
                 print("\n The received signal: subscribe1 Buffer = 0 element = ",$0.element!)
            case .completed:
                print("\n The received signal: complited subscribe1 Buffer = 0 - ",$0)
            default:
                print("\n The received signal: default subscribe1 Buffer = 0 - ",$0)
            }
        }.disposed(by: disposableBag)

        print("\n already subscribed 1 to observable1 with Buffer = 0 \n")

        print("\nreplaySubjectWithBuffer0.on(.next(60))")
        replaySubjectWithBuffer0.on(.next(60))
        print("\nreplaySubjectWithBuffer0.on(.next(70))")
        replaySubjectWithBuffer0.on(.next(70))
        print("\nreplaySubjectWithBuffer0.on(.next(80))\n")
        replaySubjectWithBuffer0.on(.next(80))


        let subscriber: (Event<Int>) -> () = {
           switch $0{
            case .next:
                 print("\n The received signal: subscribe2 Buffer = 0 element = ",$0.element!)
            case .completed:
                print("\n The received signal: complited subscribe2 Buffer=0 - ",$0)
            default:
                print("\n The received signal: default subscribe2 Buffer=0 - ",$0)
            }
        }

        print("\n will be subscribed 2 to observable1 with Buffer = 0 \n")

        observableForReplaySubjectWithBuffer0.subscribe(observer: subscriber).disposed(by: disposableBag) //!!!!!

        print("\n already subscribed 2 to observable1 with Buffer = 0 \n")

        print("\nreplaySubjectWithBuffer0.on(.next(90))")
        replaySubjectWithBuffer0.on(.next(90))
        print("\nreplaySubjectWithBuffer0.on(.completed)")
        replaySubjectWithBuffer0.on(.completed)

        print("\n replaySubjectWithBuffer0.arrayStoryEarlierEmitedElements = ",replaySubjectWithBuffer0.arrayStoryEarlierEmitedElements)
        print("\n replaySubjectWithBuffer0.arraySubscribing = ",replaySubjectWithBuffer0.arraySubscribing)

        print("\nreplaySubjectWithBuffer0.on(.next(100))\n")
        replaySubjectWithBuffer0.on(.next(100))


//MARK: replaySubject with Buffer = 3

        print("\n ----------   replaySubject with Buffer = 3   ----------\n")


        let replaySubjectWithBuffer3: AVReplaySubject<Int> = AVReplaySubject<Int>(countElementsStory: 3)
        let observableForReplaySubjectWithBuffer3: AVObservableSelf = replaySubjectWithBuffer3.asObservable()

        print("\n make observable2 with Buffer = 3 \n")


        print("\nreplaySubjectWithBuffer3.on(.next(10))")
        replaySubjectWithBuffer3.on(.next(10))
        print("\nreplaySubjectWithBuffer3.on(.next(20))")
        replaySubjectWithBuffer3.on(.next(20))
        print("\nreplaySubjectWithBuffer3.on(.next(30))")
        replaySubjectWithBuffer3.on(.next(30))
        print("\nreplaySubjectWithBuffer3.on(.next(40))")
        replaySubjectWithBuffer3.on(.next(40))
        print("\nreplaySubjectWithBuffer3.on(.next(50))\n")
        replaySubjectWithBuffer3.on(.next(50))

        print("\n will be subscribed 1 to observable2 with Buffer = 3 \n")

        observableForReplaySubjectWithBuffer3.subscribe{
           switch $0{
            case .next:
                 print("\n The received signal: subscribe1 Buffer = 3,  element = ",$0.element!)
            case .completed:
                print("\n The received signal: complited subscribe1 Buffer = 3 - ",$0)
            default:
                print("\n The received signal: default subscribe1 Buffer = 3 - ",$0)
            }
        }.disposed(by: disposableBag)

        print("\n already subscribed 1 to observable2 with Buffer = 3 \n")

        print("\nreplaySubjectWithBuffer3.on(.next(60))")
        replaySubjectWithBuffer3.on(.next(60))
        print("\nreplaySubjectWithBuffer3.on(.next(70))")
        replaySubjectWithBuffer3.on(.next(70))
        print("\nreplaySubjectWithBuffer3.on(.next(80))\n")
        replaySubjectWithBuffer3.on(.next(80))

        print("\n will be subscribed 2 to observable2 with Buffer = 3 \n")

        observableForReplaySubjectWithBuffer3.subscribe{
           switch $0{
            case .next:
                 print("\n The received signal: subscribe2 Buffer = 3 element = ",$0.element!)
            case .completed:
                print("\n The received signal: complited subscribe2 Buffer = 3 - ",$0)
            default:
                print("\n The received signal: default subscribe2 Buffer = 3 - ",$0)
            }
        }.disposed(by: disposableBag)

        print("\n already subscribed 2 to observable2 with Buffer = 3 \n")

        print("\nreplaySubjectWithBuffer3.on(.next(90))")
        replaySubjectWithBuffer3.on(.next(90))
        print("\nreplaySubjectWithBuffer3.on(.completed)")
        replaySubjectWithBuffer3.on(.completed)
        print("\nreplaySubjectWithBuffer3.on(.next(100))\n")
        replaySubjectWithBuffer3.on(.next(100))


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//MARK:  PublishSubject 

        print("\n AVPublishSubject \n")

        print("\n make publishSubject \n")

        let publishSubject: AVPublishSubject = AVPublishSubject<String>()

        print("\npublishSubject.on(.next(\"string1\"))")
        publishSubject.on(.next("string1"))
        print("\npublishSubject.on(.next(\"string2\"))\n")
        publishSubject.on(.next("string2"))

        print("\n will be subscribed 1 to publishSubject \n")

        publishSubject
        .subscribe {
            switch $0{
            case .next:
                print("\n The received signal: subscriber1 PublishSubject element = ",$0.element!)
            case .completed:
                print("\n The received signal: complited subscribe1 - ",$0)
            default:
                print("\n The received signal: default subscribe1 - ",$0)
            }
        }.disposed(by: self.disposableBag)

        print("\n already subscribed 1 to the publishSubject \n")

        print("\npublishSubject.on(.next(\"string3\"))")
        publishSubject.on(.next("string3"))
        print("\npublishSubject.on(.next(\"string4\"))\n")
        publishSubject.on(.next("string4"))

        let observable = publishSubject.asObservable() //adding asObservable() does not affect, since if it is not present, it is still called from subscribe()

        print("\n will be subscribed 2 to publishSubject \n")

        observable
        .subscribe {
            switch $0{
            case .next:
                print("\n The received signal: subscriber2 PublishSubject element = ",$0.element!)
            case .completed:
                print("\n The received signal: complited subscriibe2 - ",$0)
            default:
                print("\n The received signal: default subscriibe2 - ",$0)
            }
        }.disposed(by: self.disposableBag)

        print("\n already subscribed 2 to the publishSubject \n")

        print("\npublishSubject.on(.next(\"string5\"))")
        publishSubject.on(.next("string5"))
        print("\npublishSubject.on(.next(\"string6\"))")
        publishSubject.on(.next("string6"))
        print("\npublishSubject.on(.completed)")
        publishSubject.on(.completed)
        print("\npublishSubject.on(.next(\"string7\"))\n")
        publishSubject.on(.next("string7"))



//MARK:    implementation sabscrabeMay

        print("\n will be subscribed  to publishSubject with subscribeMy \n")
        
        publishSubject.subscribeMy{
            switch $0{
            case .next:
                print("\n The received signal: subscribeMy PublishSubject element = ",$0.element!)
            case .completed:
                print("\n The received signal: complited subscribeMy - ",$0)
            default:
                print("\n The received signal: default subscribeMy - ",$0)
            }
        }

        print("\n already subscribed  to publishSubject with subscribeMy \n")

        print("\npublishSubject.on(.next(\"string8\"))")
        publishSubject.on(.next("string8"))
        print("\npublishSubject.on(.next(\"string9\"))")
        publishSubject.on(.next("string9"))
        print("\npublishSubject.on(.completed)")
        publishSubject.on(.completed)
        print("\npublishSubject.on(.next(\"string10\"))\n")
        publishSubject.on(.next("string10"))


    }

}

