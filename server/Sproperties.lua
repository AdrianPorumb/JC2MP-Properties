--[[
Idea : using checkpoints for 

properties	(stands,windmills, ad panels, pumping stations, village shops, city shops,turist resorts, light houses,oil rigs, )-icon 12 , 

houses 
		with interiors (small shacks, shacks,houses, big houses, temples), 

			no interiors(apartments, houses with single level, houses with 2 levels, penthouses, palaces,villas,mansions), 

land for agriculture, 
fishing,
bus lines 
trash lines.

--]]
class 'Properties'
function Properties:__init()
self.ownersclub={} -- has house locations,player steamid for respawning
self.playerconnect={}
self.comercialproperties={} -- table for locating nearest comercial properties location and steamID
------------------------------------------------------------------------------
self.playerincheckpoint={} 	-- has player steamid and checkpoint id 
self.windmills={}  			--   1000000
self.pipelines={} 			--   1000000
self.adpannels={}  			--   1000000
self.pumpingstations={}  	--   1000000
self.villageshops={}  		--   1000000   
self.cityshops={}			--   5000000
self.lighthouses={}   		--   1000000
self.oilrigs={}				-- 100000000
self.smallshackinteriors={} --   1000000
self.shacksinteriors={}		--   2000000
self.housesinteriors={}		--   5000000
self.bighouseinteriors={}	--  10000000
self.apartments={}			--   1000000
self.houses1lvl={}			--   2000000
self.houses2lvl={}			-- 	 5000000
self.penthouses={}			-- 100000000
self.palaces={}				-- 500000000
self.villas={}				-- 	75000000
self.mansions={}			-- 250000000

self.GroundBase={}			-- 250 000 000
self.NavalBase={}			-- 100 000 000
self.CommOutpost={}			-- 10 000 000
self.MobileRadar={}			-- 5 000 000
self.bases={}
self.WarningLineNavalBase ={}
self.WarningLineGroundBase={} 
self.WarningLineCommOutpost={}
self.WarningLineMobileRadar={}
---------------------------------------------------------------------------------
self.pltonline={} -- table of checkpointid and hours online ,updated once per hour ,not for houses of any type

---------------------------control variables---------------------------------
self.defaultnewplayerpos=Vector3(-6733, 221,-3591)
-----------------------------------------------------------------------------
Events:Subscribe("ModuleLoad", self, self.Loadfromdb )
Events:Subscribe("ModuleLoad", self, self.MilitaryBasesLoadfromdb )
Events:Subscribe("PlayerEnterCheckpoint",self, self.Entercheckpoint)
Events:Subscribe("PlayerExitCheckpoint",self, self.Exitcheckpoint)
Events:Subscribe("PlayerChat",self,self.Chatcommands)
Events:Subscribe("ModuleUnload",self,self.Cleanup)
Events:Subscribe("PlayerQuit",self,self.Playerquits)
Events:Subscribe("PlayerQuit",self,self.Zplayerposupdate)
Events:Subscribe("ModuleLoad",self,self.Timeonline)
Events:Subscribe("Ora",self,self.Timeincrease)
Events:Subscribe("PlayerSpawn",self,self.ReturnHome)
Events:Subscribe("Minutar",self,self.Zplayerposupdate)
Events:Subscribe("PlayerDeath",self,self.PlayerDeath)
end

function Properties:Loadfromdb()
-- ALL SQL QUERIES RETURN STRINGS - MUST COERCE
local rresultlinefromdb=SQL:Query('SELECT * FROM properties'):Execute() 
-- properties has position,text 
for row,column in ipairs(rresultlinefromdb) do
			local pretext=column.position:split(",")
			local actualpos=Vector3(tonumber(pretext[1]),tonumber(pretext[2]),tonumber(pretext[3]) )
		
			local innertext=tostring(column.text)
			local text=column.text:split(",")
			local owner=tostring(text[1])
			local ownername=tostring(text[2])
			local renter= tostring(text[3])
			local rentername= tostring(text[4])
			local security=tonumber(text[5])
			local ltype=tostring(text[6]) -- this determines price, icon and activation_box
			local price,activbox,zicon=1,1,1
			if owner~=0 and ltype=="bighouseinteriors" or ltype=="penthouses" or ltype=="villas" or ltype=="mansions" or ltype=="palaces" or ltype=="apartments" or ltype=="shacksinteriors" or ltype=="houses1lvl" or ltype=="smallshackinteriors"  or ltype=="housesinteriors" or ltype=="houses2lvl" then self.ownersclub[actualpos]=owner -- this is the basis of players returning to their place after death.but only if only homes are used
			else self.comercialproperties[actualpos]=owner end -- basis of locating  owned comercial properties
			
			if ltype=="adpannels" or ltype=="pipelines" or ltype=="windmills" or ltype=="pumpingstations" or ltype=="villageshops" or ltype=="lighthouses" or ltype=="apartments" or ltype=="smallshackinteriors"  then
				 price = 1000000
				 activbox=Vector3(2,2,2) 
				elseif ltype=="oilrigs" or ltype=="penthouses" or ltype=="villas" then
				price =100000000
				activbox=Vector3(20,20,20)
				elseif ltype=="shacksinteriors" or ltype=="houses1lvl" then
				price= 2000000
				activbox=Vector3(8,8,8)
				elseif ltype=="housesinteriors" or ltype=="houses2lvl" then
				price = 5000000
				activbox=Vector3(10,10,10)
				elseif ltype=="cityshops" then	price=5000000			activbox=Vector3(2,2,2)
				elseif ltype=="bighouseinteriors" then price= 75000000 	activbox=Vector3(10,10,10)
				elseif ltype=="mansions" then price = 25000000          activbox=Vector3(25,25,25)
				elseif ltype=="palaces"  then price= 500000000          activbox=Vector3(45,45,45)
			end
			if ltype=="adpannels" or ltype=="pipelines" or ltype=="windmills" or ltype=="pumpingstations" or ltype=="villageshops" or ltype=="lighthouses" or ltype=="oilrigs" or ltype=="cityshops"  then
				zicon=12
				elseif ltype=="bighouseinteriors" or ltype=="penthouses" or ltype=="villas" or ltype=="mansions" or ltype=="palaces"then
				zicon=11 -- red up arrow
				elseif ltype=="apartments" or ltype=="shacksinteriors" or ltype=="houses1lvl" or ltype=="smallshackinteriors"  or ltype=="housesinteriors" or ltype=="houses2lvl"then
				zicon=30
			end
			local chktext=tostring(owner..","..ownername..","..renter..","..rentername..","..security..","..price..","..ltype)
			
 local chkcreation={
 text=chktext,				-- this appears only on " Distance text supported" in wiki
 type= zicon, --13 Colonel ,16 scorpion red ,28 scorpion white ,29 Black first aid icon,8 first aid 12- cash 30 square
 position=actualpos,
 activation_box=activbox,	-- size of checkpoint
 despawn_on_enter=false,    --destroyed after use
 create_checkpoint=false,   -- events trigger
 create_trigger=true,       -- ring of fire
create_indicator=true,      -- show icon
world=DefaultWorld 
 }
 local chk=Checkpoint.Create(chkcreation)
 chk:SetStreamDistance(100) -- new stuff
 if ltype=="adpannels" 				then table.insert(self.adpannels ,chk )  -- each checkpoint in its table and a table for each
 elseif ltype=="pipelines" 			then table.insert(self.pipelines ,chk )
  elseif ltype=="windmills" 		then table.insert(self.windmills ,chk )
 elseif ltype=="pumpingstations" 	then table.insert(self.pumpingstations ,chk )
 elseif ltype=="villageshops" 		then table.insert(self.villageshops ,chk )
 elseif ltype=="lighthouses"  		then table.insert(self.lighthouses ,chk )
 elseif ltype=="oilrigs" 			then table.insert(self.oilrigs ,chk )
 elseif ltype=="cityshops" 			then table.insert(self.cityshops ,chk )				
 elseif ltype=="bighouseinteriors"	then table.insert(self.bighouseinteriors ,chk )
