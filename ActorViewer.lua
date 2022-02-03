-- Actor Viewer by Jimmie1717
-- Created using BizHawk 1.11.8.2 (lower versions may not work)
console.clear();
core=require "ActorViewer.core";
form=require "ActorViewer.form";
if(core.init())then
	form.createForm();
	-- Run.
	while true do
		form.updateActor();
		emu.frameadvance();
	end
end

