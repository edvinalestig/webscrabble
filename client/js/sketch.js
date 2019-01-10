// Grey colours
const darkColour = (54, 54, 54);
const lightColour = (71, 71, 71);

// Create the required objects for the game
let gameObject;
let letterRack = new LetterRack();
let playfield = new Playfield();
let selectedLetter;
let placedTiles = [];
let waitingForChar;

// Getting the last character in the url which is the player number
// Temporary, will be removed when websockets are implemented
const playerNumber = String(document.location)[String(document.location).length-1];

// Built-in function in p5.js which runs before everything else.
function preload() {
    getJson();
}

// Built-in function in p5.js which runs just after preload.
function setup() {
    setCss();
    setScores();

    const canvasDiv = document.getElementById("playfield");
    let canvas = createCanvas(canvasDiv.offsetWidth, canvasDiv.offsetHeight);
    canvas.parent("playfield");
    letterRack.manageLetters();

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

// Function called when the player presses the play button.
function playButton() {
    console.log("PLAY!");
    // If no letters have been placed, pass
    if (placedTiles.length == 0) {
        sendToServer({"passed": true});
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
        console.log(tiles);
        sendToServer({"tiles": tiles});
    }

    // getJson();
}

// Function called when the player presses the end button.
// Functionality is temporary
function endButton() {
    console.log("END!");
    setCss();
    setScores();
    giveUp();
    winner();
}

// Get the current game info as a json from the web server
function getJson() {
    console.log(playerNumber);
    gameObject = loadJSON("/getp" + playerNumber + "/all");
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
            playButtonDiv.classList.add("myTurn");
            playButtonText.classList.remove("oppoTurn");
            playButtonText.classList.add("myTurn");
            
            playButtonDiv.onclick = () => playButton();
        } else {
            playButtonDiv.classList.add("oppoTurn");
            playButtonDiv.classList.remove("myTurn");
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

// Two ways of doing the same thing? Somehow needs to be converted into 1.
// I know I added the second way... but the format needs it!
function giveUp() {
    const obj = {"forfeit": true};
    postJson(obj);

    let route = "/winner/";
    if (playerNumber == "1") {
        route += "2";
    } else if (playerNumber == "2") {
        route += "1";
    }

    const formElement = document.getElementById("giveUpForm");
    formElement.action = route;
    formElement.submit();

}

// Changing the h1 depending on who won
function winner() {
    if (playerNumber == "1") {
        document.getElementById("winner").innerHTML="Player 2 won!"
    } else if (playerNmber == "2") {
        document.getElementById("winner").innerHTML="Player 1 won!"
    }
}

// Changing the playername depending on route
function you() {
    if (playerNumber == "1") {
        document.getElementById("player?").innerHTML="player 1"
    } else if (playerNumber == "2") {
        document.getElementById("player?").innerHTML="player 2"
    }  
}

// Built-in function in p5.js which runs in a loop continuously
function draw() {
    letterRack.show();
    playfield.show();
    noLoop();
    you();
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
