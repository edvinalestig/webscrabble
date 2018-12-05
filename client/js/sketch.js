let gameObject;

function setup() {
    getJson();
}

function playButton() {
    console.log("PLAY!")
    getJson();
}

function endButton() {
    console.log("END!")
    setCss();
}

function getJson() {
    gameObject = loadJSON("/getp1");
    // if (Object.keys(gameObject).length === 0 && gameObject.constructor === Object) {
    //     gameObject = undefined;
    // }
}

function setCss() {
    console.log(gameObject);
    if (gameObject) {
        const currentTurn = gameObject.currentTurn;
        const player1 = document.getElementById("player1Score");
        const player2 = document.getElementById("player2Score");
        if (currentTurn == 0) {
            // Player 1's turn
            player1.classList.add("activePlayer");
            player2.classList.remove("activePlayer");
        } else {
            // Player 2's turn
            player1.classList.remove("activePlayer");
            player2.classList.add("activePlayer");
        }
    }
}