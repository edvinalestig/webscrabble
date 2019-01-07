# Webscrabble
A gymnasiearbete (thesis of upper secondary education) about recreating Scrabble with network support.

## Where we are right now
We are coming closer to a finished product. The game logic is almost done and focus is on the user interface. When the user interface is mostly done we will implement the websockets. After that we are pretty much done with what we wanted to achieve with this project. 

The user interface can currently handle displaying the player's rack and the board. We have already designed how the front end should look like so the only thing we have to do is implement it.

## Network functionality
The game will utilise websockets to make the playing experience as smooth as possible. This also prevents the clients having to continuously check with the server if something has updated. This is not yet implemented.

What is currently implemented is the "bad" method of the client having to check with the server every so often to see if an update has occured.

## User interface
The UI will be the browser. The main game will be displayed on a canvas object using the library [p5.js](https://p5js.org/). The client will receive a JSON file with all the information and will display it to the user. The browser handles everything until the player finishes their turn. Then the browser sends an update to the web server. This is not yet implemented.