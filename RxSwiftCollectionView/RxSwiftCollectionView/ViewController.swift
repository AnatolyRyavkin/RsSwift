//
//  ViewController.swift
//  RxSwiftCollectionView
//
//  Created by Anatoly Ryavkin on 04.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct AnimatedSectionModel{
    var title: String
    var data: [String]
}
extension AnimatedSectionModel: AnimatableSectionModelType{
    typealias Item = String
    typealias Identity = String
    init(original: AnimatedSectionModel, items: [Item]) {
        self = original
        data = items
    }
    var identity: Identity {
        return title
    }
    var items: [Item] {
       return data
   }
}

class ViewController: UIViewController {

    @IBOutlet weak var addItem: UIBarButtonItem!
    @IBOutlet weak var addSection: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var longPressGR: UILongPressGestureRecognizer!

    var kind: String!

    var headerViewMove: Header?

    var data = BehaviorRelay.init(value: [AnimatedSectionModel.init(title: "Section - 0", data: ["0 - 0", "0 - 1"])])

    var dataSources: RxCollectionViewSectionedAnimatedDataSource <AnimatedSectionModel>!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        //"UICollectionElementKindSectionHeader" - kind (Header or Futter) !!!

        let dataSources: RxCollectionViewSectionedAnimatedDataSource <AnimatedSectionModel> = RxCollectionViewSectionedAnimatedDataSource<AnimatedSectionModel>(configureCell: { (dataSources, collectionView, indexPath, item) -> Cell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
            cell.titleLabel.text = item
            return cell
        }, configureSupplementaryView :{ (dataSources, collectionView, kind, indexPath) -> UICollectionReusableView  in
            print("kind = ",kind)
            self.kind = kind
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! Header
            header.titleLabel.text = dataSources.sectionModels[indexPath.section].identity
            return header
        },moveItem: { a, b, c in
            print("a = ",a.description)
            print("b = ",b.description)
            print("c = ",c)
        },canMoveItemAtIndexPath: { _, _ in true })

        self.dataSources = dataSources

        self.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)

        data.asDriver().drive(collectionView.rx.items(dataSource: self.dataSources)).disposed(by: self.disposeBag)

        self.addItem.rx.tap.asDriver().drive(onNext: { (_) in
            let countSection = self.data.value.count
            let countItem = self.data.value.last?.items.count
            var arrayItems = self.data.value.last?.items
            arrayItems?.append("\(countSection - 1) - \(countItem!)")
            var arraySection = self.data.value
            let lastSection = arraySection.last
            let newLastSection = AnimatedSectionModel.init(original: lastSection!, items: arrayItems!)
            arraySection.removeLast()
            arraySection.append(newLastSection)
            self.data.accept(arraySection)
        }).disposed(by: self.disposeBag)

        self.addSection.rx.tap.asDriver().drive(onNext: { (_) in
            let countSection = self.data.value.count
            var arraySection = self.data.value
            let newLastSection = AnimatedSectionModel.init(title: "Section - \(countSection)", data: ["\(countSection) - 0"])
            arraySection.append(newLastSection)
            self.data.accept(arraySection)
        }).disposed(by: self.disposeBag)

        self.longPressGR.rx.event.subscribe(onNext: { (event) in
            switch event.state{
            case .began:
                guard let selectedIndexPath = self.collectionView.indexPathForItem(at: event.location(in: self.collectionView))
                    else {
                        let arrayHeader = self.collectionView.visibleSupplementaryViews(ofKind: self.kind)
                        for view in arrayHeader{
                            if view.frame.contains(event.location(in: self.collectionView)){
                                if let headerView  = view as? Header{
                                    self.headerViewMove = headerView
                                    self.headerViewMove!.titleLabel!.text = self.headerViewMove!.titleLabel!.text! + " - Selected !!!"
                                    print("ok",headerView.titleLabel!.text!)
                                }
                            }
                        }
                        break
                    }
                print(self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath))
            case .changed:
                self.collectionView.updateInteractiveMovementTargetPosition(event.location(in: event.view!))
            case .ended:
                if let string: NSString = (self.headerViewMove?.titleLabel?.text!) as NSString?{
                    self.headerViewMove!.titleLabel!.text! = string.components(separatedBy: " - Selected !!!").first!
                }
                self.collectionView.endInteractiveMovement()
            case .cancelled:
                self.collectionView.cancelInteractiveMovement()
            case .failed:
                print("failed")
            case .possible:
                print("possible")
            @unknown default:
                self.collectionView.cancelInteractiveMovement()
            }
        }, onError: { (_) in
            print("Error")
        }, onCompleted: {
            print("completion")
        }) {
            print("disposed")
        }
        .disposed(by: self.disposeBag)

    }

}

extension ViewController: UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool{
        print("Work delegat") // Forvard Delegat!!!
        return true
    }

}

