console.clear();
-- Actor Viewer by Jimmie1717
-- Created using BizHawk 1.11.8.2 (lower versions may not work)

core=require "ActorViewer.core";
form=require "ActorViewer.form";

core.getVersion();
-- Create the Form Window.
form.createForm();

-- Run.
while true do
	form.updateActor();
	emu.frameadvance();
end