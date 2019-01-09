// Class handling the letter rack
class LetterRack {

    constructor() {
        this.width   = 70;
        this.height  = 70;
        this.letters = [];
        this.colour  = darkColour;
        this.xPos    = 70;
        this.yPos    = 41;
        this.hidden  = [];
    }

    // Draw it!
    show() {
        for (let i = 0; i < 7; i++) { // Edvin's version
            if (this.hidden.includes(i)) {
                continue;
            }
        // const spacing = playfield.height * 0.033
        // for (let i = this.yPos; i <= this.height * 9; i+= this.height + spacing) { -- Ida's version

            fill(this.colour);
            strokeWeight(0);
            let yPos = this.yPos + i * (this.height + 28.5);
            rect(this.xPos, yPos, this.width, this.height, 10);

            let lt = this.letters[i];
            if (lt.letter == "blank") {
                continue;
            }

            // Add the letter
            fill(255);
            textSize(48);
            let w = textWidth(lt);
            // Writing the letter centred in the tile
            text(lt, this.xPos + w, yPos + this.height / 1.5 );

            // Add the points
            textSize(12);
            p = getPoints(lt);
            w = textWidth(String(p));
            // Writing the points in the corner
            text(p, this.xPos + w * 10, yPos + this.height / 4 );
        }
    }

    // Highlighting the selected tile
    select(index) {
        const colour = (128, 55, 0);
        const xCorner = this.xPos - 5; 
        const yCorner = this.yPos + index * (this.height + 28.5) - 5;
        stroke(colour);
        fill(colour);
        rect(xCorner, yCorner, this.width + 10, this.height + 10, 11);
        this.show();
    }

    // Remove the highlighting
    deselect(index) {
        this.hide(index);
        this.show();
    }

    // Hide a letter when placed
    hide(index) {
        const xCorner = this.xPos - 6; 
        const yCorner = this.yPos + index * (this.height + 28.5) - 6;
        stroke("#454545");
        fill("#454545");
        rect(xCorner, yCorner, this.width + 12, this.height + 12);
    }
    
    // Update this.letters with the current rack in the game object
    manageLetters() {
        this.letters = gameObject.game.you.rack;
        console.log(this.letters);
    }
}
