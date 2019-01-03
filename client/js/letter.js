class LetterRack {

    constructor() {
        this.width   = 70;
        this.height  = 70;
        this.letters = [];
        this.colour  = (33, 33, 33);
        this.xPos    = 70;
        this.yPos    = 32;
    }

    show() {
        for (let i = 0; i < 7; i++) {
            fill(this.colour);
            strokeWeight(0);
            let yPos = this.yPos + i * (this.height + 28.5);
            rect(this.xPos, yPos, this.width, this.height, 10);

            let lt = this.letters[i];

            fill(255);
            textSize(48);
            let w = textWidth(lt);
            // Writing the letter centred in the tile
            text(lt, this.xPos + 32 - w/2, yPos + 50);

            textSize(12);
            p = getPoints(lt);
            w = textWidth(String(p));
            // Writing the points in the corner
            text(p, this.xPos + 60 - w/2, yPos + 19);
        }
        noLoop();
    }
    
    manageLetters() {
        // var gameObject = loadJSON('../logic/test.json');
        this.letters  = gameObject.game.you.rack;
        console.log(this.letters);
    }


}
