function checkRack(y) {
    console.log("rack!");

    let pos = floor((y - letterRack.yPos) / (letterRack.height + 28.5));
    console.log(pos);
    if (selectedLetter == pos) {
        letterRack.deselect(pos);
        selectedLetter = undefined;
    } else {
        for (let tile of placedTiles) {
            if (tile.rack == pos) {
                return;
            }
        }
        if (selectedLetter != undefined) {
            letterRack.deselect(selectedLetter);
        }
        letterRack.select(pos);
        selectedLetter = pos;                
    }
}


function checkBoard(x, y) {
    // Get which tile was clicked on
    const row = floor((y - playfield.yPos) / playfield.tileLength);
    const col = floor((x - playfield.xPos) / playfield.tileLength);
    console.log("Row: ", row, " Col: ", col);

    // Check if the tile has a letter already
    if (gameObject.game.board.tiles[row][col].letter != null) {
        return;
    }

    // Check if there is a letter selected to be placed
    if (selectedLetter != undefined) {
        // Check if the letter has already been placed
        for (let tile of placedTiles) {
            if (tile.rack == selectedLetter) {
                return;
            }
            if (tile.row == row && tile.col == col) {
                return;
            }
        }

        // Draw the letter
        const letter = gameObject.game.you.rack[selectedLetter];
        placedTiles.push({
            "rack": selectedLetter,
            "row": row,
            "col": col
        });

        if (letter.letter == "blank") {
            // Wait for user input
            waitingForChar = {"row": row, "col": col};
            alert("Press the desired letter on the keyboard.");
        } else {
            createNewLetter(letter, row, col);
        }
    } else {
        // Check if there is a tile there
        let index = undefined;
        for (i = 0; i < placedTiles.length; i++) {
            if (placedTiles[i].row == row && placedTiles[i].col == col) {
                index = i;
                console.log(i);
            }
        }
        if (index != undefined) {
            // Remove the tile
            playfield.removeLetter(row, col);
            const spliced = placedTiles.splice(index, 1);
            console.log(spliced[0]);
            letterRack.hidden.splice(letterRack.hidden.indexOf(spliced[0].rack), 1);
            letterRack.show();
        }
    }
}

const alphabet = "abcdefghijklmnopqrstuvwxyz";
function keyPressed() {
    // Used for getting characters for blank tiles
    if (waitingForChar) {
        if (alphabet.includes(key)) {
            gameObject.game.you.rack[selectedLetter].value = key.toUpperCase();
            createNewLetter({
                "letter": "blanks",
                "value": key.toUpperCase()
            }, waitingForChar.row, waitingForChar.col);
            waitingForChar = undefined;
        }
    }
}

function createNewLetter(letter, row, col) {
    playfield.drawLetter(letter, row, col);
    letterRack.hide(selectedLetter);
    letterRack.hidden.push(selectedLetter);
    selectedLetter = undefined;
}