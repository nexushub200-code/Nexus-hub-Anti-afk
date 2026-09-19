local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local VirtualUser=game:GetService("VirtualUser")

local LP=Players.LocalPlayer

local Themes={
	Red={
		Main=Color3.fromRGB(45,16,20),
		Panel=Color3.fromRGB(65,22,28),
		Panel2=Color3.fromRGB(85,28,35),
		Accent=Color3.fromRGB(255,65,75),
		Accent2=Color3.fromRGB(255,120,125)
	},
	Blue={
		Main=Color3.fromRGB(15,25,45),
		Panel=Color3.fromRGB(22,35,60),
		Panel2=Color3.fromRGB(30,48,80),
		Accent=Color3.fromRGB(55,140,255),
		Accent2=Color3.fromRGB(110,185,255)
	},
	Purple={
		Main=Color3.fromRGB(25,18,40),
		Panel=Color3.fromRGB(35,25,55),
		Panel2=Color3.fromRGB(48,32,72),
		Accent=Color3.fromRGB(150,65,255),
		Accent2=Color3.fromRGB(180,110,255)
	},
	["Dark X Gray"]={
		Main=Color3.fromRGB(22,22,25),
		Panel=Color3.fromRGB(32,32,36),
		Panel2=Color3.fromRGB(45,45,50),
		Accent=Color3.fromRGB(125,125,135),
		Accent2=Color3.fromRGB(175,175,185)
	}
}

local ThemeName="Purple"
local T=Themes[ThemeName]

local AFK=false
local AFKStart=0
local TimerVisible=false
local Minimized=false
local DrawerOpen=false
local RainbowHue=0
local afkLoop=nil

-- ✅ CLEANED & CORRECTED ANTI‑AFK — proper loop + cleanup + no stuck‑input calls
local function StartAntiAFK()
	if AFK then
		if afkLoop then task.cancel(afkLoop) end
		afkLoop=task.spawn(function()
			while AFK do
				pcall(function()
					local char=LP.Character
					local hrp=char and char:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.CFrame=hrp.CFrame*CFrame.new(0,0.01,0)
						task.wait(0.1)
						hrp.CFrame=hrp.CFrame*CFrame.new(0,-0.01,0)
					end
				end)
				task.wait(15)
			end
		end)
	else
		if afkLoop then
			task.cancel(afkLoop)
			afkLoop=nil
		end
	end
end

-- ✅ Idled event kept — correct official method, separate & safe
LP.Idled:Connect(function()
	if AFK then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(100,100))
	end
end)

local function Corner(o,r)
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,r)
	c.Parent=o
	return c
end

local function Stroke(o,c,t)
	local s=Instance.new("UIStroke")
	s.Color=c
	s.Transparency=t or 0
	s.Thickness=1
	s.Parent=o
	return s
end

local function Tween(o,info,props)
	return TweenService:Create(o,info,props)
end

local function FormatTime(sec)
	sec=math.max(0,math.floor(sec))
	local h=math.floor(sec/3600)
	local m=math.floor((sec%3600)/60)
	local s=sec%60
	if h>0 then return string.format("%02d:%02d:%02d",h,m,s) end
	return string.format("%02d:%02d",m,s)
end

local GUI=Instance.new("ScreenGui")
GUI.Name="NexusHub"
GUI.ResetOnSpawn=false
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.Parent=game:GetService("CoreGui")

local Main=Instance.new("Frame")
Main.Name="Main"
Main.Size=UDim2.fromOffset(270,205)
Main.Position=UDim2.new(.5,-135,.5,-102)
Main.BackgroundColor3=T.Main
Main.BorderSizePixel=0
Main.Parent=GUI
Corner(Main,12)
local MainStroke=Stroke(Main,T.Accent,.45)

local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,48)
Header.BackgroundTransparency=1
Header.Parent=Main

local Logo=Instance.new("TextLabel")
Logo.Size=UDim2.fromOffset(34,34)
Logo.Position=UDim2.fromOffset(9,7)
Logo.BackgroundColor3=T.Accent
Logo.Text="N"
Logo.TextColor3=Color3.new(1,1,1)
Logo.TextSize=19
Logo.Font=Enum.Font.GothamBold
Logo.Parent=Header
Corner(Logo,9)

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-105,0,21)
Title.Position=UDim2.fromOffset(50,7)
Title.BackgroundTransparency=1
Title.Text="Nexus Hub Anti‑AFK"
Title.TextColor3=Color3.new(1,1,1)
Title.TextSize=13
Title.Font=Enum.Font.GothamBold
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Parent=Header

