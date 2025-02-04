
--local UseSmallField=false	 		-- toggle small or large court here, basketballfield.lua and basketballfieldsmall.lua are the same for the rest

--local WakeUpOnPlayers=3				-- toggle at how many found players the field will wake up (4)
--local MinimumPlayers=4				-- toggle at how many players the field will start the game (6)
--local BasketDistance=9				-- specify distance to Basket, if the ball is closer then a Basket will be made

local UseSmallField=true	 		-- toggle small or large court here, basketballfield.lua and basketballfieldsmall.lua are the same for the rest

local WakeUpOnPlayers=1				-- toggle at how many found players the field will wake up
local MinimumPlayers=2				-- toggle at how many players the field will start the game
local BasketDistance=7				-- specify distance to Basket, if the ball is closer then a goal will be made

local timeInit = 0
local initTimer = 1
local Now = 0

local StartingMinute = -1
local EndingMinute = -1

local myMapSize = "UNKNOWN"
local mySlowTime = "UNKNOWN"

local myTimeWarpFactor = 0
local timeWarpFound = false

local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = this.GetNearbyObjects
local FindFrom = Object.GetNearbyObjects
local Spawn = Object.Spawn

local timeTot=0
local numPlayers=0
local numFloor=1
local numLine=0
local FloorTypes = { [1] = "BasketballConcreteFloor", [2] = "BasketballFloor", [3] = "BasketballPavingStone", [4] = "BasketballRoad", [5] = "BasketballWoodenFloor", [6] = "BasketballWoodLaminate", [7] = "BasketballMosaicFloor", [8] = "BasketballMetalFloor", [9] = "BasketballConcreteTiles", [10] = "BasketballDirt", [11] = "BasketballGrass", [12] = "BasketballLongGrass", [13] = "BasketballMud", [14] = "BasketballCeramicFloor", [15] = "BasketballSand", [16] = "BasketballMarbleTiles", [17] = "BasketballWhiteTiles", [18] = "BasketballFancyTiles", [19] = "Dirt" } -- type 19 is used when deleting court
local FloorDescription = { [1] = "tooltip_BasketballConcreteFloor", [2] = "tooltip_BasketballFloor", [3] = "tooltip_BasketballPavingStone", [4] = "tooltip_BasketballRoad", [5] = "tooltip_BasketballWoodenFloor", [6] = "tooltip_BasketballWoodLaminate", [7] = "tooltip_BasketballMosaicFloor", [8] = "tooltip_BasketballMetalFloor", [9] = "tooltip_BasketballConcreteTiles", [10] = "tooltip_BasketballDirt", [11] = "tooltip_BasketballGrass", [12] = "tooltip_BasketballLongGrass", [13] = "tooltip_BasketballMud", [14] = "tooltip_BasketballCeramicFloor", [15] = "tooltip_BasketballSand", [16] = "tooltip_BasketballMarbleTiles", [17] = "tooltip_BasketballWhiteTiles", [18] = "tooltip_BasketballFancyTiles" }
local LightsAreOn=false
local SpawnBallX=this.Pos.x
local SpawnBallY=this.Pos.y
local BallFound=false
local BallOk=false
local ScoreBoardFound=false
local BasketsFound=false
local BasketsFoundL=false
local BasketsFoundR=false
local TeacherFound=false
local FetchBallRetry=0

function Create()
	Set(this,"CreateMyField","ON")
	
end

----------------------------------------------------------------------------------------------------------------------------------
--  Find my things
----------------------------------------------------------------------------------------------------------------------------------

function FindMyBaskets()
	BasketsFound=false
	BasketsFoundL=false
	BasketsFoundR=false
	if this.DebugInfo=="ON" then print("Searching for Baskets...") end
	local nearbyBaskets = Find('Basket3',7)
	for thatBasket, distance in pairs (nearbyBaskets) do
		if thatBasket.HomeUID==this.HomeUID and thatBasket.LeftBasket=="yes" then
			if this.DebugInfo=="ON" then print("Left Basket found") end
			myLeftBasket=thatBasket
			BasketsFoundL=true
			myLeftBasket.Tooltip={"tooltip_linkedto",myLeftBasket.HomeUID,"X"}
		elseif thatBasket.HomeUID==this.HomeUID and thatBasket.RightBasket=="yes" then
			if this.DebugInfo=="ON" then print("Right Basket found") end
			myRightBasket=thatBasket
			BasketsFoundR=true
			myRightBasket.Tooltip={"tooltip_linkedto",myRightBasket.HomeUID,"X"}
		end
	end
	if this.UsingSmallField==false then
		if BasketsFoundL==true and BasketsFoundR==true then BasketsFound=true
		else
			DismantleAll()
		end
	else
		if BasketsFoundL==true or BasketsFoundR==true then BasketsFound=true
		else
			DismantleAll()
		end
	end
end

function FindMyCourtLights()
	if this.DebugInfo=="ON" then print("Searching for court lights...") end
	myFieldLights={}
	local nearbyLights = Find('Light',10)
	local i=1
	if next(nearbyLights) then
		for thatLight, distance in pairs (nearbyLights) do
			if thatLight.HomeUID==this.HomeUID then
				if this.UsingSmallField==true then
					if this.Or.x==0 and this.Or.y==1 and thatLight.Pos.x==this.Pos.x+3.2 and thatLight.Pos.y==this.Pos.y then
						if this.DebugInfo=="ON" then print("Found centre circle light") end
						myCentreLight=thatLight
					end	-- placed down
					if this.Or.x==-1 and this.Or.y==0 and thatLight.Pos.x==this.Pos.x and thatLight.Pos.y==this.Pos.y+3.2 then
						if this.DebugInfo=="ON" then print("Found centre circle light") end
						myCentreLight=thatLight
					end	-- rotated once
					if this.Or.x==0 and this.Or.y==-1 and thatLight.Pos.x==this.Pos.x-3.2 and thatLight.Pos.y==this.Pos.y then
						if this.DebugInfo=="ON" then print("Found centre circle light") end
						myCentreLight=thatLight
					end	-- rotated twice
					if this.Or.x==1 and this.Or.y==0 and thatLight.Pos.x==this.Pos.x and thatLight.Pos.y==this.Pos.y-3.2 then
						if this.DebugInfo=="ON" then print("Found centre circle light") end
						myCentreLight=thatLight
					end	-- rotated three times
				elseif thatLight.Pos.x==this.Pos.x and thatLight.Pos.y==this.Pos.y then
					if this.DebugInfo=="ON" then print("Found centre circle light") end
					myCentreLight=thatLight
				else
					myFieldLights[i] = thatLight
					if this.DebugInfo=="ON" then print("Found court light "..i.."") end
					i=i+1
					LightsAreOn=true
				end
			end
		end
	else
		if this.DebugInfo=="ON" then print("Court lights not found") end
	end
end

function FindMyScoreBoard()
	ScoreBoardFound=false
	if this.DebugInfo=="ON" then print("Searching for scoreboard...") end
	local nearbyScoreBoards = Find('ScoreBoard3',15)
	if next(nearbyScoreBoards) then
		for thatScoreBoard, distance in pairs (nearbyScoreBoards) do
			if thatScoreBoard.HomeUID==this.HomeUID or thatScoreBoard.HomeUID==0 then
				myScoreBoard=thatScoreBoard
				Set(myScoreBoard,"HomeUID",this.HomeUID)
				myScoreBoard.Tooltip={"tooltip_linkscoreboard",myScoreBoard.HomeUID,"X"}
				myScoreBoard.ShowCountdown = this.ShowCountdown
				ScoreBoardFound=true
			end
		end
	end
	nearbyScoreBoards = nil
	SetBoardText("Court ID: "..this.HomeUID,"scroll")
	if this.UsingSmallField==false then
		if this.DebugInfo=="ON" then print("               Score: "..this.LeftScore.." - "..this.RightScore.."") end
	else
		if this.DebugInfo=="ON" then print("               Score: "..this.LeftScore.."") end
	end
end

function FindMyBall()
	BallFound=false
	BallOk=false
	if this.DebugInfo=="ON" then print("Searching for ball...") end
	local theBall = Find('Basketball3',11)
	if next(theBall) then
		for thatBall, distance in pairs (theBall) do
			if thatBall.HomeUID==this.HomeUID and thatBall.Damage==0 then
				if BallOk==false then
					myBall=thatBall
					BallOk=true
					if this.DebugInfo=="ON" then print("Ball found") end
				else
					if this.BallKillOrDelete=="deleted" then
						if this.DebugInfo=="ON" then print("Deleting obsolete basketball") end		thatBall.Delete()
					else
						if this.DebugInfo=="ON" then print("Killing obsolete basketball") end		thatBall.Damage=1
					end
				end
			else
				if this.BallKillOrDelete=="deleted" then
					if this.DebugInfo=="ON" then print("Deleting obsolete basketball") end			thatBall.Delete()
				else
					if this.DebugInfo=="ON" then print("Killing obsolete basketball") end			thatBall.Damage=1
				end
			end
		end
	end
	if BallOk==true then BallFound=true elseif this.DebugInfo=="ON" then print("Ball not found") end
end

----------------------------------------------------------------------------------------------------------------------------------
--  Court Lights
----------------------------------------------------------------------------------------------------------------------------------

