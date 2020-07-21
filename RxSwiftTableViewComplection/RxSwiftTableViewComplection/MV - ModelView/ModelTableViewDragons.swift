//
//  ModelView.swift
//  RxSwiftTableViewComplection
//
//  Created by Anatoly Ryavkin on 07.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class ModelTableViewDragons: RxTableViewSectionedReloadDataSource<ModelSectionDragons>{


    static let SharedModelTableViewDragons: ModelTableViewDragons = {

        let configureCellDragon: ModelTableViewDragons.ConfigureCell = { dataSources, tableView, indexPath, item -> UITableViewCell in
            var cell: Cell? = tableView.dequeueReusableCell(withIdentifier: "Cell") as? Cell
            if cell == nil{
                cell = Cell.init(style: .value1, reuseIdentifier: "Cell", tableView: tableView, sizeRow: 150)
            }

            tableView.rowHeight = ((indexPath.row % Int(arc4random_uniform(2) + 1)) != 0) ? 200 : 200

            cell!.detailTextLabel!.text = dataSources.sectionModels[indexPath.section].arrayDragons[indexPath.row].flickerID

            cell!.imageView!.image = UIImage.init(named: dataSources.sectionModels[indexPath.section].arrayDragons[indexPath.row].flickerID)

            cell!.stringNameDragon = "\(indexPath.section) - \(indexPath.row)"
            //dataSources.sectionModels[indexPath.section].arrayNameDragons[indexPath.row]
            
            return cell!
        }

        let configureHeaderSection: ModelTableViewDragons.TitleForHeaderInSection = { (dataSourse, numberSection) -> String? in
            return "Grup Dragons - " + String(numberSection) //dataSourse[numberSection].identity
        }

        let sectionForSectionIndexTitle: ModelTableViewDragons.SectionForSectionIndexTitle = { (dataSource, string, num) -> Int in
            //print("string = \(string) num = \(num)")
            return 3
        }

        let mod = ModelTableViewDragons.init(configureCell: configureCellDragon,
                                        titleForHeaderInSection: configureHeaderSection,
                                        canEditRowAtIndexPath: { (dataSourse, indexPath) -> Bool in
                                            true
                                        },
                                        canMoveRowAtIndexPath: { (dataSourse, indexPath) -> Bool in true },
                                        sectionIndexTitles: { dataSourse in ["0","1","2","3"] },
                                        sectionForSectionIndexTitle: sectionForSectionIndexTitle)

        return mod
    }()


}

