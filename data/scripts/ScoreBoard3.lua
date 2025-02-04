
local Set = Object.SetProperty
local Get = Object.GetProperty
local Find = this.GetNearbyObjects

local LetterToSub = { a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8, i = 9, j = 10, k = 11, l = 12, m = 13, n = 14, o = 15, p = 16, q = 17, r = 18, s = 19, t = 20, u = 21, v = 22, w = 23, x = 24, y = 25, z = 26 }

local NumberToSub = { [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [0] = 10 }

local timeTot = 0
local timeToText = 0
local timeToNumber = 0

local maxRepeat = 0

local myLCD1 = ""
local myLCD2 = ""
local myLCD3 = ""
local myLCD4 = ""
local myLCD5 = ""
local myLCD6 = ""
local myLCD7 = ""
local myLCD8 = ""
local myLCD9 = ""
local myLCD10 = ""
local myLCD11 = ""
local myLCD12 = ""
local myLCD13 = ""
local myLCD14 = ""
local myLCD15 = ""
local myLCD16 = ""
local myLCD17 = ""
local myLCD18 = ""
local myLCD19 = ""
local myLCD20 = ""
local myLCD21 = ""
local myLCD22 = ""
local myLCD23 = ""
local myLCD24 = ""

function Create()
	Set(this,"HomeUID",0)
	Set(this,"LCDtextcolour",0)
	Set(this,"LCDtext","welcome to real-time basketball")
	Set(this,"TextType","scroll")
	Set(this,"TempText","/////////////")
	Set(this,"LCDcurChar",1)
	Set(this,"LCDnumberLeft","///")
	Set(this,"LCDnumberRight","///")
	Set(this,"TempLeft","---")
	Set(this,"TempRight","---")
	Set(this,"LCDscorecolour",26)
	Set(this,"LCDpreOffset","/////////////")
	Set(this,"repeatTimer",0)
	Set(this,"repeatNumberTimer",0)
	Set(this,"LCDclockcolour",43)
	Set(this,"LCDcoloncolour",1)
	Set(this,"ShowClock",true)
	Set(this,"ShowCountdown",false)
	Set(this,"ShowSeconds",0)
	Set(this,"HourCount",0)
	Set(this,"timePerTextUpdate",0.25)
	Set(this,"timePerNumberUpdate",0.25)
end

function Update(timePassed)
	if timePerUpdate == nil then
		if not this.LCDspawned then
			SpawnLCD()
			this.LCDspawned = true
		end
		
		myLCD1 = Load(myLCD1,"LCDletter","LCD1UID",5);		myLCD2 = Load(myLCD2,"LCDletter","LCD2UID",5);		myLCD3 = Load(myLCD3,"LCDletter","LCD3UID",5)
		myLCD4 = Load(myLCD4,"LCDletter","LCD4UID",5);		myLCD5 = Load(myLCD5,"LCDletter","LCD5UID",5);		myLCD6 = Load(myLCD6,"LCDletter","LCD6UID",5)
		myLCD7 = Load(myLCD7,"LCDletter","LCD7UID",5);		myLCD8 = Load(myLCD8,"LCDletter","LCD8UID",5);		myLCD9 = Load(myLCD9,"LCDletter","LCD9UID",5)
		myLCD10 = Load(myLCD10,"LCDletter","LCD10UID",5);	myLCD11 = Load(myLCD11,"LCDletter","LCD11UID",5);	myLCD12 = Load(myLCD12,"LCDletter","LCD12UID",5)
		myLCD13 = Load(myLCD13,"LCDletter","LCD13UID",5);	myLCD14 = Load(myLCD14,"LCDnumber","LCD14UID",5);	myLCD15 = Load(myLCD15,"LCDnumber","LCD15UID",5)
		myLCD16 = Load(myLCD16,"LCDnumber","LCD16UID",5);	myLCD17 = Load(myLCD17,"LCDletter","LCD17UID",5);	myLCD18 = Load(myLCD18,"LCDletter","LCD18UID",5)
		myLCD19 = Load(myLCD19,"LCDcolon","LCD19UID",5);	myLCD20 = Load(myLCD20,"LCDletter","LCD20UID",5);	myLCD21 = Load(myLCD21,"LCDletter","LCD21UID",5)
		myLCD22 = Load(myLCD22,"LCDnumber","LCD22UID",5);	myLCD23 = Load(myLCD23,"LCDnumber","LCD23UID",5);	myLCD24 = Load(myLCD24,"LCDnumber","LCD24UID",5)

		timePerUpdate = 0.25
	end
	
	timeToText = timeToText + timePassed
	if timeToText >= this.timePerTextUpdate then
		timeToText = 0
		if not this.TextSet then
			SetNewText()
		end
	end
	
	timeToNumber = timeToNumber + timePassed
	if timeToNumber >= this.timePerNumberUpdate then
		timeToNumber = 0
		if not this.NumberSet then
			BlinkNumber()
		end
	end
	
	ShowClock()
end

function SpawnLCD()
	-- top lcd bar
	myLCD1  =  Object.Spawn("LCDletter", this.Pos.x-1.80, this.Pos.y-0.25);	Set(this,"LCD1UID",myLCD1.Id.u)
	myLCD2  =  Object.Spawn("LCDletter", this.Pos.x-1.50, this.Pos.y-0.25);	Set(this,"LCD2UID",myLCD2.Id.u)
	myLCD3  =  Object.Spawn("LCDletter", this.Pos.x-1.20, this.Pos.y-0.25);	Set(this,"LCD3UID",myLCD3.Id.u)
	myLCD4  =  Object.Spawn("LCDletter", this.Pos.x-0.90, this.Pos.y-0.25);	Set(this,"LCD4UID",myLCD4.Id.u)
	myLCD5  =  Object.Spawn("LCDletter", this.Pos.x-0.60, this.Pos.y-0.25);	Set(this,"LCD5UID",myLCD5.Id.u)
	myLCD6  =  Object.Spawn("LCDletter", this.Pos.x-0.30, this.Pos.y-0.25);	Set(this,"LCD6UID",myLCD6.Id.u)
	myLCD7  =  Object.Spawn("LCDletter", this.Pos.x-0.00, this.Pos.y-0.25);	Set(this,"LCD7UID",myLCD7.Id.u)
	myLCD8  =  Object.Spawn("LCDletter", this.Pos.x+0.30, this.Pos.y-0.25);	Set(this,"LCD8UID",myLCD8.Id.u)
	myLCD9  =  Object.Spawn("LCDletter", this.Pos.x+0.60, this.Pos.y-0.25);	Set(this,"LCD9UID",myLCD9.Id.u)
	myLCD10 =  Object.Spawn("LCDletter", this.Pos.x+0.90, this.Pos.y-0.25);	Set(this,"LCD10UID",myLCD10.Id.u)
	myLCD11 =  Object.Spawn("LCDletter", this.Pos.x+1.20, this.Pos.y-0.25);	Set(this,"LCD11UID",myLCD11.Id.u)
	myLCD12 =  Object.Spawn("LCDletter", this.Pos.x+1.50, this.Pos.y-0.25);	Set(this,"LCD12UID",myLCD12.Id.u)
	myLCD13 =  Object.Spawn("LCDletter", this.Pos.x+1.80, this.Pos.y-0.25);	Set(this,"LCD13UID",myLCD13.Id.u)
	-- score left
	myLCD14 =  Object.Spawn("LCDnumber", this.Pos.x-1.80, this.Pos.y+0.25);	Set(this,"LCD14UID",myLCD14.Id.u)
	myLCD15 =  Object.Spawn("LCDnumber", this.Pos.x-1.50, this.Pos.y+0.25);	Set(this,"LCD15UID",myLCD15.Id.u)
	myLCD16 =  Object.Spawn("LCDnumber", this.Pos.x-1.20, this.Pos.y+0.25);	Set(this,"LCD16UID",myLCD16.Id.u)
	-- clock
	myLCD17  =  Object.Spawn("LCDletter", this.Pos.x-0.50, this.Pos.y+0.25);	Set(this,"LCD17UID",myLCD17.Id.u)
	myLCD18  =  Object.Spawn("LCDletter", this.Pos.x-0.20, this.Pos.y+0.25);	Set(this,"LCD18UID",myLCD18.Id.u)
	myLCD19  =  Object.Spawn("LCDcolon",  this.Pos.x-0.00, this.Pos.y+0.25);	Set(this,"LCD19UID",myLCD19.Id.u)
	myLCD20  =  Object.Spawn("LCDletter", this.Pos.x+0.20, this.Pos.y+0.25);	Set(this,"LCD20UID",myLCD20.Id.u)
	myLCD21  =  Object.Spawn("LCDletter", this.Pos.x+0.50, this.Pos.y+0.25);	Set(this,"LCD21UID",myLCD21.Id.u)
	--score right
	myLCD22 =  Object.Spawn("LCDnumber", this.Pos.x+1.20, this.Pos.y+0.25);	Set(this,"LCD22UID",myLCD22.Id.u)
	myLCD23 =  Object.Spawn("LCDnumber", this.Pos.x+1.50, this.Pos.y+0.25);	Set(this,"LCD23UID",myLCD23.Id.u)
	myLCD24 =  Object.Spawn("LCDnumber", this.Pos.x+1.80, this.Pos.y+0.25);	Set(this,"LCD24UID",myLCD24.Id.u)
end

function SetNewText()
	if this.TextType == "scroll" then		 this.timePerTextUpdate = 0.25;	ScrollText()
	elseif this.TextType == "blink" then	 this.timePerTextUpdate = 0.65;	BlinkText()
	elseif this.TextType == "stable" then	 this.timePerTextUpdate = 1;		StableText()
	end
end

function ScrollText()
	if not this.FadeIn then
		if string.len(this.LCDpreOffset) > 1 then
			this.LCDpreOffset = string.sub(this.LCDpreOffset,1,string.len(this.LCDpreOffset)-1)
			if string.len(this.LCDpreOffset) == 1 then
				this.CurrentText = "/"..this.LCDtext
			else
				this.CurrentText = this.LCDpreOffset..this.LCDtext
			end
			SetText()
		else
			this.LCDcurChar = 1
			this.CurrentText = this.LCDtext
			SetText()
			this.FadeIn = true
		end
	else
		if this.LCDcurChar < string.len(this.LCDtext) then
			this.LCDcurChar = this.LCDcurChar + 1
			this.CurrentText = string.sub(this.LCDtext,this.LCDcurChar)
			SetText()
		else
			this.CurrentText = "/////////////"
			SetText()
			Set(this,"LCDpreOffset","/////////////")
			this.FadeIn = nil
			this.repeatTimer = this.repeatTimer + 1
			if this.repeatTimer >= maxRepeat then
				this.repeatTimer = 0
				this.TextSet = true
				this.timePerTextUpdate = 0.25
			end
		end
	end
end

function BlinkText()
	if this.repeatTimer == 0 then
		this.CurrentText = this.LCDtext
		this.repeatTimer = this.repeatTimer + 1
	elseif this.repeatTimer == 1 then
		this.CurrentText = "/////////////"
		this.repeatTimer = this.repeatTimer + 1
	elseif this.repeatTimer == 2 then
		this.CurrentText = this.LCDtext
		this.repeatTimer = this.repeatTimer + 1
	else
		this.CurrentText = "/////////////"
		this.repeatTimer = 0
		this.TextSet = true
		this.timePerTextUpdate = 0.25
	end
	SetText()
end

function StableText()
	if this.LCDtext == "delete" then DeleteScoreBoard() end
	if this.repeatTimer == 0 then
		this.CurrentText = this.LCDtext
		this.repeatTimer = this.repeatTimer + 1
	else
		this.CurrentText = "/////////////"
		this.repeatTimer = 0
		this.TextSet = true
		this.timePerTextUpdate = 0.25
	end
	SetText()
end

function GetCurrentTime()
	local myTime = World.TimeIndex
	local hours = math.floor(math.mod(myTime,1440) /60)
	local minutes = math.mod(myTime,60)
	if minutes == nil then minutes = 0 end
	local secondsColon = 0
	secondsColon = 60 - math.mod(tonumber(string.sub(minutes,2)) * 60,60)
	-- print(secondsColon)
	if secondsColon <= 30 then
		secondsColon = ":"
	else
		secondsColon = "-"
	end
	if (hours < 10) then
		hours = "0" .. tostring(hours)
		end
	if (minutes < 10) then
		minutes = "0" .. tostring(minutes)
	end
	answer = tostring(hours)..tostring(secondsColon)..tostring(minutes)
	return answer
end

function ShowClock()
	if this.ShowClock == true then
		this.LCDclock = GetCurrentTime()
		local myLCDtext = { [1] = myLCD17, [2] = myLCD18, [3] = myLCD19, [4] = myLCD20, [5] = myLCD21 }
		
		for i = 1,5 do
			if string.lower(string.sub(this.LCDclock,i,i)) == ":" then
				myLCDtext[i].SubType = this.LCDcoloncolour + 4
			elseif string.lower(string.sub(this.LCDclock,i,i)) == "-" then
				myLCDtext[i].SubType = this.LCDcoloncolour
			elseif tonumber(string.lower(string.sub(this.LCDclock,i,i))) ~= nil then
				if tonumber(string.lower(string.sub(this.LCDclock,i,i))) == 0 then
					myLCDtext[i].SubType = this.LCDclockcolour + 30 + 10
				else
					myLCDtext[i].SubType = this.LCDclockcolour + 30 + tonumber(string.lower(string.sub(this.LCDclock,i,i)))
				end
			else
				myLCDtext[i].SubType = this.LCDclockcolour + (LetterToSub[string.lower(string.sub(this.LCDclock,i,i))] or 0)
			end
		end
	elseif this.LCDclock ~= "/////" then
		this.LCDclock = "/////"
		local myLCDtext = { [1] = myLCD17, [2] = myLCD18, [3] = myLCD19, [4] = myLCD20, [5] = myLCD21 }
		
		for i = 1,5 do
			myLCDtext[i].SubType = this.LCDclockcolour
			myLCDtext[3].SubType = this.LCDcoloncolour
		end
	else
		if this.ShowCountdown == true then
			ShowCountdown()
		elseif this.LCDcountdown ~= "/////" then
			this.LCDcountdown = "/////"
			local myLCDtext = { [1] = myLCD17, [2] = myLCD18, [3] = myLCD19, [4] = myLCD20, [5] = myLCD21 }
			
			for i = 1,5 do
				myLCDtext[i].SubType = this.LCDclockcolour
				myLCDtext[3].SubType = this.LCDcoloncolour
			end
			this.ShowCountdown = false
			this.HourCount = 0
		end
	end
end

function GetCountdown()
	local myTime = World.TimeIndex
	local minutes = math.mod(myTime,60)
	if minutes == nil then minutes = 0 end
	local seconds = 0
	local secondsColon = ":"
	seconds = 60 - math.mod(tonumber(string.sub(minutes,2)) * 60,60)
	if seconds <= 30 then
		secondsColon = ":"
	else
		secondsColon = "-"
	end
	if this.ShowSeconds == 1 then
		if seconds < 10 then
			seconds = "0" .. tostring(seconds)
		end
	end
	minutes = math.floor(minutes)
	if this.HourCount == 0 then	-- count down to the end of 1st reform hour
		--if minutes <= 30 then
			minutes = 30 - minutes
		--elseif minutes <= 60 then
		--	minutes = 60 - minutes
		--end
	else									-- count down to the end of 2nd and/or 3rd reform hour
		if minutes <= 30 then
			minutes = 30 - minutes
		elseif minutes <= 60 then			-- example: first hour ends at 9:30, so 90-30 = 60 minutes countdown to 10:30
			minutes = 90 - minutes
		end
	end
	if minutes == 0 and not this.CountdownFinished then
		this.CountdownFinished = true
	end
	if (minutes < 10) then
		minutes = "0" .. tostring(minutes)
	end
	
	if this.ShowSeconds == 1 then
		answer = tostring(minutes)..tostring(secondsColon)..tostring(seconds)
	else
		answer = "00"..tostring(secondsColon)..tostring(minutes)
	end
	return answer
end

function ShowCountdown()
	if not this.CountdownFinished then
		this.LCDcountdown = GetCountdown()
		local myLCDtext = { [1] = myLCD17, [2] = myLCD18, [3] = myLCD19, [4] = myLCD20, [5] = myLCD21 }
		for i = 1,5 do
			if string.lower(string.sub(this.LCDcountdown,i,i)) == ":" then
				myLCDtext[i].SubType = this.LCDcoloncolour + 4
			elseif string.lower(string.sub(this.LCDcountdown,i,i)) == "-" then
				myLCDtext[i].SubType = this.LCDcoloncolour
			elseif tonumber(string.lower(string.sub(this.LCDcountdown,i,i))) ~= nil then
				if tonumber(string.lower(string.sub(this.LCDcountdown,i,i))) == 0 then
					myLCDtext[i].SubType = this.LCDclockcolour + 30 + 10
				else
					myLCDtext[i].SubType = this.LCDclockcolour + 30 + tonumber(string.lower(string.sub(this.LCDcountdown,i,i)))
				end
			else
				myLCDtext[i].SubType = this.LCDclockcolour + (LetterToSub[string.lower(string.sub(this.LCDcountdown,i,i))] or 0)
			end
		end
	end
end

function SetText()
	local myLCDtext = { [1] = myLCD1, [2] = myLCD2, [3] = myLCD3, [4] = myLCD4, [5] = myLCD5, [6] = myLCD6, [7] = myLCD7, [8] = myLCD8, [9] = myLCD9, [10] = myLCD10, [11] = myLCD11, [12] = myLCD12, [13] = myLCD13 }

	for i = 1,13 do
		if string.lower(string.sub(this.CurrentText,i,i)) == "-" then
			myLCDtext[i].SubType = this.LCDtextcolour + 27
		elseif string.lower(string.sub(this.CurrentText,i,i)) == "." then
			myLCDtext[i].SubType = this.LCDtextcolour + 28
		elseif string.lower(string.sub(this.CurrentText,i,i)) == "_" then
			myLCDtext[i].SubType = this.LCDtextcolour + 29
		elseif string.lower(string.sub(this.CurrentText,i,i)) == ":" then
			myLCDtext[i].SubType = this.LCDtextcolour + 30
		elseif tonumber(string.lower(string.sub(this.CurrentText,i,i))) ~= nil then
			if tonumber(string.lower(string.sub(this.CurrentText,i,i))) == 0 then
				myLCDtext[i].SubType = this.LCDtextcolour + 30 + 10
			else
				myLCDtext[i].SubType = this.LCDtextcolour + 30 + tonumber(string.lower(string.sub(this.CurrentText,i,i)))
			end
		else
			myLCDtext[i].SubType = this.LCDtextcolour + (LetterToSub[string.lower(string.sub(this.CurrentText,i,i))] or 0)
		end
	end
end

function BlinkNumber()
	if this.repeatNumberTimer == 0 then
		this.timePerNumberUpdate = 0.65
		if this.TempLeft ~= this.LCDnumberLeft then
			this.TempLeft = this.LCDnumberLeft
			this.LCDnumberLeft = "///"
			changeLeft = true
		end
		if this.TempRight ~= this.LCDnumberRight then
			this.TempRight = this.LCDnumberRight
			this.LCDnumberRight = "///"
			changeRight = true
		end
		this.repeatNumberTimer = this.repeatNumberTimer + 1
	elseif this.repeatNumberTimer == 1 then
		this.timePerNumberUpdate = 0.65
		if changeLeft == true then
			this.LCDnumberLeft = this.TempLeft
			this.TempLeft = "///"
		end
		if changeRight == true then
			this.LCDnumberRight = this.TempRight
			this.TempRight = "///"
		end
		this.repeatNumberTimer = this.repeatNumberTimer + 1
	elseif this.repeatNumberTimer == 2 then
		this.timePerNumberUpdate = 0.65
		if changeLeft == true then
			this.TempLeft = this.LCDnumberLeft
			this.LCDnumberLeft = "///"
		end
		if changeRight == true then
			this.TempRight = this.LCDnumberRight
			this.LCDnumberRight = "///"
		end
		this.repeatNumberTimer = this.repeatNumberTimer + 1
	else
		this.timePerNumberUpdate = 0.25
		if changeLeft == true then
			this.LCDnumberLeft = this.TempLeft
		end
		if changeRight == true then
			this.LCDnumberRight = this.TempRight
		end
		this.repeatNumberTimer = 0
		this.NumberSet = true
		changeLeft = nil
		changeRight = nil
	end
	SetNewNumber()
end

function SetNewNumber()
	local myLCDnumber = { [1] = myLCD14, [2] = myLCD15, [3] = myLCD16, [4] = myLCD22, [5] = myLCD23,[6] = myLCD24 }
	
	if this.LCDnumberLeft == "---" then
		myLCDnumber[1].SubType = this.LCDscorecolour
		myLCDnumber[2].SubType = this.LCDscorecolour
		myLCDnumber[3].SubType = this.LCDscorecolour
	elseif this.LCDnumberLeft == "///" then
		myLCDnumber[1].SubType = this.LCDscorecolour + 11
		myLCDnumber[2].SubType = this.LCDscorecolour + 11
		myLCDnumber[3].SubType = this.LCDscorecolour + 11
	else
		if tonumber(this.LCDnumberLeft) > 999 then this.LCDnumberLeft = 0 end
		if tonumber(this.LCDnumberLeft) < 10 then
			myLCDnumber[1].SubType = this.LCDscorecolour + 10
			myLCDnumber[2].SubType = this.LCDscorecolour + 10
			myLCDnumber[3].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberLeft,1,1))] or 10)
		elseif tonumber(this.LCDnumberLeft) < 100 then
			myLCDnumber[1].SubType = this.LCDscorecolour + 10
			myLCDnumber[2].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberLeft,1,1))] or 10)
			myLCDnumber[3].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberLeft,2,2))] or 10)
		else
			myLCDnumber[1].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberLeft,1,1))] or 10)
			myLCDnumber[2].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberLeft,2,2))] or 10)
			myLCDnumber[3].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberLeft,3,3))] or 10)
		end
	end
	
	if this.LCDnumberRight == "---" then
		myLCDnumber[4].SubType = this.LCDscorecolour
		myLCDnumber[5].SubType = this.LCDscorecolour
		myLCDnumber[6].SubType = this.LCDscorecolour
	elseif this.LCDnumberRight == "///" then
		myLCDnumber[4].SubType = this.LCDscorecolour + 11
		myLCDnumber[5].SubType = this.LCDscorecolour + 11
		myLCDnumber[6].SubType = this.LCDscorecolour + 11
	else
		if tonumber(this.LCDnumberRight) > 999 then this.LCDnumberRight = 0 end
		if tonumber(this.LCDnumberRight) < 10 then
			myLCDnumber[4].SubType = this.LCDscorecolour + 10
			myLCDnumber[5].SubType = this.LCDscorecolour + 10
			myLCDnumber[6].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberRight,1,1))] or 10)
		elseif tonumber(this.LCDnumberRight) < 100 then
			myLCDnumber[4].SubType = this.LCDscorecolour + 10
			myLCDnumber[5].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberRight,1,1))] or 10)
			myLCDnumber[6].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberRight,2,2))] or 10)
		else
			myLCDnumber[4].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberRight,1,1))] or 10)
			myLCDnumber[5].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberRight,2,2))] or 10)
			myLCDnumber[6].SubType = this.LCDscorecolour + (NumberToSub[tonumber(string.sub(this.LCDnumberRight,3,3))] or 10)
		end
	end