function LightsOn()
	if LightsAreOn==false then
		myFieldLights={}
		if this.DebugInfo=="ON" then print("Turning court lights on") end
		if this.UsingSmallField==false then
			SetBoardText("  Lights on","stable")
			if this.Or.x==0 then				-- horizontal court
				myCentreLight = Spawn("Light", this.Pos.x, this.Pos.y)
				myFieldLights[1] = Spawn("Light", this.Pos.x-7.80000,this.Pos.y-4.8)	myFieldLights[2] = Spawn("Light", this.Pos.x-7.80000,this.Pos.y+4.8)
				myFieldLights[3] = Spawn("Light", this.Pos.x,this.Pos.y-4.8)			myFieldLights[4] = Spawn("Light", this.Pos.x,this.Pos.y+4.8)
				myFieldLights[5] = Spawn("Light", this.Pos.x+7.80000,this.Pos.y-4.8)	myFieldLights[6] = Spawn("Light", this.Pos.x+7.80000,this.Pos.y+4.8)
				myFieldLights[7] = Spawn("Light", this.Pos.x-7.80000,this.Pos.y)		myFieldLights[8] = Spawn("Light", this.Pos.x+7.80000,this.Pos.y)
			elseif this.Or.y==0 then 			-- vertical court
				myCentreLight = Spawn("Light", this.Pos.x, this.Pos.y)
				myFieldLights[1] = Spawn("Light", this.Pos.x-4.80000,this.Pos.y-7.8)	myFieldLights[2] = Spawn("Light", this.Pos.x-4.80000,this.Pos.y+7.8)
				myFieldLights[3] = Spawn("Light", this.Pos.x,this.Pos.y-7.8)			myFieldLights[4] = Spawn("Light", this.Pos.x,this.Pos.y+7.8)
				myFieldLights[5] = Spawn("Light", this.Pos.x+4.80000,this.Pos.y-7.8)	myFieldLights[6] = Spawn("Light", this.Pos.x+4.80000,this.Pos.y+7.8)
				myFieldLights[7] = Spawn("Light", this.Pos.x-4.80000,this.Pos.y)		myFieldLights[8] = Spawn("Light", this.Pos.x+4.80000,this.Pos.y)
			end
			for i=1,8 do
				Set(myFieldLights[i],"HomeUID",this.HomeUID)
			end
		else
			--this.Tooltip = "Or.x: "..this.Or.x.." Or.y: "..this.Or.y
			if this.Or.x==0 and this.Or.y==1 then -- placed down
				myFieldLights[1] = Spawn("Light", this.Pos.x-3.8,this.Pos.y-4.8)	myFieldLights[2] = Spawn("Light", this.Pos.x-3.8,this.Pos.y+4.8)
				myFieldLights[4] = Spawn("Light", this.Pos.x+3.8,this.Pos.y+4.8)	myFieldLights[3] = Spawn("Light", this.Pos.x+3.8,this.Pos.y-4.8)
				myFieldLights[5] = Spawn("Light", this.Pos.x-3.8,this.Pos.y)		myFieldLights[6] = Spawn("Light", this.Pos.x+3.8,this.Pos.y)
			elseif this.Or.x==-1 and this.Or.y==0 then -- rotated once
				myFieldLights[1] = Spawn("Light", this.Pos.x-4.8,this.Pos.y-3.8)	myFieldLights[2] = Spawn("Light", this.Pos.x+4.8,this.Pos.y-3.8)
				myFieldLights[4] = Spawn("Light", this.Pos.x,this.Pos.y-3.8)		myFieldLights[3] = Spawn("Light", this.Pos.x,this.Pos.y+3.8)
				myFieldLights[5] = Spawn("Light", this.Pos.x-4.8,this.Pos.y+3.8)	myFieldLights[6] = Spawn("Light", this.Pos.x+4.8,this.Pos.y+3.8)
			elseif this.Or.x==0 and this.Or.y==-1 then -- rotated twice
				myFieldLights[1] = Spawn("Light", this.Pos.x-3.8,this.Pos.y-4.8)	myFieldLights[2] = Spawn("Light", this.Pos.x-3.80000,this.Pos.y+4.8)
				myFieldLights[4] = Spawn("Light", this.Pos.x+3.8,this.Pos.y+4.8)	myFieldLights[3] = Spawn("Light", this.Pos.x+3.8,this.Pos.y-4.8)
				myFieldLights[5] = Spawn("Light", this.Pos.x-3.8,this.Pos.y)		myFieldLights[6] = Spawn("Light", this.Pos.x+3.8,this.Pos.y)
			elseif this.Or.x==1 and this.Or.y==0 then -- rotated three times
				myFieldLights[1] = Spawn("Light", this.Pos.x-4.8,this.Pos.y-3.8)		myFieldLights[2] = Spawn("Light", this.Pos.x+4.8,this.Pos.y-3.8)
				myFieldLights[4] = Spawn("Light", this.Pos.x,this.Pos.y+3.8)			myFieldLights[3] = Spawn("Light", this.Pos.x,this.Pos.y+3.8)
				myFieldLights[5] = Spawn("Light", this.Pos.x-4.8,this.Pos.y+3.8)		myFieldLights[6] = Spawn("Light", this.Pos.x+4.8,this.Pos.y+3.8)
			end
			for i=1,6 do
				Set(myFieldLights[i],"HomeUID",this.HomeUID)
			end
		end
		LightsAreOn=true
		Set(this,"CourtLights","ON")
		this.SetInterfaceCaption("toggleCourtLights", "tooltip_button_courtlights","tooltip_on","X")
	end
end

function LightsOff()
	if this.DebugInfo=="ON" then print("Turning court lights off") end
	SetBoardText("  Lights off","stable")
	for i=1,8 do
		if myFieldLights[i]~=nil then
			myFieldLights[i].Delete()
		end
	end
	if myCentreLight~=nil then myCentreLight.Delete() end
	myFieldLights={}
	Set(this,"CourtLights","OFF")
	this.SetInterfaceCaption("toggleCourtLights", "tooltip_button_courtlights","tooltip_off","X")
	LightsAreOn=false
end

----------------------------------------------------------------------------------------------------------------------------------
--  Ball stuff
----------------------------------------------------------------------------------------------------------------------------------

function SpawnNewBall(DribbleCounter)  -- 0=dribble, 7=don't dribble at spawn
	if myTeacher == nil or myTeacher.SubType == nil then
		SpawnTeacher()
	end
	if this.DebugInfo=="ON" then print("Spawning a new basketball") end
	myBall = Spawn("Basketball3", SpawnBallX,SpawnBallY)
	Set(myBall,"TimeWarp",this.TimeWarp)
	Set(myBall,"HomeUID",this.HomeUID)
	Set(myBall,"Xmin",this.Pos.x+this.Xmin-4)	-- allow some headroom for the ball in case a Bezier curve goes outside the court lines
	Set(myBall,"Xmax",this.Pos.x+this.Xmax+4)
	Set(myBall,"Ymin",this.Pos.y+this.Ymin-4)
	Set(myBall,"Ymax",this.Pos.y+this.Ymax+4)
	Set(myBall,"NewPosX",nil)
	Set(myBall,"NewPosY",nil)
	Set(myBall,"Energy",100)
	Set(myBall,"BallKillOrDelete",this.BallKillOrDelete)
	if not this.UsingYard then
		if this.UsingSmallField==false then
			Set(myBall,"LinkMeTo","BasketballTrainerFullCourt")
		else
			Set(myBall,"LinkMeTo","BasketballTrainerHalfCourt")
		end
	else
		Set(myBall,"LinkMeTo","BasketballTrainerYard")
	end
	Set(myBall,"NewPlayerI",myTeacher.Id.i)
	Set(myBall,"NewPlayerU",myTeacher.Id.u)
	Set(myBall,"Dribble",DribbleCounter)
	Set(myBall,"DribbleAt",myTeacher.Type)
	Set(myBall,"DribblePlayerI",myTeacher.Id.i)
	Set(myBall,"DribblePlayerU",myTeacher.Id.u)
	this.BallBounced = 0
	BallFound=true
end

function BounceBall() -- if ball is carried by player (= arrived) then do next action, otherwise do nothing and wait for the ball to arrive at its target
	local doShot = false
	if myTeacher == nil or myTeacher.SubType == nil then
		SpawnTeacher()
	end
	if myBall == nil or myBall.SubType == nil or myBall.Damage == 1 then
		SpawnBallX=myTeacher.Pos.x
		SpawnBallY=myTeacher.Pos.y+0.1
		SpawnNewBall(0)
	end
	if Get(myBall,"Carried") >- 1 and Get(this,"LeftBasketMade")==false and Get(this,"RightBasketMade")==false then
		if myCurrentPlayer~=nil then myPriorPlayer=myCurrentPlayer.Id.i end
		myCurrentPlayer=myNewPlayer
		if this.DebugInfo=="ON" then print("               Removing carried from "..myCurrentPlayer.Id.i.."") end
		Set(myBall,"Carried",-1)					Set(myBall,"Energy",100)
		Set(myBall,"NewPosX",nil)					Set(myBall,"NewPosY",nil)
		Set(myBall,"CarrierId.i",-1)				Set(myBall,"CarrierId.u",-1)
		Set(myCurrentPlayer,"Carrying.i",-1)		Set(myCurrentPlayer,"Carrying.u",-1)
		
		Set(myBall,"Pos.y",myCurrentPlayer.Pos.y+0.2)
		Set(myBall,"Dribble",0)
		Set(myBall,"DribbleAt",myCurrentPlayer.Type)
		Set(myBall,"DribblePlayerI",myCurrentPlayer.Id.i)
		Set(myBall,"DribblePlayerU",myCurrentPlayer.Id.u)

		if this.BallBounced >= 1 and myLeftBasket ~= nil then	-- to prevent 'score-fetchball-score-fetchball-score-' require the ball to be played at least once between the players before a score attempt can be made.
			if this.DebugInfo=="ON" then print("Checking left basket") end
			local fromDist = 7
			if this.UsingSmallField==false then
				if this.Or.x==0 then				-- horizontal court
					fromDist = myCurrentPlayer.Pos.x - myLeftBasket.Pos.x
				elseif this.Or.y==0 then 			-- vertical court
					fromDist = myCurrentPlayer.Pos.y - myLeftBasket.Pos.y
				end
			end
			if fromDist <= 7 and PlayerFacingBasket(myLeftBasket,myCurrentPlayer) == true then	-- score when player is moving/facing towards the basket. this seems already random enough, so every attempt is successful.
				local dX1 = myCurrentPlayer.Pos.x
				local dX2 = myLeftBasket.Pos.x
				local dY1 = myCurrentPlayer.Pos.y
				local dY2 = myLeftBasket.Pos.y
				local leftBasketDistance = math.sqrt((dX2-dX1)^2+(dY2-dY1)^2)
				Set(myBall,"BasketDistance",leftBasketDistance)
				if this.DebugInfo=="ON" then print("Left Basket distance: "..leftBasketDistance.."") end
				if myCurrentPlayer.Pos.x - dX2 > myBall.Pos.x - dX2 then myBall.Pos.x = myCurrentPlayer.Pos.x-0.15 else myBall.Pos.x = myCurrentPlayer.Pos.x+0.15 end
				myBall.Pos.y = myCurrentPlayer.Pos.y
				Set(myBall,"StartX",myBall.Pos.x)				Set(myBall,"StartY",myBall.Pos.y)
				Set(myBall,"NewPosX",myLeftBasket.Pos.x)		Set(myBall,"NewPosY",myLeftBasket.Pos.y+0.65)
				Set(myBall,"NewPlayerI",myLeftBasket.Id.i)		Set(myBall,"NewPlayerU",myLeftBasket.Id.u)
				Set(myBall,"LinkMeTo","Basket3")				Set(this,"LeftBasketMade",true)
				SetBoardText("score attempt","blink")
				doShot=true
			else
				if this.DebugInfo=="ON" then print("Left basket too far away ("..fromDist.." tiles) or player not facing basket") end
			end
		end
		
		if this.BallBounced >= 1 and myRightBasket ~= nil and doShot == false then
			if this.DebugInfo=="ON" then print("Checking right basket") end
			local fromDist = 7
			if this.UsingSmallField==false then
				if this.Or.x==0 then				-- horizontal court
					fromDist = myRightBasket.Pos.x - myCurrentPlayer.Pos.x
				elseif this.Or.y==0 then 			-- vertical court
					fromDist = myRightBasket.Pos.y - myCurrentPlayer.Pos.y
				end
			end
			if fromDist <= 7 and PlayerFacingBasket(myRightBasket,myCurrentPlayer) == true then
				local dX1 = myCurrentPlayer.Pos.x
				local dX2 = myRightBasket.Pos.x
				local dY1 = myCurrentPlayer.Pos.y
				local dY2 = myRightBasket.Pos.y
				rightBasketDistance = math.sqrt((dX2-dX1)^2+(dY2-dY1)^2)
				Set(myBall,"BasketDistance",rightBasketDistance)
				if this.DebugInfo=="ON" then print("Right Basket distance: "..rightBasketDistance.."") end
				if dX2 - myCurrentPlayer.Pos.x < dX2 - myBall.Pos.x then myBall.Pos.x = myCurrentPlayer.Pos.x+0.15 else myBall.Pos.x = myCurrentPlayer.Pos.x-0.15 end
				myBall.Pos.y = myCurrentPlayer.Pos.y
				Set(myBall,"StartX",myBall.Pos.x)				Set(myBall,"StartY",myBall.Pos.y)
				Set(myBall,"NewPosX",myRightBasket.Pos.x)		Set(myBall,"NewPosY",myRightBasket.Pos.y+0.65)
				Set(myBall,"NewPlayerI",myRightBasket.Id.i)		Set(myBall,"NewPlayerU",myRightBasket.Id.u)
				Set(myBall,"LinkMeTo","Basket3")				Set(this,"RightBasketMade",true)
				SetBoardText("score attempt","blink")
				doShot=true
			else
				if this.DebugInfo=="ON" then print("Right basket too far away ("..fromDist.." tiles) or player not facing basket") end
			end
		end
		
		if Get(this,"LeftBasketMade")==false and Get(this,"RightBasketMade")==false then
			FindMyPlayer()
			if this.DebugInfo=="ON" then print("               Navigating to "..myNewPlayer.Id.i.."") end
