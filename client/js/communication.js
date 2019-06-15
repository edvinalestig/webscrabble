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
                // The game has ended, redirect to /end_page with the room name attached
                document.location = "/end_page?room=" + room;
            } else {
                if (!gameObject) {
                    gameObject = message.data;
                } else {
                    updateData(message.data);
                }
                playerNumber = message.playerNumber;
                spectator = message.spectator;
                update();
            }
        } else if (message.action == 'connect') {
            spectator = message.spectator;
            playerNumber = message.playerNumber;

            setTimeout(keepAlive, 10000);
        }
    }
}

function keepAlive() {
    socket.send(JSON.stringify({"action": "keepAlive"}));
    console.log("keepAlive message sent");
    setTimeout(keepAlive, 10000);
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

function updateData(newData) {
    // Deep copy of the board
    let oldBoard = JSON.parse(JSON.stringify(gameObject.game.board.tiles));
    gameObject = newData;

    // Update the board
    let lut = newData.game.board.latestUpdatedTiles;
    for (let t of lut) {
        oldBoard[t.row][t.column].letter = t.letter;
    }
    gameObject.game.board.tiles = oldBoard;
}

function saveGame() {
    console.log("saving..");
    socket.send(JSON.stringify({"action":"save"}));
}