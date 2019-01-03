function drawBoard() {
    // canvas.canvas.style("visibility", "visible");
    const tileLength = 45;
    const upLeftCornerX = 200;
    const upLeftCornerY = 20;

    fill(33);
    rect(upLeftCornerX, upLeftCornerY, tileLength * 15, tileLength * 15);

    stroke(200);
    fill(200);

    for (let i = 0; i <= 15; i++) {
        // Horizontal
        line(upLeftCornerX, upLeftCornerY + i * tileLength, upLeftCornerX + 15 * tileLength, upLeftCornerY + i * tileLength);
        // Vertical
        line(upLeftCornerX + i * tileLength, upLeftCornerY, upLeftCornerX + i * tileLength, upLeftCornerY + 15 * tileLength);
    }

    // Centre tile
    const x = upLeftCornerX + tileLength * 7.5;
    const y = upLeftCornerY + tileLength * 7.5;
    star(x, y, 8, 15, 5);
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

function drawTile() {
    
}