--			if myNewPlayer.Id.i==myTeacher.Id.i then
--				if not this.UsingYard then
--					if this.UsingSmallField==false then
--						Set(myBall,"LinkMeTo","BasketballTrainerFullCourt")
--					else
--						Set(myBall,"LinkMeTo","BasketballTrainerHalfCourt")
--					end
--				else
--					Set(myBall,"LinkMeTo","BasketballTrainerYard")
--				end
--			else
--				Set(myBall,"LinkMeTo","Prisoner")
				Set(myBall,"LinkMeTo",myNewPlayer.Type)
--			end
			
			if myCurrentPlayer.Pos.x > myNewPlayer.Pos.x then myBall.Pos.x = myCurrentPlayer.Pos.x-0.15 else myBall.Pos.x = myCurrentPlayer.Pos.x+0.15 end
			myBall.Pos.y = myCurrentPlayer.Pos.y
			Set(myBall,"StartX",myBall.Pos.x)				Set(myBall,"StartY",myBall.Pos.y)
			Set(myBall,"NewPosX",myNewPlayer.Pos.x)			Set(myBall,"NewPosY",myNewPlayer.Pos.y)
			Set(myBall,"NewPlayerI",myNewPlayer.Id.i)		Set(myBall,"NewPlayerU",myNewPlayer.Id.u)
			this.BallBounced = this.BallBounced + 1
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------
--  Player stuff
----------------------------------------------------------------------------------------------------------------------------------

function PlayerFacingBasket(theBasket,thePlayer)

	local BX = theBasket.Pos.x
	local BY = theBasket.Pos.y
	
	local PX = thePlayer.Pos.x
	local PY = thePlayer.Pos.y
	
	local OX = thePlayer.Or.x
	local OY = thePlayer.Or.y
	
	local VX = thePlayer.Vel.x
	local VY = thePlayer.Vel.y
	
	local facingDown = false
	local facingUp = false
	local facingLeft = false
	local facingRight = false
	
	local movingDown = false
	local movingUp = false
	local movingLeft = false
	local movingRight = false
	
	local FacingBasket = false
	
	if OY > 0 then facingDown = true if this.DebugInfo=="ON" then print("facing down") end end
	if OX < 0 then facingLeft = true if this.DebugInfo=="ON" then print("facing left") end end
	if OY < 0 then facingUp = true if this.DebugInfo=="ON" then print("facing up") end end
	if OX > 0 then facingRight = true if this.DebugInfo=="ON" then print("facing right") end end
	
	if VY >= 0 then movingDown = true if this.DebugInfo=="ON" then print("moving down") end end
	if VX <= 0 then movingLeft = true if this.DebugInfo=="ON" then print("moving left") end end
	if VY <= 0 then movingUp = true if this.DebugInfo=="ON" then print("moving up") end end
	if VX >= 0 then movingRight = true if this.DebugInfo=="ON" then print("moving right") end end
	
	if BX < PX then
		if BY < PY then
			if movingUp == true and movingLeft == true and facingLeft == true then FacingBasket = true end
		else
			if movingDown == true and movingLeft == true and facingLeft == true then FacingBasket = true end
		end
	else
		if BY < PY then
			if movingUp == true and movingRight == true and facingRight == true then FacingBasket = true end
		else
			if movingDown == true and movingRight == true and facingRight == true then FacingBasket = true end
		end
	end
	
	if FacingBasket == true then
		if this.DebugInfo=="ON" then print("FacingBasket = true") end
	else
		if this.DebugInfo=="ON" then print("FacingBasket = false") end
	end
	
	return FacingBasket
end

function CheckNumPlayers()
	if this.DebugInfo=="ON" then print("                                             Finding players on court...") end
	numPlayers=0
	numLeaving=0
	numStaying=0
	
	local entityGroup = { "Prisoner", "Guard" }
	for _, typ in pairs(entityGroup) do
		somePlayers = Find(typ,10)
		for thatEntity, dist in pairs(somePlayers) do
			if (thatEntity.Pos.x>=this.Pos.x+this.Xmin-2 and thatEntity.Pos.x<=this.Pos.x+this.Xmax+2) and (thatEntity.Pos.y>=this.Pos.y+this.Ymin-2 and thatEntity.Pos.y<=this.Pos.y+this.Ymax+2) then
				numPlayers = numPlayers + 1
				
				if (thatEntity.Dest.x>=this.Pos.x+this.Xmin-4 and thatEntity.Dest.x<=this.Pos.x+this.Xmax+4) and (thatEntity.Dest.y>=this.Pos.y+this.Ymin-4 and thatEntity.Dest.y<=this.Pos.y+this.Ymax+4) then
					numStaying = numStaying + 1
				else
					numLeaving = numLeaving + 1
				end
			end
		end
		somePlayers = nil
	end
	entityGroup=nil
	local minutes = math.floor(math.mod(World.TimeIndex,60))
	if minutes < 25 or minutes > 35 then numStaying = numStaying+numLeaving; numLeaving = 0 end	-- reform roughly ends at 30 minutes past a whole hour, so disregard numLeaving at other times
	if this.DebugInfo=="ON" then print("                                             "..(numPlayers).." players found on court ("..numStaying.." stay, "..numLeaving.." leave)") end
	if numPlayers==0 or numLeaving == numPlayers then	-- when all prisoners are leaving at once then the reform must be finished, so game over
		DoSleepMode()
	else
		if this.DebugInfo=="ON" then print("                                             "..(numPlayers).." players found on court ("..MinimumPlayers.." required)") end
		if ScoreBoardFound == true and numPlayers < MinimumPlayers then
			SetBoardText("  "..numPlayers..":"..MinimumPlayers.." found","stable")
		end
		this.Tooltip={"tooltip_playersfoundandrequired",this.HomeUID,"X",numPlayers,"Y",MinimumPlayers,"Z"}
		DecideWhatToDo()
	end -- either sleep or check if teacher has stuff to do before bounceball() gets called in update()
	possiblePlayers = nil
	
--	local possiblePlayers = Find('Prisoner',10)
--	if next(possiblePlayers) then
--		for thatprisoner,dist in pairs( possiblePlayers ) do
--			if (thatprisoner.Pos.x>=this.Pos.x+this.Xmin-2 and thatprisoner.Pos.x<=this.Pos.x+this.Xmax+2) and (thatprisoner.Pos.y>=this.Pos.y+this.Ymin-2 and thatprisoner.Pos.y<=this.Pos.y+this.Ymax+2) then
--				numPlayers = numPlayers + 1
				
--				if (thatprisoner.Dest.x>=this.Pos.x+this.Xmin-4 and thatprisoner.Dest.x<=this.Pos.x+this.Xmax+4) and (thatprisoner.Dest.y>=this.Pos.y+this.Ymin-4 and --thatprisoner.Dest.y<=this.Pos.y+this.Ymax+4) then
--					numStaying = numStaying + 1
--				else
--					numLeaving = numLeaving + 1
--				end
--			end
--		end
--		local minutes = math.floor(math.mod(World.TimeIndex,60))
--		if minutes < 25 or minutes > 35 then numStaying = numStaying+numLeaving; numLeaving = 0 end	-- reform roughly ends at 30 minutes past a whole hour, so disregard numLeaving at other times
--		if this.DebugInfo=="ON" then print("                                             "..(numPlayers).." players found on court ("..numStaying.." stay, "..numLeaving.." leave)") end
--		if numPlayers==0 or numLeaving == numPlayers then	-- when all prisoners are leaving at once then the reform must be finished, so game over
--			DoSleepMode()
--		else
--			if this.DebugInfo=="ON" then print("                                             "..(numPlayers).." players found on court ("..MinimumPlayers.." required)") end
--			if ScoreBoardFound == true and numPlayers < MinimumPlayers then
--				SetBoardText("  "..numPlayers..":"..MinimumPlayers.." found","stable")
--			end
--			this.Tooltip={"tooltip_playersfoundandrequired",this.HomeUID,"X",numPlayers,"Y",MinimumPlayers,"Z"}
--			DecideWhatToDo()
--		end -- either sleep or check if teacher has stuff to do before bounceball() gets called in update()
--		possiblePlayers = nil
--	else
--		possiblePlayers = nil
--		DoSleepMode()
--	end
end

function FindMyPlayer()
	if myTeacher == nil or myTeacher.SubType == nil then
		SpawnTeacher()
	end
	if this.DebugInfo=="ON" then print("               Finding next player...") end
	myNewPlayer=myTeacher -- in case the game ends and there are no new players it could crash if myNewPlayer stays empty, so we make it the teacher by default.
--	if myCurrentPlayer==nil then
--		somePlayers = Find('Prisoner',10)
--	else
--		somePlayers = FindFrom(myCurrentPlayer,'Prisoner',10)
--	end
--	if next(somePlayers) then
--		local currentDist=20
--		for thatprisoner,dist in pairs( somePlayers ) do
--			if (thatprisoner.Pos.x>=this.Pos.x+this.Xmin-1 and thatprisoner.Pos.x<=this.Pos.x+this.Xmax+1) and (thatprisoner.Pos.y>=this.Pos.y+this.Ymin-1 and thatprisoner.Pos.y<=this.Pos.y+this.Ymax+1) then
--				if dist < currentDist and dist > 2 then
--					currentDist=dist
--					if myCurrentPlayer~=nil then
--						myNewPlayer=thatprisoner
--						if this.DebugInfo=="ON" then print("               Nearest player "..myNewPlayer.Id.i.." is at dist: "..math.floor(currentDist).." Position: "..myNewPlayer.Pos.x.." "..myNewPlayer.Pos.y.."") end
--						--break
--					else
--						myNewPlayer=thatprisoner
--						if this.DebugInfo=="ON" then print("               Nearest player "..myNewPlayer.Id.i.." is at dist: "..math.floor(currentDist).." Position: "..myNewPlayer.Pos.x.." "..myNewPlayer.Pos.y.."") end
--						--break
--					end
--				end
--			end
--		end
--		if this.DebugInfo=="ON" then print("               Next player: "..myNewPlayer.Id.i.."") end
--	end
--	somePlayers = nil
	
	
	
	local entityGroup = { "Prisoner", "Guard" }
	local currentDist=20
	for _, typ in pairs(entityGroup) do
		if myCurrentPlayer==nil then
			somePlayers = Find(typ,10)
		else
			somePlayers = FindFrom(myCurrentPlayer,typ,10)
		end
		for thatEntity, dist in pairs(somePlayers) do
			if (thatEntity.Pos.x>=this.Pos.x+this.Xmin-1 and thatEntity.Pos.x<=this.Pos.x+this.Xmax+1) and (thatEntity.Pos.y>=this.Pos.y+this.Ymin-1 and thatEntity.Pos.y<=this.Pos.y+this.Ymax+1) then
				if dist < currentDist and dist > 3 then
					currentDist=dist
					myNewPlayer=thatEntity
					if this.DebugInfo=="ON" then print("               Nearest player "..myNewPlayer.Id.i.." is at dist: "..math.floor(currentDist).." Position: "..myNewPlayer.Pos.x.." "..myNewPlayer.Pos.y.."") end
				end
			end
		end
	--	if this.DebugInfo=="ON" then print("               Next player: "..myNewPlayer.Type.." "..myNewPlayer.Id.i.."") end
		entityType=nil
	end
	entityGroup=nil
	if this.DebugInfo=="ON" then print("               Next player: "..myNewPlayer.Type.." "..myNewPlayer.Id.i.."") end
end

----------------------------------------------------------------------------------------------------------------------------------
--  Teacher stuff
----------------------------------------------------------------------------------------------------------------------------------

