let socket;
comm();

function comm() {
    if (!room) {
        setTimeout(comm, 1000);
        return;
    }

    socket = new WebSocket("ws://" + document.location.host + "/ws");
    console.log(socket);

    // Fired when a new socket i opened
    // Send a confirmation message
    socket.onopen = event => {
        console.log("Connection opened", event);
        socket.send(JSON.stringify({
            'action': 'connect',
            'room': room
        }));
    }

    // Fired when a message is sent through the socket
    socket.onmessage = event => {
        // Parse the data sent
        const message = JSON.parse(event.data);
        console.log("Message received:", message);

        if (message.action == 'data') {
            if (message.data.error) {
                // There is an error, display it with an alert
                const type = Object.keys(message.data.error)[0];
                const msg = message.data.error[type];
                if (msg == "Room does not exist") {
                    alert(msg);
                    document.location = "/";
                } else {
                    alert(type + ": " + msg);
                }
            } else if (message.data.ended) {
                // The game has ended, redirect to /end_page
                document.location = "/end_page";
            } else {
                gameObject = message.data;
                playerNumber = message.playerNumber;
                spectator = message.spectator;
                update();
            }
        } else if (message.action == 'connect') {
            spectator = message.spectator;
            playerNumber = message.playerNumber;
        }
    }
}

function sendWebsocket(object) {
    const sendobj = {
        "action": "data",
        "data": object,
        "room": room
    }
    console.log("Sending", sendobj);
    socket.send(JSON.stringify(sendobj));
}