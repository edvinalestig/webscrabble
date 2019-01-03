class Playfield {

    constructor() {
        this.width  = 871;
        this.height = 871;
        this.colour = (51, 51, 51);
        this.xPos   = 250;
        this.yPos   = 41;
    }

    show() {
        fill(this.colour);
        strokeWeight(1);
        stroke(255, 255, 255);
        rect(this.xPos, this.yPos, this.width, this.height, 0);
    }
}