function FindMyTeacher()
	TeacherFound = false
	if this.DebugInfo=="ON" then print("Searching for Basketball Trainer...") end
	SetBoardText("find  trainer","stable")
	local nearbyTeachers = {}
	if this.UsingSmallField==false then
		nearbyTeachers = Find('BasketballTrainerFullCourt', 10)
	else
		nearbyTeachers = Find('BasketballTrainerHalfCourt', 10)
	end
	if next(nearbyTeachers) then
		for thatTeacher,dist in pairs( nearbyTeachers ) do
			if (thatTeacher.Pos.x>=this.Pos.x+this.Xmin-2 and thatTeacher.Pos.x<=this.Pos.x+this.Xmax+2) and (thatTeacher.Pos.y>=this.Pos.y+this.Ymin-2 and thatTeacher.Pos.y<=this.Pos.y+this.Ymax+2) then
				myTeacher = thatTeacher
				if this.DebugInfo=="ON" then print("Basketball Trainer found") end
				TeacherFound=true
				Set(this,"UsingYard",nil)
				SetBoardText("trainer found","stable")
				startingHour = math.floor(math.mod(World.TimeIndex,1440) /60)
				
				if BallFound==false then
					SpawnBallX=myTeacher.Pos.x
					SpawnBallY=myTeacher.Pos.y+0.1
					SpawnNewBall(0)
				end
				
				break
			end
		end
	end
	if TeacherFound == false then
		if this.DebugInfo=="ON" then print("Basketball Trainer not found, checking Yard") end
		nearbyTeachers = Find('BasketballTrainerYard', 10)
		if next(nearbyTeachers) then
			for thatTeacher,dist in pairs( nearbyTeachers ) do
				if (thatTeacher.Pos.x>=this.Pos.x+this.Xmin-2 and thatTeacher.Pos.x<=this.Pos.x+this.Xmax+2) and (thatTeacher.Pos.y>=this.Pos.y+this.Ymin-2 and thatTeacher.Pos.y<=this.Pos.y+this.Ymax+2) then
					myTeacher = thatTeacher
					if this.DebugInfo=="ON" then print("Basketball Trainer found") end
					TeacherFound=true
					Set(this,"UsingYard",true)
					SetBoardText("trainer found","stable")
					startingHour = math.floor(math.mod(World.TimeIndex,1440) /60)
					
					if BallFound==false then
						SpawnBallX=myTeacher.Pos.x
						SpawnBallY=myTeacher.Pos.y+0.1
						SpawnNewBall(0)
					end
					
					break
				end
			end
		else
			if this.DebugInfo=="ON" then print("Basketball Trainer not found") end
			TeacherFound=false
		end
	end
	nearbyTeachers = nil
end

function SpawnTeacher()
	if not this.UsingYard then
		if this.UsingSmallField==false then
			myTeacher = Spawn("BasketballTrainerFullCourt", this.Pos.x,this.Pos.y)
		else
			myTeacher = Spawn("BasketballTrainerHalfCourt", this.Pos.x,this.Pos.y)
		end
	else
		myTeacher = Spawn("BasketballTrainerYard", this.Pos.x,this.Pos.y)
	end
end

function TeacherStartsGame()
	if myTeacher == nil or myTeacher.SubType == nil then
		SpawnTeacher()
	end
	if myBall == nil or myBall.SubType == nil or myBall.Damage == 1 then
		SpawnBallX=myTeacher.Pos.x
		SpawnBallY=myTeacher.Pos.y+0.1
		SpawnNewBall(0)
	end
	--if (myTeacher.Pos.x>=this.Pos.x-2 and myTeacher.Pos.x<=this.Pos.x+2) and (myTeacher.Pos.y>=this.Pos.y-2 and myTeacher.Pos.y<=this.Pos.y+2) then
		if this.DebugInfo=="ON" then print("Basketball Trainer starting the game...") end
		--SetBoardText("     Play","stable")
		SetBoardText("   Tip-off","stable")
		
		Set(myBall,"Energy",100)			Set(myBall,"Carried",-1)
		Set(myBall,"NewPosX",nil)			Set(myBall,"NewPosY",nil)
		Set(myBall,"CarrierId.i",-1)		Set(myBall,"CarrierId.u",-1)
		
		Set(myBall,"Pos.y",myTeacher.Pos.y+0.2)
		Set(myBall,"Dribble",0)
		Set(myBall,"DribbleAt",myTeacher.Type)
		Set(myBall,"DribblePlayerI",myTeacher.Id.i)
		Set(myBall,"DribblePlayerU",myTeacher.Id.u)
		
		Set(myTeacher,"Carrying.i",-1)		Set(myTeacher,"Carrying.u",-1)
		
		this.Sound("BasketballCourt","WhistleA")
	
		Set(this,"hasStarted",true)
		Set(this,"LeftBasketMade",false)	Set(this,"RightBasketMade",false)
		
		FindMyPlayer()
		if this.DebugInfo=="ON" then print("Playing ball to first player "..myNewPlayer.Id.i) end
--		Set(myBall,"LinkMeTo","Prisoner")
		Set(myBall,"LinkMeTo",myNewPlayer.Type)
		if myTeacher.Pos.x > myNewPlayer.Pos.x then myBall.Pos.x = myTeacher.Pos.x-0.15 else myBall.Pos.x = myTeacher.Pos.x+0.15 end
		myBall.Pos.y = myTeacher.Pos.y
		Set(myBall,"StartX",myBall.Pos.x)			Set(myBall,"StartY",myBall.Pos.y)
		Set(myBall,"NewPosX",myNewPlayer.Pos.x)		Set(myBall,"NewPosY",myNewPlayer.Pos.y)
		Set(myBall,"NewPlayerI",myNewPlayer.Id.i)	Set(myBall,"NewPlayerU",myNewPlayer.Id.u)
		
		Set(this,"TeacherStartingGame",false)
	--end
end

function TeacherBringBallToCentre()
	if myTeacher == nil or myTeacher.SubType == nil then
		SpawnTeacher()
	end
	if myBall == nil or myBall.SubType == nil or myBall.Damage == 1 then
		SpawnBallX=myTeacher.Pos.x
		SpawnBallY=myTeacher.Pos.y+0.1
		SpawnNewBall(0)
	end
	if Get(myBall,"Carried") > -1 then
		if this.DebugInfo=="ON" then print("Basketball Trainer placing ball in centre...") end
		myTeacher.ClearRouting()
		FetchBallRetry = 0
	--	if this.UsingSmallField==true then
	--		if this.Or.x==0 and this.Or.y==1 then
	--			Object.NavigateTo(myTeacher, this.Pos.x-1, this.Pos.y)
	--		end	-- placed down
	--		if this.Or.x==-1 and this.Or.y==0 then
	--			Object.NavigateTo(myTeacher, this.Pos.x, this.Pos.y-1)
	--		end	-- rotated once
	--		if this.Or.x==0 and this.Or.y==-1 then
	--			Object.NavigateTo(myTeacher, this.Pos.x+1, this.Pos.y)
	--		end	-- rotated twice
	--		if this.Or.x==1 and this.Or.y==0 then
	--			Object.NavigateTo(myTeacher, this.Pos.x, this.Pos.y+1)
	--		end	-- rotated three times
	--	else
	--		Object.NavigateTo(myTeacher, this.Pos.x, this.Pos.y)
	--	end		
		
		Set(this,"TeacherBringToCentre",false)	Set(this,"TeacherStartingGame",true)
	else
		TeacherFetchBall()
	end
end

function TeacherFetchBall()
	if myTeacher == nil or myTeacher.SubType == nil then
		SpawnTeacher()
	end
	
	if myBall == nil or myBall.SubType == nil or myBall.Damage == 1 then
		FetchBallRetry = 0
		SpawnBallX=myTeacher.Pos.x
		SpawnBallY=myTeacher.Pos.y+0.1
		SpawnNewBall(0)
	end
	
	if (myBall.Pos.x > this.Pos.x+this.Xmin-0.5 and myBall.Pos.x < this.Pos.x+this.Xmax+0.5) and (myBall.Pos.y > this.Pos.y+this.Ymin-0.5 and myBall.Pos.y < this.Pos.y+this.Ymax+0.5) then
		Object.NavigateTo(myTeacher, myBall.Pos.x, myBall.Pos.y)
		FetchBallRetry = FetchBallRetry + 1
		if FetchBallRetry > 4 then
			Object.NavigateTo(myTeacher, this.Pos.x, this.Pos.y)
			FetchBallRetry = 0
			if this.DebugInfo=="ON" then print("Basketball Trainer was unable to fetch ball") end
			if this.BallKillOrDelete=="deleted" then
				myBall.Delete()
				SpawnBallX=myTeacher.Pos.x
				SpawnBallY=myTeacher.Pos.y+0.1
				SpawnNewBall(0)
			else
				myBall.Damage=1
				SpawnBallX=myTeacher.Pos.x
				SpawnBallY=myTeacher.Pos.y+0.1
				SpawnNewBall(0)
			end
		end
		--t1 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmin-0.5,this.Pos.y+this.Ymin-0.5)	-- for testing boundaries
		--t2 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmax+0.5,this.Pos.y+this.Ymax+0.5)
		--t3 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmin-0.5,this.Pos.y+this.Ymax+0.5)
		--t4 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmax+0.5,this.Pos.y+this.Ymin-0.5)
		--print("ball OK") 
		-- OK
	else	-- it's outside the court lines
		Object.NavigateTo(myTeacher, this.Pos.x, this.Pos.y)
		FetchBallRetry = 0
		if this.DebugInfo=="ON" then print("Basketball went outside the court lines") end
		if this.BallKillOrDelete=="deleted" then
			myBall.Delete()
			SpawnBallX=myTeacher.Pos.x
			SpawnBallY=myTeacher.Pos.y+0.1
			SpawnNewBall(0)
		else
			myBall.Damage=1
			SpawnBallX=myTeacher.Pos.x
			SpawnBallY=myTeacher.Pos.y+0.1
			SpawnNewBall(0)
		end
		--t1 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmin-0.5,this.Pos.y+this.Ymin-0.5)	-- for testing boundaries
		--t2 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmax+0.5,this.Pos.y+this.Ymax+0.5)
		--t3 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmin-0.5,this.Pos.y+this.Ymax+0.5)
		--t4 = Object.Spawn("LCDnumber",this.Pos.x+this.Xmax+0.5,this.Pos.y+this.Ymin-0.5)
	end
	
	if this.DebugInfo=="ON" then print("Basketball Trainer fetching ball...") end
	
	Set(myBall,"Energy",100)			Set(myBall,"Carried",-1)
	Set(myBall,"NewPosX",nil)			Set(myBall,"NewPosY",nil)
	if not this.UsingYard then
		if this.UsingSmallField==false then
			Set(myBall,"LinkMeTo","BasketballTrainerFullCourt")
		else
			Set(myBall,"LinkMeTo","BasketballTrainerHalfCourt")
		end
	else
		Set(myBall,"LinkMeTo","BasketballTrainerYard")
	end
	Set(myBall,"NewPlayerI",myTeacher.Id.i)		Set(myBall,"NewPlayerU",myTeacher.Id.u)
	
	myCurrentPlayer=nil
	Set(this,"TeacherFetchBall",true)
	Set(this,"TeacherBringToCentre",true)
end

----------------------------------------------------------------------------------------------------------------------------------
--  Decide
----------------------------------------------------------------------------------------------------------------------- -----------

