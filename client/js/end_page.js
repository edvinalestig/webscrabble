function getReq() {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            document.getElementById("winner").innerHTML = "Player " + xhttp.responseText + " won!";
        }
    };

    xhttp.open("GET", "/winner", true);
    xhttp.send();
}

getReq();
