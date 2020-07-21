//
//  TableViewWithEditingCommandsViewController.swift
//  RxExample
//
//  Created by carlos on 26/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

/**
Another way to do "MVVM". There are different ideas what does MVVM mean depending on your background.
 It's kind of similar like FRP.

 In the end, it doesn't really matter what jargon are you using.

 This would be the ideal case, but it's really hard to model complex views this way
 because it's not possible to observe partial model changes.
*/
struct TableViewEditingCommandsViewModel {
    let favoriteUsers: [User]
    let users: [User]

    static func executeCommand(state: TableViewEditingCommandsViewModel, _ command: TableViewEditingCommand) -> TableViewEditingCommandsViewModel {
        switch command {
        case let .setUsers(users):
            return TableViewEditingCommandsViewModel(favoriteUsers: state.favoriteUsers, users: users)
        case let .setFavoriteUsers(favoriteUsers):
            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: state.users)
        case let .deleteUser(indexPath):
            var all = [state.favoriteUsers, state.users]
            all[indexPath.section].remove(at: indexPath.row)
            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
        case let .moveUser(from, to):
            var all = [state.favoriteUsers, state.users]
            let user = all[from.section][from.row]
            all[from.section].remove(at: from.row)
            all[to.section].insert(user, at: to.row)

            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
        }
    }
}

enum TableViewEditingCommand {
    case setUsers(users: [User])
    case setFavoriteUsers(favoriteUsers: [User])
    case deleteUser(indexPath: IndexPath)
    case moveUser(from: IndexPath, to: IndexPath)
}

class TableViewWithEditingCommandsViewController: ViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    let dataSource = TableViewWithEditingCommandsViewController.configureDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        typealias Feedback = (ObservableSchedulerContext<TableViewEditingCommandsViewModel>) -> Observable<TableViewEditingCommand>

        self.navigationItem.rightBarButtonItem = self.editButtonItem

        let superMan =  User(
            firstName: "Super",
            lastName: "Man",
            imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg"
        )

        let watMan = User(firstName: "Wat",
            lastName: "Man",
            imageURL: "http://www.iri.upc.edu/files/project/98/main.GIF"
        )

        let loadFavoriteUsers = RandomUserAPI.sharedAPI
            .getExampleUserResultSet()
            .map(TableViewEditingCommand.setUsers)
            .catchErrorJustReturn(TableViewEditingCommand.setUsers(users: []))

        let initialLoadCommand = Observable.just(TableViewEditingCommand.setFavoriteUsers(favoriteUsers: [superMan, watMan]))
                .concat(loadFavoriteUsers)
                .observeOn(MainScheduler.instance)

        let uiFeedback: Feedback = bind(self) { this, state in
            let subscriptions = [
                state.map {
                        [
                            SectionModel(model: "Favorite Users", items: $0.favoriteUsers),
                            SectionModel(model: "Normal Users", items: $0.users)
                        ]
                    }
                    .bind(to: this.tableView.rx.items(dataSource: this.dataSource)),
                this.tableView.rx.itemSelected
                    .withLatestFrom(state) { i, latestState in
                        let all = [latestState.favoriteUsers, latestState.users]
                        return all[i.section][i.row]
                    }
                    .subscribe(onNext: { [weak this] user in
                        this?.showDetailsForUser(user)
                    }),
            ]

            let events: [Observable<TableViewEditingCommand>] = [

                this.tableView.rx.itemDeleted.map(TableViewEditingCommand.deleteUser),
                this.tableView .rx.itemMoved.map({ val in return TableViewEditingCommand.moveUser(from: val.0, to: val.1) })
            ]

            return Bindings(subscriptions: subscriptions, events: events)
        }

        let initialLoadFeedback: Feedback = { _ in initialLoadCommand }

        Observable.system(
            initialState: TableViewEditingCommandsViewModel(favoriteUsers: [], users: []),
            reduce: TableViewEditingCommandsViewModel.executeCommand,
            scheduler: MainScheduler.instance,
            scheduledFeedback: uiFeedback, initialLoadFeedback
        )
            .subscribe()
            .disposed(by: self.disposeBag)

        // customization using delegate
        // RxTableViewDelegateBridge will forward correct messages
        tableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }

    // MARK: Table view delegate ;)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = dataSource[section]

        let label = UILabel(frame: CGRect.zero)
        // hacky I know :)
        label.text = "  \(title)"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.darkGray
        label.alpha = 0.9

        return label
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // MARK: Navigation
    private func showDetailsForUser(_ user: User) {
        let storyboard = UIStoryboard(name: "TableViewWithEditingCommands", bundle: Bundle(identifier: "RxExample-iOS"))
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.user = user
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: Work over Variable
    static func configureDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, User>> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>(
            configureCell: { (_, tv, ip, user: User) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = user.firstName + " " + user.lastName
                return cell
            },
            titleForHeaderInSection: { dataSource, sectionIndex in
                return dataSource[sectionIndex].model
            },
            canEditRowAtIndexPath: { (ds, ip) in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )

        return dataSource
    }

}





