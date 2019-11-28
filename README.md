# Majora's Mask: Actor Viewer

Lua Scripts for BizHawk that create a form window and display actor data.
This works for USA, Japan, and Japan (Rev A).

### Usage

Have the Majora's Mask loaded then run the script.
A form window will be created.
At the top are 3 buttons:
- Get All Actors: Will get all current loaded actors.
- Get Actors by List: Will get all actors loaded in the selected list.
- Get Actors by ID: Will go through all lists until it finds the actor(s).

On the right a list of all the actors will be listed and their address.

Current actor data is updated every frame.

If a new scene is loaded the actor list will be reloaded.