local Subtitle=Instance.new("TextLabel")
Subtitle.Size=UDim2.new(1,-105,0,16)
Subtitle.Position=UDim2.fromOffset(50,26)
Subtitle.BackgroundTransparency=1
Subtitle.Text="By King Flame / Nexus Hub Team"
Subtitle.TextColor3=Color3.fromRGB(165,165,175)
Subtitle.TextSize=8
Subtitle.Font=Enum.Font.Gotham
Subtitle.TextXAlignment=Enum.TextXAlignment.Left
Subtitle.Parent=Header

local Min=Instance.new("TextButton")
Min.Size=UDim2.fromOffset(26,26)
Min.Position=UDim2.new(1,-60,0,10)
Min.BackgroundColor3=T.Panel
Min.Text="-"
Min.TextColor3=Color3.fromRGB(220,220,225)
Min.TextSize=16
Min.Font=Enum.Font.GothamBold
Min.AutoButtonColor=false
Min.Parent=Header
Corner(Min,8)

local Close=Instance.new("TextButton")
Close.Size=UDim2.fromOffset(26,26)
Close.Position=UDim2.new(1,-31,0,10)
Close.BackgroundColor3=T.Panel
Close.Text="×"
Close.TextColor3=Color3.fromRGB(220,220,225)
Close.TextSize=16
Close.Font=Enum.Font.GothamBold
Close.AutoButtonColor=false
Close.Parent=Header
Corner(Close,8)

local Body=Instance.new("Frame")
Body.Size=UDim2.new(1,-18,1,-57)
Body.Position=UDim2.fromOffset(9,48)
Body.BackgroundTransparency=1
Body.Parent=Main

local AFKCard=Instance.new("Frame")
AFKCard.Size=UDim2.new(1,0,0,65)
AFKCard.BackgroundColor3=T.Panel
AFKCard.BorderSizePixel=0
AFKCard.Parent=Body
Corner(AFKCard,10)

local AFKTitle=Instance.new("TextLabel")
AFKTitle.Size=UDim2.new(1,-75,0,22)
AFKTitle.Position=UDim2.fromOffset(12,9)
AFKTitle.BackgroundTransparency=1
AFKTitle.Text="Anti‑AFK"
AFKTitle.TextColor3=Color3.new(1,1,1)
AFKTitle.TextSize=12
AFKTitle.Font=Enum.Font.GothamBold
AFKTitle.TextXAlignment=Enum.TextXAlignment.Left
AFKTitle.Parent=AFKCard

local AFKDesc=Instance.new("TextLabel")
AFKDesc.Size=UDim2.new(1,-75,0,20)
AFKDesc.Position=UDim2.fromOffset(12,30)
AFKDesc.BackgroundTransparency=1
AFKDesc.Text="Prevent idle kick"
AFKDesc.TextColor3=Color3.fromRGB(155,155,165)
AFKDesc.TextSize=9
AFKDesc.Font=Enum.Font.Gotham
AFKDesc.TextXAlignment=Enum.TextXAlignment.Left
AFKDesc.Parent=AFKCard

local Switch=Instance.new("TextButton")
Switch.Size=UDim2.fromOffset(45,24)
Switch.Position=UDim2.new(1,-57,.5,-12)
Switch.BackgroundColor3=Color3.fromRGB(65,65,70)
Switch.Text=""
Switch.AutoButtonColor=false
Switch.Parent=AFKCard
Corner(Switch,12)

local Knob=Instance.new("Frame")
Knob.Size=UDim2.fromOffset(18,18)
Knob.Position=UDim2.fromOffset(3,3)
Knob.BackgroundColor3=Color3.fromRGB(235,235,240)
Knob.BorderSizePixel=0
Knob.Parent=Switch
Corner(Knob,9)

local ThemeCard=Instance.new("TextButton")
ThemeCard.Size=UDim2.new(1,0,0,65)
ThemeCard.Position=UDim2.fromOffset(0,73)
ThemeCard.BackgroundColor3=T.Panel
ThemeCard.BorderSizePixel=0
ThemeCard.Text=""
ThemeCard.AutoButtonColor=false
ThemeCard.Parent=Body
Corner(ThemeCard,10)