elseif  ltype=="penthouses" 		then table.insert(self.penthouses ,chk )
elseif 	ltype=="villas" 			then table.insert(self.villas ,chk )
elseif 	ltype=="mansions" 			then table.insert(self.mansions ,chk )
elseif ltype=="palaces"				then table.insert(self.palaces ,chk )
elseif ltype=="apartments" 			then table.insert(self.apartments ,chk )
elseif ltype=="shacksinteriors" 	then table.insert(self.shacksinteriors ,chk )
elseif ltype=="houses1lvl" 			then table.insert(self.houses1lvl ,chk )
elseif ltype=="smallshackinteriors" then table.insert(self.smallshackinteriors ,chk )
elseif ltype=="housesinteriors" 	then table.insert(self.housesinteriors ,chk )
elseif ltype=="houses2lvl"			then table.insert(self.houses2lvl ,chk )
				
end  
end
end
 

function Properties:MilitaryBasesLoadfromdb()
-- ALL SQL QUERIES RETURN STRINGS - MUST COERCE
local rresultlinefromdb=SQL:Query('SELECT * FROM militarybases'):Execute() 
-- properties has position,text 
for row,column in ipairs(rresultlinefromdb) do
			local pretext=column.position:split(",")
			local actualpos=Vector3(tonumber(pretext[1]),tonumber(pretext[2]),tonumber(pretext[3]) )
			local innertext=tostring(column.text)
			local text=column.text:split(",")
			local faction=tostring(text[1])
			local basename=tostring(text[2])
			local reserve2= tostring(text[3])
			local reserve3= tostring(text[4])
			local security=tonumber(text[5])
			local ltype=tostring(text[6]) -- this determines price, icon and activation_box
			local price,activbox,zicon=1,1,1
			if faction~="0" and ltype=="Ground Base" or ltype=="Naval Base" or ltype=="Comm Outpost" or ltype=="Mobile Radar"  then self.bases[actualpos]=faction -- this is the basis of players returning to their place after death.but only if only bases are used
			end 
			
				if ltype=="Naval Base"  then				price = 100000000			activbox=Vector3(50,50,50) 
				elseif ltype=="Comm Outpost" then		price =10000000				activbox=Vector3(20,20,20)
				elseif ltype=="Ground Base" then 		price= 25000000 			activbox=Vector3(75,75,75)
				elseif ltype=="Mobile Radar" then		price = 5000000        		activbox=Vector3(15,15,15)
					end
		zicon=14 -- artillery
				local chktext=tostring(faction..","..basename..","..reserve2..","..reserve3..","..security..","..price..","..ltype)
			
 local chkcreation={
 text=chktext,				-- this appears only on " Distance text supported" in wiki
 type= zicon, --13 Colonel ,16 scorpion red ,28 scorpion white ,29 Black first aid icon,8 first aid 12- cash 30 square
 position=actualpos,
 activation_box=activbox,	-- size of checkpoint
 despawn_on_enter=false,    --destroyed after use
 create_checkpoint=false,   -- ring of fire
 create_trigger=true,       -- events trigger
create_indicator=true,      -- show icon
world=DefaultWorld 
 }
 local chk=Checkpoint.Create(chkcreation)
 chk:SetStreamDistance(200) 
 self:WarningLineCreation(ltype,actualpos,chktext)
 if ltype=="Naval Base" 				then table.insert(self.NavalBase ,chk )  -- each checkpoint in its table and a table for each
elseif ltype=="Ground Base"				then table.insert(self.GroundBase ,chk )
elseif ltype=="Comm Outpost" 			then table.insert(self.CommOutpost ,chk )
elseif ltype=="Mobile Radar" 	then table.insert(self.MobileRadar ,chk )
				
end  
end
end

function Properties:WarningLineCreation(ltype,pos,chktext)
local activbox=1
if ltype=="Naval Base"  	then			activbox=Vector3(100,100,100)
elseif ltype=="Comm Outpost" then		activbox=Vector3(40,40,40)
elseif ltype=="Ground Base" then 		activbox=Vector3(100,100,100)
elseif ltype=="Mobile Radar" then		activbox=Vector3(30,30,30)
end
local chkcreation={
 text=chktext,				-- this appears only on " Distance text supported" in wiki
 type= zicon, --13 Colonel ,16 scorpion red ,28 scorpion white ,29 Black first aid icon,8 first aid 12- cash 30 square
 position=pos,
 activation_box=activbox,	-- size of checkpoint
 despawn_on_enter=false,    --destroyed after use
 create_checkpoint=false,   -- ring of fire
 create_trigger=true,       -- events trigger
create_indicator=false,      -- show icon
world=DefaultWorld 
 }
 local chk=Checkpoint.Create(chkcreation)
 chk:SetStreamDistance(120) 
 if ltype=="Naval Base" 			then table.insert(self.WarningLineNavalBase ,chk )  
elseif ltype=="Ground Base"			then table.insert(self.WarningLineGroundBase ,chk )
elseif ltype=="Comm Outpost"		then table.insert(self.WarningLineCommOutpost ,chk )
elseif ltype=="Mobile Radar"		then table.insert(self.WarningLineMobileRadar ,chk )
end
end 
 
function Properties:Timeonline (args)
for k,v in ipairs(self.windmills) do
local ckhid=v:GetId()-- id of the checkpoint is used as key in pltonline table
self.pltonline[ckhid]=0
end
for k,v in ipairs(self.pipelines) do
local ckhid=v:GetId()
self.pltonline[ckhid]=0
end
for k,v in ipairs(self.adpannels) do
local ckhid=v:GetId()
self.pltonline[ckhid]=0
end

for k,v in ipairs(self.villageshops) do
local ckhid=v:GetId()
self.pltonline[ckhid]=0
end

for k,v in ipairs(self.cityshops) do
local ckhid=v:GetId()
self.pltonline[ckhid]=0
end

for k,v in ipairs(self.pumpingstations) do
local ckhid=v:GetId()
self.pltonline[ckhid]=0
end

for k,v in ipairs(self.lighthouses) do
local ckhid=v:GetId()
self.pltonline[ckhid]=0
end

for k,v in ipairs(self.oilrigs) do
local ckhid=v:GetId()
self.pltonline[ckhid]=0
end

