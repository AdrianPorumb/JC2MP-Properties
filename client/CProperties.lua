function SetWaypointHome(args)
local steamidd=tostring(LocalPlayer:GetSteamId().id)
if steamidd==tostring(args.playersteam) then Waypoint:SetPosition(args.position) else return end
 end
Network:Subscribe("SetWaypointHome",SetWaypointHome)
