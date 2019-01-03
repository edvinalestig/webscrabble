class LetterRack {

    constructor(letters) {
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
            console.log(this.letters[i]);
            // letter(this.letters[i]);

            fill(255);
            text(this.letters[i], this.xPos + 10, yPos + 20);
        }


        // let j = 0;
        // for (let i = this.yPos; i <= this.height * 9; i += this.height + 28.5) {
        //     fill(this.colour);
        //     strokeWeight(0);
        //     rect(this.xPos, i, this.width, this.height, 10);
            
        //     console.log(j);
        //     //letter();
        //     j++;
        // }
        noLoop();
    }
    
    letter(letter_) {
        console.log("text");
        fill(255);
        
        text(letter_, this.xPos, this.yPos);
    }
    
    manageLetters() {
        // var gameObject = loadJSON('../logic/test.json');
        this.letters  = gameObject.game.you.rack;
        console.log(this.letters);
    }
}
