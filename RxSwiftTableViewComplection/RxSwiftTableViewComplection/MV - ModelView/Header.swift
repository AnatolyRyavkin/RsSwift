//
//  Header.swift
//  RxSwiftTableViewComplection
//
//  Created by Anatoly Ryavkin on 12.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Header: UITableViewHeaderFooterView {

    let disposeBag = DisposeBag()

    var tableView: UITableView!
    var section: Int!
    var dataSourceDragon: [ModelSectionDragons]!
    var data: BehaviorRelay<[ModelSectionDragons]>!
    var typeEditingTableDelete: Bool!

     required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(reuseIdentifier: String! = "Header",
        tableView: UITableView,
        section: Int,
        dataSourceDragon: [ModelSectionDragons],
        data: BehaviorRelay<[ModelSectionDragons]>,
        typeEditingTableDelete: Bool) {

        super.init(reuseIdentifier: reuseIdentifier)

        self.tableView = tableView
        self.section = section
        print("init section = ",section)
        self.dataSourceDragon = dataSourceDragon
        self.data = data
        self.typeEditingTableDelete = typeEditingTableDelete

    }

    open override func prepareForReuse(){
        let sec = self.section!
        print("section = ", self.section ?? 0 )
        print("sec = ", sec )
        if self.contentView.subviews.count == 0 {
            for view in self.contentView.subviews{
                view.superview?.removeFromSuperview()
            }
        }

        let buttonAddDragonAtBeginSection = UIButton.init(frame: CGRect.init(x: 180, y: 10, width: 150, height: 30))
        buttonAddDragonAtBeginSection.setTitle("+ New Dragon Up", for: .normal)
        buttonAddDragonAtBeginSection.setTitle("YES !!!", for: .highlighted)
        buttonAddDragonAtBeginSection.backgroundColor = UIColor.systemBlue
        self.contentView.addSubview(buttonAddDragonAtBeginSection)

        buttonAddDragonAtBeginSection.rx.tap.asDriver().drive(onNext: { (_) in
            print("section = ", self.section ?? 0 )
            print("sec = ", sec )
            var sectionDragons: ModelSectionDragons = self.dataSourceDragon.remove(at: self.section)
            var items = sectionDragons.arrayDragons
            let nameSection = sectionDragons.nameSection
            items.insert(Dragon.init("New Dragon"), at: 0)
            sectionDragons = ModelSectionDragons.init(arrayDragons: items, nameSection: nameSection)
            print("section = ", self.section ?? 0 )
            self.dataSourceDragon.insert(sectionDragons, at: self.section)
            self.data.accept(self.dataSourceDragon)
        }).disposed(by: disposeBag)

        let buttonAddDragonToChousRow = UIButton.init(frame: CGRect.init(x: 350, y: 10, width: 250, height: 30))
        buttonAddDragonToChousRow.setTitle("+ New Dragon To Couse Place", for: .normal)
        buttonAddDragonToChousRow.setTitle("Enable", for: .highlighted)
        buttonAddDragonToChousRow.setTitleColor(UIColor.green, for: .normal)
        buttonAddDragonToChousRow.backgroundColor = UIColor.yellow
        self.contentView.addSubview(buttonAddDragonToChousRow)
        buttonAddDragonToChousRow.rx.tap.asDriver().drive(onNext: { (_) in
            print("section = ", self.section ?? 0 )
            print("sec = ", sec )
            self.typeEditingTableDelete = false
            self.tableView.isEditing = !self.tableView.isEditing
        }).disposed(by: disposeBag)

        let buttonDeleteSection = UIButton.init(frame: CGRect.init(x: 620, y: 10, width: 50, height: 30))
        buttonDeleteSection.setTitle("X", for: .normal)
        buttonDeleteSection.setTitle("WAR", for: .highlighted)
        buttonDeleteSection.setTitleColor(UIColor.green, for: .normal)
        buttonDeleteSection.setTitleColor(UIColor.red, for: .highlighted)
        buttonDeleteSection.backgroundColor = UIColor.orange
        self.contentView.addSubview(buttonDeleteSection)
        buttonDeleteSection.rx.tap.asDriver().drive(onNext: { (_) in
            print("del section = ", self.section ?? 0 )
            print("del sec = ", sec )
            self.dataSourceDragon.remove(at: self.section)
            self.data.accept(self.dataSourceDragon)
        }).disposed(by: disposeBag)

        self.textLabel?.backgroundColor = UIColor.orange.withAlphaComponent(0.5)
        self.contentView.backgroundColor = UIColor.green.withAlphaComponent(0.2)

    }


