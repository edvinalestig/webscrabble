// Websocket stuff is in communication.js

// Grey colours
const darkColour = (54, 54, 54);
const lightColour = (71, 71, 71);
let TWColour;
let DWColour;
let TLColour;
let DLColour;

// Create the required objects for the game
let gameObject;
let letterRack = new LetterRack();
let playfield = new Playfield();
let selectedLetter;
let placedTiles = [];
let waitingForChar;
let playerNumber;

// Built-in function in p5.js which runs just after preload.
function setup() {
    // Constants
    TWColour = color(235, 51, 51);
    DWColour = color(233, 134, 1);
    TLColour = color(30, 101, 226);
    DLColour = color(134, 168, 226);

    // Set up the canvas
    const canvasDiv = document.getElementById("playfield");
    let canvas = createCanvas(canvasDiv.offsetWidth, canvasDiv.offsetHeight);
    canvas.parent("playfield");

    // Set the dimensions
    letterRack.width  = width / 11;
    w = width * 0.7528;
    h = height * 0.9256;
    letterRack.height = height * 0.9256 * 0.1148;

    if (w > h) {
        playfield.length = h;
    } else {
        playfield.length = w;
    }
}

// Built-in function in p5.js which runs continuously in loop until noLoop() is called
function draw() {
    // Wait for the data to arrive before drawing it
    if (gameObject) {
        update();
        noLoop();
    }
}

// Update the board, scores etc with new information
function update() {
    you();
    letterRack.manageLetters();
    letterRack.hidden = [];
    placedTiles = [];
    setCss();
    setScores();
    // Draw the things
    letterRack.show();
    playfield.show();
}

// Function called when the player presses the play button.
function playButton() {
    console.log("PLAY!");
    // If no letters have been placed, pass
    if (placedTiles.length == 0) {
        sendWebsocket({"passed": true});
        // sendToServer({"passed": true}, () => document.location.reload());
    } else {
        console.log(placedTiles);
        let tiles = [];
        for (let t of placedTiles) {
            tiles.push({
                "row": t.row,
                "column": t.col,
                "letter": gameObject.game.you.rack[t.rack]
            });
        }
        // sendToServer({"tiles": tiles}, () => document.location.reload());
        sendWebsocket({"tiles": tiles});
    }
}

// Function called when the player presses the end button.
function endButton() {
    console.log("END!");
    giveUp();
}

// Set the css
// The interface should be different when it's the opponents turn
function setCss() {
    if (gameObject) { // Only run if game information is available
        const currentTurn = gameObject.game.currentTurn;
        const player1 = document.getElementById("player1Score");
        const player2 = document.getElementById("player2Score");

        // Determine which player you are.
        let me;
        for (let i = 0; i < gameObject.game.players.length; i++) {
            if (gameObject.game.players[i].isYou) {
                me = i;
                break;
            }
        }

        // Add and remove classes for changing the appearance of the elements.
        if (currentTurn == 0) {
            // Player 1's turn
            player1.classList.add("activePlayer");
            player2.classList.remove("activePlayer");
        } else {
            // Player 2's turn
            player1.classList.remove("activePlayer");
            player2.classList.add("activePlayer");
        }

        const playButtonDiv = document.getElementById("playButton");
        const playButtonText = document.getElementById("playButtonText");
        
        if (currentTurn == me) {
            playButtonDiv.classList.remove("oppoTurn");
            playButtonDiv.classList.add("myTurn", "pass");
            playButtonText.classList.remove("oppoTurn");
            playButtonText.classList.add("myTurn");
            playButtonText.innerHTML = "pass";
            
            playButtonDiv.onclick = () => playButton();
        } else {
            playButtonDiv.classList.add("oppoTurn");
            playButtonDiv.classList.remove("myTurn", "pass", "placed");
            playButtonText.classList.add("oppoTurn");
            playButtonText.classList.remove("myTurn");
            
            playButtonDiv.onclick = () => console.log("Deactivated");
        }
    }
}

// Set the scores.
// Updates the text in the score paragraph elements.
function setScores() {
    if (gameObject) {
        const p1Element = document.getElementById("player1ScoreP");
        const p2Element = document.getElementById("player2ScoreP");
        const p1Points = gameObject.game.players[0].points;
        const p2Points = gameObject.game.players[1].points;
        p1Element.innerHTML = p1Points + "p";
        p2Element.innerHTML = p2Points + "p";
    }
}

// Function to call when your opponent is too good
function giveUp() {
    const obj = {"forfeit": true};
    sendWebsocket(obj);
}

// Changing the playername depending on route
function you() {
    if (playerNumber == "0") {
        document.getElementById("player?").innerHTML="player 1"
    } else if (playerNumber == "1") {
        document.getElementById("player?").innerHTML="player 2"
    } else {
        document.getElementById("player?").innerHTML="spectator"
    }
}

// Built-in function in p5.js which runs when the mouse is clicked
function mouseClicked() {
    if (waitingForChar) {
        return;
    }
    const x = mouseX;
    const y = mouseY;

    // Check the board
    if (x >= playfield.xPos && x <= playfield.xPos + playfield.length) {
        if (y >= playfield.yPos && y <= playfield.yPos + playfield.length) {
            // Click is on the board
            checkBoard(x, y);
        }
    }

    // Check the rack
    if (x >= letterRack.xPos && x <= letterRack.xPos + letterRack.width) {
        if (y >= letterRack.yPos && y <= letterRack.yPos + letterRack.height * 7 + 28.5 * 6) {
            // Click is on the rack
            checkRack(y);
        }
    }
}
