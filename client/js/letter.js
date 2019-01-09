// Class handling the letter rack
class LetterRack {

    constructor() {
        this.width   = 70;
        this.height  = 70;
        this.letters = [];
        this.colour  = darkColour;
        this.xPos    = 70;
        this.yPos    = 32;
    }

    // Draw it!
    show() {
        for (let i = 0; i < 7; i++) { // Edvin's version

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
            text(lt, this.xPos + 32 - w/2, yPos + 50);

            // Add the points
            textSize(12);
            p = getPoints(lt);
            w = textWidth(String(p));
            // Writing the points in the corner
            text(p, this.xPos + 60 - w/2, yPos + 19);
        }
    }
    
    // Update this.letters with the current rack in the game object
    manageLetters() {
        this.letters = gameObject.game.you.rack;
        console.log(this.letters);
    }
}
