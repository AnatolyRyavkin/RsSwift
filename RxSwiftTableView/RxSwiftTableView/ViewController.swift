//
//  ViewController.swift
//  RxSwiftTableView
//
//  Created by Anatoly Ryavkin on 01.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {  //}, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    var dispose: Disposable!

//    var behaviorSubject: BehaviorSubject<Observable<[Dragon]>> = BehaviorSubject(value: Observable<[Dragon]>.create { (observer) -> Disposable in
//        observer.onNext([
//            Dragon(name: "Dragon - 1", flickerID: "1"),
//            Dragon(name: "Dragon - 2", flickerID: "2"),
//            Dragon(name: "Dragon - 3", flickerID: "3"),
//            Dragon(name: "Dragon - 4", flickerID: "4")
//        ])
//        return Disposables.create()
//    })

    var behaviorSubject: BehaviorSubject<[Dragon]> = BehaviorSubject(value: [
            Dragon(name: "Dragon - 1", flickerID: "1"),
            Dragon(name: "Dragon - 2", flickerID: "2"),
            Dragon(name: "Dragon - 3", flickerID: "3"),
            Dragon(name: "Dragon - 4", flickerID: "4")
    ])

    var dragons: Observable<[Dragon]> = Observable.create { (observer) -> Disposable in
        observer.onNext([
            Dragon(name: "Dragon - 1", flickerID: "1"),
            Dragon(name: "Dragon - 2", flickerID: "2"),
            Dragon(name: "Dragon - 3", flickerID: "3"),
            Dragon(name: "Dragon - 4", flickerID: "4")
        ])
        return Disposables.create()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

//        behaviorSubject.bind(to: tableView.rx.items){row, dragon, cell in
//            cell.textLabel.text = dragon.name
//            cell.detailTextLabel.text = dragon.flickrID
//            cell.imageView.image = dragon.image
//        }.disposed(by: disposeBag)

        self.dispose = behaviorSubject.bind(to: tableView.rx.items(cellIdentifier: "cell")){row, dragon, cell in
            cell.textLabel!.text = dragon.name
            cell.detailTextLabel?.text = dragon.flickrID
            cell.imageView?.image = dragon.image
        }

        tableView.rx.cancelPrefetchingForRows.subscribe { event in
            print("event = ",event)
        }.disposed(by: disposeBag)

        tableView.rx.itemSelected.subscribe { (event) in
            print("event.element = ",event.element!)
        }.disposed(by: disposeBag)

        tableView.rx.backgroundColor.asObserver().onNext(UIColor.red.withAlphaComponent(0.3))

        tableView.rx.isUserInteractionEnabled.onNext(true)



        tableView.rx.itemDeleted.subscribe(onNext: { (_) in
            self.dispose.dispose()
            self.behaviorSubject = BehaviorSubject(value: [
                    Dragon(name: "Dragon - 1", flickerID: "1"),
                    Dragon(name: "Dragon - 2", flickerID: "2"),
                    Dragon(name: "Dragon - 3", flickerID: "3"),
                    //Dragon(name: "Dragon - 4", flickerID: "4")
            ])
//            self.behaviorSubject.onNext([
//                    Dragon(name: "Dragon - 1", flickerID: "1"),
//                    Dragon(name: "Dragon - 2", flickerID: "2"),
//                    Dragon(name: "Dragon - 3", flickerID: "3"),
//                    //Dragon(name: "Dragon - 4", flickerID: "4")
//            ])

            self.behaviorSubject.bind(to: self.tableView.rx.items(cellIdentifier: "cell")){row, dragon, cell in
                cell.textLabel!.text = dragon.name
                cell.detailTextLabel?.text = dragon.flickrID
                cell.imageView?.image = dragon.image
            }.disposed(by: self.disposeBag)

//            self.behaviorRelay.value.bind(to: self.tableView.rx.items(cellIdentifier: "cell")){row, dragon, cell in
//                cell.textLabel!.text = dragon.name
//                cell.detailTextLabel?.text = dragon.flickrID
//                cell.imageView?.image = dragon.image
//            }.disposed(by: self.disposeBag)

        })


    }

}

