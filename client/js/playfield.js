// Playfield object (the board)
class Playfield {

    constructor() {
        this.colour = darkColour;
        this.length = 871;
        this.tileLength = this.length / 15.0
        this.xPos   = 250;
        this.yPos   = 41;
    }

    // Method for drawing the board on the canvas
    show() {
        fill(this.colour);
        strokeWeight(1);
        stroke(255, 255, 255);
        rect(this.xPos, this.yPos, this.length, this.length, 0);

        // Grid
        this.tileLength = this.length / 15.0
        for (let i = 0; i <= 15; i++) {
            // Horizontal line
            line(this.xPos, this.yPos + i * this.tileLength, this.xPos + 15 * this.tileLength, this.yPos + i * this.tileLength);
            // Vertical line
            line(this.xPos + i * this.tileLength, this.yPos, this.xPos + i * this.tileLength, this.yPos + 15 * this.tileLength);
        }


        // Special tiles
        for (let row = 0; row < 15; row++) {
            for (let col = 0; col < 15; col++) {
                const a = gameObject.game.board.tiles[row][col].attribute;
                if (a) {
                    this.drawSpecial(a, row, col);
                }
            }
        }

        // Go through all the tiles and draw them if they have something placed on them
        for (let row of gameObject.game.board.tiles) {
            for (let tile of row) {
                if (tile.letter != null) {
                    this.drawLetter(tile.letter, tile.row, tile.column);
                }
            }
        }
    }

    // Draw special tiles such as Double word etc
    drawSpecial(attribute, row, col) {
        const x = this.xPos + this.tileLength * col;
        const y = this.yPos + this.tileLength * row;
        // Set colour
        if (attribute == "centre") {
            fill(lightColour);
        } else if (attribute == "TW") {
            fill(TWColour);
        } else if (attribute == "DW") {
            fill(DWColour);
        } else if (attribute == "TL") {
            fill(TLColour);
        } else if (attribute == "DL") {
            fill(DLColour);
        }
        rect(x, y, this.tileLength, this.tileLength);
        if (attribute == "centre") {return;}
        // Print the tile label
        fill(0);
        stroke(0);
        textSize(24);
        textAlign(CENTER);
        text(attribute, x + this.tileLength/2, y + this.tileLength/2 + this.tileLength * 0.2);
        stroke(255);
    }

    // Method for drawing a letter on the board
    drawLetter(letter, row, col) {
        fill(49);
        stroke(255);

        // Create the background
        const xCorner = this.xPos + col * this.tileLength;
        const yCorner = this.yPos + row * this.tileLength;
        rect(xCorner, yCorner, this.tileLength, this.tileLength);

        // Get points and get the letter from the blank
        let points;
        if (letter.value != undefined) {
            letter = letter.value;
            points = "";
        } else {
            points = getPoints(letter);
        }

        // Print the letter and the points
        fill(255);
        textSize(42);
        textAlign(CENTER);
        text(letter, xCorner + this.tileLength/2, yCorner + this.tileLength/2 + this.tileLength * 0.2);

        textSize(14);
        text(String(points), xCorner + this.tileLength * 0.8, yCorner + this.tileLength * 0.3);
    }

    // Method for removing a letter from the board
    removeLetter(row, col) {
        const xCorner = this.xPos + col * this.tileLength;
        const yCorner = this.yPos + row * this.tileLength;
        
        stroke(255);
        strokeWeight(1);
        const a = gameObject.game.board.tiles[row][col].attribute;
        if (a) {
            this.drawSpecial(a, row, col);
        } else {
            fill(this.colour);
            rect(xCorner, yCorner, this.tileLength, this.tileLength);
        }
    }
}
