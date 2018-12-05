function setup() {
    var canvasDiv = document.getElementById("playfield");
    var canvas = createCanvas(canvasDiv.offsetWidth, canvasDiv.offsetHeight);
    canvas.parent("playfield");
    background(31, 31, 31);
}

function draw() {
    letterTray.show();
}