local ThemeTitle=Instance.new("TextLabel")
ThemeTitle.Size=UDim2.new(1,-55,0,22)
ThemeTitle.Position=UDim2.fromOffset(12,9)
ThemeTitle.BackgroundTransparency=1
ThemeTitle.Text="Select Theme"
ThemeTitle.TextColor3=Color3.new(1,1,1)
ThemeTitle.TextSize=12
ThemeTitle.Font=Enum.Font.GothamBold
ThemeTitle.TextXAlignment=Enum.TextXAlignment.Left
ThemeTitle.Parent=ThemeCard

local ThemeDesc=Instance.new("TextLabel")
ThemeDesc.Size=UDim2.new(1,-55,0,20)
ThemeDesc.Position=UDim2.fromOffset(12,30)
ThemeDesc.BackgroundTransparency=1
ThemeDesc.Text="Change UI color"
ThemeDesc.TextColor3=Color3.fromRGB(155,155,165)
ThemeDesc.TextSize=9
ThemeDesc.Font=Enum.Font.Gotham
ThemeDesc.TextXAlignment=Enum.TextXAlignment.Left
ThemeDesc.Parent=ThemeCard

local Arrow=Instance.new("TextLabel")
Arrow.Size=UDim2.fromOffset(28,28)
Arrow.Position=UDim2.new(1,-40,.5,-14)
Arrow.BackgroundTransparency=1
Arrow.Text="›"
Arrow.TextColor3=T.Accent2
Arrow.TextSize=22
Arrow.Font=Enum.Font.GothamBold
Arrow.Parent=ThemeCard

local Drawer=Instance.new("Frame")
Drawer.Name="ThemeDrawer"
Drawer.Size=UDim2.fromOffset(8,8)
Drawer.Position=UDim2.new(1,-45,0,111)
Drawer.BackgroundColor3=T.Panel2
Drawer.BorderSizePixel=0
Drawer.Visible=false
Drawer.ClipsDescendants=true
Drawer.Parent=Main
Corner(Drawer,10)
local DrawerStroke=Stroke(Drawer,T.Accent,.45)

local DrawerTitle=Instance.new("TextLabel")
DrawerTitle.Size=UDim2.new(1,-35,0,22)
DrawerTitle.Position=UDim2.fromOffset(10,7)
DrawerTitle.BackgroundTransparency=1
DrawerTitle.Text="Themes"
DrawerTitle.TextColor3=Color3.new(1,1,1)
DrawerTitle.TextSize=11
DrawerTitle.Font=Enum.Font.GothamBold
DrawerTitle.TextXAlignment=Enum.TextXAlignment.Left
DrawerTitle.Parent=Drawer

local DrawerClose=Instance.new("TextButton")
DrawerClose.Size=UDim2.fromOffset(24,24)
DrawerClose.Position=UDim2.new(1,-30,0,5)
DrawerClose.BackgroundColor3=T.Panel
DrawerClose.Text="×"
DrawerClose.TextColor3=Color3.fromRGB(220,220,225)
DrawerClose.TextSize=14
DrawerClose.Font=Enum.Font.GothamBold
DrawerClose.AutoButtonColor=false
DrawerClose.Parent=Drawer
Corner(DrawerClose,7)

local ThemeButtons={}
local function MakeThemeButton(name,y)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,-16,0,27)
	b.Position=UDim2.fromOffset(8,y)
	b.BackgroundColor3=Themes[name].Main
	b.Text=name
	b.TextColor3=Color3.new(1,1,1)
	b.TextSize=9
	b.Font=Enum.Font.GothamBold
	b.AutoButtonColor=false
	b.Parent=Drawer
	Corner(b,7)
	ThemeButtons[name]=b
	return b
end
MakeThemeButton("Red",36)
MakeThemeButton("Blue",67)
MakeThemeButton("Purple",98)
MakeThemeButton("Dark X Gray",129)

