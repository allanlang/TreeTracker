import Foundation
import GRDB

final class Database {
    private enum Constants {
        static let databaseUrl = URL.documentsDirectory.appendingPathComponent("db.sqlite")
    }

    private let dbQueue: DatabaseQueue?

    init() {
        self.dbQueue = try? DatabaseQueue(path: Constants.databaseUrl.path)

        try? createTablesIfNeeded()
    }

    private func createTablesIfNeeded() throws {
        try dbQueue?.write { db in
            if try db.tableExists(RemoteTree.databaseTableName) == false {
                try db.create(table: RemoteTree.databaseTableName) { table in
                    table.column(RemoteTree.CodingKeys.id.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.supervisor.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.species.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.notes.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.coordinates.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.what3words.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.imageUrl.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.thumbnailUrl.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.imageMd5.stringValue, .text)
                    table.column(RemoteTree.CodingKeys.uploadDate.stringValue, .date)
                    table.column(RemoteTree.CodingKeys.createDate.stringValue, .date)

                    table.primaryKey([RemoteTree.CodingKeys.id.stringValue])
                }
            }

            if try db.tableExists(LocalTree.databaseTableName) == false {
                try db.create(table: LocalTree.databaseTableName) { table in
                    table.column(LocalTree.CodingKeys.phImageId.stringValue, .text)
                    table.column(LocalTree.CodingKeys.createDate.stringValue, .date)
                    table.column(LocalTree.CodingKeys.supervisor.stringValue, .text)
                    table.column(LocalTree.CodingKeys.species.stringValue, .text)
                    table.column(LocalTree.CodingKeys.notes.stringValue, .text)
                    table.column(LocalTree.CodingKeys.coordinates.stringValue, .text)
                    table.column(LocalTree.CodingKeys.what3words.stringValue, .text)
                    table.column(LocalTree.CodingKeys.imageMd5.stringValue, .text)

                    table.primaryKey([LocalTree.CodingKeys.phImageId.stringValue])
                }
            }

            if try db.tableExists(LocalTree.databaseTableName) == false {
                try db.create(table: LocalTree.databaseTableName) { table in
                    table.column(LocalTree.CodingKeys.phImageId.stringValue, .text)
                    table.column(LocalTree.CodingKeys.createDate.stringValue, .date)
                    table.column(LocalTree.CodingKeys.supervisor.stringValue, .text)
                    table.column(LocalTree.CodingKeys.species.stringValue, .text)
                    table.column(LocalTree.CodingKeys.notes.stringValue, .text)
                    table.column(LocalTree.CodingKeys.coordinates.stringValue, .text)
                    table.column(LocalTree.CodingKeys.what3words.stringValue, .text)
                    table.column(LocalTree.CodingKeys.imageMd5.stringValue, .text)

                    table.primaryKey([LocalTree.CodingKeys.phImageId.stringValue])
                }
            }

            if try db.tableExists(Site.databaseTableName) == false {
                try db.create(table: Site.databaseTableName) { table in
                    table.column(Site.CodingKeys.id.stringValue, .text)
                    table.column(Site.CodingKeys.name.stringValue, .text)

                    table.primaryKey([Site.CodingKeys.id.stringValue])
                }
            }

            if try db.tableExists(Supervisor.databaseTableName) == false {
                try db.create(table: Supervisor.databaseTableName) { table in
                    table.column(Supervisor.CodingKeys.id.stringValue, .text)
                    table.column(Supervisor.CodingKeys.name.stringValue, .text)

                    table.primaryKey([Supervisor.CodingKeys.id.stringValue])
                }
            }

            if try db.tableExists(Species.databaseTableName) == false {
                try db.create(table: Species.databaseTableName) { table in
                    table.column(Species.CodingKeys.id.stringValue, .text)
                    table.column(Species.CodingKeys.name.stringValue, .text)

                    table.primaryKey([Species.CodingKeys.id.stringValue])
                }
            }
        }
    }

    func save(_ trees: [AirtableTree]) {
        try? dbQueue?.write { db in
            trees.forEach { tree in
                let tree = tree.toRemoteTree()
                do {
                    let potentialTree = try RemoteTree
                        .filter(key: tree.id)
                        .fetchOne(db)

                    if potentialTree == nil {
                        try tree.insert(db)
                    }
                } catch {
                    print("Tree: \(tree)")
                    print("Error when adding remote tree to DB. \(error)")
                }
            }
        }
    }

    func save(_ trees: [LocalTree]) {
        try? dbQueue?.write { db in
            trees.forEach { tree in
                do {
                    let potentialTree = try LocalTree
                        .filter(key: tree.phImageId)
                        .fetchOne(db)

                    if potentialTree == nil {
                        try tree.insert(db)
                    }
                } catch {
                    print("Tree: \(tree)")
                    print("Error when adding tree to DB. \(error)")
                }
            }
        }
    }

    func save<T: Identifiable & TableRecord & FetchableRecord & PersistableRecord>(_ models: [T]) where T.ID: DatabaseValueConvertible {
        try? dbQueue?.write { db in
            models.forEach { model in
                do {
                    let potentialModel = try T
                        .filter(key: model.id)
                        .fetchOne(db)

                    if potentialModel == nil {
                        try model.insert(db)
                    }

                    print("Saved: \(model)")
                } catch {
                    print("Model: \(model)")
                    print("Error when adding model to DB. \(error)")
                }
            }
        }
    }

    func remove(tree: LocalTree, completion: @escaping () -> Void) {
        dbQueue?.asyncWrite { db in
            try? tree.delete(db)
        } completion: { db, result in
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func update(tree: LocalTree, completion: @escaping () -> Void) {
        dbQueue?.asyncWrite { db in
            try? tree.update(db)
        } completion: { db, result in
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    func fetchRemoteTrees(_ completion: @escaping ([RemoteTree]) -> Void) {
        dbQueue?.read { db in
            let trees = try? RemoteTree.fetchAll(db)
            DispatchQueue.main.async {
                completion(trees ?? [])
            }
        }
    }

    func fetchLocalTrees(_ completion: @escaping ([LocalTree]) -> Void) {
        dbQueue?.read { db in
            let trees = try? LocalTree.fetchAll(db)
            DispatchQueue.main.async {
                completion(trees ?? [])
            }
        }
    }

    func fetch<T: Identifiable & TableRecord & FetchableRecord & PersistableRecord>(_ completion: @escaping ([T]) -> Void) {
        dbQueue?.read { db in
            let models = try? T.fetchAll(db)
            DispatchQueue.main.async {
                completion(models ?? [])
            }
        }
    }
}
