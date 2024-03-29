require("lua.utils")
--------------------------------------------------------------------------------
podcastSyncScript = "./helpers/cp-podcasts.sh"
function openSwimAdded (device)
	if not(device.eventType == "added" and device.productName == "LC8234xx_17S EVK") then return end

	notify ("⏳ Starting Podcast Sync…")
	hs.task.new(podcastSyncScript, function (exitCode, _, stdErr) -- wrapped like this, since hs.task objects can only be run one time
		if exitCode == 0 then
			notify ("✅ podcast sync finished")
		else
			notify("⚠️️ podcast sync error"..stdErr)
		end
	end):start()
end

openSwimWatcher = hs.usb.watcher.new(openSwimAdded)
openSwimWatcher:start()