end

function Properties:Timeincrease() -- sub to Ora 
for k,v in pairs(self.pltonline) do
self.pltonline[k]=v+1
-- print("Timeincrease on" )
-- print ("self.pltonline key",k,"self.pltonline value",v )
end
end 
   
function Properties:Entercheckpoint(args)-- works

local iCheckpoint=tonumber(args.checkpoint:GetId()) 
	for k,v in ipairs(self.pipelines) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PropTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.windmills) do 
		local tablechk=v:GetId()
			if tablechk==iCheckpoint then
			--print("tablechkwindmills=",tablechk,"iCheckpoint=",iCheckpoint )
				self:PropTreatmentDecision(args.player,args.checkpoint)
			end
	end
	for k,v in ipairs(self.adpannels) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PropTreatmentDecision(args.player,args.checkpoint)
		end
	end
	
	for k,v in ipairs(self.pumpingstations) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PropTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.villageshops) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PropTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.lighthouses) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PropTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.oilrigs) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PropTreatmentDecision(args.player,args.checkpoint)
		end
	end
for k,v in ipairs(self.cityshops) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PropTreatmentDecision(args.player,args.checkpoint)
		end
	end
for k,v in ipairs(self.bighouseinteriors) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
for k,v in ipairs(self.penthouses) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
for k,v in ipairs(self.villas) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
for k,v in ipairs(self.mansions) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
for k,v in ipairs(self.palaces) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
for k,v in ipairs(self.apartments) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
	
	for k,v in ipairs(self.shacksinteriors) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.houses1lvl) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.smallshackinteriors) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
	
	for k,v in ipairs(self.housesinteriors) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
	
	for k,v in ipairs(self.houses2lvl) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:PplTreatmentDecision(args.player,args.checkpoint)
		end
	end
	local iCheckpoint=tonumber(args.checkpoint:GetId()) 
	for k,v in ipairs(self.WarningLineCommOutpost) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:WarningLineTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.WarningLineGroundBase) do 
		local tablechk=v:GetId()
			if tablechk==iCheckpoint then
			--print("tablechkwindmills=",tablechk,"iCheckpoint=",iCheckpoint )
				self:WarningLineTreatmentDecision(args.player,args.checkpoint)
			end
	end
	for k,v in ipairs(self.WarningLineMobileRadar) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:WarningLineTreatmentDecision(args.player,args.checkpoint)
		end
	end
	
	for k,v in ipairs(self.WarningLineNavalBase) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:WarningLineTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.CommOutpost) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:MilitaryTreatmentDecision(args.player,args.checkpoint)
		end
	end
	for k,v in ipairs(self.GroundBase) do 
		local tablechk=v:GetId()
			if tablechk==iCheckpoint then
			--print("tablechkwindmills=",tablechk,"iCheckpoint=",iCheckpoint )
				self:MilitaryTreatmentDecision(args.player,args.checkpoint)
			end
	end
	for k,v in ipairs(self.MobileRadar) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:MilitaryTreatmentDecision(args.player,args.checkpoint)
		end
	end
	
	for k,v in ipairs(self.NavalBase) do 
	local tablechk=v:GetId()
		if tablechk==iCheckpoint then
		--print("tablechk=",tablechk,"iCheckpoint=",iCheckpoint )
			self:MilitaryTreatmentDecision(args.player,args.checkpoint)
		end
	end

end

function Properties:PplTreatmentDecision(player,checkpoint)

local iCheckpoint=tonumber(checkpoint:GetId()) -- works
local owner,ownername,renter,rentername,security,price,ltype=self:XXCheckpointtextextractor(checkpoint:GetText())
local available=string.format("Price  %d ,use /buy to own",price)
--local q="This is Checkpoint number "
--local textreveal="The text is "
--local vehicle=player:GetVehicle()
--local itext=checkpoint:GetText()-- works
local rubnsteamid=tostring(player:GetSteamId().id)--steamid of player in checkpoint
--player:SendChatMessage(q .. iCheckpoint,Color.White )
--player:SendChatMessage(textreveal .. itext,Color.Red ) -- works
self.playerincheckpoint[rubnsteamid]=iCheckpoint -- works 
--print( "playerincheckpoint no",self.playerincheckpoint[rubnsteamid])
--print(owner,ownername,renter, rentername,security,price)
if IsValid(player) and owner=="0" then --if not owned triggers first 
		player:SendChatMessage(available,Color.White)
	--	print(" if")
		self.pltonline[iCheckpoint]=0
	elseif IsValid(player) and owner~=rubnsteamid and renter==rubnsteamid  then -- renter is home
		self:WelcomeHome(player)
		--print(" elseif0")
	elseif IsValid(player)and renter~=rubnsteamid and owner==rubnsteamid  then -- owner is home
		self:WelcomeHome(player)
		self:SecurityDisplay(player,security,price)
		--self:SmallRewards(player,price,iCheckpoint)
		--print(" elseif1")
	elseif IsValid(player) and owner ~=rubnsteamid and renter~=rubnsteamid then -- for strangers
	--	print(" elseif2")
		self:Security(player,security)
	--	print(" elseif2end")
end
end
function Properties:PropTreatmentDecision(player,checkpoint)

local iCheckpoint=tonumber(checkpoint:GetId()) -- works
local owner,ownername,renter,rentername,security,price,ltype=self:XXCheckpointtextextractor(checkpoint:GetText())
local available=string.format("Price: %d ,pays %d per hour,use /buy  to purchase",price,price/200)
--local q="This is Checkpoint number "
--local textreveal="The text is "
--local vehicle=player:GetVehicle()
--local itext=checkpoint:GetText()-- works
local rubnsteamid=tostring(player:GetSteamId().id)--steamid of player in checkpoint
--player:SendChatMessage(q .. iCheckpoint,Color.White )
--player:SendChatMessage(textreveal .. itext,Color.Red ) -- works
self.playerincheckpoint[rubnsteamid]=iCheckpoint -- works 
--print( "playerincheckpoint no",self.playerincheckpoint[rubnsteamid])
--print(owner,ownername,renter, rentername,security,price)
if IsValid(player) and owner=="0" then --if not owned triggers first 
		player:SendChatMessage(available,Color.White)
		--print(" if")
		self.pltonline[iCheckpoint]=0
	elseif IsValid(player) and owner~=rubnsteamid and renter==rubnsteamid  then -- renter is home
		--self:WelcomeHome(player)
	--	print(" elseif0")
	elseif IsValid(player)and renter~=rubnsteamid and owner==rubnsteamid  then -- owner is home
		--self:WelcomeHome(player)
		self:SmallRewards(player,price,iCheckpoint)
		self:SecurityDisplay(player,security,price)
	--	print(" elseif1")
	elseif IsValid(player) and owner ~=rubnsteamid and renter~=rubnsteamid then -- for strangers
	--	print(" elseif2")
		self:Security(player,security)
	--	print(" elseif2end")
end
end
	
function Properties:MilitaryTreatmentDecision(player,checkpoint)

