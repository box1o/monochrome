import QtQml
import Quickshell
import Quickshell.Io

QtObject {
    id: pairing

    property var prompt: ({})
    property bool awaitingResult: false
    readonly property bool active: process.running
    readonly property Process process: Process {
        stdinEnabled: true
        onExited: {
            if (pairing.awaitingResult)
                pairing.complete(false, "Pairing failed. Check the device and try again.");
        }

        stdout: SplitParser {
            onRead: data => {
                return pairing.readEvent(data);
            }
        }
    }

    signal succeeded
    signal failed(string message)

    function start(devicePath) {
        if (active)
            return false;

        prompt = {};
        awaitingResult = true;
        process.command = ["bash", Quickshell.env("HOME") + "/.local/libexec/mono/bluetooth/pair.sh", "--device", devicePath];
        process.running = true;
        return true;
    }

    function reply(accept, value = "") {
        if (!active || !awaitingResult)
            return;

        process.write(JSON.stringify({
            "accept": accept,
            "value": value
        }) + "\n");
        prompt = {};
    }

    function readEvent(data) {
        if (!awaitingResult)
            return;

        let message;
        try {
            message = JSON.parse(data);
            if (!message || typeof message !== "object" || Array.isArray(message))
                throw new Error("Expected a pairing event");
        } catch (_) {
            cancel();
            failed("Invalid pairing response.");
            return;
        }
        if (message.event === "prompt")
            prompt = message;
        else if (message.event === "clear")
            prompt = {};
        else if (message.event === "result")
            complete(message.success === true, typeof message.message === "string" ? message.message : "Pairing failed.");
    }

    function complete(success, message) {
        awaitingResult = false;
        prompt = {};
        if (success)
            succeeded();
        else
            failed(failureMessage(message));
    }

    function failureMessage(message) {
        if (!message.includes("org."))
            return message;

        if (/AuthenticationCanceled|AuthenticationRejected|Error.Rejected/.test(message))
            return "Pairing was canceled or rejected.";

        if (/AuthenticationFailed|AuthenticationTimeout/.test(message))
            return "Authentication failed. Check the pairing code and try again.";

        if (/NotReady/.test(message))
            return "Bluetooth is not ready. Check that the radio is enabled.";

        if (/InProgress/.test(message))
            return "Another pairing request is already in progress.";

        return "Pairing failed. Put the device in pairing mode and try again.";
    }

    function cancel() {
        awaitingResult = false;
        prompt = {};
        process.running = false;
    }
}
