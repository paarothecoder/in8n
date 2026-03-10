import SwiftUI

// MARK: Node Types
enum NodeType: String, CaseIterable, Identifiable {
    case trigger = "Trigger"
    case llm = "LLM"
    case output = "Output"
    case web = "web"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .trigger: return .pink
        case .llm: return .purple
        case .output: return .orange
        case .web: return .blue
        }
    }
}

enum NodeData {
    case trigger(time: Double)
    case llm(prompt: String, model: String)
    case web(hook: String)
    case output
}

struct Node: Identifiable {
    let id = UUID()
    var type: NodeType
    var data: NodeData
    var position: CGPoint
}

struct WorkflowView: View {

    @State private var nodes: [Node] = []
    @State private var connections: [(UUID, UUID)] = []
    @State private var selectedNode: UUID? = nil
    @State private var sidePanel = false
    @State private var outputText: String = ""

    var body: some View {

        ZStack {

            // Background gradient matching the theme
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.12), Color(red: 0.02, green: 0.02, blue: 0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Grid Overlay for technical feel
            GeometryReader { geometry in
                Path { path in
                    let step: CGFloat = 40
                    for x in stride(from: 0, to: geometry.size.width, by: step) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    for y in stride(from: 0, to: geometry.size.height, by: step) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Terminal Output:")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Text(outputText.isEmpty ? "Ready." : outputText)
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(outputText.isEmpty ? .white.opacity(0.3) : .green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
            }

            // MARK: Connections
            Canvas { context, size in
                for connection in connections {

                    if let from = nodes.first(where: { $0.id == connection.0 }),
                       let to = nodes.first(where: { $0.id == connection.1 }) {

                        let start = from.position
                        let end = to.position

                        var path = Path()
                        path.move(to: start)
                        path.addLine(to: end)

                        context.stroke(path, with: .color(selectedNode == from.id || selectedNode == to.id ? .purple : .white.opacity(0.4)), lineWidth: 3)

                        drawArrow(context: context, from: start, to: end)
                    }
                }
            }

            // MARK: Nodes
            ForEach(nodes) { node in
                nodeView(node)
            }

            // MARK: Side Panel
            if sidePanel {

                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            sidePanel = false
                        }
                    }

                HStack {
                    Spacer()

                    SidePanel(showPanel: $sidePanel, addNode: addNode)
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .transition(.move(edge: .trailing))
                }
            }

            // MARK: Bottom Controls
            VStack {

                Spacer()

                HStack {

                    Button(action: {
                        Task {
                            let result = NodeLogic.run(
                                nodes: nodes,
                                connections: connections
                            )

                            guard let token = Auth.getToken() else {
                                outputText = "Error: No Auth Token"
                                return
                            }

                            do {
                                let data = try await UserRequest.reqwest(
                                    what: "workflow/set",
                                    method: "POST",
                                    auth: token,
                                    data: result
                                )
                                outputText = String(data: data, encoding: .utf8) ?? "Invalid response"
                            } catch {
                                outputText = "Request failed: \(error.localizedDescription)"
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Run Workflow")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding(.vertical, 14)
                        .padding(.horizontal, 24)
                        .background(
                            LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding()

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            sidePanel = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .frame(width: 56, height: 56)
                            .background(
                                LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(color: .pink.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: Node View
    func nodeView(_ node: Node) -> some View {

        Text(node.type.rawValue)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .padding()
            .frame(width: 120, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedNode == node.id ? node.type.color.opacity(0.6) : node.type.color.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(node.type.color, lineWidth: selectedNode == node.id ? 2 : 1)
            )
            .foregroundColor(.white)
            .shadow(color: node.type.color.opacity(0.3), radius: 10, x: 0, y: 5)
            .position(node.position)

            .onTapGesture {
                handleNodeTap(node.id)
            }

            .gesture(
                DragGesture()
                    .onChanged { value in
                        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
                            nodes[index].position = value.location
                        }
                    }
            )
    }

    // MARK: Add Node
    func addNode(type: NodeType, data: NodeData) {

        let newNode = Node(
            type: type,
            data: data,
            position: CGPoint(
                x: 120 + CGFloat(nodes.count * 30),
                y: 120 + CGFloat(nodes.count * 30)
            )
        )

        nodes.append(newNode)

        withAnimation {
            sidePanel = false
        }
    }

    // MARK: Connection Logic
    func handleNodeTap(_ id: UUID) {

        if selectedNode == nil {
            selectedNode = id
            return
        }

        guard let first = selectedNode else { return }

        if first == id {
            selectedNode = nil
            return
        }

        if let index = connections.firstIndex(where: {
            ($0.0 == first && $0.1 == id) ||
            ($0.0 == id && $0.1 == first)
        }) {

            connections.remove(at: index)
            selectedNode = nil
            return
        }

        let firstConnections = connections.filter {
            $0.0 == first || $0.1 == first
        }.count

        let secondConnections = connections.filter {
            $0.0 == id || $0.1 == id
        }.count

        if firstConnections >= 3 || secondConnections >= 3 {
            print("Connection limit reached (max 3)")
            selectedNode = nil
            return
        }

        connections.append((first, id))
        selectedNode = nil
    }

    // MARK: Arrow Drawing
    func drawArrow(context: GraphicsContext, from: CGPoint, to: CGPoint) {

        let angle = atan2(to.y - from.y, to.x - from.x)
        let size: CGFloat = 12
        let offset: CGFloat = 50

        let tip = CGPoint(
            x: to.x - offset * cos(angle),
            y: to.y - offset * sin(angle)
        )

        let p1 = CGPoint(
            x: tip.x - size * cos(angle - .pi / 6),
            y: tip.y - size * sin(angle - .pi / 6)
        )

        let p2 = CGPoint(
            x: tip.x - size * cos(angle + .pi / 6),
            y: tip.y - size * sin(angle + .pi / 6)
        )

        var path = Path()
        path.move(to: tip)
        path.addLine(to: p1)
        path.addLine(to: p2)
        path.closeSubpath()

        context.fill(path, with: .color(Color.white.opacity(0.8)))
    }
}

// MARK: Side Panel
struct SidePanel: View {

    @Binding var showPanel: Bool
    var addNode: (NodeType, NodeData) -> Void

    @State private var selectedType: NodeType = .trigger

    // input states
    @State private var triggerTime: Double = 0
    @State private var prompt: String = ""
    @State private var webhook: String = ""
    @State private var model: String = ""

    var body: some View {

        VStack(spacing: 20) {

            Text("Create Node")
                .font(.title2.bold())

            // Picker
            Picker("Node Type", selection: $selectedType) {
                ForEach(NodeType.allCases, id: \.self) { type in
                    Text(type.rawValue)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)

            Divider()

            // Dynamic fields
            nodeInputs

            Spacer()

            Button("Done") {
                let data = buildData()
                addNode(selectedType, data)
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showPanel = false
                }
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .padding()
            .frame(maxWidth: .infinity)
            .background(selectedType.color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: selectedType.color.opacity(0.4), radius: 8, x: 0, y: 4)

        }
        .padding(24)
        .frame(width: 280)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
        )
        .background(Color.black.opacity(0.5)) // Darken the material slightly
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 20, x: -10, y: 0)
    }
}
extension SidePanel {

    @ViewBuilder
    var nodeInputs: some View {

        switch selectedType {

        case .trigger:

            VStack(alignment: .leading) {
                Text("Time")

                TextField("Seconds", value: $triggerTime, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
        case .web:
            VStack(alignment: .leading) {
                Text("Hook / Web")

                TextField("Link", text: $webhook)
                    .textFieldStyle(.roundedBorder)
            }
            

        case .llm:

            VStack(alignment: .leading) {

                Text("Prompt")

                TextField("Enter prompt", text: $prompt)
                    .textFieldStyle(.roundedBorder)

                Text("Model")

                TextField("Model name", text: $model)
                    .textFieldStyle(.roundedBorder)
            }

        case .output:
            Text("No inputs required")
        }
    }
}
extension SidePanel {

    func buildData() -> NodeData {

        switch selectedType {
        case .web:
            return .web(hook: webhook)

        case .trigger:
            return .trigger(time: triggerTime)

        case .llm:
            return .llm(prompt: prompt, model: model)

        case .output:
            return .output
        }
    }
}

#Preview {
    WorkflowView()
}
