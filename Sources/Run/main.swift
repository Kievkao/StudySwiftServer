import App

let config = try Config()
try config.setup()

let drop = try Droplet(config)
try drop.setup()

//-------------------------------------------------
// GET "Hello, world" output
//-------------------------------------------------
drop.get("hello") { _ in
    return "Hello, world"
}
//-------------------------------------------------

//-------------------------------------------------
// GET all users list
//-------------------------------------------------
drop.get("users") { _ in
    let users = try User.makeQuery().all()
    
    guard users.count > 0 else {
        return "No users"
    }
    
    return try users.makeJSON()
}
//-------------------------------------------------

//-------------------------------------------------
// GET user by id
// parameter: id
//-------------------------------------------------
drop.get("user") { request in
    guard let id = request.data[User.idKey]?.int else {
        return "id parameter is missed"
    }
    
    guard let user = try User.makeQuery().filter(User.idKey, id).first() else {
        return "No such user with id: \(id)"
    }
    
    return try user.makeJSON()
}
//-------------------------------------------------

//-------------------------------------------------
// POST new user
// payload: {"name" : "Username"}
//-------------------------------------------------
drop.post("user") { request in
    guard let json = request.json, let user = try? User(json: json) else {
        return "Invalid payload"
    }
    
    try user.save()
    return "Success"
}
//-------------------------------------------------

//-------------------------------------------------
// PATCH update existed user
// parameter: id
// payload: {"name" : "New username"}
//-------------------------------------------------
drop.patch("user") { request in
    guard let id = request.data[User.idKey]?.int else {
        return "id parameter is missed"
    }
    
    guard let user = try User.makeQuery().filter(User.idKey, id).first() else {
        return "No such user with id: \(id)"
    }
    
    guard let newName = request.data[User.nameKey]?.string else {
        return "new name is missed"
    }
    
    user.update(name: newName)
    
    try user.save()    
    return "Success"
}
//-------------------------------------------------

//-------------------------------------------------
// DELETE delete user
// parameter: id
//-------------------------------------------------
drop.delete("user") { request in
    guard let id = request.data[User.idKey]?.int else {
        return "id parameter is missed"
    }
    
    guard let user = try User.makeQuery().filter(User.idKey, id).first() else {
        return "No such user with id: \(id)"
    }
    
    try user.delete()
    return "Success"
}
//-------------------------------------------------

try drop.run()
