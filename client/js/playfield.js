// Playfield object (the board)
class Playfield {

    constructor() {
        this.width  = 871; // It's a square so only length would suffice?
        this.height = 871;
        this.colour = darkColour;
        this.xPos   = 250;
        this.yPos   = 41;
    }

    // Method for drawing the board on the canvas
    show() {
        fill(this.colour);
        strokeWeight(1);
        stroke(255, 255, 255);
        rect(this.xPos, this.yPos, this.width, this.height, 0);

        // Grid
        const tileLength = this.width/15.0;
        for (let i = 0; i <= 15; i++) {
            // Horizontal line
            line(this.xPos, this.yPos + i * tileLength, this.xPos + 15 * tileLength, this.yPos + i * tileLength);
            // Vertical line
            line(this.xPos + i * tileLength, this.yPos, this.xPos + i * tileLength, this.yPos + 15 * tileLength);
        }

        // Create a rectangle on the centre tile
        const x = this.xPos + tileLength * 7;
        const y = this.yPos + tileLength * 7;
        fill(lightColour);
        rect(x, y, tileLength, tileLength);
    }
}