local iCheckpoint=tonumber(checkpoint:GetId()) -- works
local faction,basename,reserve2,reserve3,security,price,ltype=self:MilitaryCheckpointtextextractor(checkpoint:GetText())
local available=string.format("Price  %d ,use /buy to own if you are in a faction/tribe/gang/mafia",price)
--local q="This is Checkpoint number "
--local textreveal="The text is "
--local vehicle=player:GetVehicle()
--local itext=checkpoint:GetText()-- works
local rubnsteamid=tostring(player:GetSteamId().id)--steamid of player in checkpoint
local playerfaction=player:GetValue("Faction")
--player:SendChatMessage(q .. iCheckpoint,Color.White )
--player:SendChatMessage(textreveal .. itext,Color.Red ) -- works
self.playerincheckpoint[rubnsteamid]=iCheckpoint -- works 

--print( "playerincheckpoint no",self.playerincheckpoint[rubnsteamid])
--print(faction,basename,reserve2, reserve3,security,price)
if IsValid(player) and faction=="0" then --if not owned triggers first 
		player:SendChatMessage(available,Color.White)
	--	print(" if")
	elseif IsValid(player)and faction==playerfaction  then -- faction is home
		self:WelcomeHome(player)
		self:SecurityDisplay(player,security,price)
		--self:SmallRewards(player,price,iCheckpoint)
		--print(" elseif1")
	elseif IsValid(player) and faction ~=playerfaction then -- for strangers
	--	print(" elseif2")
		self:MSecurity(player,security)
	--	print(" elseif2end")
end
end	

function Properties:WarningLineTreatmentDecision(player,checkpoint)

local iCheckpoint=tonumber(checkpoint:GetId()) -- works
local faction,basename,reserve2,reserve3,security,price,ltype=self:MilitaryCheckpointtextextractor(checkpoint:GetText())
local warning="Warning this base belongs to "..faction

local rubnsteamid=tostring(player:GetSteamId().id)--steamid of player in checkpoint
local playerfaction=player:GetValue("Faction")
--player:SendChatMessage(q .. iCheckpoint,Color.White )
--player:SendChatMessage(textreveal .. itext,Color.Red ) -- works
self.playerincheckpoint[rubnsteamid]=iCheckpoint -- works 
if IsValid(player) and faction~="0" and faction ~=playerfaction then 
player:SendChatMessage(warning,Color.Pink)
end
end



function Properties:SecurityDisplay(player,security,price)
		local secactive=0
		if security==0 then secactive="disabled" elseif security==1 then secactive="alpha" elseif security==2 then secactive="beta"
		elseif security==3 then secactive="delta" elseif security==4 then secactive="gamma" elseif security==5 then secactive="omega" end
		local alphaprice=price/10
		local betaprice =price/8
		local deltaprice=price/6
		local gammaprice=price/5
		local omegaprice=price/4
		local SecurityDisplaymsg=string.format("Security status: %s",secactive)
		local SecurityDisplayMsgUpgrade=string.format("Security options prices :  /alpha=%d, /beta=%d, /delta=%d, /gamma=%d, /omega=%d ",alphaprice,betaprice,deltaprice,gammaprice,omegaprice)
	player:SendChatMessage(SecurityDisplaymsg,Color.White)
	player:SendChatMessage(SecurityDisplayMsgUpgrade,Color.White)
end
function Properties:WelcomeHome(player) -- works 
local welcome=" Welcome Home "
if IsValid(player) then 	player:SendChatMessage(welcome .. player:GetName(),Color.White)
player:SetHealth(1)end
local vehicle=player:GetVehicle()
if vehicle and IsValid(player) and IsValid(vehicle) then 
   vehicle:SetHealth(1)
end
end
 
function Properties:Security(player,level)
local p = player
local v = player:GetVehicle()
local lvl5message   =string.format("Property Defence ON :Kill Order %s Executed ",p:GetName())
local level4message =string.format("Property Defence ON :Entry Denied to %s !",p:GetName())
local level3message =string.format("Property Defence ON :Entry Denied to %s !",p:GetName())
local level2message =string.format("Property Defence ON :Entry Denied to %s !",p:GetName())
local level1message =string.format("Property Defence ON :Entry Denied to %s !",p:GetName())
if level == 5 then
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.9)end
		if IsValid(p) then 
		p:SetHealth(0) end
		Chat:Broadcast(lvl5message,Color.Red)
	elseif level == 4 then 
		if IsValid(p) then 
		p:SetHealth(0.2) end
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.7)end
		self:NoEntry(p)
		Chat:Broadcast(level4message,Color.Red)
	elseif level == 3 then
		if IsValid(p) then 
		p:SetHealth(p:GetHealth()- 0.5) end
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.5)end
		self:NoEntry(p)
		Chat:Broadcast(level3message,Color.Red)
	elseif level == 2 then
		if IsValid(p) then 
		p:SetHealth(p:GetHealth()- 0.2) end
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.2)end
		self:NoEntry(p)
		Chat:Broadcast(level2message,Color.Red)
	elseif level == 1 then
		self:NoEntry(p)
		Chat:Broadcast(level1message,Color.Red)
	end
end

function Properties:MSecurity(player,level)
local p = player
local v = player:GetVehicle()
local lvl5message   =string.format("Guard:Kill Order %s Executed ",p:GetName())
local level4message =string.format("Guard:Entry Denied to %s !",p:GetName())
local level3message =string.format("Guard:Entry Denied to %s !",p:GetName())
local level2message =string.format("Guard:Entry Denied to %s !",p:GetName())
local level1message =string.format("Guard:Entry Denied to %s !",p:GetName())
if level == 5 then
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.9)end
		if IsValid(p) then 
		p:SetHealth(0) end
		Chat:Broadcast(lvl5message,Color.Red)
	elseif level == 4 then 
		if IsValid(p) then 
		p:SetHealth(0.2) end
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.7)end
		self:NoEntry(p)
		Chat:Broadcast(level4message,Color.Red)
	elseif level == 3 then
		if IsValid(p) then 
		p:SetHealth(p:GetHealth()- 0.5) end
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.5)end
		self:NoEntry(p)
		Chat:Broadcast(level3message,Color.Red)
	elseif level == 2 then
		if IsValid(p) then 
		p:SetHealth(p:GetHealth()- 0.2) end
		if IsValid(v)then
		v:SetHealth(v:GetHealth()-0.2)end
		self:NoEntry(p)
		Chat:Broadcast(level2message,Color.Red)
	elseif level == 1 then
		self:NoEntry(p)
		Chat:Broadcast(level1message,Color.Red)
	end
end


function Properties:NoEntry(player) -- stops player and vehicle;works
local p= player
local v=player:GetVehicle()
local pangle=p:GetAngle()
if IsValid(p) and not p:InVehicle() then
p:SetAngle(-pangle)-- works
p:SetPosition(p:GetPosition()+Vector3(0,1,2) )
elseif IsValid(p) and IsValid(v) and p:InVehicle() then
local Vstop=Vector3(0,0,3)
v:SetPosition(v:GetPosition()-Vstop)
v:SetLinearVelocity(Vstop)
end
end

function Properties:SmallRewards(player,price,iCheckpoint) -- good
local smallreward=(price/200) * self.pltonline[iCheckpoint]
player:SetMoney(player:GetMoney()+smallreward )
self.pltonline[iCheckpoint]=0
end

