// Sending and receiving data in JSON format using POST method

function sendpost(url, msg, callback) {
    let xhr = new XMLHttpRequest();
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 && xhr.status === 200) {
            console.log("Done")
            if (callback) {
                callback();
            }
        }
    };
    const data = JSON.stringify(msg);
    xhr.send(data);
}


function toJson() {
    console.log(arguments.length);
    let d = {
        "tiles": []
    };

    for (let i = 0; i < arguments.length; i++) {
        d.tiles.push({
            "letter": arguments[i][0],
            "row": arguments[i][1],
            "col": arguments[i][2]
        });
    }
    // .replace(/\"/g, "'")
    return d;
}