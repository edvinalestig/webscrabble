// Playfield object (the board)
class Playfield {

    constructor() {
        this.length = 871;
        this.tileLength = this.length / 15.0
        this.colour = (51, 51, 51);
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

        // Create a star on the centre tile
        const x = this.xPos + this.tileLength * 7.5;
        const y = this.yPos + this.tileLength * 7.5;
        star(x, y, 8, 15, 5);

        // Go through all the tiles and draw them if they have something placed on them
        for (let row of gameObject.game.board.tiles) {
            for (let tile of row) {
                if (tile.letter != null) {
                    this.drawLetter(tile.letter, tile.row, tile.column);
                }
            }
        }
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
        rect(xCorner, yCorner, this.tileLength, this.tileLength);
        
        fill(45);
        stroke(255);
        rect(xCorner, yCorner, this.tileLength, this.tileLength);
    }
}

// Copied from the p5 website with minor changes
// https://p5js.org/examples/form-star.html
function star(x, y, radius1, radius2, npoints) {
    const angle = TWO_PI / npoints;
    const halfAngle = angle/2.0;

    fill(150, 0, 0);
    stroke(150, 0, 0);
    beginShape();
    for (let a = PI / -2; a < TWO_PI; a += angle) {
        let sx = x + cos(a) * radius2;
        let sy = y + sin(a) * radius2;
        vertex(sx, sy);
        sx = x + cos(a+halfAngle) * radius1;
        sy = y + sin(a+halfAngle) * radius1;
        vertex(sx, sy);
    }
    endShape(CLOSE);
}