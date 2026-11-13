import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: service

    property var state: ({
    })
    property var devices: []
    property string endpoint: Quickshell.env("XDG_RUNTIME_DIR") + "/mps/control.sock"
    property string operationError: ""
    property string connectionError: ""
    property var queue: []
    property var pending: null
    property int serial: 0
    property bool lastOutputOn: false
    property double lastSeen: 0
    property double now: Date.now()
    readonly property bool connected: socket.connected
    readonly property bool ready: connected && state.phase === "ready"
    readonly property bool stale: !ready || state.stale !== false || now - lastSeen > 5000
    readonly property bool writable: ready && !stale && state.readOnly === false
    readonly property var values: state.values || ({
    })
    readonly property bool busy: !!pending && pending.mutation || queue.some((item) => {
        return item.mutation;
    })
    readonly property string error: operationError || connectionError || state.error || ""
    readonly property Socket
    socket: Socket {
        path: service.endpoint
        onConnectedChanged: {
            if (connected) {
                service.connectionError = "";
                Qt.callLater(() => {
                    service.request("watch");
                    service.request("devices");
                });
            } else {
                service.lost("Service disconnected; pending actions were discarded");
            }
        }
        onError: service.lost("MPS service unavailable")

        parser: SplitParser {
            onRead: (data) => {
                return service.receive(data);
            }
        }

    }

    readonly property Timer
    reconnect: Timer {
        interval: 2000
        repeat: true
        running: !socket.connected
        triggeredOnStart: true
        onTriggered: socket.connected = true
    }

    readonly property Timer
    clock: Timer {
        interval: 1000
        repeat: true
        running: socket.connected
        onTriggered: service.now = Date.now()
    }

    readonly property Timer
    deadline: Timer {
        interval: 15000
        onTriggered: {
            service.lost("Request timed out; refresh before retrying");
            socket.connected = false;
        }
    }

    signal completed(string tag, var result)
    signal failed(string tag)

    function lost(message) {
        deadline.stop();
        const tags = queue.map((item) => {
            return item.tag;
        });
        if (pending)
            tags.push(pending.tag);

        pending = null;
        queue = [];
        for (const tag of tags) if (tag) {
            failed(tag);
        }
        state = ({
        });
        connectionError = message;
    }

    function request(method, params = {
    }, tag = "") {
        if (!connected || queue.length >= 24)
            return false;

        const mutation = tag.length > 0 && !tag.startsWith("read");
        if (mutation)
            operationError = "";

        queue = queue.concat([{
            "id": String(++serial),
            "method": method,
            "params": params,
            "tag": tag,
            "mutation": mutation
        }]);
        dispatch();
        return true;
    }

    function dispatch() {
        if (pending || !queue.length || !connected)
            return ;

        pending = queue[0];
        queue = queue.slice(1);
        socket.write(JSON.stringify({
            "version": 1,
            "id": pending.id,
            "method": pending.method,
            "params": pending.params
        }) + "\n");
        socket.flush();
        deadline.restart();
    }

    function receive(line) {
        try {
            const message = JSON.parse(line);
            if (message.version !== 1)
                throw new Error("Unsupported service response");

            if (message.event === "state") {
                update(message.data);
                return ;
            }
            if (!pending || message.id !== pending.id)
                return ;

            const operation = pending;
            pending = null;
            deadline.stop();
            if (message.ok) {
                if (operation.method === "devices")
                    devices = message.result.devices || [];
                else
                    update(message.result);
                if (operation.tag)
                    completed(operation.tag, message.result);

            } else {
                operationError = message.error ? message.error.message : "Operation failed";
                if (operation.tag)
                    failed(operation.tag);

            }
            Qt.callLater(dispatch);
        } catch (error) {
            lost("Invalid service response");
            socket.connected = false;
        }
    }

    function update(snapshot) {
        if (!snapshot || !snapshot.values || typeof snapshot.phase !== "string")
            throw new Error("Invalid snapshot");

        if (snapshot.values.outputEnabled === 0 || snapshot.values.outputEnabled === 1)
            lastOutputOn = snapshot.values.outputEnabled === 1;

        state = snapshot;
        lastSeen = Date.now();
        connectionError = "";
    }

    function details() {
        if (!ready)
            return ;

        request("settings");
        request("protection");
        for (let number = 1; number <= 6; ++number) request("preset", {
            "number": number
        })
    }

}