function Properties:Exitcheckpoint(args)
local rubnsteamid=tostring(args.player:GetSteamId().id)
self.playerincheckpoint[rubnsteamid]=nil
--local m=" Good bye "
--args.player:SendChatMessage(m,Color.Blue)
-- print( "0=removal succesfull",tonumber(#self.playerincheckpoint))
end

function Properties:ReturnHome(args) -- works
local deathpos=args.player:GetValue("Deathlocation")
--local templocation={}
local steamidd=tostring(args.player:GetSteamId().id)
--local tempdistances={}
local playerfaction=args.player:GetValue("Faction")
 --print("faction",playerfaction)
 local hasbase=table.find(self.bases,playerfaction)
 if deathpos==nil then -- if player is connecting
--print("player connecting")
SQL:Execute("CREATE TABLE IF NOT EXISTS xplayerspositions (steamID VARCHAR UNIQUE, posX REAL, posY REAL, posZ REAL)")
self.playerconnect[steamidd] = args.player -- put him in the players DB
	local qry = SQL:Query("SELECT steamID FROM xplayerspositions WHERE steamID = (?) LIMIT 1") -- return steamID and pos'es from 1 row with this steamID
	qry:Bind(1, steamidd)
	local result = qry:Execute()
	if #result > 0 then  -- restore pos on connection
		--print("Already in DB")
		local qry = SQL:Query("SELECT posX, posY, posZ FROM xplayerspositions WHERE steamID = (?) LIMIT 1")
		qry:Bind(1, steamidd)
		local postable = qry:Execute()
		local plypos = Vector3(tonumber(postable[1].posX), tonumber(postable[1].posY), tonumber(postable[1].posZ)) 
		args.player:SetPosition(plypos+Vector3(0,1,0)) -- place him here
		return false
	else -- if first join
	--print("player first join")
	args.player:SetPosition(self.defaultnewplayerpos)
	local position=args.player:GetPosition()
		local command = SQL:Command("INSERT INTO xplayerspositions (steamID, posX, posY, posZ) VALUES (?, ?, ?, ?)")
		command:Bind(1, steamidd)
		command:Bind(2, position.x)
		command:Bind(3, position.y)
		command:Bind(4, position.z)
		command:Execute() -- insert position in db

		return false 	end

elseif deathpos ~=nil and not playerfaction then -- if player is not in a faction
--print("player is not in a faction")
self:Findplayerspawn(args.player,self.ownersclub)
 elseif deathpos ~=nil and  playerfaction and not hasbase then -- if the clan doesn't have a base
 -- print("no base")
 self:Findplayerspawn(args.player,self.ownersclub)
elseif deathpos ~=nil and  playerfaction and hasbase then -- the clan has a base
 --print("has base")
 local templocation,tempdistances={},{}
for k,v in pairs(self.bases) do -- k is players base position, v is player faction
	if v==playerfaction then table.insert(templocation,k) end end -- now templocation has all faction bases positions 
if #templocation==1 then args.player:SetPosition(templocation[1])  
	elseif #templocation>1 then		
	for k,v in ipairs(templocation) do 
			local ds=Vector3.Distance(v,deathpos)	-- calculate distances from deathpos to each base
			table.insert(tempdistances,k,ds)		-- insert into tempdistances using the same key as templocation
			end
	local mindistance=math.min(table.unpack(tempdistances))
	for k,v in ipairs(tempdistances) do
			if v==mindistance then 
				args.player:SetPosition(templocation[k]) 
	end
end
end
end
return false end

function Properties:Findplayerspawn(player,atable)
local Homelessppl={								-- if player  has no homes he spawns to one of these if he is new then he drops from the sky above the financial city.
Vector3(5411, 204, 13990),
Vector3(1081, 201, -1586),
Vector3(722, 223, -2559),
Vector3(226, 204, -12491),
Vector3(-370, 214, -12972),
Vector3(-12638, 212, 15134),
Vector3(-463, 243, -12060),
Vector3(-6996, 316, 5426),
Vector3(-10271, 202, -3012),
Vector3(-12632, 217, -4819),
Vector3(-15225, 202, -2878),
Vector3(-12987, 202, -1007),
Vector3(-13255, 202, -1646),
Vector3(-11977, 202, -626),
Vector3(-15613, 202, -2872),
Vector3( -15141, 202, -2159),
Vector3(-12583, 202, -3939.8),
Vector3(-11793, 202, -5285),
Vector3(-11039.33, 202, -3794),
Vector3(-9964, 202, -3575),
Vector3(-10066, 202, -2205),  
 }
local templocation={}
local steamidd=tostring(player:GetSteamId().id)
local tempdistances={}
local deathpos=player:GetValue("Deathlocation")

for k,v in pairs(atable) do -- k is players house position, v is player steamID
	if v==steamidd then table.insert(templocation,k) end end -- now templocation has all players house positions 
if #templocation==0 then player:SetPosition(table.randomvalue(Homelessppl))return false -- no house so you get a random spawn
	elseif #templocation==1 then player:SetPosition(templocation[1]) return false -- single house situation
	elseif #templocation>1 then		-- many houses situation
	for k,v in ipairs(templocation) do 
			local ds=Vector3.Distance(v,deathpos)	-- calculate distances from deathpos to each house
			table.insert(tempdistances,k,ds)		-- insert into tempdistances using the same key as templocation
			end
	local mindistance=math.min(table.unpack(tempdistances))
	for k,v in ipairs(tempdistances) do
			if v==mindistance then 
				player:SetPosition(templocation[k]) -- player spawns at the closest house he owns
			return false end
	end
end
end
function Properties:PlayerDeath(args)  --works
local pos= args.player:GetPosition()
args.player:SetNetworkValue("Deathlocation",pos)
args.player:SetPosition(pos+Vector3(0,3000,0)) -- after death we send them to the sky were they get a glimpse of sky and then return
if args.player:GetMoney()>= 100000000 and IsValid(args.killer) then 
local eattherich=args.player:GetMoney()/100
args.killer:SetMoney(args.killer:GetMoney()+ eattherich)
args.killer:SendChatMessage("You killed a rich person !!!",Color.White)
args.player:SetMoney(args.player:GetMoney()-eattherich )
args.player:SendChatMessage("You lost some money!",Color.White)
end
end

function Properties:Zplayerposupdate() -- works
local xplayer=1
for player in Server:GetPlayers() do 
xplayer=player
local update = SQL:Command("UPDATE xplayerspositions SET posX = ?, posY = ?, posZ = ? WHERE steamID = (?)")
				update:Bind(1, xplayer:GetPosition().x)
				update:Bind(2, xplayer:GetPosition().y)
				update:Bind(3, xplayer:GetPosition().z)
				update:Bind(4, tostring(xplayer:GetSteamId().id))
				update:Execute()
end
end
function Properties:Chatcommands(args)	
	local rubnsteamid=tostring(args.player:GetSteamId().id)
	local thisisyours="#########TRANSACTION SUCCESSFUL ##########"
	local playerfaction=args.player:GetValue("Faction")
	local msg = {}
	 msg = args.text:split(" ") --splits the args.text  by spaces and puts them in a table (msg)
	 if	msg[1]=="/home"and IsValid(args.player) then --find the closest home and set a waypoint (client side) to it
		--print("/home")
		local templocation,tempdistances={},{}
			for k,v in pairs(self.ownersclub) do -- k is players house position, v is player steamID
				if v==rubnsteamid then table.insert(templocation,k) end 
				end -- now templocation has all players house positions
						--print("ownersclub")					
			if #templocation==0 then args.player:SendChatMessage("You need a home to use this",Color.Red)	return false 
			elseif #templocation==1 then 
				local transfertabletoclientwithsteamidandpos={}
				transfertabletoclientwithsteamidandpos.playersteam=rubnsteamid
				transfertabletoclientwithsteamidandpos.position=templocation[1]
				Network:Send(args.player,"SetWaypointHome",transfertabletoclientwithsteamidandpos) return false 
			elseif #templocation>1 then		
					for k,v in ipairs(templocation) do 
					local ds=Vector3.Distance(v,args.player:GetPosition())	-- calculate distances from deathpos to each house
					table.insert(tempdistances,k,ds)		-- insert into tempdistances using the same key as templocation
					end
			end
	local mindistance=math.min(table.unpack(tempdistances))
		for k,v in ipairs(tempdistances) do
			if v==mindistance then 
			local transfertabletoclientwithsteamidandpos={}
			transfertabletoclientwithsteamidandpos.playersteam=rubnsteamid
			transfertabletoclientwithsteamidandpos.position=templocation[k]
				Network:Send(args.player,"SetWaypointHome",transfertabletoclientwithsteamidandpos)
				
			end
		end
	end
		 if	msg[1]=="/comercial"and IsValid(args.player) then --find the closest comercial property and set a waypoint (client side) to it
		--print("/home")
		local templocation,tempdistances={},{}
			for k,v in pairs(self.comercialproperties) do -- k is players house position, v is player steamID
				if v==rubnsteamid then table.insert(templocation,k) end 
				end -- now templocation has all players house positions
						--print("ownersclub")					
			if #templocation==0 then args.player:SendChatMessage("You need a comercial property to use this",Color.Red)	return false 
			elseif #templocation==1 then 
				local transfertabletoclientwithsteamidandpos={}
				transfertabletoclientwithsteamidandpos.playersteam=rubnsteamid
				transfertabletoclientwithsteamidandpos.position=templocation[1]
				Network:Send(args.player,"SetWaypointHome",transfertabletoclientwithsteamidandpos) return false 
			elseif #templocation>1 then		
					for k,v in ipairs(templocation) do 
					local ds=Vector3.Distance(v,args.player:GetPosition())	-- calculate distances from deathpos to each house
					table.insert(tempdistances,k,ds)		-- insert into tempdistances using the same key as templocation
					end
			end
	local mindistance=math.min(table.unpack(tempdistances))
		for k,v in ipairs(tempdistances) do
			if v==mindistance then 
			local transfertabletoclientwithsteamidandpos={}
			transfertabletoclientwithsteamidandpos.playersteam=rubnsteamid
			transfertabletoclientwithsteamidandpos.position=templocation[k]
				Network:Send(args.player,"SetWaypointHome",transfertabletoclientwithsteamidandpos)
				
			end
		end
	end
	--[[ if	msg[1]=="/homes"and IsValid(args.player) then -- not possible to set multiple waypoints 
		-- --print("/home")
		-- --local templocation,tempdistances={},{}
			-- for k,v in pairs(self.ownersclub) do -- k is players house position, v is player steamID
				-- if v==rubnsteamid then  
					-- local transfertabletoclientwithsteamidandpos={}
					-- transfertabletoclientwithsteamidandpos.playersteam=rubnsteamid
					-- transfertabletoclientwithsteamidandpos.position=k
					-- Network:Send(args.player,"SetWaypointHome",transfertabletoclientwithsteamidandpos) return false 
					-- end
				-- end
	-- end ]]
	
	 ----------------------------------------------------------checkpoint stuff----------------------------------------
	 local id=tonumber(self.playerincheckpoint[rubnsteamid])
if id ==nil then return end	 
		local checkpoint=Checkpoint.GetById(id)
		local chkpos=checkpoint:GetPosition()
		local owner,ownername,renter,rentername,security,price,ltype=self:XXCheckpointtextextractor(checkpoint:GetText())
		local faction,basename,reserve2,reserve3,msecurity,price,mtype=self:MilitaryCheckpointtextextractor(checkpoint:GetText())
		local notyours=string.format("Property of %s!",ownername)
		local notenoughmoney=string.format("You need %d ",price)
		local alphaprice=price/10
		local betaprice =price/8
		local deltaprice=price/6
		local gammaprice=price/5
		local omegaprice=price/4
 if msg[1]== "/buy" and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) and playerfaction then		
				if faction ~="0" and faction==playerfaction then args.player:SendChatMessage("You already own this", Color.Orange)
					elseif faction ~="0" then args.player:SendChatMessage(notyours, Color.Red)					
					elseif args.player:GetMoney()<price then args.player:SendChatMessage(notenoughmoney, Color.Red)
					elseif	faction=="0" then 
						args.player:SetMoney(args.player:GetMoney()-price)
						if ltype=="Ground Base" or ltype=="Naval Base" or ltype=="Comm Outpost" or ltype=="Mobile Radar" then self.bases[chkpos]=faction end
							local sqltext=tostring(playerfaction..","..basename..",".."0"..",".."0"..",".."0"..","..mtype)
								chktext=tostring(playerfaction..","..basename..",".."0"..",".."0"..",".."0"..","..price..","..ltype)
								checkpoint:SetText(chktext)
								self:MilitarySqlUpdateDB(sqltext,chkpos)				
								args.player:SendChatMessage(thisisyours, Color.Orange)
								print(args.player:GetName(),"from",playerfaction,"purchased a",mtype,"for",price, "at",chkpos)
							end
					end
	
	if msg[1]== "/alpha" and self.playerincheckpoint[rubnsteamid]  and IsValid(args.player) and playerfaction then		
					-- security levels 1-alpha, 2-beta,3-delta,4-
				if args.player:GetMoney()<alphaprice then args.player:SendChatMessage("Not enough money", Color.Red)
				elseif msecurity==1 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif faction==playerfaction then
				args.player:SetMoney(args.player:GetMoney() -alphaprice)
						local sqltext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."1"..","..mtype)
						local chktext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."1"..","..price..","..mtype)
							checkpoint:SetText(chktext)
							self:MilitarySqlUpdateDB(sqltext,chkpos)	
							args.player:SendChatMessage(thisisyours,Color.Orange)		
							end
				end
	if msg[1]=="/beta"and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) and playerfaction  then		
					-- security levels 1-alpha, 2-beta,3-delta,4-
				if args.player:GetMoney()<betaprice then args("Not enough money", Color.Red)
				elseif msecurity==2 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif faction==playerfaction then
				args.player:SetMoney(args.player:GetMoney()-betaprice)				
						local sqltext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."2"..","..mtype)
						local chktext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."2"..","..price..","..mtype)
							checkpoint:SetText(chktext)
							self:MilitarySqlUpdateDB(sqltext,chkpos)	
							args.player:SendChatMessage(thisisyours,Color.Orange)		
							end
				end
	if msg[1]=="/delta" and self.playerincheckpoint[rubnsteamid]  and IsValid(args.player) and playerfaction then		
					-- security levels 1-alpha, 2-beta,3-delta,4-
				if args.player:GetMoney()<deltaprice then arge("Not enough money", Color.Red)
				elseif msecurity==3 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif faction==playerfaction then
				args.player:SetMoney(args.player:GetMoney()-deltaprice)
						local sqltext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."3"..","..mtype)
						local chktext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."3"..","..price..","..mtype)
							checkpoint:SetText(chktext)
							self:MilitarySqlUpdateDB(sqltext,chkpos)	
							args.player:SendChatMessage(thisisyours,Color.Orange)	
							end
				end
	if msg[1]=="/gamma" and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) and playerfaction then		
					-- security levels 1-alpha, 2-beta,3-delta,4-gamma,5-omega
				if args.player:GetMoney()<gammaprice then args.player:SendChatMessage("Not enough money", Color.Red)
				elseif msecurity==4 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif faction==playerfaction then
				args.player:SetMoney(args.player:GetMoney()-gammaprice)
						local sqltext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."4"..","..mtype)
						local chktext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."4"..","..price..","..mtype)
							checkpoint:SetText(chktext)
							self:MilitarySqlUpdateDB(sqltext,chkpos)					
							args.player:SendChatMessage(thisisyours, Color.Orange)		
							end
				end
	if	msg[1]=="/omega"and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) and playerfaction then		
					-- security levels 1-alpha, 2-beta,3-delta,4-gamma,5-omega
				if args.player:GetMoney()<omegaprice then args.player:SendChatMessage("Not enough money", Color.Red)
				elseif msecurity==5 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif faction==playerfaction then
						args.player:SetMoney(args.player:GetMoney()-omegaprice)
						local sqltext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."5"..","..mtype)
						local chktext=tostring(faction..","..basename..","..reserve2..","..reserve3..",".."5"..","..price..","..mtype)
							checkpoint:SetText(chktext)
							self:MilitarySqlUpdateDB(sqltext,chkpos)					
							args.player:SendChatMessage(thisisyours, Color.Orange)		
							end
				end		
 if msg[1]== "/buy" and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) then		
				if owner ~="0" and owner==rubnsteamid then args.player:SendChatMessage("You already own this", Color.Orange)
					elseif owner ~="0" then args.player:SendChatMessage(notyours, Color.Red)					
					elseif args.player:GetMoney()<price then args.player:SendChatMessage(notenoughmoney, Color.Red)
					elseif	owner=="0" then 
						args.player:SetMoney(args.player:GetMoney()-price)
						if ltype=="bighouseinteriors" or ltype=="penthouses" or ltype=="villas" or ltype=="mansions" or ltype=="palaces" or ltype=="apartments" or ltype=="shacksinteriors" or ltype=="houses1lvl" or ltype=="smallshackinteriors"  or ltype=="housesinteriors" or ltype=="houses2lvl" then self.ownersclub[chkpos]=rubnsteamid end
						
						if ltype=="mansions"or ltype=="penthouses" or ltype=="villas" or ltype=="palaces" then
							local sqltext=tostring(rubnsteamid..","..args.player:GetName()..",".."0"..",".."0"..",".."2"..","..ltype)
							chktext=tostring(rubnsteamid..","..args.player:GetName()..",".."0"..",".."0"..",".."2"..","..price..","..ltype)
							checkpoint:SetText(chktext)
							self:SqlUpdateDB(sqltext,chkpos)			
							args.player:SendChatMessage(thisisyours, Color.Orange)					
							print(args.player:GetName(),rubnsteamid,"purchased",chkpos," one of",ltype,"for",price)
						else 
								local sqltext=tostring(rubnsteamid..","..args.player:GetName()..",".."0"..",".."0"..",".."0"..","..ltype)
								chktext=tostring(rubnsteamid..","..args.player:GetName()..",".."0"..",".."0"..",".."0"..","..price..","..ltype)
								checkpoint:SetText(chktext)
								self:SqlUpdateDB(sqltext,chkpos)				
								args.player:SendChatMessage(thisisyours, Color.Orange)
								print(args.player:GetName(),rubnsteamid,"purchased",chkpos," one of",ltype,"for",price)
							end
					end
	end
	if msg[1]== "/alpha" and self.playerincheckpoint[rubnsteamid]  and IsValid(args.player)  then		
					-- security levels 1-alpha, 2-beta,3-delta,4-
				if args.player:GetMoney()<alphaprice then arge("Not enough money", Color.Red)
				elseif security==1 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif owner==rubnsteamid then
				args.player:SetMoney(args.player:GetMoney() -alphaprice)
						local sqltext=tostring(owner..","..ownername..","..renter..","..rentername..",".."1"..","..ltype)
						local chktext=tostring(owner..","..ownername..","..renter..","..rentername..",".."1"..","..price..","..ltype)
							checkpoint:SetText(chktext)
							self:SqlUpdateDB(sqltext,chkpos)	
							args.player:SendChatMessage(thisisyours,Color.Orange)		
							end
				end
	if msg[1]=="/beta"and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) 	  then		
					-- security levels 1-alpha, 2-beta,3-delta,4-
				if args.player:GetMoney()<betaprice then args("Not enough money", Color.Red)
				elseif security==2 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif owner==rubnsteamid then
				args.player:SetMoney(args.player:GetMoney()-betaprice)				
						local sqltext=tostring(owner..","..ownername..","..renter..","..rentername..",".."2"..","..ltype)
						local chktext=tostring(owner..","..ownername..","..renter..","..rentername..",".."2"..","..price..","..ltype)
							checkpoint:SetText(chktext)
							self:SqlUpdateDB(sqltext,chkpos)	
							args.player:SendChatMessage(thisisyours,Color.Orange)		
							end
				end
	if msg[1]=="/delta" and self.playerincheckpoint[rubnsteamid]  and IsValid(args.player)then		
					-- security levels 1-alpha, 2-beta,3-delta,4-
				if args.player:GetMoney()<deltaprice then arge("Not enough money", Color.Red)
				elseif security==3 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif owner==rubnsteamid then
				args.player:SetMoney(args.player:GetMoney()-deltaprice)
						local sqltext=tostring(owner..","..ownername..","..renter..","..rentername..",".."3"..","..ltype)
						local chktext=tostring(owner..","..ownername..","..renter..","..rentername..",".."3"..","..price..","..ltype)
							checkpoint:SetText(chktext)
							self:SqlUpdateDB(sqltext,chkpos)	
							args.player:SendChatMessage(thisisyours,Color.Orange)	
							end
				end
	if msg[1]=="/gamma" and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) then		
					-- security levels 1-alpha, 2-beta,3-delta,4-gamma,5-omega
				if args.player:GetMoney()<gammaprice then args.player:SendChatMessage("Not enough money", Color.Red)
				elseif security==4 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif owner==rubnsteamid then
				args.player:SetMoney(args.player:GetMoney()-gammaprice)
						local sqltext=tostring(owner..","..ownername..","..renter..","..rentername..",".."4"..","..ltype)
						local chktext=tostring(owner..","..ownername..","..renter..","..rentername..",".."4"..","..price..","..ltype)
							checkpoint:SetText(chktext)
							self:SqlUpdateDB(sqltext,chkpos)					
							args.player:SendChatMessage(thisisyours, Color.Orange)		
							end
				end
	if	msg[1]=="/omega"and self.playerincheckpoint[rubnsteamid] and IsValid(args.player) then		
					-- security levels 1-alpha, 2-beta,3-delta,4-gamma,5-omega
				if args.player:GetMoney()<omegaprice then args.player:SendChatMessage("Not enough money", Color.Red)
				elseif security==5 then args.player:SendChatMessage("Already installed", Color.Red)
				elseif owner==rubnsteamid then
						args.player:SetMoney(args.player:GetMoney()-omegaprice)
						local sqltext=tostring(owner..","..ownername..","..renter..","..rentername..",".."5"..","..ltype)
						local chktext=tostring(owner..","..ownername..","..renter..","..rentername..",".."5"..","..price..","..ltype)
							checkpoint:SetText(chktext)
							self:SqlUpdateDB(sqltext,chkpos)					
							args.player:SendChatMessage(thisisyours, Color.Orange)		
							end
				end				
 				
