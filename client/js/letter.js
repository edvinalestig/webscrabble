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

        console.log("show");
        for (let i = 0; i < 7; i++) {
            fill(this.colour);
            strokeWeight(0);
            let yPos = this.yPos + i * (this.height + 28.5);
            rect(this.xPos, yPos, this.width, this.height, 10);

            fill(255);
            textSize(48);
            text(this.letters[i], this.xPos + 18, yPos + 50);
            textSize(12);
            p = getPoints(this.letters[i]);
            text(p, this.xPos + 54, yPos + 19);
        }
        noLoop();
    }
    
    manageLetters() {
        // var gameObject = loadJSON('../logic/test.json');
        this.letters  = gameObject.game.you.rack;
        console.log(this.letters);
    }


}
