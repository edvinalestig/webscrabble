# Webscrabble
A gymnasiearbete (thesis of upper secondary education) about recreating Scrabble with network support.

## Where we are right now
We are done! Well, it's working as intended at least. There are some rough edges but we are happy with it! Websockets are implemented, the frontend works nicely and the backend follows the rules as it's supposed to do.

## Network functionality
The game uses websockets for communicating between the clients and the server. The server gives data to the client when asked and updates all players when the game updates. This is not something you can do without websockets unless you continuously poll the server for updates.

The libraries used for it are [sinatra](http://sinatrarb.com/) and [sinatra-websocket](https://github.com/gruis/sinatra-websocket). Thanks for making them!

## User interface
The UI is the browser. The main game is displayed on a canvas object using the library [p5.js](https://p5js.org/). The client receives a JSON file with all the information and will display it to the user. The browser handles everything until the player finishes their turn. Then the browser sends an update to the web server. The browser is easy to work with when it comes to network functionality because it is such an integral part of it. It also has native JavaScript support which makes it very easy to manipulate the browser which is exactly what we want. Another bonus is that the game can be run by practically everyone on any computer.