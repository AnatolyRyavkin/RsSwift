//
//  ViewController.swift
//  RxSwiftTableViewComplection
//
//  Created by Anatoly Ryavkin on 07.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController, UITableViewDelegate {

    var tableView: UITableView!
    var nc: UINavigationController?
    var addDragonBarButton: UIBarButtonItem!
    var stopEditingBarButton: UIBarButtonItem!
    var gestureRecognizer: UILongPressGestureRecognizer!
    var modelTableViewDragons: ModelTableViewDragons!
    var dataSourceDragonClass: DataSourceDragon = DataSourceDragon.SharedDataSourceDragon
    var typeIsRandom: Bool!
    var dataSourceDragon: [ModelSectionDragons]!
    var dataSourceDragon1: [ModelSectionDragons]{
        return (typeIsRandom) ? dataSourceDragonClass.random : dataSourceDragonClass.plain
    }
    var data: BehaviorRelay<[ModelSectionDragons]>!
    let disposeBag = DisposeBag()
    var typeEditingTableDelete: Bool = true
    var firstLoad = true
    
//MARK: configuration Table And View

    func configuratingTableView(){
        self.view.backgroundColor = .white
        self.gestureRecognizer = UILongPressGestureRecognizer.init()
        self.view.addGestureRecognizer(self.gestureRecognizer)
        self.tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorEffect = UIVisualEffect()
        self.tableView.backgroundColor = .white
        self.tableView.sectionHeaderHeight = 50
        self.tableView.backgroundView?.backgroundColor = UIColor.red
        self.tableView.allowsSelectionDuringEditing = true
        self.view.addSubview(self.tableView)
        self.navigationItem.title = "DRAGONS - " + self.dataSourceDragonClass.typeDataSource.message
        self.navigationController?.navigationBar.barTintColor = UIColor.cyan.withAlphaComponent(0.01)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: self, action: nil)
        self.addDragonBarButton = self.navigationItem.rightBarButtonItem
        self.stopEditingBarButton = self.navigationItem.leftBarButtonItem

        self.addDragonBarButton.rx.tap.asDriver().drive(onNext: { _ in
            self.dataSourceDragonClass.appendSectionToDataSourceDragon()
                //.insert(ModelSectionDragons.init(arrayDragons: [], nameSection: "Section - NEW "), at: 0)
            self.data.accept(self.dataSourceDragon1)
        }).disposed(by: self.disposeBag)

        self.stopEditingBarButton.rx.tap.subscribe{ _ in
            self.tableView.isEditing = false
        }.disposed(by: self.disposeBag)

        self.tableView.delegate = self

        //       OperationQueue.main.addOperation {
        //          self.tableView.rx.setDelegate(self).disposed(by: self.disposeBag)
        //       }
    }

    @objc func gestureRecognizerForImage(){
        print("someMetod")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.tableView.frame = CGRect.init(origin: CGPoint.zero, size: size)
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//MARK clip dataSource
        self.typeIsRandom = false
        self.dataSourceDragon = {
            return (typeIsRandom) ? dataSourceDragonClass.random : dataSourceDragonClass.plain
        }()
        self.modelTableViewDragons = ModelTableViewDragons.SharedModelTableViewDragons
        self.data = BehaviorRelay(value: self.dataSourceDragon1)
        self.configuratingTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        if !self.firstLoad{
            return
        }
        self.firstLoad = false
        self.data.asDriver().drive(self.tableView.rx.items(dataSource: self.modelTableViewDragons)).disposed(by: self.disposeBag)

//MARK: redaction table

// row selected and deleting and addition

        self.tableView.rx.itemSelected.bind { (indexPath) in
            self.typeEditingTableDelete = true
            OperationQueue.main.addOperation {
                self.tableView.isEditing = !self.tableView.isEditing
            }
        }.disposed(by: self.disposeBag)


        self.tableView.rx.itemMoved.bind(onNext: { (sourceIndex: IndexPath, destinationIndex: IndexPath) -> Void in
            self.dataSourceDragonClass.moveDragonOnIndexPath(from: sourceIndex, to: destinationIndex)
            self.data.accept(self.dataSourceDragon1)
        }).disposed(by: disposeBag)


        self.tableView.rx.itemDeleted.bind { (indexPath) in
            _ = self.dataSourceDragonClass.removeDragonOnIndexPath(on: indexPath)
            self.data.accept(self.dataSourceDragon1)
            OperationQueue.main.addOperation {
                self.tableView.isEditing = false
            }
        }.disposed(by: self.disposeBag)



        tableView.rx.itemInserted.bind { (indexPath) in
            OperationQueue.main.addOperation {
                self.tableView.isEditing = false
            }
            self.dataSourceDragonClass.insertDragonOnIndexPath(on: indexPath, dragon: nil)
            self.data.accept(self.dataSourceDragon1)
        }.disposed(by: disposeBag)
    }

