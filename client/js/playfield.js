class Playfield {

    constructor() {
        this.width  = 871; // It's a square so only length would suffice?
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

        // Grid
        const tileLength = this.width/15.0;
        for (let i = 0; i <= 15; i++) {
            // Horizontal
            line(this.xPos, this.yPos + i * tileLength, this.xPos + 15 * tileLength, this.yPos + i * tileLength);
            // Vertical
            line(this.xPos + i * tileLength, this.yPos, this.xPos + i * tileLength, this.yPos + 15 * tileLength);
        }

        // Centre tile
        const x = this.xPos + tileLength * 7.5;
        const y = this.yPos + tileLength * 7.5;
        star(x, y, 8, 15, 5);
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