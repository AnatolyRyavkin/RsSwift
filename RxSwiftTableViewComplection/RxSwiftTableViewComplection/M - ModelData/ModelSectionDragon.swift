//
//  DataSources.swift
//  RxSwiftTableViewComplection
//
//  Created by Anatoly Ryavkin on 07.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa


struct Dragon {
    var name: String
    var flickerID: String = String(Int(arc4random_uniform(35)) + 1)
    var image: UIImage?{
        return UIImage.init(named: flickerID)
    }

    init( _ name: String) {
        self.name = name
    }

    mutating func changeImageDragon(){
        self.flickerID = String(Int(arc4random_uniform(35)) + 1)
    }

}

struct ModelSectionDragons {
    var arrayDragons: [Dragon]
    var nameSection: String
    var arrayNameDragons: [String] = []
    init( arrayDragons: [Dragon], nameSection: String) {
        self.arrayDragons = arrayDragons
        self.nameSection = nameSection
        self = ModelSectionDragons.init(original: self)
    }
    private init(original: ModelSectionDragons) {
        self = original
        for dragon in self.arrayDragons{
            self.arrayNameDragons.append(dragon.name)
        }
    }
}

extension ModelSectionDragons: AnimatableSectionModelType{
    typealias Item = String
    typealias Identity = String
    public var items: [Item] {
        return arrayNameDragons
    }
    init(original: ModelSectionDragons, items: [Item]) {
        self = original
        arrayNameDragons = items
        // check count Dragons with count NameDragons !!!
    }
    var identity: Identity {
        return nameSection
    }

    mutating func removeDragonFromSectionAtNumber(number: Int) -> (Dragon?){
        if number >= self.arrayNameDragons.count{
            return (nil)
        }
        let dragon = self.arrayDragons.remove(at: number)
        self.arrayNameDragons.remove(at: number)
        return dragon
    }

    mutating func insertDragonFromSectionAtNumber(number: Int, dragon: Dragon?){
        if number >= self.arrayNameDragons.count && number != 0{
            return
        }
        let newNameDragon = (dragon == nil) ? "New Dragon" : dragon!.name
        let newDragon = (dragon == nil) ? Dragon.init(newNameDragon) : dragon!
        self.arrayNameDragons.insert(newNameDragon, at: number) 
        self.arrayDragons.insert(newDragon, at: number)

    }

    mutating func moveDragonsInBoundsSection(from beginIndex: Int, to endIndex: Int){
        let dragon = self.removeDragonFromSectionAtNumber(number: beginIndex)
        self.insertDragonFromSectionAtNumber(number: endIndex, dragon: dragon)
    }

    mutating func renameSection(newNameSection: String){
        self.nameSection = newNameSection
    }
}

