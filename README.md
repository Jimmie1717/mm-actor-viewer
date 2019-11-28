# Majora's Mask: Actor Viewer

~[ActorViewer](https://repository-images.githubusercontent.com/224662090/6f7bd180-11c0-11ea-97dd-36c93f061470)

Lua Scripts for BizHawk that create a form window and display actor data.
This works for USA, Japan, and Japan (Rev A).

### Usage

File locations:
```
Bizhawk/
	Lua/
		ActorViewer.lua
		ActorViewer/
			core.lua
			form.lua
```

Have the Majora's Mask ROM loaded then run the ActorViewer.lua script.
A form window will be created.

At the top are 3 buttons:
- Get All Actors: Will get all current loaded actors.
- Get Actors by List: Will get all actors loaded in the selected list.
- Get Actors by ID: Will go through all lists until it finds the actor(s).

On the right a list of all the actors will be listed and their address.
If a new scene is loaded the actor list will be reloaded.

Current actor data is updated every frame.