function DecideWhatToDo()

	if numPlayers>WakeUpOnPlayers and this.StillAsleep==true then
		LightsOn()
		timePerUpdate = 2
		if TeacherFound==false then	FindMyTeacher()	end
	end
	
	if numPlayers>=MinimumPlayers and TeacherFound==true and this.StillAsleep==true then
	
			DoWakeUpMode()

	elseif numPlayers>=MinimumPlayers and TeacherFound==true and this.StillAsleep==false then
		-- the teacher can't do the three functions below in one turn, so it goes step by step while update() waits a few moments in between to give the teacher time to navigate
		if myBall == nil or myBall.SubType == nil or myBall.Damage == 1 then
			this.TeacherFetchBall=false
		end
		
		if this.TeacherFetchBall==false then
			TeacherFetchBall()
		end
		
		if this.TeacherBringToCentre==true then
			TeacherBringBallToCentre()			
		end
		
		if this.TeacherStartingGame==true then
			TeacherStartsGame()
		end
		--else
		--	if this.DebugInfo=="ON" then print("Nothing to be done by teacher") end
			currentHour = math.floor(math.mod(World.TimeIndex,1440) /60)
		--	if currentHour ~= startingHour and myScoreBoard.ShowCountdown == false then
			if currentHour ~= startingHour and this.ShowCountdown == false then
				if myBall ~= nil and myBall.SubType ~= nil and myBall.Damage ~= 1 then
					myBall.Delete()
					TeacherFetchBall()
					SetBoardText("game  started","blink")
					Set(this,"LeftScore",0)
					Set(this,"RightScore",0)
					SetBoardScore()
				end
			end
		--end
		if this.ShowCountdown == false then
	--	if Get(myScoreBoard,"ShowCountdown") == false then
			SetBoardText("   warm up","stable")
		elseif Get(myScoreBoard,"CountdownFinished") == true then
			local minutes = math.floor(math.mod(World.TimeIndex,60))
			if minutes ~= 30 then
				myScoreBoard.HourCount = myScoreBoard.HourCount + 1
				if myScoreBoard.HourCount == 1 then
					SetBoardText("1 hour done","blink")
				elseif myScoreBoard.HourCount == 1 then
					SetBoardText("2 hours done","blink")
				end
				myScoreBoard.CountdownFinished = nil
			end
		end
	elseif numPlayers<WakeUpOnPlayers and this.StillAsleep==false then
		DoSleepMode()
	end
	
end

----------------------------------------------------------------------------------------------------------------------------------
--  Sleep or Wake up
----------------------------------------------------------------------------------------------------------------------------------

function DoWakeUpMode()
	if this.DebugInfo=="ON" then print("Waking up") end
	this.Tooltip={"tooltip_gettingready",this.HomeUID,"X"}
	timePerUpdate = 2
	Set(this,"LeftScore",0)
	Set(this,"RightScore",0)
	SetBoardText("   Wake up","stable")
	Set(myScoreBoard,"repeatNumberTimer",0)
	SetBoardScore()
	Set(this,"TeacherFetchBall",false)
	Set(this,"StillAsleep",false)
end

function DoSleepMode()
	if this.StillAsleep==false then
		if this.UsingSmallField==false then
			if this.DebugInfo=="ON" then print("Score for this match was: "..this.LeftScore.." - "..this.RightScore.."") end
		else
			if this.DebugInfo=="ON" then print("Score for this match was: "..this.LeftScore.."") end
		end
		if this.DebugInfo=="ON" then print("Going back to sleep") end
		LightsOff()
		this.Tooltip={"tooltip_sleepmode",this.HomeUID,"X"}
		timePerUpdate = 10
		TeacherFound=false
		this.Sound("BasketballCourt","WhistleB")
		this.Sound("BasketballCourt","WhistleB")
		this.Sound("BasketballCourt","WhistleB")
		this.Sound("BasketballCourt","WhistleB")
		Set(this,"StillAsleep",true)
		Set(this,"hasStarted",false)
		Set(this,"TeacherBringToCentre",false)
		Set(this,"LeftBasketMade",false)
		SetBoardText("game over","stable")
		Set(this,"LeftScore","///")
		Set(this,"RightBasketMade",false)
		Set(this,"RightScore","///")
		Set(myScoreBoard,"repeatNumberTimer",0)
		SetBoardScore()
		Set(this,"TeacherFetchBall",false)
		Set(this,"TeacherBringToCentre",false)
		Set(this,"TeacherStartingGame",false)
		if BallFound==true then
			BallFound=false
			Set(myBall,"Carried",-1)
			Set(myBall,"NewPosX",nil)
			Set(myBall,"NewPosY",nil)
			Set(myBall,"CarrierId.i",-1)
			Set(myBall,"CarrierId.u",-1)
			Set(myCurrentPlayer,"Carrying.i",-1)
			Set(myCurrentPlayer,"Carrying.u",-1)
			Set(myNewPlayer,"Carrying.i",-1)
			Set(myNewPlayer,"Carrying.u",-1)
			Set(myTeacher,"Carrying.i",-1)
			Set(myTeacher,"Carrying.u",-1)
			if this.BallKillOrDelete=="deleted" then
				if this.DebugInfo=="ON" then print("Deleting the basketball") end
				if myBall ~= nil and myBall.SubType ~= nil then
					myBall.Delete()
				end
			else
				if this.DebugInfo=="ON" then print("Killing the basketball") end
				myBall.Damage=1
			end
			myBall=nil
		end
		--LightsOff()
	end
end

----------------------------------------------------------------------------------------------------------------------------------
--  Update
----------------------------------------------------------------------------------------------------------------------------------		
			  
function Update( timePassed )		
	if this.TimeWarp == nil then
		if World.TimeWarpFactor == nil then
			CalculateTimeWarpFactor(timePassed)
		else 
			Set(this,"TimeWarp",World.TimeWarpFactor)
		end
		return
	elseif timePerUpdate==nil then

		if this.CreateMyField=="ON" then CreateMyField() Set(this,"CreateMyField","OFF") end
		
		Interface.AddComponent(this,"toggleDelete", "Button", "tooltip_button_delete")
		
		FindMyScoreBoard()
		if ScoreBoardFound == true then
			AddScoreboardButtons()
		else
			Interface.AddComponent(this,"scoreboardconfig","Caption","tooltip_scoreboardconfig")
			Interface.AddComponent(this,"toggleFindScoreboard", "Button", "tooltip_button_toggleFindScoreboard")
		end
		
		Interface.AddComponent(this,"courtconfig","Caption","tooltip_courtconfig")
		
		FindMyBaskets()
		AddCourtButton()
		
		FindMyCourtLights()
		if this.PLAYGAME=="ON" then
			FindMyBall()
			FindMyTeacher()
			if BallFound==true then
				myBall.Delete()
				myBall = nil
				Set(this,"hasStarted",false)
				Set(this,"TeacherBringToCentre",false)
				timePerUpdate = 2
			else
				timePerUpdate = 10
				if this.UsingSmallField==false then
					this.Tooltip={"tooltip_fullcourtwelcome",this.HomeUID,"X"}
				else
					this.Tooltip={"tooltip_halfcourtwelcome",this.HomeUID,"X"}
				end
			end
		else
			timePerUpdate = 1440
		end
	end
	timeTot = timeTot + timePassed
	if timeTot>=timePerUpdate then
		timeTot=0
				
		if this.PLAYGAME=="ON" then
		
			if BasketsFound==false then
				FindMyBaskets()
			end
			
			if BasketsFound==true then

				CheckNumPlayers()

				if this.hasStarted==true then
					if this.LeftBasketMade==false and this.RightBasketMade==false then
						if myBall.LinkMeTo == "None" then
							BounceBall()
						end
					end
				end
			end
		end
	end
	if myBall ~= nil and myBall.LinkMeTo == "None" and myBall.Success==true then
		DoGoal()
	end
	if myScoreBoard == nil or myScoreBoard.SubType == nil and ScoreBoardFound == true then
		ReorganizeButtons()
		ScoreBoardFound = false
	end
end

function DoGoal()
	if myBall.Success==true and this.LeftBasketMade==true then
		this.Sound("BasketballCourt","WhistleB")
		this.Sound("BasketballCourt","WhistleB")
		this.Sound("BasketballCourt","WhistleA")
		if this.DebugInfo=="ON" then print("               SCORE!!!") end
		if myBall.BasketDistance>=4.5 then
			Set(this,"RightScore",this.RightScore+3)		-- three points goal
			SetBoardText("     3 points","blink")
		elseif (myBall.StartX >= myLeftBasket.Pos.x - 0.25 and myBall.StartX <= myLeftBasket.Pos.x+2.5) and (myBall.StartY >= myLeftBasket.Pos.y - 0.5 and myBall.StartY <= myLeftBasket.Pos.y + 0.5) then
			Set(this,"RightScore",this.RightScore+1)		-- one points goal
			SetBoardText("      1 point","blink")
		else
			Set(this,"RightScore",this.RightScore+2)		-- two points goal
			SetBoardText("     2 points","blink")
		end
		if this.UsingSmallField==false then
			if this.DebugInfo=="ON" then print("               Score: "..this.LeftScore.." - "..this.RightScore.."") end
			this.Tooltip={"tooltip_fullcourtBasket",this.HomeUID,"X",this.LeftScore,"Y",this.RightScore,"Z"}
		else
			if this.DebugInfo=="ON" then print("               Score: "..this.RightScore.."") end
			this.Tooltip={"tooltip_halfcourtBasket",this.HomeUID,"X",this.RightScore,"Y"}
		end
		SetBoardScore()
		if myBall == nil or myBall.SubType == nil then
			SpawnBallX=myLeftBasket.Pos.x
			SpawnBallY=myLeftBasket.Pos.y+0.50
		else
			SpawnBallX=myBall.Pos.x
			SpawnBallY=myBall.Pos.y
		end
		myBall.Delete()
		myBall=nil
		SpawnNewBall(7)
		Set(this,"hasStarted",false)
		Set(this,"TeacherFetchBall",false)
	elseif myBall.Success==true and this.RightBasketMade==true then
		this.Sound("BasketballCourt","WhistleB")
		this.Sound("BasketballCourt","WhistleB")
		this.Sound("BasketballCourt","WhistleA")
		if this.DebugInfo=="ON" then print("               SCORE!!!") end
		if myBall.BasketDistance>=4.5 then
			Set(this,"LeftScore",this.LeftScore+3)		-- three points goal
			SetBoardText("3 points","blink")
		elseif (myBall.StartX <= myRightBasket.Pos.x + 0.25 and myBall.StartX >= myRightBasket.Pos.x-2.5) and (myBall.StartY >= myRightBasket.Pos.y - 0.5 and myBall.StartY <= myRightBasket.Pos.y + 0.5) then
			Set(this,"LeftScore",this.LeftScore+1)		-- one points goal
			SetBoardText("1 point","blink")
		else
			Set(this,"LeftScore",this.LeftScore+2)		-- two points goal
			SetBoardText("2 points","blink")
		end
		if this.DebugInfo=="ON" then print("               Score: "..this.LeftScore.." - "..this.RightScore.."") end
		this.Tooltip={"tooltip_fullcourtBasket",this.HomeUID,"X",this.LeftScore,"Y",this.RightScore,"Z"}
		SetBoardScore()
		if myBall == nil or myBall.SubType == nil then
			SpawnBallX=myRightBasket.Pos.x
			SpawnBallY=myRightBasket.Pos.y+0.50
		else
			SpawnBallX=myBall.Pos.x
			SpawnBallY=myBall.Pos.y
		end
		myBall.Delete()
		myBall=nil
		SpawnNewBall(7)
		Set(this,"hasStarted",false)
		Set(this,"TeacherFetchBall",false)
	end
end

function SetBoardText(theText,theTextType)
	if ScoreBoardFound==true then
		Set(myScoreBoard,"LCDcurChar",1)
		Set(myScoreBoard,"LCDpreOffset","/////////////")
		Set(myScoreBoard,"ScrollingText","/////////////")
		Set(myScoreBoard,"repeatTimer",0)
		if theText == "game over" then
			Set(myScoreBoard,"ShowClock",this.ShowClock)
			Set(this,"ShowCountdown",false)
			Set(myScoreBoard,"ShowCountdown",false)
			Set(myScoreBoard,"FirstCountdownFinished",nil)
			if myRightBasket ~= nil and myLeftBasket ~= nil then
				Set(myScoreBoard,"LCDtext","game over...   score: "..this.LeftScore.."-"..this.RightScore)
			elseif myLeftBasket ~= nil then
				Set(myScoreBoard,"LCDtext","game over...   score: "..this.RightScore.." points")
			elseif myRightBasket ~= nil then
				Set(myScoreBoard,"LCDtext","game over...   score: "..this.LeftScore.." points")
			end
			Set(myScoreBoard,"TextType","scroll")
		else
			Set(myScoreBoard,"LCDtext",theText)
			Set(myScoreBoard,"TextType",theTextType)
		end
		if theText == "game  started" then
			Set(myScoreBoard,"ShowClock",false)
			Set(this,"ShowCountdown",true)
			Set(myScoreBoard,"ShowCountdown",true)
		end
		Set(myScoreBoard,"FadeIn",nil)
		Set(myScoreBoard,"TextSet",nil)
	end
