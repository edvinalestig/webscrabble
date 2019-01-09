function sendToServer(object) {
    object.player = playerNumber - 1
    postJson("/testpost", object, getJson);
}


function postJson(url, msg, callback) {
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
    console.log(data);
    xhr.send(data);
}