//
//
//
//
//
//
//
////
////  TableViewWithEditingCommandsViewController.swift
////  RxExample
////
////  Created by carlos on 26/5/15.
////  Copyright © 2015 Krunoslav Zaher. All rights reserved.
////
//import UIKit
//import Foundation
//import RxDataSources
//import RxSwift
//import RxCocoa
//
//
////extension Reactive where Base == TableViewWithEditingCommandsViewController{
////    var bindSelf: Binder<Observable<TableViewEditingCommandsViewModel>>{
////        return Binder(self.base, binding: ({ (this, state) -> Void in
////         let subscriptions = [
////             state.map{
////                     [SectionModel(model: "Favorite Users", items: $0.favoriteUsers), SectionModel(model: "Normal Users", items: $0.users)]
////             }
////             .bind(to: this.tableView.rx.items(dataSource: this.dataSource)) ,
////
////             this.tableView.rx.itemSelected
////             .withLatestFrom(state) { i, latestState in
////                let all = [latestState.favoriteUsers, latestState.users]
////                return all[i.section][i.row]
////            }
////            .subscribe(onNext: { [weak this] user in
////                this?.showDetailsForUser(user)
////            }),
////         ]
////
////         let events: [Observable<TableViewEditingCommand>] = [
////             this.tableView.rx.itemDeleted.map(TableViewEditingCommand.deleteUser),
////             this.tableView .rx.itemMoved.map({ val in return TableViewEditingCommand.moveUser(from: val.0, to: val.1) })
////        ]
////        }))
////    }
////}
//
//protocol Wireframe {
//    func open(url: URL)
//    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
//}
//
///**
//Another way to do "MVVM". There are different ideas what does MVVM mean depending on your background.
// It's kind of similar like FRP.
//
// In the end, it doesn't really matter what jargon are you using.
//
// This would be the ideal case, but it's really hard to model complex views this way
// because it's not possible to observe partial model changes.
//*/
//struct TableViewEditingCommandsViewModel {
//    let favoriteUsers: [User]
//    let users: [User]
//
//    static func executeCommand(state: TableViewEditingCommandsViewModel, _ command: TableViewEditingCommand) -> TableViewEditingCommandsViewModel {
//        switch command {
//        case let .setUsers(users):
//            return TableViewEditingCommandsViewModel(favoriteUsers: state.favoriteUsers, users: users)
//        case let .setFavoriteUsers(favoriteUsers):
//            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: state.users)
//        case let .deleteUser(indexPath):
//            var all = [state.favoriteUsers, state.users]
//            all[indexPath.section].remove(at: indexPath.row)
//            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
//        case let .moveUser(from, to):
//            var all = [state.favoriteUsers, state.users]
//            let user = all[from.section][from.row]
//            all[from.section].remove(at: from.row)
//            all[to.section].insert(user, at: to.row)
//
//            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
//        }
//    }
//}
//
//enum TableViewEditingCommand {
//    case setUsers(users: [User])
//    case setFavoriteUsers(favoriteUsers: [User])
//    case deleteUser(indexPath: IndexPath)
//    case moveUser(from: IndexPath, to: IndexPath)
//}
//
//
//class TableViewWithEditingCommandsViewController: ViewController, UITableViewDelegate {
//
//    @IBOutlet weak var tableView: UITableView!
//    let disposeBag = DisposeBag()
//
//    let dataSource = TableViewWithEditingCommandsViewController.configureDataSource()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.navigationItem.rightBarButtonItem = self.editButtonItem
//
//        let superMan =  User(
//            firstName: "Super",
//            lastName: "Man",
//            imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg"
//        )
//
//        let watMan = User(firstName: "Wat",
//            lastName: "Man",
//            imageURL: "http://www.iri.upc.edu/files/project/98/main.GIF"
//        )
//
//        let loadFavoriteUsers = RandomUserAPI.sharedAPI
//            .getExampleUserResultSet()
//            .map(TableViewEditingCommand.setUsers)
//            .catchErrorJustReturn(TableViewEditingCommand.setUsers(users: []))
//
//        let initialLoadCommand: Observable<TableViewEditingCommand> = Observable.just(TableViewEditingCommand.setFavoriteUsers(favoriteUsers: [superMan, watMan]))
//                .concat(loadFavoriteUsers)
//                .observeOn(MainScheduler.instance)
//
//        let state = initialLoadCommand
//
//        var point: Binder<CGPoint?>{
//            return Binder(self, binding: ( { (label, point) -> Void in
//                print("lable.text = ", point!)
//            }))
//        }
//
//        typealias Feedback = (Observable<TableViewEditingCommandsViewModel>) -> Observable<TableViewEditingCommand>
//
//        let uiFeedback: Feedback = {
//            var subscriptionsOut: [Disposable]
//            var eventsOut: [Observable<TableViewEditingCommand>]
//            Binder<Observable<TableViewEditingCommandsViewModel>>(self, binding: ({ this, state in
//                let subscriptions = [
//                    state.map{
//                        [SectionModel(model: "Favorite Users", items: $0.favoriteUsers), SectionModel(model: "Normal Users", items: $0.users)]
//                    }
//                    .bind(to: this.tableView.rx.items(dataSource: this.dataSource)) ,
//
//                    this.tableView.rx.itemSelected
//                        .withLatestFrom(state) { indexPath, latestState in
//                            let all = [latestState.favoriteUsers, latestState.users]
//                            return all[indexPath.section][indexPath.row]
//                    }
//                    .subscribe(onNext: { [weak this] user in
//                        this?.showDetailsForUser(user)
//                    })
//                ]
//                subscriptionsOut = subscriptions
//                let events: [Observable<TableViewEditingCommand>] = [
//                    this.tableView.rx.itemDeleted.map(TableViewEditingCommand.deleteUser),
//                    this.tableView .rx.itemMoved.map({ val in return TableViewEditingCommand.moveUser(from: val.0, to: val.1) })
//                ]
//                eventsOut = events
//            }))
//
//            return {  (observable: Observable<TableViewEditingCommandsViewModel>) -> Observable<TableViewEditingCommand> in
//                eventsOut[0].subscribe(subscriptionsOut[0] as! (Event<TableViewEditingCommand>) -> Void).disposed(by: self.disposeBag)
//                return initialLoadCommand
//            }
//        }()
//
//
//
//        let initialLoadFeedback: Feedback = { _ in initialLoadCommand }
//
////        public static func generate(initialState: Element, condition: @escaping (Element) throws -> Bool, scheduler: ImmediateSchedulerType = CurrentThreadScheduler.instance, iterate: @escaping (Element) throws -> Element) -> Observable<Element> {
////            return Generate(initialState: initialState, condition: condition, iterate: iterate, resultSelector: { $0 }, scheduler: scheduler)
////        }
//
//        Observable.generate(
//            initialState: TableViewEditingCommandsViewModel(favoriteUsers: [], users: []), condition: <#(Self.Element) throws -> Bool#>,
//            //reduce: TableViewEditingCommandsViewModel.executeCommand,
//            scheduler: MainScheduler.instance,
//            //.scheduledFeedback: uiFeedback, initialLoadFeedback
//        )
//            .subscribe()
//            .disposed(by: disposeBag)
//
//        // customization using delegate
//        // RxTableViewDelegateBridge will forward correct messages
//        tableView.rx.setDelegate(self)
//            .disposed(by: disposeBag)
//    }
//
//    override func setEditing(_ editing: Bool, animated: Bool) {
//        super.setEditing(editing, animated: animated)
//        tableView.isEditing = editing
//    }
//
//    // MARK: Table view delegate ;)
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let title = dataSource[section]
//
//        let label = UILabel(frame: CGRect.zero)
//        // hacky I know :)
//        label.text = "  \(title)"
//        label.textColor = UIColor.white
//        label.backgroundColor = UIColor.darkGray
//        label.alpha = 0.9
//
//        return label
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40
//    }
//
//    // MARK: Navigation
//    private func showDetailsForUser(_ user: User) {
//        let storyboard = UIStoryboard(name: "TableViewWithEditingCommands", bundle: Bundle(identifier: "RxExample-iOS"))
//        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
//        viewController.user = user
//        self.navigationController?.pushViewController(viewController, animated: true)
//    }
//
//    // MARK: Work over Variable
//    static func configureDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, User>> {
//        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>(
//            configureCell: { (_, tv, ip, user: User) in
//                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
//                cell.textLabel?.text = user.firstName + " " + user.lastName
//                return cell
//            },
//            titleForHeaderInSection: { dataSource, sectionIndex in
//                return dataSource[sectionIndex].model
//            },
//            canEditRowAtIndexPath: { (ds, ip) in
//                return true
//            },
//            canMoveRowAtIndexPath: { _, _ in
//                return true
//            }
//        )
//
//        return dataSource
//    }
//
//}
//
//
////class TableViewWithEditingCommandsViewController: ViewController, UITableViewDelegate {
////
////    @IBOutlet weak var tableView: UITableView!
////    let disposeBag = DisposeBag()
////
////    let dataSource = TableViewWithEditingCommandsViewController.configureDataSource()
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        //typealias Feedback = (ObservableSchedulerContext<TableViewEditingCommandsViewModel>) -> Observable<TableViewEditingCommand>
////
////        typealias Feedback = (ObservableSchedulerContext<TableViewEditingCommandsViewModel>) -> Observable<TableViewEditingCommand>
////
////        self.navigationItem.rightBarButtonItem = self.editButtonItem
////
////        let superMan =  User(
////            firstName: "Super",
////            lastName: "Man",
////            imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg"
////        )
////
////        let watMan = User(firstName: "Wat",
////            lastName: "Man",
////            imageURL: "http://www.iri.upc.edu/files/project/98/main.GIF"
////        )
////
////        let loadFavoriteUsers = RandomUserAPI.sharedAPI
////            .getExampleUserResultSet()
////            .map(TableViewEditingCommand.setUsers)
////            .catchErrorJustReturn(TableViewEditingCommand.setUsers(users: []))
////
////        let initialLoadCommand = Observable.just(TableViewEditingCommand.setFavoriteUsers(favoriteUsers: [superMan, watMan]))
////                .concat(loadFavoriteUsers)
////                .observeOn(MainScheduler.instance)
////
////
////        let uiFeedback: Feedback = bind(self) { this, state in
////            let subscriptions = [
////                state.map {
////                        [
////                            SectionModel(model: "Favorite Users", items: $0.favoriteUsers),
////                            SectionModel(model: "Normal Users", items: $0.users)
////                        ]
////                    }
////                    .bind(to: this.tableView.rx.items(dataSource: this.dataSource)),
////                this.tableView.rx.itemSelected
////                    .withLatestFrom(state) { i, latestState in
////                        let all = [latestState.favoriteUsers, latestState.users]
////                        return all[i.section][i.row]
////                    }
////                    .subscribe(onNext: { [weak this] user in
////                        this?.showDetailsForUser(user)
////                    }),
////            ]
////
////            let events: [Observable<TableViewEditingCommand>] = [
////
////                this.tableView.rx.itemDeleted.map(TableViewEditingCommand.deleteUser),
////                this.tableView .rx.itemMoved.map({ val in return TableViewEditingCommand.moveUser(from: val.0, to: val.1) })
////            ]
////
////            return Bindings(subscriptions: subscriptions, events: events)
////        }
////
////        let initialLoadFeedback: Feedback = { _ in initialLoadCommand }
////
////        Observable.system(
////            initialState: TableViewEditingCommandsViewModel(favoriteUsers: [], users: []),
////            reduce: TableViewEditingCommandsViewModel.executeCommand,
////            scheduler: MainScheduler.instance,
////            scheduledFeedback: uiFeedback, initialLoadFeedback
////        )
////            .subscribe()
////            .disposed(by: disposeBag)
////
////        // customization using delegate
////        // RxTableViewDelegateBridge will forward correct messages
////        tableView.rx.setDelegate(self)
////            .disposed(by: disposeBag)
////    }
////
////    override func setEditing(_ editing: Bool, animated: Bool) {
////        super.setEditing(editing, animated: animated)
////        tableView.isEditing = editing
////    }
////
////    // MARK: Table view delegate ;)
////    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
////        let title = dataSource[section]
////
////        let label = UILabel(frame: CGRect.zero)
////        // hacky I know :)
////        label.text = "  \(title)"
////        label.textColor = UIColor.white
////        label.backgroundColor = UIColor.darkGray
////        label.alpha = 0.9
////
////        return label
////    }
////
////    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////        return 40
////    }
////
////    // MARK: Navigation
////    private func showDetailsForUser(_ user: User) {
////        let storyboard = UIStoryboard(name: "TableViewWithEditingCommands", bundle: Bundle(identifier: "RxExample-iOS"))
////        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
////        viewController.user = user
////        self.navigationController?.pushViewController(viewController, animated: true)
////    }
////
////    // MARK: Work over Variable
////    static func configureDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, User>> {
////        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>(
////            configureCell: { (_, tv, ip, user: User) in
////                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
////                cell.textLabel?.text = user.firstName + " " + user.lastName
////                return cell
////            },
////            titleForHeaderInSection: { dataSource, sectionIndex in
////                return dataSource[sectionIndex].model
////            },
////            canEditRowAtIndexPath: { (ds, ip) in
////                return true
////            },
////            canMoveRowAtIndexPath: { _, _ in
////                return true
////            }
////        )
////
////        return dataSource
////    }
////
////}