return false end
			
function Properties:SqlUpdateDB(sqltext,chkpos)
local update = SQL:Command("UPDATE properties SET text = ? WHERE position = ?")
										update:Bind(1, sqltext)
										update:Bind(2, tostring(chkpos))
										update:Execute()
end
function Properties:XXCheckpointtextextractor(text) -- works
local edrtxt={}
				edrtxt=text:split(",")
				local owner=tostring(edrtxt[1])
				local ownername=tostring(edrtxt[2])
				local renter= tostring(edrtxt[3])
				local rentername= tostring(edrtxt[4])
				local security=tonumber(edrtxt[5])
				local price =tonumber(edrtxt[6])
				local ltype =tostring(edrtxt[7])
return owner,ownername,renter,rentername,security,price,ltype
end

function Properties:MilitarySqlUpdateDB(sqltext,chkpos)
local update = SQL:Command("UPDATE militarybases SET text = ? WHERE position = ?")
										update:Bind(1, sqltext)
										update:Bind(2, tostring(chkpos))
										update:Execute()
end
function Properties:MilitaryCheckpointtextextractor(text) -- works
local edrtxt={}
				edrtxt=text:split(",")
				local faction=tostring(edrtxt[1])
				local basename=tostring(edrtxt[2])
				local reserve2= tostring(edrtxt[3])
				local reserve3= tostring(edrtxt[4])
				local security=tonumber(edrtxt[5])
				local price =tonumber(edrtxt[6])
				local ltype =tostring(edrtxt[7])