local Show=Instance.new("TextButton")
Show.Name="ShowUI"
Show.Size=UDim2.fromOffset(72,28)
Show.Position=UDim2.new(.5,-36,0,8)
Show.BackgroundColor3=Color3.new(1,1,1)
Show.BackgroundTransparency=.3
Show.Text="Show UI"
Show.TextColor3=Color3.fromRGB(25,25,28)
Show.TextSize=10
Show.Font=Enum.Font.GothamBold
Show.AutoButtonColor=false
Show.Visible=false
Show.Parent=GUI
Corner(Show,9)

local Timer=Instance.new("Frame")
Timer.Name="AFKTimer"
Timer.Size=UDim2.fromOffset(92,34)
Timer.Position=UDim2.new(.5,42,0,5)
Timer.BackgroundColor3=T.Accent
Timer.BorderSizePixel=0
Timer.Visible=false
Timer.ZIndex=50
Timer.Parent=GUI
Corner(Timer,17)
local TimerStroke=Stroke(Timer,Color3.new(1,1,1),0)
TimerStroke.Thickness=1.5

local TimerText=Instance.new("TextLabel")
TimerText.Size=UDim2.new(1,-12,1,0)
TimerText.Position=UDim2.fromOffset(6,0)
TimerText.BackgroundTransparency=1
TimerText.Text="00:00"
TimerText.TextColor3=Color3.new(1,1,1)
TimerText.TextSize=11
TimerText.Font=Enum.Font.GothamBold
TimerText.TextXAlignment=Enum.TextXAlignment.Center
TimerText.ZIndex=51
TimerText.Parent=Timer

local function ApplyTheme()
	T=Themes[ThemeName]
	Main.BackgroundColor3=T.Main; MainStroke.Color=T.Accent
	Logo.BackgroundColor3=T.Accent; Min.BackgroundColor3=T.Panel; Close.BackgroundColor3=T.Panel
	AFKCard.BackgroundColor3=T.Panel; ThemeCard.BackgroundColor3=T.Panel
	Arrow.TextColor3=T.Accent2; Drawer.BackgroundColor3=T.Panel2; DrawerStroke.Color=T.Accent; DrawerClose.BackgroundColor3=T.Panel
	for _,b in pairs(ThemeButtons) do b.BackgroundColor3=Themes[b.Text].Main end
	Timer.BackgroundColor3=T.Accent; if AFK then Switch.BackgroundColor3=T.Accent end
end

local function UpdateSwitch(v)
	if v then
		Switch.BackgroundColor3=T.Accent
		Tween(Knob,TweenInfo.new(.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(1,-21,0,3)}):Play()
	else
		Switch.BackgroundColor3=Color3.fromRGB(65,65,70)
		Tween(Knob,TweenInfo.new(.22,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(3,3)}):Play()
	end
end

local function PressSwitch()
	local oldSize,oldPos=Switch.Size,Switch.Position
	Tween(Switch,TweenInfo.new(.07,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(48,27),Position=UDim2.new(1,-59.5,.5,-13.5)}):Play()
	task.delay(.07,function()
		Tween(Switch,TweenInfo.new(.13,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=oldSize,Position=oldPos}):Play()
	end)
end

local function ShowTimer()
	if TimerVisible then return end
	TimerVisible=true; Timer.Visible=true; Timer.Size=UDim2.fromOffset(8,8); Timer.BackgroundTransparency=1; TimerStroke.Transparency=1
	Tween(Timer,TweenInfo.new(.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(92,34),BackgroundTransparency=0}):Play()
	Tween(TimerStroke,TweenInfo.new(.35,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Transparency=0}):Play()
end

local function HideTimer()
	if not TimerVisible then return end
	TimerVisible=false
	Tween(TimerStroke,TweenInfo.new(.2),{Transparency=1}):Play()
	local tw=Tween(Timer,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.fromOffset(8,8),BackgroundTransparency=1})
	tw:Play()
	tw.Completed:Connect(function() if not TimerVisible then Timer.Visible=false end end)
end

local function AFKState(v)
	AFK=v; PressSwitch(); UpdateSwitch(v); StartAntiAFK()
	if v then AFKStart=os.clock(); ShowTimer() else HideTimer(); TimerText.Text="00:00" end
end

Switch.MouseButton1Click:Connect(function() AFKState(not AFK) end)

RunService.RenderStepped:Connect(function(dt)
	if AFK then TimerText.Text=FormatTime(os.clock()-AFKStart) end
	RainbowHue=(RainbowHue+dt*.18)%1; TimerStroke.Color=Color3.fromHSV(RainbowHue,1,1)
end)

