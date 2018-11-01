import Vapor
import WebSocket

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world -- RiseTime Server!"
    }
    
    // First, create an HTTPProtocolUpgrader
    let ws = HTTPServer.webSocketUpgrader(shouldUpgrade: { req in
        // Returning nil in this closure will reject upgrade
        if req.url.path == "/deny" { return nil }
        // Return any additional headers you like, or just empty
        return [:]
    }, onUpgrade: { ws, req in
        // This closure will be called with each new WebSocket client
        ws.send("Connected")
        ws.onText { ws, string in
            ws.send(string.reversed())
        }
    })
    
    /// Echoes the request as a response.
    struct EchoResponder: HTTPServerResponder {
        /// See `HTTPServerResponder`.
        func respond(to req: HTTPRequest, on worker: Worker) -> Future<HTTPResponse> {
            // Create an HTTPResponse with the same body as the HTTPRequest
            let res = HTTPResponse(body: req.body)
            // We don't need to do any async work here, we can just
            // se the Worker's event-loop to create a succeeded future.
            return worker.eventLoop.newSucceededFuture(result: res)
        }
    }
    
    // Create an EventLoopGroup with an appropriate number
    // of threads for the system we are running on.
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    // Make sure to shutdown the group when the application exits.
    defer { try! group.syncShutdownGracefully() }
    
    // Start an HTTPServer using our EchoResponder
    // We are fine to use `wait()` here since we are on the main thread.
    let server = try HTTPServer.start(
        hostname: "localhost",
        port: 8080,
        responder: EchoResponder(),
        upgraders: [ws],
        on: group
        ).wait()
    
    // Wait for the server to close (indefinitely).
    try server.onClose.wait()
    
//    router.websocket("ping") { (req, ws) in
//        ws.onString({ (ws, msg) in
//            if msg == "ping" {
//                ws.send(string: "pong")
//           }
//        })
//    }
    
    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
