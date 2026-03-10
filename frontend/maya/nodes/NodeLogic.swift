import Foundation

class NodeLogic {

    struct NodePayload: Codable {
        let id: UUID
        let type: String
        let data: [String: String]
    }

    struct ConnectionPayload: Codable {
        let from: UUID
        let to: UUID
    }

    struct WorkflowPayload: Codable {
        let nodes: [NodePayload]
        let connections: [ConnectionPayload]
    }

    static func run(nodes: [Node],
                    connections: [(UUID, UUID)]) -> String {

        let nodePayloads: [NodePayload] = nodes.map { node in

            var data: [String: String] = [:]

            switch node.data {

            case .trigger(let time):
                data["time"] = "\(time)"

            case .web(let webhook):
                data["webhook"] = webhook

            case .llm(let prompt, let model):
                data["prompt"] = prompt
                data["model"] = model

            case .output:
                data["type"] = "output"
            }

            return NodePayload(
                id: node.id,
                type: node.type.rawValue,
                data: data
            )
        }

        let connectionPayloads = connections.map {
            ConnectionPayload(from: $0.0, to: $0.1)
        }

        let payload = WorkflowPayload(
            nodes: nodePayloads,
            connections: connectionPayloads
        )

        do {
            let json = try JSONEncoder().encode(payload)
            return String(data: json, encoding: .utf8) ?? "{}"
        } catch {
            return "{\"error\":\"encoding failed\"}"
        }
    }
}