end

function DeleteScoreBoard()
	myLCD1.Delete()
	myLCD2.Delete()
	myLCD3.Delete()
	myLCD4.Delete()
	myLCD5.Delete()
	myLCD6.Delete()
	myLCD7.Delete()
	myLCD8.Delete()
	myLCD9.Delete()
	myLCD10.Delete()
	myLCD11.Delete()
	myLCD12.Delete()
	myLCD13.Delete()
	myLCD14.Delete()
	myLCD15.Delete()
	myLCD16.Delete()
	myLCD17.Delete()
	myLCD18.Delete()
	myLCD19.Delete()
	myLCD20.Delete()
	myLCD21.Delete()
	myLCD22.Delete()
	myLCD23.Delete()
	myLCD24.Delete()
	this.Delete()
	return
end


--Return Object if in range.
function GetObject(type,id,dist)
	objs = Object.GetNearbyObjects(type,dist or 1)
	for o,d in pairs(objs) do
		 if o.Id.u == id then
		 	return o
		 end
	end
end
--Find Object after Load.
function Load(Object, Type, ID, dist)
    if Object == "" then
        print(tostring("Trying to load "..Type.." with ID: "..ID));
        TempID = Get(tostring(ID));
        Object = GetObject(Type,TempID,dist);
        print("Found: "..Type.." Table: "..tostring(Object).." ID: "..TempID);
    end
	if Object == nil then Set(ID,"None") end
    return Object
end