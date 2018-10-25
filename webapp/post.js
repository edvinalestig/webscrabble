// Sending and receiving data in JSON format using POST method
//

function sendpost(url, msg) {
    var xhr = new XMLHttpRequest();
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            // var json = JSON.parse(xhr.responseText);
            // console.log(json.email + ", " + json.password);
            console.log("Done")
        }
    };
    var data = JSON.stringify(msg);
    xhr.send(data);
}