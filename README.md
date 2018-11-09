# Webscrabble
A gymnasiearbete (high school exam project) about recreating Scrabble with network support.

## Where we are right now
We have the bare bones of the game up and running, the main focus at the moment is the user interface and the web server.

The game logic can handle:
* Keeping track of players, their points and rack
* Keeping track of letters on the board and in the letter bag
* Point calculation
* Receiving data from the web app
* Formatting data to JSON format for sending to the client
* Error checking
    * Checking if the letters are on the player's rack
    * Checking if the words are valid
    * Checking if tiles are occupied


## Network functionality
The game will utilise websockets to make the playing experience as smooth as possible. This also prevents the clients having to continuesly check with the server if something has updated. This is not yet implemented.

## User interface
The UI will be the browser. The main game will be displayed on a canvas object using the library [p5.js](https://p5js.org/). The client will receive a JSON file with all the information and will display it to the user. The browser handles everything until the player finishes their turn. Then the browser sends an update to the web server. This is not yet implemented.