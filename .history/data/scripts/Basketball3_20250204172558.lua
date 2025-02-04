
local Get = Object.GetProperty
local Set = Object.SetProperty
local Find = this.GetNearbyObjects

local timeTot=0
local up=false
local timePerUpdate = 0.025
local dribbleSteps = 0
local dribbleDone = false

-- https://developer.roblox.com/articles/Bezier-curves
-- https://javascript.info/bezier-curve

function cubicBezier(t, p0, p1, p2, p3)
	if (this.Pos.x >= this.Xmin and this.Pos.x <= this.Xmax) and (this.Pos.y >= this.Ymin and this.Pos.y <= this.Ymax) then

		return (1 - t)^3*p0 + 3*(1 - t)^2*t*p1 + 3*(1 - t)*t^2*p2 + t^3*p3

	else	-- it's way outside the court lines (more than 4 tiles)

		if this.BallKillOrDelete=="deleted" then
			this.Delete()
		else
			this.Damage=1
		end

	end
end

function Create()
	Set(this,"Dribble",0)
	Set(this,"Step",0)
end

function Update( timePassed )
	timeTot = timeTot + timePassed
	if timeTot>=timePerUpdate then
		timeTot=0
		if this.Dribble < 6 then
			if myDribbleAt == nil then
				local dribbleAt = Find(this.DribbleAt, 16)
				if next(dribbleAt) then
					for thatPlayer,dist in pairs( dribbleAt ) do
						if thatPlayer.Id.i==this.DribblePlayerI and thatPlayer.Id.u==this.DribblePlayerU then
							myDribbleAt = thatPlayer
							if this.DribbleAt =="Basket3" then
								yOffset = 0.65
								dribbleSide = 0
							else
								yOffset = 0.25
								if myDribbleAt.Or.x < 0 then dribbleSide = -0.5 else dribbleSide = 0.5 end
							end
							this.ClearRouting()
							break
						end
					end
				end
			end
			if up==true then
				if dribbleSteps < 3 then
					dribbleSteps = dribbleSteps+1
					this.Pos.x = myDribbleAt.Pos.x+dribbleSide
					this.Pos.y = (myDribbleAt.Pos.y+yOffset)-(dribbleSteps / 50)
				else
					this.Dribble=this.Dribble+1
					dribbleSteps = 0
					up=false
					dribbleDone = true
				end
			else
				if dribbleSteps < 3 then
					dribbleSteps = dribbleSteps+1
					this.Pos.x = myDribbleAt.Pos.x+dribbleSide
					this.Pos.y = (myDribbleAt.Pos.y+yOffset)+(dribbleSteps / 50)
				else
					this.Dribble=this.Dribble+1
					dribbleSteps = 0
					up=true
					dribbleDone = true
				end
			end
			timePerUpdate = 0
		else
			dribbleSteps = 0
			if tonumber(this.Carried) == -1 and not this.Success then

				if this.LinkMeTo ~= "None" and myNextPlayer == nil then
					local nextPlayer = this.GetNearbyObjects(this.LinkMeTo, 16)
					if next(nextPlayer) then
						for thatPlayer,dist in pairs( nextPlayer ) do
							if thatPlayer.Id.i==this.NewPlayerI and thatPlayer.Id.u==this.NewPlayerU then
								myNextPlayer = thatPlayer
								if myDribbleAt ~= nil then
									this.Pos.x = myDribbleAt.Pos.x
									this.StartX = myDribbleAt.Pos.x
									this.Pos.y = myDribbleAt.Pos.y
									this.StartY = myDribbleAt.Pos.y
									dribbleDone = false
									myDribbleAt = nil
								end
								break
							end
						end
					end
					if (myNextPlayer ~= nil and myNextPlayer.SubType ~= nil) and (this.LinkMeTo == "BasketballTrainerFullCourt" or this.LinkMeTo == "BasketballTrainerHalfCourt" or this.LinkMeTo == "BasketballTrainerYard") and this.Dribble < 7 then
						Set(myNextPlayer,"Carrying.i",this.Id.i)
						Set(myNextPlayer,"Carrying.u",this.Id.u)
						this.CarrierId.i = myNextPlayer.Id.i
						this.CarrierId.u = myNextPlayer.Id.u
						this.Carried=3
						this.NewPosX=nil
						this.NewPosY=nil
						this.LinkMeTo = "None"
						myNextPlayer = nil
					end
					timeTot=timePerUpdate
				else
					timePerUpdate = 0
					if this.LinkMeTo == "Basket3" then
						if (this.Pos.x >= myNextPlayer.Pos.x - 0.15 and this.Pos.x <= myNextPlayer.Pos.x + 0.15 and this.Pos.y >= myNextPlayer.Pos.y - 0.15 and this.Pos.y <= myNextPlayer.Pos.y + 0.15) or this.Step >= 0.99 then
							aboveBasket = true
							this.Step = 0
							this.Pos.x = myNextPlayer.Pos.x
							this.Pos.y = myNextPlayer.Pos.y
							this.NavigateTo(myNextPlayer.Pos.x,myNextPlayer.Pos.y+0.5) -- bounce away
							timePerUpdate = 0.25
						elseif aboveBasket == true and dribbleDone == false then
							this.Dribble = 3
							this.DribbleAt = "Basket3"
							this.DribblePlayerI = myNextPlayer.Id.i
							this.DribblePlayerU = myNextPlayer.Id.u
							timePerUpdate = 0.025
						elseif aboveBasket == true and dribbleDone == true then
							myNextPlayer = nil
							this.NewPosX = nil
							this.NewPosY = nil
							this.LinkMeTo = "None"
							aboveBasket = nil
							this.Success=true
							up = false
						else
							this.Step = this.Step+0.033
							if myNextPlayer.Pos.x > this.Pos.x then
								this.Pos.x = cubicBezier(this.Step,this.StartX,myNextPlayer.Pos.x-2,myNextPlayer.Pos.x-0.5,myNextPlayer.Pos.x)
								this.Pos.y = cubicBezier(this.Step,this.StartY,myNextPlayer.Pos.y-2,myNextPlayer.Pos.y-2,myNextPlayer.Pos.y)
							else
								this.Pos.x = cubicBezier(this.Step,this.StartX,myNextPlayer.Pos.x+2,myNextPlayer.Pos.x+0.5,myNextPlayer.Pos.x)
								this.Pos.y = cubicBezier(this.Step,this.StartY,myNextPlayer.Pos.y-2,myNextPlayer.Pos.y-2,myNextPlayer.Pos.y)
							end
						end
					elseif this.LinkMeTo == "Prisoner" or this.LinkMeTo == "Guard" then
						if (this.Pos.x>=myNextPlayer.Pos.x-0.35 and this.Pos.x<=myNextPlayer.Pos.x+0.35 and this.Pos.y>=myNextPlayer.Pos.y-0.35 and this.Pos.y<=myNextPlayer.Pos.y+0.35) or this.Step >= 0.99 then
							Set(myNextPlayer,"Carrying.i",this.Id.i)
							Set(myNextPlayer,"Carrying.u",this.Id.u)
							this.CarrierId.i=myNextPlayer.Id.i
							this.CarrierId.u=myNextPlayer.Id.u
							this.Carried=3
							this.NewPosX=nil
							this.NewPosY=nil
							this.LinkMeTo = "None"
							myNextPlayer = nil
							this.Step = 0
						else
							this.Step = this.Step+0.033
							if myNextPlayer.Pos.x > this.Pos.x then
								this.Pos.x = cubicBezier(this.Step,this.StartX,myNextPlayer.Pos.x-1,myNextPlayer.Pos.x-0.35,myNextPlayer.Pos.x)
								this.Pos.y = cubicBezier(this.Step,this.StartY,myNextPlayer.Pos.y-1,myNextPlayer.Pos.y-1,myNextPlayer.Pos.y)
							else
								this.Pos.x = cubicBezier(this.Step,this.StartX,myNextPlayer.Pos.x+1,myNextPlayer.Pos.x+0.35,myNextPlayer.Pos.x)
								this.Pos.y = cubicBezier(this.Step,this.StartY,myNextPlayer.Pos.y-1,myNextPlayer.Pos.y-1,myNextPlayer.Pos.y)
							end
						end
					elseif this.LinkMeTo == "BasketballTrainerFullCourt" or this.LinkMeTo == "BasketballTrainerHalfCourt" or this.LinkMeTo == "BasketballTrainerYard" then
						if this.Pos.x>=myNextPlayer.Pos.x-0.5 and this.Pos.x<=myNextPlayer.Pos.x+0.5 and this.Pos.y>=myNextPlayer.Pos.y-0.5 and this.Pos.y<=myNextPlayer.Pos.y+0.5 then
							Set(myNextPlayer,"Carrying.i",this.Id.i)
							Set(myNextPlayer,"Carrying.u",this.Id.u)
							this.CarrierId.i=myNextPlayer.Id.i
							this.CarrierId.u=myNextPlayer.Id.u
							this.Carried=3
							this.NewPosX=nil
							this.NewPosY=nil
							this.LinkMeTo = "None"
							myNextPlayer = nil
						end
					end
				end
			end
		end
	end

	if this.Damage==1 and this.Loaded==true then
		this.Delete()
	end

end
