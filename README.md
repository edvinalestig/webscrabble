# Webscrabble
A gymnasiearbete about recreating Scrabble with LAN-support. We are currently in the very early stages of the project and are focusing on the bare bones of the game.

## Languages
The frontend will be written in JavaScript and the backend will be written in Ruby. 

## Network functionality
The game will utilise websockets to make the playing experience as smooth as possible. This also prevents the clients having to continuesly check with the server if something has updated. 

## Libraries used
The game will be dependent on a few libraries (see https://github.com/itggot-edvin-alestig/gymnasiearbete/network/dependencies).
The client will use p5.js for the graphics and something else for the websocket. The server will use sinatra for the webserver and something for the websockets. What libraries to use for the websockets has not been decided yet. We will probably also use some form of database library.