end

function SetBoardScore()
	if ScoreBoardFound==true then
		if myRightBasket ~= nil then Set(myScoreBoard,"LCDnumberLeft",this.LeftScore) end
		if myLeftBasket ~= nil then Set(myScoreBoard,"LCDnumberRight",this.RightScore) end
		Set(myScoreBoard,"NumberSet",nil)
	end
end

function DismantleAll()
	if this.UsingSmallField==nil then Set(this,"UsingSmallField", UseSmallField) end
	if BasketsFoundL==true then print("deleting left basket") myLeftBasket.Delete() end
	if BasketsFoundR==true then print("deleting right basket") myRightBasket.Delete() end
	FindMyCourtLights() print("deleting court lights")
	if myCentreLight~=nil then myCentreLight.Delete() end
	LightsOff()
	SetBoardText("delete","stable")
	this.Delete()
end

----------------------------------------------------------------------------------------------------------------------------------
--  Create stuff
----------------------------------------------------------------------------------------------------------------------------------

function MakeFloor(FloorType)
	local U16 = false	-- see if PA Update 16 is running by checking a new feature
	if Interface.SetReportTabs ~= nil then
		U16 = true		-- if it exists we can set the material to Indoors by default (since cell.Ind always returns false in prior versions)
	end
	
	local x = this.Pos.x --math.floor(this.Pos.x)
	local y = this.Pos.y --math.floor(this.Pos.y)
	if FloorType~="Dirt" then
		for i=this.Ymin-1,this.Ymax+1 do	for j=this.Xmin-1,this.Xmax+1 do	local cell = World.GetCell(x+j,y+i)	cell.Mat = "ConcreteTiles"	if U16 == true then cell.Ind = true end end	end
		for i=this.Ymin,this.Ymax do		for j=this.Xmin,this.Xmax do		local cell = World.GetCell(x+j,y+i)	cell.Mat = FloorType		if U16 == true then cell.Ind = true end end	end
	else -- deleted court, resetting floor to concrete if indoor or dirt if outdoor
		for i=this.Ymin-1,this.Ymax+1 do	for j=this.Xmin-1,this.Xmax+1 do	local cell = World.GetCell(x+j,y+i)	if cell.Ind==true then cell.Mat = "ConcreteFloor" else cell.Mat = "Dirt" end 	end	end
	end
end

-- default placement Down: orX 0 orY 1
-- Left: orX -1 orY 0
-- Up : orX 0 orY -1
-- Right: orX 1 orY 0

function CreateMyField()
	--print("Or.x "..this.Or.x.." Or.y "..this.Or.y.."")
	Set(this,"HomeUID",me["id-uniqueId"])
	this.Tooltip={"tooltip_welcometoslam",this.HomeUID,"X"}
	Set(this,"UsingSmallField",UseSmallField)
	Set(this,"PLAYGAME","OFF")
	Set(this,"ShowClock",true)
	Set(this,"ShowCountdown",false)
	Set(this,"BallKillOrDelete","deleted")
	Set(this,"CourtLights","OFF")
	Set(this,"DebugInfo","OFF")
	Set(this,"numLine",numLine)
	Set(this,"StillAsleep",true)
	Set(this,"hasStarted",false)
	Set(this,"LeftBasketMade",false)
	Set(this,"RightBasketMade",false)
	Set(this,"TeacherFetchBall",false)
	Set(this,"TeacherBringToCentre",false)
	Set(this,"TeacherStartingGame",false)
	if this.UsingSmallField==false then
		
		if this.Or.x==0 then
			Set(this,"Xmin",-7.5)	Set(this,"Xmax",7.5)	Set(this,"Ymin",-4.5)	Set(this,"Ymax",4.5)
		elseif this.Or.y==0 then
			Set(this,"Xmin",-4.5)	Set(this,"Xmax",4.5)	Set(this,"Ymin",-7.5)	Set(this,"Ymax",7.5)
		end
	else
		print("this.Or.x "..this.Or.x.." y "..this.Or.y)
		if this.Or.x==0 and this.Or.y==1 then
			Set(this,"Xmin",-3.5)	Set(this,"Xmax",3.5)	Set(this,"Ymin",-4.5)	Set(this,"Ymax",4.5)
		elseif this.Or.x==1 and this.Or.y==0 then
			Set(this,"Xmin",-4.5)	Set(this,"Xmax",4.5)	Set(this,"Ymin",-3.5)	Set(this,"Ymax",3.5)
		elseif this.Or.x==0 and this.Or.y==-1 then
			Set(this,"Xmin",-3.5)	Set(this,"Xmax",3.5)	Set(this,"Ymin",-4.5)	Set(this,"Ymax",4.5)
		elseif this.Or.x==-1 and this.Or.y==0 then
			Set(this,"Xmin",-4.5)	Set(this,"Xmax",4.5)	Set(this,"Ymin",-3.5)	Set(this,"Ymax",3.5)
		end
	end
	
	if this.UsingSmallField==false then

		if this.Or.x==0 then  -- horizontal large court
			myLeftBasket = Spawn("Basket3", this.Pos.x-7.00000,this.Pos.y)
			myRightBasket = Spawn("Basket3", this.Pos.x+7.00000,this.Pos.y)
			Set(myRightBasket,"Or.x",1)	Set(myRightBasket,"Or.y",0)
			
			myScoreBoard = Spawn("ScoreBoard3", this.Pos.x, this.Pos.y-5.60000)
			
			myContainer = Spawn("BasketballContainer3", this.Pos.x+3.5, this.Pos.y-5.50000)
			myContainer = Spawn("BasketballContainer3", this.Pos.x-3.5, this.Pos.y-5.50000)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x+8.5, this.Pos.y+5.50000)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x-8.5, this.Pos.y+5.50000)
			
		elseif this.Or.y==0 then  -- vertical large court
			myLeftBasket = Spawn("Basket3", this.Pos.x,this.Pos.y-7.00000)
			myRightBasket = Spawn("Basket3", this.Pos.x,this.Pos.y+7.00000)
			
			myScoreBoard = Spawn("ScoreBoard3", this.Pos.x, this.Pos.y-8.60000)
			
			myContainer = Spawn("BasketballContainer3", this.Pos.x+3.50000, this.Pos.y-8.5)
			myContainer = Spawn("BasketballContainer3", this.Pos.x-3.50000, this.Pos.y-8.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x+5.50000, this.Pos.y+8.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x-5.50000, this.Pos.y+8.5)
		end
		
		Set(myScoreBoard,"HomeUID",this.HomeUID)
		myScoreBoard.Tooltip="buildtoolbar_popup_obj_ScoreBoardLeague"
		Set(myLeftBasket,"HomeUID",this.HomeUID)
		Set(myLeftBasket,"LeftBasket","yes")
		Set(myLeftBasket,"RightBasket","no")
		Set(myRightBasket,"HomeUID",this.HomeUID)
		Set(myRightBasket,"LeftBasket","no")
		Set(myRightBasket,"RightBasket","yes")
		myRightBasket.Tooltip={"tooltip_linkedto",myRightBasket.HomeUID,"X"}
		
		Set(this,"LeftScore",0)	Set(this,"RightScore",0)		

		myCentreLight = Spawn("Light", this.Pos.x, this.Pos.y)
		
	else -- small court
	
		if this.Or.x==0 and this.Or.y==1 then	-- placed down
			myLeftBasket = Spawn("Basket3", this.Pos.x-3,this.Pos.y)
			Set(myLeftBasket,"HomeUID",this.HomeUID)
			Set(myLeftBasket,"LeftBasket","yes")
			Set(myLeftBasket,"RightBasket","no")
			myScoreBoard = Spawn("ScoreBoard3", this.Pos.x, this.Pos.y-5.60000)
			myContainer = Spawn("BasketballContainer3", this.Pos.x+3.50000, this.Pos.y-5.5)
			myContainer = Spawn("BasketballContainer3", this.Pos.x-3.50000, this.Pos.y-5.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x+4.50000, this.Pos.y+5.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x-4.50000, this.Pos.y+5.5)
			myCentreLight = Spawn("Light", this.Pos.x+3.8, this.Pos.y)
			
		elseif this.Or.x==-1 and this.Or.y==0 then	-- rotated once
			myLeftBasket = Spawn("Basket3", this.Pos.x,this.Pos.y-3)
			Set(myLeftBasket,"HomeUID",this.HomeUID)
			Set(myLeftBasket,"LeftBasket","yes")
			Set(myLeftBasket,"RightBasket","no")
			myScoreBoard = Spawn("ScoreBoard3", this.Pos.x, this.Pos.y-4.60000)
			myContainer = Spawn("BasketballContainer3", this.Pos.x+3.50000, this.Pos.y-4.5)
			myContainer = Spawn("BasketballContainer3", this.Pos.x-3.50000, this.Pos.y-4.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x+5.50000, this.Pos.y+4.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x-5.50000, this.Pos.y+4.5)
			myCentreLight = Spawn("Light", this.Pos.x, this.Pos.y+3.8)
			
		elseif this.Or.x==0 and this.Or.y==-1 then	-- rotated twice
			myRightBasket = Spawn("Basket3", this.Pos.x+3,this.Pos.y)
			Set(myRightBasket,"HomeUID",this.HomeUID)
			Set(myRightBasket,"LeftBasket","no")
			Set(myRightBasket,"RightBasket","yes")
			myScoreBoard = Spawn("ScoreBoard3", this.Pos.x, this.Pos.y-5.60000)
			myContainer = Spawn("BasketballContainer3", this.Pos.x+3.50000, this.Pos.y-5.5)
			myContainer = Spawn("BasketballContainer3", this.Pos.x-3.50000, this.Pos.y-5.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x+4.50000, this.Pos.y+5.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x-4.50000, this.Pos.y+5.5)
			myCentreLight = Spawn("Light", this.Pos.x-3.8, this.Pos.y)
			
		elseif this.Or.x==1 and this.Or.y==0 then	-- rotated three times
			myRightBasket = Spawn("Basket3", this.Pos.x,this.Pos.y+3)
			Set(myRightBasket,"HomeUID",this.HomeUID)
			Set(myRightBasket,"LeftBasket","no")
			Set(myRightBasket,"RightBasket","yes")
			myScoreBoard = Spawn("ScoreBoard3", this.Pos.x, this.Pos.y-4.60000)
			myContainer = Spawn("BasketballContainer3", this.Pos.x+3.50000, this.Pos.y-4.5)
			myContainer = Spawn("BasketballContainer3", this.Pos.x-3.50000, this.Pos.y-4.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x+5.50000, this.Pos.y+4.5)
