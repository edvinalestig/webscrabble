function drawBoard() {
    // canvas.canvas.style("visibility", "visible");
    const tileLength = 45;
    const upLeftCornerX = 200;
    const upLeftCornerY = 20;
    stroke(0);
    fill(0);


    for (let i = 0; i <= 15; i++) {
        console.log(i);
        // Horizontal
        line(upLeftCornerX, upLeftCornerY + i * tileLength, upLeftCornerX + 15 * tileLength, upLeftCornerY + i * tileLength);
        // Vertical
        line(upLeftCornerX + i * tileLength, upLeftCornerY, upLeftCornerX + i * tileLength, upLeftCornerY + 15 * tileLength);
    }
}