//        if let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier){
//            header = head as! Header
//        }else{
//            header = UITableViewHeaderFooterView.init(reuseIdentifier: reuseIdentifier) as! Header
//        }


    //    override func layoutSubviews(){
    //        super.layoutSubviews()
    //
    //        if self.contentView.subviews.count == 0 {
    //            for view in self.contentView.subviews{
    //                view.superview?.removeFromSuperview()
    //            }
    //        }
    //
    //        let buttonAddDragonAtBeginSection = UIButton.init(frame: CGRect.init(x: 180, y: 10, width: 150, height: 30))
    //        buttonAddDragonAtBeginSection.setTitle("+ New Dragon Up", for: .normal)
    //        buttonAddDragonAtBeginSection.setTitle("YES !!!", for: .highlighted)
    //        buttonAddDragonAtBeginSection.backgroundColor = UIColor.systemBlue
    //        self.contentView.addSubview(buttonAddDragonAtBeginSection)
    //        buttonAddDragonAtBeginSection.rx.tap.asDriver().drive(onNext: { (_) in
    //            var sectionDragons: ModelSectionDragons = self.dataSourceDragon.remove(at: self.section)
    //            var items = sectionDragons.arrayDragons
    //            let nameSection = sectionDragons.nameSection
    //            items.insert(Dragon.init("New Dragon"), at: 0)
    //            sectionDragons = ModelSectionDragons.init(arrayDragons: items, nameSection: nameSection)
    //            self.dataSourceDragon.insert(sectionDragons, at: self.section)
    //            self.data.accept(self.dataSourceDragon)
    //        }).disposed(by: disposeBag)
    //
    //        let buttonAddDragonToChousRow = UIButton.init(frame: CGRect.init(x: 350, y: 10, width: 250, height: 30))
    //        buttonAddDragonToChousRow.setTitle("+ New Dragon To Couse Place", for: .normal)
    //        buttonAddDragonToChousRow.setTitle("Enable", for: .highlighted)
    //        buttonAddDragonToChousRow.setTitleColor(UIColor.green, for: .normal)
    //        buttonAddDragonToChousRow.backgroundColor = UIColor.yellow
    //        self.contentView.addSubview(buttonAddDragonToChousRow)
    //        buttonAddDragonToChousRow.rx.tap.asDriver().drive(onNext: { (_) in
    //            self.typeEditingTableDelete = false
    //            self.tableView.isEditing = !self.tableView.isEditing
    //        }).disposed(by: disposeBag)
    //
    //        let buttonDeleteSection = UIButton.init(frame: CGRect.init(x: 620, y: 10, width: 50, height: 30))
    //        buttonDeleteSection.setTitle("X", for: .normal)
    //        buttonDeleteSection.setTitle("WAR", for: .highlighted)
    //        buttonDeleteSection.setTitleColor(UIColor.green, for: .normal)
    //        buttonDeleteSection.setTitleColor(UIColor.red, for: .highlighted)
    //        buttonDeleteSection.backgroundColor = UIColor.orange
    //        self.contentView.addSubview(buttonDeleteSection)
    //        buttonDeleteSection.rx.tap.asDriver().drive(onNext: { (_) in
    //            self.dataSourceDragon.remove(at: self.section)
    //            self.data.accept(self.dataSourceDragon)
    //        }).disposed(by: disposeBag)
    //
    //        self.textLabel?.backgroundColor = UIColor.orange.withAlphaComponent(0.5)
    //        self.contentView.backgroundColor = UIColor.green.withAlphaComponent(0.2)
    //
    //    }


}


