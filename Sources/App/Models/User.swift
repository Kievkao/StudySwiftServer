//
//  User.swift
//  MyServer
//
//  Created by Andrii Kravchenko on 24.05.17.
//
//

import Vapor
import FluentProvider
import HTTP

final class User: Model {
    let storage = Storage()
    static let nameKey = "name"
    
    private(set) var name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get(type(of: self).nameKey)
    }
    
    func update(name: String) {
        self.name = name
    }
}

extension User: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(type(of: self).nameKey, name)

        return row
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(nameKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(name: json.get(type(of: self).nameKey))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(type(of: self).idKey, id)
        try json.set(type(of: self).nameKey, name)
        
        return json
    }
}
