function setup() {
    var canvasDiv = document.getElementById("playfield");
    var canvas = createCanvas(canvasDiv.offsetWidth, canvasDiv.offsetHeight);
    canvas.parent("playfield");
    background(51, 51, 51);
    var letterRack = new LetterRack("a")
    letterRack.manageLetters()
}

    console.log(testObject);
function draw() {
    letterRack.show();
}
