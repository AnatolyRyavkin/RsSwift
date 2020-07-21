//
//  TableViewCell.swift
//  RxSwiftTableViewComplection
//
//  Created by Anatoly Ryavkin on 08.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Cell: UITableViewCell {

    var widthCell: CGFloat{
        self.bounds.width
    }
    var heightCell: CGFloat{
        self.bounds.height
    }
    var disposeBag = DisposeBag()
    var tableView: UITableView?
    var stringNameDragon = "stringNameDragon"
    static var count: Int = 0

    init(style: UITableViewCell.CellStyle? = .value1, reuseIdentifier: String? = "Cell", tableView: UITableView? = nil, sizeRow: CGFloat? = nil) {
        super.init(style: style!, reuseIdentifier: reuseIdentifier)

        if let tableViewOur = tableView{
            self.tableView = tableViewOur
            if let size = sizeRow{
                self.tableView!.rowHeight = size
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews(){
        super.layoutSubviews()

        let spaceForViewInCell = widthCell/40
        let height = heightCell - 2 * spaceForViewInCell
        let widthDetailTextLabel = heightCell
        let widthImageView = height
        let widthTextLabel = widthCell - (widthDetailTextLabel + widthImageView + 2 * spaceForViewInCell)

        self.imageView?.frame = CGRect.init(x: 0, y: spaceForViewInCell, width: widthImageView, height: height)
        self.textLabel?.frame = CGRect.init(x: widthImageView + spaceForViewInCell, y: spaceForViewInCell, width: widthTextLabel, height: height)
        self.detailTextLabel?.frame = CGRect.init(x: (self.textLabel?.frame.maxX)! + spaceForViewInCell, y: spaceForViewInCell,
                                                  width: widthDetailTextLabel, height: height)

        self.textLabel?.textAlignment = .center
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: height / 2)
        self.detailTextLabel?.textAlignment = .center

        self.imageView?.contentMode = .scaleToFill
        self.textLabel!.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        self.detailTextLabel!.backgroundColor = UIColor.blue.withAlphaComponent(0.175)

        let shadow = NSShadow.init()
        shadow.shadowBlurRadius = 0.5
        shadow.shadowOffset = CGSize.init(width: 10, height: 10)
        shadow.shadowColor = UIColor.blue.withAlphaComponent(0.3)

        let dictionaryAttributeString: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font : UIFont(name: "Chalkduster", size: heightCell/2.5)! ,
            NSAttributedString.Key.shadow : shadow,
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.strokeWidth : 6,
            NSAttributedString.Key.strokeColor : UIColor.red,
            ] as [NSAttributedString.Key : Any]

        let atributeText = NSMutableAttributedString.init(string: stringNameDragon, attributes: dictionaryAttributeString)
        let range = NSRange(location: 0, length: 1)
        let anotherAttribute = [ NSAttributedString.Key.backgroundColor: UIColor.yellow.withAlphaComponent(0.5) ]
        let range1 = NSRange(location: 2, length: 1)
        let anotherAttribute1 = [ NSAttributedString.Key.backgroundColor: UIColor.blue.withAlphaComponent(0.5) ]
        let range2 = NSRange(location: 4, length: 1)
        let anotherAttribute2 = [ NSAttributedString.Key.backgroundColor: UIColor.green.withAlphaComponent(0.5) ]
        atributeText.addAttributes(anotherAttribute, range: range)
        atributeText.addAttributes(anotherAttribute1, range: range1)
        atributeText.addAttributes(anotherAttribute2, range: range2)
        self.textLabel!.attributedText = atributeText
        self.backgroundColor = UIColor.yellow.withAlphaComponent(0.1)

//MARK: Zoom Image

        guard let imageView = self.imageView else{ return }
        guard let vc = self.findViewController() as? ViewController else{ return }
        let observer = imageView.rx.point
        if (observer != nil) {

            vc.gestureRecognizer.rx.point.asDriver(onErrorJustReturn: CGPoint.init(x: 0, y: 0)).drive(observer!).disposed(by: disposeBag)
        }

    }
}