--			myContainer = Spawn("BasketballContainer3", this.Pos.x-5.50000, this.Pos.y+4.5)
			myCentreLight = Spawn("Light", this.Pos.x, this.Pos.y-3.8)
			
		end
		
		Set(this,"LeftScore",0)
	end
	
	Set(myCentreLight,"HomeUID",this.HomeUID)
	
	
	timePerUpdate = 1440
	
	Interface.AddComponent(this,"toggleDelete", "Button", "tooltip_button_delete")
	Interface.AddComponent(this,"scoreboardconfig","Caption","tooltip_scoreboardconfig")
	Interface.AddComponent(this,"toggleScoreboardcolour", "Button", "tooltip_button_toggleScoreboardcolour","tooltip_button_boardcolour"..myScoreBoard.SubType,"X")
	Interface.AddComponent(this,"toggleLCDtextcolour", "Button", "tooltip_button_toggleLCDtextcolour","tooltip_button_textcolour"..myScoreBoard.LCDtextcolour,"X")
	Interface.AddComponent(this,"toggleLCDscorecolour", "Button", "tooltip_button_toggleLCDscorecolour","tooltip_button_scorecolour"..myScoreBoard.LCDscorecolour,"X")
	Interface.AddComponent(this,"toggleLCDclockcolour", "Button", "tooltip_button_toggleLCDclockcolour","tooltip_button_clockcolour"..myScoreBoard.LCDclockcolour,"X")
	Interface.AddComponent(this,"toggleShowClock", "Button", "tooltip_button_toggleLCDShowClock")
	Interface.AddComponent(this,"toggleShowSeconds", "Button", "tooltip_button_toggleLCDShowSeconds","tooltip_button_showseconds"..myScoreBoard.ShowSeconds,"X")
	Interface.AddComponent(this,"courtconfig","Caption","tooltip_courtconfig")
	Interface.AddComponent(this,"toggleGame", "Button", "tooltip_button_game","tooltip_off","X")
	Interface.AddComponent(this,"toggleDeleteOrKillBall", "Button", "tooltip_button_balldelkill","tooltip_del","X")
	Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_button_floortype",FloorDescription[numFloor],"X")
	Interface.AddComponent(this,"toggleLineType", "Button", "tooltip_button_linetype",this.numLine,"X")
	Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_off","X")
	Interface.AddComponent(this,"toggleDebugInfo", "Button", "tooltip_button_debuginfo","tooltip_off","X")
	MakeFloor(FloorTypes[numFloor])
end

----------------------------------------------------------------------------------------------------------------------------------
--  Buttons
----------------------------------------------------------------------------------------------------------------------------------

function toggleFindScoreboardClicked()
	FindMyScoreBoard()
	if ScoreBoardFound == true then
		SetBoardScore()
		Interface.RemoveComponent(this,"toggleFindScoreboard")
		Interface.RemoveComponent(this,"courtconfig")
		Interface.RemoveComponent(this,"toggleGame")
		Interface.RemoveComponent(this,"toggleDeleteOrKillBall")
		Interface.RemoveComponent(this,"toggleFloorType")
		Interface.RemoveComponent(this,"toggleLineType")
		Interface.RemoveComponent(this,"toggleCourtLights")
		Interface.RemoveComponent(this,"toggleDebugInfo")
		
		Interface.AddComponent(this,"toggleScoreboardcolour", "Button", "tooltip_button_toggleScoreboardcolour","tooltip_button_boardcolour"..myScoreBoard.SubType,"X")
		Interface.AddComponent(this,"toggleLCDtextcolour", "Button", "tooltip_button_toggleLCDtextcolour","tooltip_button_textcolour"..myScoreBoard.LCDtextcolour,"X")
		Interface.AddComponent(this,"toggleLCDscorecolour", "Button", "tooltip_button_toggleLCDscorecolour","tooltip_button_scorecolour"..myScoreBoard.LCDscorecolour,"X")
		Interface.AddComponent(this,"toggleLCDclockcolour", "Button", "tooltip_button_toggleLCDclockcolour","tooltip_button_clockcolour"..myScoreBoard.LCDclockcolour,"X")
		Interface.AddComponent(this,"toggleShowClock", "Button", "tooltip_button_toggleLCDShowClock")
		Interface.AddComponent(this,"toggleShowSeconds", "Button", "tooltip_button_toggleLCDShowSeconds","tooltip_button_showseconds"..myScoreBoard.ShowSeconds,"X")
		
		Interface.AddComponent(this,"courtconfig","Caption","tooltip_courtconfig")
		
		if this.PLAYGAME=="ON" then
			Interface.AddComponent(this,"toggleGame", "Button", "tooltip_button_game","tooltip_on","X")
		else
			Interface.AddComponent(this,"toggleGame", "Button", "tooltip_button_game","tooltip_off","X")
		end
		if this.BallKillOrDelete=="deleted" then
			Interface.AddComponent(this,"toggleDeleteOrKillBall", "Button", "tooltip_button_balldelkill","tooltip_del","X")
		else
			Interface.AddComponent(this,"toggleDeleteOrKillBall", "Button", "tooltip_button_balldelkill","tooltip_kill","X")
		end
		Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_button_floortype",FloorDescription[this.numFloor],"X")
		Interface.AddComponent(this,"toggleLineType", "Button", "tooltip_button_linetype",this.numLine,"X")
		if this.PLAYGAME=="OFF" then
			if this.CourtLights=="ON" then
				Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_on","X")
			else
				Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_off","X")
			end
		end
		if this.DebugInfo=="ON" then
			Interface.AddComponent(this,"toggleDebugInfo", "Button", "tooltip_button_debuginfo","tooltip_on","X")
		else
			Interface.AddComponent(this,"toggleDebugInfo", "Button", "tooltip_button_debuginfo","tooltip_off","X")
		end
	end
end

function toggleScoreboardcolourClicked()
	if myScoreBoard.SubType == 0 then
		myScoreBoard.SubType = 1
		SetBoardText("Border: blue","stable")
	elseif myScoreBoard.SubType == 1 then
		myScoreBoard.SubType = 2
		SetBoardText("Border: brown","stable")
	elseif myScoreBoard.SubType == 2 then
		myScoreBoard.SubType = 3
		SetBoardText("Border: white","stable")
	elseif myScoreBoard.SubType == 3 then
		myScoreBoard.SubType = 4
		SetBoardText("Border: red","stable")
	elseif myScoreBoard.SubType == 4 then
		myScoreBoard.SubType = 0
		SetBoardText("Border: grey","stable")
	end
	this.SetInterfaceCaption("toggleScoreboardcolour", "tooltip_button_toggleScoreboardcolour","tooltip_button_boardcolour"..myScoreBoard.SubType,"X")
end

function toggleLCDtextcolourClicked()
	if myScoreBoard.LCDtextcolour == 0 then
		myScoreBoard.LCDtextcolour = 43
		SetBoardText("Text: cyan","stable")
	elseif myScoreBoard.LCDtextcolour == 43 then
		myScoreBoard.LCDtextcolour = 86
		SetBoardText("Text: yellow","stable")
	elseif myScoreBoard.LCDtextcolour == 86 then
		myScoreBoard.LCDtextcolour = 129
		SetBoardText("Text: green","stable")
	elseif myScoreBoard.LCDtextcolour == 129 then
		myScoreBoard.LCDtextcolour = 0
		SetBoardText("Text: red","stable")
	end
	this.SetInterfaceCaption("toggleLCDtextcolour", "tooltip_button_toggleLCDtextcolour","tooltip_button_textcolour"..myScoreBoard.LCDtextcolour,"X")
end

function toggleLCDscorecolourClicked()
	if myScoreBoard.LCDscorecolour == 0 then
		myScoreBoard.LCDscorecolour = 13
		SetBoardText("score: cyan","stable")
	elseif myScoreBoard.LCDscorecolour == 13 then
		myScoreBoard.LCDscorecolour = 26
		SetBoardText("score: yellow","stable")
	elseif myScoreBoard.LCDscorecolour == 26 then
		myScoreBoard.LCDscorecolour = 39
		SetBoardText("score: green","stable")
	elseif myScoreBoard.LCDscorecolour == 39 then
		myScoreBoard.LCDscorecolour = 0
		SetBoardText("score: red","stable")
	end
	this.SetInterfaceCaption("toggleLCDscorecolour", "tooltip_button_toggleLCDscorecolour","tooltip_button_scorecolour"..myScoreBoard.LCDscorecolour,"X")
	myScoreBoard.NumberSet = nil
end

function toggleLCDclockcolourClicked()
	if myScoreBoard.LCDclockcolour == 0 then
		myScoreBoard.LCDclockcolour = 43
		myScoreBoard.LCDcoloncolour = 1
		SetBoardText("Clock: cyan","stable")
	elseif myScoreBoard.LCDclockcolour == 43 then
		myScoreBoard.LCDclockcolour = 86
		myScoreBoard.LCDcoloncolour = 2
		SetBoardText("Clock: yellow","stable")
	elseif myScoreBoard.LCDclockcolour == 86 then
		myScoreBoard.LCDclockcolour = 129
		myScoreBoard.LCDcoloncolour = 3
		SetBoardText("Clock: green","stable")
	elseif myScoreBoard.LCDclockcolour == 129 then
		myScoreBoard.LCDclockcolour = 0
		myScoreBoard.LCDcoloncolour = 0
		SetBoardText("Clock: red","stable")
	end
	this.SetInterfaceCaption("toggleLCDclockcolour", "tooltip_button_toggleLCDclockcolour","tooltip_button_clockcolour"..myScoreBoard.LCDclockcolour,"X")
end

function toggleShowClockClicked()
	if this.ShowClock == false then
		this.ShowClock = true
		myScoreBoard.ShowClock = true
		SetBoardText("   clock on","stable")
	else
		this.ShowClock = false
		myScoreBoard.ShowClock = false
		SetBoardText("  clock off","stable")
	end
end

function toggleShowSecondsClicked()
	if myScoreBoard.ShowSeconds == 0 then
		myScoreBoard.ShowSeconds = 1
		SetBoardText(" seconds on","stable")
	else
		myScoreBoard.ShowSeconds = 0
		SetBoardText("seconds off","stable")
	end
	this.SetInterfaceCaption("toggleShowSeconds", "tooltip_button_toggleLCDShowSeconds","tooltip_button_showseconds"..myScoreBoard.ShowSeconds,"X")
end

function toggleGameClicked()
	if this.PLAYGAME=="ON" then
		Set(this,"PLAYGAME","OFF")
		Set(this,"StillAsleep",false)
		DoSleepMode()
		Set(this,"LeftBasketMade",false)
		Set(this,"LeftScore","///")
		Set(this,"RightBasketMade",false)
		Set(this,"RightScore","///")
		if ScoreBoardFound == true then
			SetBoardText("Game off. Deep sleep mode enabled","scroll")
			Set(myScoreBoard,"ShowClock",this.ShowClock)
			SetBoardScore()
		end
		if this.DebugInfo=="ON" then print("GAME OFF - Going into deep sleep mode") end
		this.Tooltip={"tooltip_deepsleep",this.HomeUID,"X"}
		this.SetInterfaceCaption("toggleGame", "tooltip_button_game","tooltip_off","X")
		Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_off","X")
		timePerUpdate = 1440
	else
		this.SetInterfaceCaption("toggleGame", "tooltip_button_game","tooltip_on","X")
		if this.CourtLights=="ON" then toggleCourtLightsClicked() end
		Interface.RemoveComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_off","X")
		Set(this,"PLAYGAME","ON")
		if this.UsingSmallField==false then
			this.Tooltip={"tooltip_fullcourtwelcome",this.HomeUID,"X"}
		else
			this.Tooltip={"tooltip_halfcourtwelcome",this.HomeUID,"X"}
		end
		FindMyScoreBoard()
		SetBoardText("   Game on. schedule reform to start real-time game","scroll")
		Set(this,"LeftScore","///")
		Set(this,"RightScore","///")
		SetBoardScore()
		FindMyCourtLights()
		FindMyBaskets()
		timePerUpdate = 2
	end	
end

function toggleFloorTypeClicked()
	numFloor=numFloor+1
	if numFloor>18 then	numFloor=1	end
	Set(this,"numFloor",numFloor)
	this.SetInterfaceCaption("toggleFloorType", "tooltip_button_floortype",FloorDescription[this.numFloor],"X")
	MakeFloor(FloorTypes[numFloor])
