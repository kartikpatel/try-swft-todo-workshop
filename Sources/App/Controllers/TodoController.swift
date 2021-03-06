import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo.Outgoing]> {
        return Todo.query(on: req).all().makeOutgoing(with: req)
    }
    
    /// Returns a parameterized `Todo`
    func view(_ req: Request) throws -> Future<Todo.Outgoing> {
        return try req.parameters.next(Todo.self).makeOutgoing(with: req)
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo.Outgoing> {
        return try req.content.decode(Todo.Incoming.self).flatMap { incoming in
            return incoming.makeTodo().save(on: req)
        }.makeOutgoing(with: req)
    }
    
    /// Update a parameterized `Todo`
    func update(_ req: Request) throws -> Future<Todo.Outgoing> {
        let todo = try req.parameters.next(Todo.self)
        let incoming = try req.content.decode(Todo.Incoming.self)
        return flatMap(to: Todo.self, todo, incoming) { todo, incoming in
            let updated = todo.patched(with: incoming)
            return updated.update(on: req)
        }.makeOutgoing(with: req)
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
    
    func clear(_ req: Request) throws -> Future<HTTPStatus> {
        return Todo.query(on: req).delete().transform(to: .ok)
    }
}
