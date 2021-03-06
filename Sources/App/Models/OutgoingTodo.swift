import Vapor

extension Todo {
    struct Outgoing: Content {
        var id: Int?
        var title: String?
        var completed: Bool?
        var order: Int?
        var url: String
    }
}

extension Todo {
    func makeOutgoing(with req: Request) -> Outgoing {
        let idString = id?.description ?? ""
        let url = req.baseURL + idString
        return Outgoing(id: id, title: title, completed: completed, order: order, url: url)
    }
}

extension Future where T == Todo {
    func makeOutgoing(with req: Request) -> Future<Todo.Outgoing> {
        return map { todo in
            todo.makeOutgoing(with: req)
        }
    }
}

extension Future where T == [Todo] {
    func makeOutgoing(with req: Request) -> Future<[Todo.Outgoing]> {
        return map { todos in
            return todos.map { todo in
                return todo.makeOutgoing(with: req)
            }
        }
    }
}
