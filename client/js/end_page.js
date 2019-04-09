function getReq() {
    let xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
            const resp = JSON.parse(xhttp.responseText);
            document.getElementById("winner").innerHTML = "Player " + resp.winner + " won!";
            document.getElementById("scores").innerHTML = resp.scores;
        }
    };

    xhttp.open("GET", "/winner?room=" + document.location.href.split("?room=")[1], true);
    xhttp.send();
}

getReq();