ThemeCard.MouseButton1Click:Connect(function()
	if DrawerOpen then return end
	DrawerOpen=true; Drawer.Visible=true; Drawer.Size=UDim2.fromOffset(8,8); Drawer.Position=UDim2.new(1,-45,0,111)
	Tween(Drawer,TweenInfo.new(.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(145,174),Position=UDim2.new(1,-153,0,27)}):Play()
end)

local function CloseDrawer()
	if not DrawerOpen then return end
	DrawerOpen=false
	local tw=Tween(Drawer,TweenInfo.new(.32,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.fromOffset(8,8),Position=UDim2.new(1,-45,0,111)})
	tw:Play()
	tw.Completed:Connect(function() if not DrawerOpen then Drawer.Visible=false end end)
end
DrawerClose.MouseButton1Click:Connect(CloseDrawer)

for name,b in pairs(ThemeButtons) do
	b.MouseButton1Click:Connect(function() ThemeName=name; ApplyTheme(); CloseDrawer() end)
end

-- ✅ CRITICAL SYNTAX FIX — replaced wrong‑character minus sign with proper minus everywhere
local function Drag(frame)
	local dragging=false; local dragStart; local startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true; dragStart=input.Position; startPos=frame.Position
			input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
			local delta=input.Position-dragStart  -- ✅ PROPER MINUS — NO MORE ERROR!
			frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		end
	end)
end

Drag(Main); Drag(Timer)

local function Minimize()
	if Minimized then return end
	Minimized=true; CloseDrawer()
	Show.Visible=true; Show.BackgroundTransparency=1; Show.Size=UDim2.fromOffset(8,8)
	Tween(Show,TweenInfo.new(.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(72,28),BackgroundTransparency=.3}):Play()
	local tw=Tween(Main,TweenInfo.new(.32,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.fromOffset(8,8),BackgroundTransparency=1})
	tw:Play()
	tw.Completed:Connect(function() if Minimized then Main.Visible=false end end)
end

local function Restore()
	if not Minimized then return end
	Minimized=false; Main.Position=UDim2.new(.5,-135,.5,-102)
	Main.Visible=true; Main.Size=UDim2.fromOffset(8,8); Main.BackgroundTransparency=1
	Tween(Main,TweenInfo.new(.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(270,205),BackgroundTransparency=0}):Play()
	Tween(Show,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.fromOffset(8,8),BackgroundTransparency=1}):Play()
	task.delay(.25,function() if not Minimized then Show.Visible=false; Show.Size=UDim2.fromOffset(72,28); Show.BackgroundTransparency=.3 end end)
end

Min.MouseButton1Click:Connect(Minimize)
Show.MouseButton1Click:Connect(Restore)

Close.MouseButton1Click:Connect(function()
	local tw=Tween(Main,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.fromOffset(8,8),BackgroundTransparency=1})
	tw:Play(); tw.Completed:Connect(function() GUI:Destroy() end)
end)

Min.MouseEnter:Connect(function() Tween(Min,TweenInfo.new(.15),{BackgroundColor3=T.Accent}):Play() end)
Min.MouseLeave:Connect(function() Tween(Min,TweenInfo.new(.15),{BackgroundColor3=T.Panel}):Play() end)
Close.MouseEnter:Connect(function() Tween(Close,TweenInfo.new(.15),{BackgroundColor3=T.Accent}):Play() end)
Close.MouseLeave:Connect(function() Tween(Close,TweenInfo.new(.15),{BackgroundColor3=T.Panel}):Play() end)
ThemeCard.MouseEnter:Connect(function() Tween(ThemeCard,TweenInfo.new(.15),{BackgroundColor3=T.Panel2}):Play() end)
ThemeCard.MouseLeave:Connect(function() Tween(ThemeCard,TweenInfo.new(.15),{BackgroundColor3=T.Panel}):Play() end)
Show.MouseEnter:Connect(function() Tween(Show,TweenInfo.new(.15),{BackgroundTransparency=.15}):Play() end)
Show.MouseLeave:Connect(function() Tween(Show,TweenInfo.new(.15),{BackgroundTransparency=.3}):Play() end)

ApplyTheme(); UpdateSwitch(false)