//MARK: metods at delegate

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header: UITableViewHeaderFooterView

        if let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header"){
            header = head
        }else{
            header = UITableViewHeaderFooterView.init(reuseIdentifier: "Header")
        }

        if header.contentView.subviews.count == 0 {
            for view in header.contentView.subviews{
                view.superview?.removeFromSuperview()
            }
        }

        let buttonAddDragonAtBeginSection = UIButton.init(frame: CGRect.init(x: 180, y: 10, width: 150, height: 30))
        buttonAddDragonAtBeginSection.setTitle("+ New Dragon Up", for: .normal)
        buttonAddDragonAtBeginSection.setTitle("YES !!!", for: .highlighted)
        buttonAddDragonAtBeginSection.backgroundColor = UIColor.systemBlue
        header.contentView.addSubview(buttonAddDragonAtBeginSection)
        buttonAddDragonAtBeginSection.rx.tap.asDriver().drive(onNext: { (_) in
            self.dataSourceDragonClass.insertDragonOnIndexPath(on: IndexPath.init(item: 0, section: section), dragon: Dragon.init("New Dragon"))
            self.data.accept(self.dataSourceDragon1)
        }).disposed(by: disposeBag)

        let buttonAddDragonToChousRow = UIButton.init(frame: CGRect.init(x: 350, y: 10, width: 250, height: 30))
        buttonAddDragonToChousRow.setTitle("+ New Dragon To Couse Place", for: .normal)
        buttonAddDragonToChousRow.setTitle("Enable", for: .highlighted)
        buttonAddDragonToChousRow.setTitleColor(UIColor.green, for: .normal)
        buttonAddDragonToChousRow.backgroundColor = UIColor.yellow
        header.contentView.addSubview(buttonAddDragonToChousRow)
        buttonAddDragonToChousRow.rx.tap.asDriver().drive(onNext: { (_) in
            self.typeEditingTableDelete = false
            self.tableView.isEditing = !self.tableView.isEditing
        }).disposed(by: disposeBag)

        let buttonDeleteSection = UIButton.init(frame: CGRect.init(x: 620, y: 10, width: 50, height: 30))
        buttonDeleteSection.setTitle("X", for: .normal)
        buttonDeleteSection.setTitle("WAR", for: .highlighted)
        buttonDeleteSection.setTitleColor(UIColor.green, for: .normal)
        buttonDeleteSection.setTitleColor(UIColor.red, for: .highlighted)
        buttonDeleteSection.backgroundColor = UIColor.orange
        header.contentView.addSubview(buttonDeleteSection)
        buttonDeleteSection.rx.tap.asDriver().drive(onNext: { (_) in
            self.dataSourceDragonClass.removeSectionToDataSourceDragon(on: section
            )
            self.data.accept(self.dataSourceDragon1)
        }).disposed(by: disposeBag)

        header.textLabel?.backgroundColor = UIColor.orange.withAlphaComponent(0.5)
        header.contentView.backgroundColor = UIColor.green.withAlphaComponent(0.2)

        return header
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle{
        return (self.typeEditingTableDelete) ? .delete : .insert
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool{
        true
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool{
        true
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool{
        return false
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 50
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "Dragon Del"
    }





    

    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let header: Header
    //        if let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header"){
    //            header = head as! Header
    //            header.tableView = tableView
    //            header.section = section
    //            header.dataSourceDragon = dataSourceDragon
    //            header.data = data
    //            header.typeEditingTableDelete = typeEditingTableDelete
    //
    //        }else{
    //            header = Header.init(reuseIdentifier: "Header", tableView: tableView, section: section, dataSourceDragon: self.dataSourceDragon, data: self.data, typeEditingTableDelete: self.typeEditingTableDelete)
    //        }
    //        return header
    //    }

}

