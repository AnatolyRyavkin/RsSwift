//
//  DataSourseDragon1.swift
//  RxSwiftTableViewComplection
//
//  Created by Anatoly Ryavkin on 07.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation

class DataSourceDragon{

    enum TypeDataSourceEnum {
        case plain
        case random

        var message: String{
            var mes: String
            switch self {
            case .plain : mes = "plain"
            case .random : mes = "random"
            }
            return mes
        }
    }

    var dataIsRandom: Bool{
        return typeDataSource == TypeDataSourceEnum.random
    }

    var numberNewSection: (random: Int, plain: Int) = (1,1)

    public var typeDataSource: TypeDataSourceEnum!

    public var random: [ModelSectionDragons]{
        return self.randomIn
    }

    public var plain: [ModelSectionDragons]{
        return self.plainIn
    }

    public static let SharedDataSourceDragon = DataSourceDragon()

    private lazy var randomIn: [ModelSectionDragons] = {
        self.typeDataSource = .random
        var dataDragons: [ModelSectionDragons] = []
        var countSection = Int(arc4random_uniform(20))
        for i in 0 ... countSection{
            var countDragonsAtSection = Int(arc4random_uniform(36))
            var arrayDragons: [Dragon] = []
            for j in 0 ... countDragonsAtSection{
                var dragon = Dragon.init("\(i) - \(j) Dragon")
                arrayDragons.append(dragon)
            }
            dataDragons.append(ModelSectionDragons.init(arrayDragons: arrayDragons, nameSection: "Section - \(i)"))
        }

        return dataDragons
    }()

    private lazy var plainIn: [ModelSectionDragons] =
    {
        self.typeDataSource = .plain
        return [
        ModelSectionDragons.init(arrayDragons: [Dragon.init("0 - 1"), Dragon.init("0 - 2")], nameSection: "First Section"),
        ModelSectionDragons.init(arrayDragons: [Dragon.init("1 - 1"), Dragon.init("1 - 2")], nameSection: "Second Section"),
        ModelSectionDragons.init(arrayDragons: [Dragon.init("2 - 1"), Dragon.init("2 - 2")], nameSection: "Third Section"),
        ModelSectionDragons.init(arrayDragons: [Dragon.init("3 - 1"), Dragon.init("3 - 2")], nameSection: "Fourth Section"),
        ModelSectionDragons.init(arrayDragons: [Dragon.init("4 - 1"), Dragon.init("4 - 2")], nameSection: "Fifth Section"),
        ModelSectionDragons.init(arrayDragons: [Dragon.init("5 - 1"), Dragon.init("5 - 2")], nameSection: "Sixth Section"),
        ModelSectionDragons.init(arrayDragons: [Dragon.init("6 - 1"), Dragon.init("6 - 2")], nameSection: "Seventh Second"),
        ModelSectionDragons.init(arrayDragons: [Dragon.init("7 - 1"), Dragon.init("7 - 2")], nameSection: "Eighth Second"),
    ]}()
    
    private init(){

    }

    public func appendSectionToDataSourceDragon() {
        var arraySectionDragon = (dataIsRandom) ? self.randomIn : self.plainIn
        arraySectionDragon.insert(ModelSectionDragons.init(arrayDragons: [],
        nameSection: "Section - \((dataIsRandom) ? numberNewSection.random : numberNewSection.plain) "), at: 0) 
        numberNewSection = (dataIsRandom) ? (numberNewSection.random + 1, numberNewSection.plain)  : (numberNewSection.random, numberNewSection.plain + 1)
        if dataIsRandom{
            self.randomIn = arraySectionDragon}
        else{
            self.plainIn = arraySectionDragon }
    }

    public func removeSectionToDataSourceDragon(on section: Int) {
        var arraySectionDragon = (dataIsRandom) ? self.randomIn : self.plainIn
        arraySectionDragon.remove(at: section)
        if dataIsRandom{
            self.randomIn = arraySectionDragon}
        else{
            self.plainIn = arraySectionDragon }
    }

    public func removeDragonOnIndexPath(on indexPath: IndexPath) -> (Dragon?){
        var arraySectionDragon = (dataIsRandom) ? self.randomIn : self.plainIn
        var section = (indexPath.section < arraySectionDragon.count) ?
            arraySectionDragon.remove(at: indexPath.section) : nil
        let dragon = section?.removeDragonFromSectionAtNumber(number: indexPath.row)
        if let sec = section{
            arraySectionDragon.insert(sec, at: indexPath.section)
        }
        if dataIsRandom{ self.randomIn = arraySectionDragon}
        else{ self.plainIn = arraySectionDragon }
        return dragon
    }

    public func insertDragonOnIndexPath(on indexPath: IndexPath, dragon: Dragon?){
        var arraySectionDragon = (dataIsRandom) ? self.randomIn : self.plainIn
        var section = (indexPath.section < arraySectionDragon.count) ?
            arraySectionDragon.remove(at: indexPath.section) :
            nil
        section?.insertDragonFromSectionAtNumber(number: indexPath.row, dragon: dragon)
        if let sec = section{
            arraySectionDragon.insert(sec, at: indexPath.section)
        }
        if dataIsRandom{ self.randomIn = arraySectionDragon}
        else{ self.plainIn = arraySectionDragon }
    }

    public func moveDragonOnIndexPath(from beginIndexPath: IndexPath, to endIndexPath: IndexPath){
        let dragon = self.removeDragonOnIndexPath(on: beginIndexPath)
        self.insertDragonOnIndexPath(on: endIndexPath, dragon: dragon)
    }

}


