let socket = new WebSocket("ws://" + document.location.host + "/ws");
console.log(socket);

socket.onopen = event => {
    console.log("Connection opened", event);
    socket.send(JSON.stringify({
        'action': 'connect'
    }));
}

socket.onmessage = event => {
    const message = JSON.parse(event.data);
    console.log("Message received:", message);

    if (message.action == 'data') {
        if (message.data.error) {
            const type = Object.keys(message.data.error)[0];
            const msg = message.data.error[type];
            alert(type + ": " + msg);
        } else if (message.data.ended) {
            document.location = "http://" + document.location.host + "/end_page";
        } else {
            gameObject = message.data;
            playerNumber = message.playerNumber;
            console.log("Updating", playerNumber);
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
    // object.action = "data"
    console.log("Sending", sendobj);
    socket.send(JSON.stringify(sendobj));
}