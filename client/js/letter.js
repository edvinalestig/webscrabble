class LetterTray {

    constructur(letter) {
        this.width  = 100;
        this.height = 100;
        this.letter = letter;
        this.colour = (49, 49, 49);
    }

    show() {
        var i;
        for (i = LetterTray.height; i < LetterTray.height * 7; i++LetterTray.height) {
            fill(LetterTray.colour);
            rect(200, i, LetterTray.width, LetterTray.height, 10);
        }
    }
}