return faction,basename,reserve2,reserve3,security,price,ltype
end

function Properties:Cleanup()
 for k,v in ipairs(self.pipelines) do 
	v:Remove()
	self.pipelines[k]=nil

	end
	for k,v in ipairs(self.windmills) do 
		v:Remove()
		self.windmills[k]=nil
	end
	for k,v in ipairs(self.adpannels) do 
	v:Remove()
	self.adpannels[k]=nil
	end
	
	for k,v in ipairs(self.pumpingstations) do 
	v:Remove()
	self.pumpingstations[k]=nil
	end
	for k,v in ipairs(self.villageshops) do 
	v:Remove()
	self.villageshops[k]=nil
	end
	for k,v in ipairs(self.lighthouses) do 
	v:Remove()
	self.lighthouses[k]=nil
	end
	for k,v in ipairs(self.oilrigs) do 
	v:Remove()
	self.oilrigs[k]=nil
	end
for k,v in ipairs(self.cityshops) do 
	v:Remove()
	self.cityshops[k]=nil
	end
for k,v in ipairs(self.bighouseinteriors) do 
	v:Remove()
	self.bighouseinteriors[k]=nil
	end
for k,v in ipairs(self.penthouses) do 
	v:Remove()
	self.penthouses[k]=nil
	end
