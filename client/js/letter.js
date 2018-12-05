class LetterTray {

    constructor(letter) {
        this.width  = 100;
        this.height = 100;
        this.letter = letter;
        this.colour = (7, 49, 49);
    }

    show() {

        for (let i = this.height; i <= this.height * 7; i+= this.height) {
            fill(this.colour);
            strokeWeight(0);
            rect(200, i, this.width, this.height, 10);
        }
    }
}

var letterTray = new LetterTray("a")
