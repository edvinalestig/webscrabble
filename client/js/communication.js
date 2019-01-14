let socket = new WebSocket("ws://" + document.location.host + "/ws");
console.log(socket);

// Fired when a new socket i opened
// Send a confirmation message
socket.onopen = event => {
    console.log("Connection opened", event);
    socket.send(JSON.stringify({
        'action': 'connect'
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
            alert(type + ": " + msg);
        } else if (message.data.ended) {
            // The game has ended, redirect to /end_page
            document.location = "/end_page";
        } else {
            gameObject = message.data;
            playerNumber = message.playerNumber;
            update();
        }
    } else if (message.action == 'connect') {
        playerNumber = message.playerNumber;
    }
}

function sendWebsocket(object) {
    const sendobj = {
        "action": "data",
        "data": object
    }
    console.log("Sending", sendobj);
    socket.send(JSON.stringify(sendobj));
}