for k,v in ipairs(self.villas) do 
	v:Remove()
	self.villas[k]=nil
	end
for k,v in ipairs(self.mansions) do 
	v:Remove()
	self.mansions[k]=nil
	end
for k,v in ipairs(self.palaces) do 
	v:Remove()
	self.palaces[k]=nil
	end
for k,v in ipairs(self.apartments) do 
	v:Remove()
	self.apartments[k]=nil
	end
	
	for k,v in ipairs(self.shacksinteriors) do 
	v:Remove()
	self.shacksinteriors[k]=nil
	end
	for k,v in ipairs(self.houses1lvl) do 
	v:Remove()
	self.houses1lvl[k]=nil
	end
	for k,v in ipairs(self.smallshackinteriors) do 
	v:Remove()
	self.smallshackinteriors[k]=nil
	end
	
	for k,v in ipairs(self.housesinteriors) do 
	v:Remove()
	self.housesinteriors[k]=nil
	end
	
	for k,v in ipairs(self.houses2lvl) do 
	v:Remove()
	self.houses2lvl[k]=nil
	end
	for k,v in ipairs(self.WarningLineCommOutpost) do 
	v:Remove()
	self.WarningLineCommOutpost[k]=nil

	end
	for k,v in ipairs(self.WarningLineGroundBase) do 
	v:Remove()
	self.WarningLineGroundBase[k]=nil

	end
	for k,v in ipairs(self.WarningLineMobileRadar) do 
	v:Remove()
	self.WarningLineMobileRadar[k]=nil

	end
	for k,v in ipairs(self.WarningLineNavalBase) do 
	v:Remove()
	self.WarningLineNavalBase[k]=nil

	end
	for k,v in ipairs(self.GroundBase) do 
	v:Remove()
	self.GroundBase[k]=nil

	end
	for k,v in ipairs(self.NavalBase) do 
	v:Remove()
	self.NavalBase[k]=nil

	end
	for k,v in ipairs(self.CommOutpost) do 
	v:Remove()
	self.CommOutpost[k]=nil

	end
	for k,v in ipairs(self.MobileRadar) do 
	v:Remove()
	self.MobileRadar[k]=nil

	end
	for k,v in ipairs(self.bases) do 
	--v:Remove()
	self.bases[k]=nil
	end
	for k,v in ipairs(self.ownersclub) do 
	--v:Remove()
	self.ownersclub[k]=nil
	end
	
	for k,v in ipairs(self.comercialproperties) do 
	--v:Remove()
	self.comercialproperties[k]=nil
	end
	
Events:UnsubscribeAll()
end
function Properties:Playerquits(args)
for k,v in pairs (self.playerincheckpoint) do -- removes  player from playerincheckpoint
	if IsValid(args.player) and v==args.player then
	local rubnsteamid=tostring(args.player:GetSteamId().id)
		 self.playerincheckpoint[rubnsteamid]=nil
	end
end
end

Properties=Properties()