end

function toggleLineTypeClicked()
	numLine=numLine+1
	if numLine>11 then	numLine=0	end
	Set(this,"numLine",numLine)
	Set(this,"SubType",numLine)
	this.SetInterfaceCaption("toggleLineType", "tooltip_button_linetype",this.numLine,"X")
end

function toggleCourtLightsClicked()  -- courtlights can only be toggled on/off manually when GAME OFF. The game will toggle lights on/off automatically when game starts/stops.
	if this.CourtLights=="ON" then
		Set(this,"CourtLights","OFF")	LightsOff()
		this.SetInterfaceCaption("toggleCourtLights", "tooltip_button_courtlights","tooltip_off","X")
	else
		Set(this,"CourtLights","ON")	LightsOn()
		this.SetInterfaceCaption("toggleCourtLights", "tooltip_button_courtlights","tooltip_on","X")
	end
end

function toggleDebugInfoClicked()
	if this.DebugInfo=="ON" then
		Set(this,"DebugInfo","OFF")	print("DebugInfo: OFF")
		this.SetInterfaceCaption("toggleDebugInfo", "tooltip_button_debuginfo","tooltip_off","X")
	else
		Set(this,"DebugInfo","ON")	print("DebugInfo: ON")
		this.SetInterfaceCaption("toggleDebugInfo", "tooltip_button_debuginfo","tooltip_on","X")
		print("The error below was made intentionally to open this window by itself:")
		local dummyBo0lean=false
		Game.DebugOut(""..dummyBo0lean.."")
	end
end

function toggleDeleteOrKillBallClicked()
	if this.BallKillOrDelete=="deleted" then
		Set(this,"BallKillOrDelete","killed")
		this.SetInterfaceCaption("toggleDeleteOrKillBall", "tooltip_button_balldelkill","tooltip_kill","X")
		print("Ball gets killed after a match")
		SetBoardText("  kill ball","stable")
	else
		Set(this,"BallKillOrDelete","deleted")
		this.SetInterfaceCaption("toggleDeleteOrKillBall", "tooltip_button_balldelkill","tooltip_del","X")
		print("Ball gets deleted after a match")
		SetBoardText(" delete ball","stable")
	end
end

function toggleDeleteClicked()
	if this.PLAYGAME=="OFF" then toggleGameClicked() end
	DismantleAll()
end

function ReorganizeButtons()
	Interface.RemoveComponent(this,"toggleScoreboardcolour")
	Interface.RemoveComponent(this,"toggleLCDtextcolour")
	Interface.RemoveComponent(this,"toggleLCDscorecolour")
	Interface.RemoveComponent(this,"toggleLCDclockcolour")
	Interface.RemoveComponent(this,"toggleShowClock")
	Interface.RemoveComponent(this,"toggleShowSeconds")
	Interface.RemoveComponent(this,"courtconfig")
	Interface.RemoveComponent(this,"toggleGame")
	Interface.RemoveComponent(this,"toggleDeleteOrKillBall")
	Interface.RemoveComponent(this,"toggleFloorType")
	Interface.RemoveComponent(this,"toggleLineType")
	Interface.RemoveComponent(this,"toggleCourtLights")
	Interface.RemoveComponent(this,"toggleDebugInfo")
	
	Interface.AddComponent(this,"toggleFindScoreboard", "Button", "tooltip_button_toggleFindScoreboard")
	
	Interface.AddComponent(this,"courtconfig","Caption","tooltip_courtconfig")
	
	if this.PLAYGAME=="ON" then
		Interface.AddComponent(this,"toggleGame", "Button", "tooltip_button_game","tooltip_on","X")
	else
		Interface.AddComponent(this,"toggleGame", "Button", "tooltip_button_game","tooltip_off","X")
	end
	if this.BallKillOrDelete=="deleted" then
		Interface.AddComponent(this,"toggleDeleteOrKillBall", "Button", "tooltip_button_balldelkill","tooltip_del","X")
	else
		Interface.AddComponent(this,"toggleDeleteOrKillBall", "Button", "tooltip_button_balldelkill","tooltip_kill","X")
	end
	Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_button_floortype",FloorDescription[this.numFloor],"X")
	Interface.AddComponent(this,"toggleLineType", "Button", "tooltip_button_linetype",this.numLine,"X")
	if this.PLAYGAME=="OFF" then
		if this.CourtLights=="ON" then
			Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_on","X")
		else
			Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_off","X")
		end
	end
	if this.DebugInfo=="ON" then
		Interface.AddComponent(this,"toggleDebugInfo", "Button", "tooltip_button_debuginfo","tooltip_on","X")
	else
		Interface.AddComponent(this,"toggleDebugInfo", "Button", "tooltip_button_debuginfo","tooltip_off","X")
	end
end

function AddScoreboardButtons()
	Interface.AddComponent(this,"scoreboardconfig","Caption","tooltip_scoreboardconfig")
	Interface.AddComponent(this,"toggleScoreboardcolour", "Button", "tooltip_button_toggleScoreboardcolour","tooltip_button_boardcolour"..myScoreBoard.SubType,"X")
	Interface.AddComponent(this,"toggleLCDtextcolour", "Button", "tooltip_button_toggleLCDtextcolour","tooltip_button_textcolour"..myScoreBoard.LCDtextcolour,"X")
	Interface.AddComponent(this,"toggleLCDscorecolour", "Button", "tooltip_button_toggleLCDscorecolour","tooltip_button_scorecolour"..myScoreBoard.LCDscorecolour,"X")
	Interface.AddComponent(this,"toggleLCDclockcolour", "Button", "tooltip_button_toggleLCDclockcolour","tooltip_button_clockcolour"..myScoreBoard.LCDclockcolour,"X")
	Interface.AddComponent(this,"toggleShowClock", "Button", "tooltip_button_toggleLCDShowClock")
	Interface.AddComponent(this,"toggleShowSeconds", "Button", "tooltip_button_toggleLCDShowSeconds","tooltip_button_showseconds"..myScoreBoard.ShowSeconds,"X")
end

function AddCourtButton()
	if this.PLAYGAME=="ON" then
		Interface.AddComponent(this,"toggleGame", "Button", "tooltip_button_game","tooltip_on","X")
		if this.UsingSmallField==false then
			this.Tooltip={"tooltip_fullcourtwelcome",this.HomeUID,"X"}
		else
			this.Tooltip={"tooltip_halfcourtwelcome",this.HomeUID,"X"}
		end
	else
		this.Tooltip={"tooltip_deepsleep",this.HomeUID,"X"}
		Interface.AddComponent(this,"toggleGame", "Button", "tooltip_button_game","tooltip_off","X")
	end

	if this.BallKillOrDelete=="deleted" then
		Interface.AddComponent(this,"toggleDeleteOrKillBall", "Button", "tooltip_button_balldelkill","tooltip_del","X")
	else
		Interface.AddComponent(this,"toggleDeleteOrKillBall", "Button", "tooltip_button_balldelkill","tooltip_kill","X")
	end
	
	if this.numFloor~=nil then
		numFloor=this.numFloor
		Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_button_floortype",FloorDescription[this.numFloor],"X")
	else
		Set(this,"numFloor",1)
		Interface.AddComponent(this,"toggleFloorType", "Button", "tooltip_button_floortype",FloorDescription[this.numFloor],"X")
	end

	if this.numLine~=nil then
		numLine=this.numLine
		Interface.AddComponent(this,"toggleLineType", "Button", "tooltip_button_linetype",this.numLine,"X")
	else
		Set(this,"numLine",0)
		Interface.AddComponent(this,"toggleLineType", "Button", "tooltip_button_linetype",this.numLine,"X")
	end

	if this.PLAYGAME=="OFF" then
		if this.CourtLights=="ON" then
			Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_on","X")
		else
			Interface.AddComponent(this,"toggleCourtLights", "Button", "tooltip_button_courtlights","tooltip_off","X")
		end
	end
	
	if this.DebugInfo=="ON" then
		Interface.AddComponent(this,"toggleDebugInfo", "Button", "tooltip_button_debuginfo","tooltip_on","X")
	else
		Interface.AddComponent(this,"toggleDebugInfo", "Button", "tooltip_button_debuginfo","tooltip_off","X")
	end
end

function CalculateTimeWarpFactor(timePassed)
	if timeInit > initTimer then
	
		if timePerUpdate == nil then
			Now = math.floor(math.mod(World.TimeIndex,60))
			if not StartCountdown then
				if Now ~= StartingMinute then
				--	this.SubType = 3
					StartingMinute = Now
					if Now < 59 then
						EndingMinute = Now + 1				-- calculate TimeWarp within the next minute
						StartCountdown = true
					else
						return				-- wait another minute if object is placed 1 minute before next whole hour
					end
				end
			else
				timeTot=timeTot+timePassed
				this.Tooltip = {"tooltip_Init_TimeWarpB",StartingMinute,"A",EndingMinute,"B",Now,"C",timeTot,"D" }
				
				if Now >= StartingMinute+1 then
					if timeTot >= 5.4 then			-- the result should be around 8 (1/8) for large map with slow time enabled, compare with 5.4 to compensate for lag
						myTimeWarpFactor = 0.125
					--	this.SubType = 4
						myMapSize = "LARGE"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 4.1 then		-- the result should be around 5.33 (3/16) for medium map with slow time enabled
						myTimeWarpFactor = 0.1875
					--	this.SubType = 5
						myMapSize = "MEDIUM"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 2.1 then		-- the result should be around 4 (1/4) for small map with slow time enabled
						myTimeWarpFactor = 0.25
					--	this.SubType = 6
						myMapSize = "SMALL"
						mySlowTime = "YES"
						timeWarpFound = true
					elseif timeTot >= 1.4 then		-- the result should be around 2 (1/2) for large map
						myTimeWarpFactor = 0.5
					--	this.SubType = 7
						myMapSize = "LARGE"
						mySlowTime = "NO"
						timeWarpFound = true
					elseif timeTot >= 1.1 then		-- the result should be around 1.33 (3/4) for medium map
						myTimeWarpFactor = 0.75
					--	this.SubType = 8
						myMapSize = "MEDIUM"
						mySlowTime = "NO"
						timeWarpFound = true
					else							-- the result should be around 1 (1) for small map
						myTimeWarpFactor = 1
					--	this.SubType = 9
						myMapSize = "SMALL"
						mySlowTime = "NO"
						timeWarpFound = true
					end
					
					-- Instead of using the hard coded TimeWarp values (found in de saved game and mentioned above),
					-- you could also calculate your own by dividing 1 minute by the time it took to get to that minute.
					-- The result will be approximately the hard coded TimeWarp value, but can be different for each object you place,
					-- depending on how busy the game is, this is should not be used by default:
					
					--timeWarpFound = false					-- enable to see this calculation result in action
					--if timeWarpFound == false then myTimeWarpFactor = 1 / timeTot end
					
					this.Tooltip = {"tooltip_Init_TimeWarpC",StartingMinute,"A",EndingMinute,"B",Now,"C",timeTot,"D",myMapSize,"E",myTimeWarpFactor,"F",mySlowTime,"G" }	-- show results
					
					-- set the timePerUpdate here so we get out of this function
					timePerUpdate = 1 / myTimeWarpFactor	-- will show the results for 1 game minutes
				end
			end
		else		-- calculation completed, so save the results
			timeTot = timeTot+timePassed
			if timeTot > timePerUpdate then
			--	this.SubType = 0						-- change sprite back to normal
				Set(this,"TimeWarp",myTimeWarpFactor)	-- this tells function Update() to proceed
				this.Tooltip = "tooltip_ReadyForAction"
				timePerUpdate = nil				-- reset to nil so function Update() can proceed with normal activity
			end
		end
	else
		timeInit = timeInit+timePassed
		StartingMinute = math.floor(math.mod(World.TimeIndex,60))
	end
end
