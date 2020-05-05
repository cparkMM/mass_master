script_name('News Network')
script_author('ZAKO & cpark')
script_version_number(10)
script_version("1.0")
script_properties("forced-reloading-only")

require "lib.moonloader"
require "lib.sampfuncs"
local encoding = require 'encoding'
local memory = require "memory"
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local vkeys = require 'vkeys'
local rkeys = require 'rkeys'
local bNotf, notf = pcall(import, "imgui_notf.lua")
encoding.default = 'CP1251'
u8 = encoding.UTF8
imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.HotKey = require('imgui_addons').HotKey
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
if not doesFileExist('moonloader\\config\\MM\\MM.ini') then
	if not doesDirectoryExist('moonloader\\config\\MM') then  createDirectory('moonloader\\config\\MM') end
	local  ini =
		{
				config =
				{
					sex = true
				}
		}
	inicfg.save(ini, 'MM\\MM')
end
local directIni = 'moonloader\\config\\MM\\MM.ini'
local mainIni = inicfg.load(nil, directIni)
local check_my = true
local my = {}
local iScreenWidth, iScreenHeight = getScreenResolution()
local rangs =
{
	 '���������� ��������',
	 '�������� ��������',
	 '�����������',
	 '�������',
	 '��������',
	 '�������',
	 '��������',
	 '��������',
	 '��.��������',
	 '��������',
	 '�����������'
}
local binder =
{
	binders=
	{
		{
			name = u8'����������',
			wait = 0,
			key = {18,49},
			lines =
			{
				'/edit '
			}
		},
		{
			name = u8'����',
			wait = 0,
			key = {18,50},
			lines =
			{
				'/time'
			}
		}
	}
}
local default_key = {v={vkeys[0]}}
local binder_select = 1
local iScreenWidth, iScreenHeight = getScreenResolution()
local binder_create_name = imgui.ImBuffer(256)
local binder_create_key = {}
local binder_create_wait = imgui.ImInt(1000)
local select_bind = 0
local find = {}
local select_find = {}
local binder_create_lines = {
	imgui.ImBuffer(256),
	imgui.ImBuffer(256),
	imgui.ImBuffer(256)
}
local tab_id = -1
-------------------------IMGUI-------------------------------------
local imgui_main_window = imgui.ImBool(false)
local find_window = imgui.ImBool(false)
local window_binder = imgui.ImBool(false)
local window_state_tab = imgui.ImBool(false)
local focus = false
local edit_window = imgui.ImBool(false)
local img_logo = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\image\\logomm.png')
local input_prefix_f = imgui.ImBuffer((mainIni.config.prefix_f and mainIni.config.prefix_f or ''),256)
local input_prefix_r = imgui.ImBuffer((mainIni.config.prefix_r and mainIni.config.prefix_r or ''),256)
local input_acent = imgui.ImBuffer((mainIni.config.acent and mainIni.config.acent or ''),256)
local enter_text = imgui.ImBuffer(256)
local imgui_find = imgui.ImBool(mainIni.config.acent==true)
local sex = imgui.ImInt((mainIni.config.sex==0 and 0 or 1 ))
-------------------------------------------------------------------
function main()
	while not isSampAvailable() do wait(100) end
	autoupdate("https://api.jsonbin.io/b/5eb1066747a2266b147307a5", '['..string.upper(thisScript().name)..']: ', "http://vk.com/kirill_batozhok")
	sampRegisterChatCommand('mmset', cmd_mmset)
	sampRegisterChatCommand('fwarn', cmd_fwarn)
	sampRegisterChatCommand('invite', cmd_invite)
	sampRegisterChatCommand('setskin', cmd_setskin)
	sampRegisterChatCommand('rang', cmd_rang)
	sampRegisterChatCommand('sobes', cmd_sobes)
	sampRegisterChatCommand('r', cmd_r)
	sampRegisterChatCommand('f', cmd_f)
	sampRegisterChatCommand('ka', cmd_ka)
	sampRegisterChatCommand('uninvite', cmd_uninvite)
	sampRegisterChatCommand('unfwarn', cmd_unfwarn)
	sampRegisterChatCommand('black', cmd_black)
	sampRegisterChatCommand('ko', cmd_ko)
	sampRegisterChatCommand('offblack', cmd_offblack)
	_, my['id'] =  sampGetPlayerIdByCharHandle(PLAYER_PED)
	my['name']  =  sampGetPlayerNickname(my['id'])
	my['lastname'] = my['name']:match('.*_(.*)')
	my['firstname'] = my['name']:match('(.*)_.*')
	if bNotf then	notf.addNotification('MASS MEDIA MASTER ��������', 3, 1) end
	file = io.open(getWorkingDirectory().."\\config\\SMI_BINDER.json","r+")
	if file == nil then
		file = io.open(getWorkingDirectory().."\\config\\SMI_BINDER.json","w")
		file:write(encodeJson(binder))
		file:flush()
		file:close()
		file = io.open(getWorkingDirectory().."\\config\\SMI_BINDER.json","r+")
	end
	binder = decodeJson(file:read())
	file:flush()
	file:close()
	updatebind()
	sampSendChat('/stats')
	while true do wait(0)
		imgui.Process = true
	end
end
function sampev.onShowDialog(id,style,title,button1,button2,text)
	if (title:find('����� ����������� ������')) then
		find = {}
		for line in text: gmatch("[^\n]+") do
			if line:find('(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s(%d)%/3%s+([A-Za-z_]+)[%s+]?(.*)') then
				local id,lvl,number,rang,warn,name,dop = line:match('(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s(%d)%/3%s+([A-Za-z_]+)[%s+]?(.*)')
				local nearby = '���'
				for k, v in pairs(getAllChars()) do
					local _, l_id = sampGetPlayerIdByCharHandle(v)
					if tonumber(id) == l_id then  nearby = '��' end
				end
				table.insert(find,{id,lvl,number,rang,warn,name,nearby,(dop and dop:gsub('%{[A-Za-z%d+]+%}','') or '-')})
			end
	end
	select_find = find[1]
	find_window.v = true
	sampSendDialogResponse(id)
	return false
elseif title:find('^[A-Za-z_]+$') and not text:find('\n') then
				edit_text = text
				edit_title = title
				edit_window.v = true
				enter_text.v = 	tostring(my['edit_teg'])
				edit_id = id
				focus = trueasd
				return false
	elseif title:find('����������') and check_my then
		for line in text: gmatch("[^\n]+") do
			if line:find('����:%s+%{0099ff%}(.*)') then
				my['rang'] = tonumber(line:match('����:%s+%{0099ff%}(.*)'))
				binder_tags =
				{
					myname = 			{
													text	 = '��� ������� ��� (��)',
													input	 = imgui.ImBuffer('myname',256),
													action = my['name']:gsub('_',' ')
												},
					myid =  			{
													text	 = '��� ������� ID',
													input	 = imgui.ImBuffer('myid',256),
													action = my['id']
												},
					myrang =  		{
													text   ='���� ���������',
													input  =imgui.ImBuffer('myrang',256),
													action = my['rang']
												},
					myfirstname = {
													text	 = '���� ���',
													input	 = imgui.ImBuffer('myfirstname',256),
													action = my['firstname']
												},
					mylastname =  {
													text	 ='���� �������',
													input  = imgui.ImBuffer('mylastname',256),
													action = my['lastname']
												}
				}
				check_my = false
				sampSendDialogResponse(id)
				return false
			elseif line:find('���������:%s+%{0099ff%}(.*) %/') then
				my['rc'] = line:match('���������:%s+%{0099ff%}(.*) %/')
				if my['rc'] == '���������� ��' then
					my['edit_teg'] = 'LS-N | '
				elseif my['rc'] == '���������� ��' then
					 my['edit_teg'] = 'SF-N | '
				elseif my['rc'] == '���������� ��' then
					my['edit_teg'] = 'LV-N | '
			  end
			end
		end
	end
end
function sampev.onServerMessage(color,text)
	if text:find('����� ���������� �� Diamond Role Play!') and check_my then
		sampSendChat('/stats')
	end
end
function imgui.OnDrawFrame()
	if imgui_main_window.v or window_binder.v or find_window.v or edit_window.v then imgui.ShowCursor = true else imgui.ShowCursor = false end
	if imgui_main_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
		imgui.Begin(u8'##s',imgui_main_window, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoResize)
		local draw_list = imgui.GetWindowDrawList();
		local p = imgui.GetCursorScreenPos();
		draw_list:AddRectFilled(imgui.ImVec2(0,0), imgui.ImVec2(p.x+181.8	,p.y+400), 0x990E0E0E)
		imgui.Columns(2,nil,false)
		imgui.SetCursorPos(imgui.ImVec2(0, 20))
		imgui.Image(img_logo, imgui.ImVec2(165, 70))
		imgui.SetColumnWidth(-1, 181.8)
		imgui.CenterColumnText(u8:encode((my['name'] and my['name'] or '��������')))
		imgui.CenterColumnText(u8:encode((my['rc'] and my['rc'] or '��������')))
		imgui.CenterColumnText(u8:encode((rangs[my['rang']] and rangs[my['rang']] or '��������')))
		imgui.NextColumn()
		if imgui.InputText(u8'��� � /f',input_prefix_f) then mainIni.config.prefix_f = input_prefix_f.v inicfg.save(mainIni, directIni)
		elseif imgui.InputText(u8'��� � /r',input_prefix_r)  then mainIni.config.prefix_r = input_prefix_r.v inicfg.save(mainIni, directIni)
		elseif imgui.InputText(u8'������',input_acent)  then mainIni.config.acent = input_acent.v inicfg.save(mainIni, directIni)
		end
		imgui.PushItemWidth(130)
		if imgui.ListBox('##2', sex,{u8'������',u8'�������'}, 2) then mainIni.config.sex = sex.v inicfg.save(mainIni, directIni)	 end
		imgui.SameLine()
		if imgui.Checkbox(u8"��������� ����", imgui_find) then end
		if imgui.Button(u8'������') then window_binder.v = not window_binder.v end
		imgui.Columns(1)
		imgui.End()
	end
	if edit_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2((imgui.CalcTextSize(u8:encode(edit_text)).x+200), 150), imgui.Cond.FirstUseEver)
		imgui.Begin(edit_title,find_window, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.ShowBorders)
		imgui.Columns(2,nil,false)
		imgui.SetColumnWidth(-1, 120)
		imgui.SetCursorPos(imgui.ImVec2(-30, 10))
		imgui.Image(img_logo, imgui.ImVec2(165, 70))
		if imgui.Button(u8'����������') then
			 setClipboardText(edit_text)
			 if bNotf then	notf.addNotification('����� ���������� ���������� � ����� ������', 3, 2) end
		end
		imgui.NextColumn()
		imgui.Text(u8:encode(edit_text))
		if (imgui.InputText('##1', enter_text, imgui.InputTextFlags.EnterReturnsTrue ) or imgui.Button(u8'���������')) then
			sampSendDialogResponse(edit_id,1,65535,u8:decode(enter_text.v))
			edit_window.v = false
		end
		imgui.SameLine()
		if imgui.Button(u8'������') then sampSendDialogResponse(edit_id) ;edit_window.v = false end
		imgui.End()
	end
	if find_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(880, 495), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"����� ����������� ������",find_window, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoResize)
		imgui.Columns(2,nil,false)
		imgui.SetColumnWidth(-1, 680)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'[ID]')
		imgui.SameLine(60.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'���')
		imgui.SameLine(200.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'���������')
		imgui.SameLine(335.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'����')
		imgui.SameLine(400.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'��������')
		imgui.SameLine(470.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'�����')
		imgui.SameLine(530.0)
		imgui.TextColored(imgui.ImColor(255.0, 255.0, 255.0, 255.0):GetVec4(),u8'VOICE\\AFK')
		imgui.BeginChild('find', imgui.ImVec2(670,380), true)
		for i = 1,table.maxn(find) do
			if imgui.Selectable(u8:encode(find[i][1]),(find[i][1] == select_find[1])) then select_find = find[i] end
			imgui.SameLine(50.0)
			imgui.Text(u8:encode(find[i][6]))
			imgui.SameLine(180.0)
			imgui.Text(u8:encode(rangs[tonumber(find[i][4])]))
			imgui.SameLine(335.0)
			imgui.Text(u8:encode(find[i][4]))
			imgui.SameLine(400.0)
			imgui.Text(u8:encode(find[i][5]..'/3'))
			imgui.SameLine(470.0)
			imgui.Text(u8:encode(find[i][7]))
			imgui.SameLine(530.0)
			imgui.Text(u8:encode(find[i][8]))
		--	imgui.SameLine(520.0)
		--	imgui.Text(find[i][8])
		end
		imgui.EndChild()
		imgui.Text(u8'������ �����������: '..tostring(#find))
		imgui.SameLine()
		imgui.Text(u8'����� ������: '..sampGetPlayerCount(false))
		imgui.NextColumn()
		imgui.SetCursorPos(imgui.ImVec2(695, 35))
		imgui.Image(img_logo, imgui.ImVec2(165, 70))
		imgui.CenterColumnText(select_find[6])
		if imgui.Button(u8'���������� ���',imgui.ImVec2(180, 20)) then setClipboardText(select_find[6]:gsub('_',' '));if bNotf then	notf.addNotification('��� ���������� � ����� ������', 3, 2) end end
		if imgui.Button(u8'���������� ���',imgui.ImVec2(180, 20))  then setClipboardText(select_find[3]);if bNotf then	notf.addNotification('������� ���������� � ����� ������', 3, 2) end end
		if imgui.Button(u8'��������� ��������������',imgui.ImVec2(180, 20))  then
			sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..rangs[tonumber(select_find[4])]..' '..select_find[6]:gsub('_',' ')..', �������� ���� ��������������!')
		end
		imgui.Columns(1,nil,false)
		imgui.End() -- ����
	end
	if window_binder.v then
	 imgui.SetNextWindowPos(imgui.ImVec2(iScreenWidth/2, iScreenHeight /2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 	0.5))
	 imgui.SetNextWindowSize(imgui.ImVec2(700, 500), imgui.Cond.FirstUseEver)
	 imgui.Begin(u8'MASS MEDIA | Binder',window_binder, imgui.WindowFlags.ShowBorders+imgui.WindowFlags.NoCollapse+imgui.WindowFlags.NoResize)
	 imgui.Columns(2,nil,false)
	 imgui.SetColumnWidth(-1, 180)
	 if imgui.Selectable(u8'�������',(binder_select==1)) then binder_select = 1
	 elseif imgui.Selectable(u8'������� ������',(binder_select==2)) then binder_select = 2 end
	 imgui.SetCursorPos(imgui.ImVec2(0, 80))
	 imgui.BeginChild('tags', imgui.ImVec2(165,420), true)
	 for key, val in pairs(binder_tags) do
		 imgui.Text(u8:encode(val['text']))
		 imgui.InputText('##'..val['text'],val['input'],imgui.InputTextFlags.ReadOnly)
	 end
	 imgui.EndChild()
	 imgui.NextColumn()
	 if binder_select==1 then
		 for key, val in pairs(binder['binders']) do
			 if imgui.Selectable(tostring(key),(select_bind==key)) then
				 select_bind = key
			 end
			 imgui.SameLine()
			 imgui.CenterColumnText(tostring(val['name']))
			 if key == select_bind then
				 imgui.NewLine();imgui.SameLine(70)
				 imgui.BeginChild('createbind', imgui.ImVec2(280,90), true)
					 imgui.Text(u8'�������: '..	table.concat(rkeys.getKeysName( val['key'])))
					 imgui.Text(u8'������������ ��������: '..val['wait']..u8'��.')
					 if imgui.Button(u8'�������������', imgui.ImVec2(100,25)) then
						 binder_create_wait = imgui.ImInt(val['wait'])
						 binder_create_name = imgui.ImBuffer(val['name'],256)
						 binder_create_key = {v={vkeys[val['key']]}}
						 default_key = {v={vkeys[val['key']]}}
						 binder_create_lines = {}
						 for key, val in pairs(val['lines']) do
							 table.insert(binder_create_lines,imgui.ImBuffer(u8:encode(val),256))
						 end
						 binder_select = 2
					 end
					 imgui.SameLine()
					 if imgui.Button(u8'�������', imgui.ImVec2(100,25)) then
						 for lkey, lval in pairs(binder['binders']) do
							 if val['name']== lval['name'] then
								 rkeys.unRegisterHotKey(lval['id'])
								 table.remove(binder['binders'],lkey)
							 end
						 end
						 os.remove(getWorkingDirectory().."\\config\\SMI_BINDER.json")
						 file = io.open(getWorkingDirectory().."\\config\\SMI_BINDER.json","w")
						 file:write(encodeJson(binder))
						 file:flush()
						 file:close()
						 select_bind = 0
					 end
				 imgui.EndChild()
			 end
		 end
	 elseif binder_select==2 then
	 imgui.CenterColumnText(u8'�������� �������')
	 imgui.Text(u8'�������� �����')
	 imgui.SameLine(220)
	 imgui.Text(u8'�������')
	 imgui.PushItemWidth(190)
	 imgui.InputText('##1',binder_create_name)
	 imgui.SameLine()
	 imgui.HotKey("##active",default_key, binder_create_key, 100)
	 imgui.InputInt(u8'��������',binder_create_wait)
	 imgui.BeginChild('createbind', imgui.ImVec2(430,300), true)
	 for line_num, line in pairs(binder_create_lines) do
		 imgui.PushItemWidth(290)
		 imgui.InputText('##'..line_num,binder_create_lines[line_num])
		 imgui.SameLine()
		 if imgui.Button('X##'..line_num) then table.remove(binder_create_lines,line_num) end
	 end
	 imgui.EndChild()
	 if imgui.Button(u8'��� ������') then
		 table.insert(binder_create_lines,imgui.ImBuffer(256))
	 end
	 imgui.SameLine()
	 if imgui.Button(u8'���������') then
		if #binder_create_name.v>0 then
		 local lines = {}
		 for key, val in pairs(binder['binders']) do
			 if val['name']== binder_create_name.v then
				 rkeys.unRegisterHotKey(val['id'])
				 table.remove(binder['binders'],key)
			 end
		 end
		 for line_num, line in pairs(binder_create_lines) do
			 table.insert(lines,u8:decode(binder_create_lines[line_num].v))
		 end
		 local key = table.concat(rkeys.getKeysName(binder_create_key.v))
		 table.insert(binder['binders'],
		 {
			 name = binder_create_name.v,
			 key = default_key.v,
			 wait = binder_create_wait.v,
			 lines = lines
		 })
		 os.remove(getWorkingDirectory().."\\config\\SMI_BINDER.json")
		 file = io.open(getWorkingDirectory().."\\config\\SMI_BINDER.json","w")
		 file:write(encodeJson(binder))
		 file:flush()
		 file:close()
		 binder_create_name = imgui.ImBuffer(256)
		 binder_create_key = {}
		 binder_create_wait = imgui.ImInt(1000)
		 binder_create_lines = {
			 imgui.ImBuffer(256),
			 imgui.ImBuffer(256),
			 imgui.ImBuffer(256)
		 }
		 updatebind()
		 if bNotf then	notf.addNotification('���� ���������������', 3, 2) end
		else
			if bNotf then	notf.addNotification('�� ������ ������� �������� �����', 3, 1) end
		end
	 end
	 end
	 imgui.Columns(1)
	 imgui.End()
	end
end
function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100) then
		if(wparam == VK_ESCAPE and (imgui_main_window.v or window_binder.v or find_window.v)) then
			imgui_main_window.v = false
			find_window.v = false
			window_binder.v = false
			consumeWindowMessage()
		end
	end
end
function cmd_mmset()
	imgui_main_window.v = not imgui_main_window.v
end
function apply_custom_style()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4
	style.WindowTitleAlign = imgui.ImVec2(0.08, 0.5)
  style.WindowPadding = imgui.ImVec2(15, 15)
  style.WindowRounding = 1.5
  style.FramePadding = imgui.ImVec2(5, 5)
  style.FrameRounding = 4.0
  style.ItemSpacing = imgui.ImVec2(12, 8)
  style.ItemInnerSpacing = imgui.ImVec2(8, 6)
  style.IndentSpacing = 25.0
  style.ScrollbarSize = 15.0
  style.ScrollbarRounding = 9.0
  style.GrabMinSize = 5.0
  style.GrabRounding = 3.0
  colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
  colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
  colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 0.95)
  colors[clr.ChildWindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
  colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
  colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.28)
  colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
  colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
  colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
  colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
  colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
  colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
  colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
  colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
  colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
  colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
  colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
  colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.Separator] = ImVec4(0.06, 0.05, 0.07, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
  colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
  colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
  colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
  colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
  colors[clr.Header] = ImVec4(0.56, 0.56, 0.58, 0.20)
  colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 0.20)
  colors[clr.HeaderActive]     = ImVec4(0.56, 0.56, 0.58, 0.20)
  colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
  colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
  colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
  colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
  colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 0.00)
  colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
  colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
  colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
  colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

apply_custom_style()
function cmd_r(text)
	if #text ~= 0 then
		sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..text)
	else
		sampAddChatMessage('/r (�����)', -1)
	end
end
function cmd_f(text)
	if #text ~= 0 then
		sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' '..text)
	else
		sampAddChatMessage('/f (�����)', -1)
	end
end
function sampev.onSendChat(msg)
	msg = u8:decode(input_acent.v)..''..msg
	return {msg}
end
function imgui.CenterText(text)
    imgui.SetCursorPosX((imgui.GetWindowSize().x/2) - (imgui.CalcTextSize(text).x / 2))
    imgui.Text(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function updatebind()
	for key, val in pairs(binder['binders']) do
		if binder['binders'][key]['id'] then
			rkeys.unRegisterHotKey(binder['binders'][key]['id'])
		end
		binder['binders'][key]['id'] = rkeys.registerHotKey(val['key'], true, function ()
			lua_thread.create(function()
				for num_line, line in pairs(val['lines']) do
					for tag, val_tag in pairs(binder_tags) do
						if line:find (tostring(val_tag['input'].v)) then
						 line = line:gsub(tostring(val_tag['input'].v),val_tag['action']) end
					end
					if line:find('^%/f') then
						sampSendChat('/f '..u8:decode((input_prefix_f.v and input_prefix_f.v or ''))..' '..line:gsub('%/f',''))
					elseif line:find('^%/r') then
						sampSendChat('/r '..u8:decode((input_prefix_r.v and input_prefix_r.v or ''))..' '..line:gsub('%/r',''))
					else
						sampSendChat(line)
					end
						wait(val['wait'])
				end
			end) -- �����
		end) -- �������
	end
end
function cmd_sobes(id)
	if #id>0 then
		lua_thread.create(function()
			sampSendChat('������������, �� ������ �� ������������� � ����������!')
			wait(2000)
			sampSendChat('����������, ����������, ���� ���������.')
			wait(2000)
			sampSendChat('/n /pass '..my['id']..' /lic '..my['id']..' /med '..my['id'])
			wait(300)
			sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� {00ff00}Y{ffffff} - ���� �� ������ � {ff0000}N{ffffff} - ���� �� �����', -1)
			while not isKeyJustPressed(VK_Y) and not isKeyJustPressed(VK_N) do wait(0) end
			if isKeyJustPressed(VK_Y) then
				sampSendChat('�������, � ����������� ������ �������!')
				wait(2000)
				local random =
				{
					'��� � ���� ��� �������?',
					'� ����� �� ����������� �����?',
					'��� ����� ��?'
				}
				sampSendChat(random[math.random(0,#random)])
				wait(300)
				sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� {00ff00}Y{ffffff} - ���� �� ������ � {ff0000}N{ffffff} - ���� �� �����', -1)
				while not isKeyJustPressed(VK_Y) and not isKeyJustPressed(VK_N) do wait(0) end
				if isKeyJustPressed(VK_Y) then
					local random =	{'��','��','��'}
					local random2={'��','��','��','��','��'}
					sampSendChat('/n ����������� ��������� ��������: '..random2[math.random(0,#random2)]..', '..random[math.random(0,#random)])
					wait(300)
					sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� {00ff00}Y{ffffff} - ���� �� ������ � {ff0000}N{ffffff} - ���� �� �����', -1)
					while not isKeyJustPressed(VK_Y) and not isKeyJustPressed(VK_N) do wait(0) end
					if isKeyJustPressed(VK_Y) then
						cmd_invite(id)
					elseif isKeyJustPressed(VK_N) then
						sampSendChat('� ���������, �� ��� �� ���������.')
					end
				elseif isKeyJustPressed(VK_N) then
					sampSendChat('� ���������, �� ��� �� ���������.')
				end
			elseif isKeyJustPressed(VK_N) then
				sampSendChat('� ���������, �� ��� �� ���������.')
			end
		end)
	else
		sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� ID ������ (/sobes id)', -1)
	end
end
function imgui.CenterTextColoredRGB(text)
    local width = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, 1000):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(u8(w))
            end
        end
    end
    render_text(text)
end
function cmd_uninvite(arg)
		arg1, arg2 = string.match(arg, "(%d+) (.+)")
				if my['rc'] == '���������� ��' then
				my['teg'] = 'LS | '
		elseif my['rc'] == '���������� ��' then
				 my['teg'] = 'SF | '
		elseif my['rc'] == '���������� ��' then
				my['teg'] = 'LV | '
			end	
	if tonumber(my['rang']) < 8 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg1 == nil or arg1 == "" or arg2 == nil or arg2 == "" then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ � ������� ��� ���� (/uninvite id �������)')
	else
	 lua_thread.create(function()
		sampSendChat('/do � ����� ������� � ��������� �����������.')
		wait(2000)
		sampSendChat('/me ������� ��������� ���� �������������'..(sex.v==0 and '' or '�')..' �������,  , ����� ���� ��������'..(sex.v==0 and '' or '�')..' ���� ������')
		wait(2000)
		sampSendChat('/me ���'..(sex.v and '��' or '��')..' � ������ ������� ������� ����������, �����'..(sex.v==0 and '' or '�')..' �� ������ �����������, ����� ������������'..(sex.v==0 and '' or '�')..' �������')
		wait(1000)
		sampSendChat('/uninvite '..arg1..' '..my['teg']..''..arg2..(' [')..arg1..(']'))
	end)
 end
end
function cmd_invite(arg)
	if tonumber(my['rang']) < 9 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg:match("%d+") ~= arg then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ (/invite id)')
	else
 	lua_thread.create(function()
		sampSendChat('/do � ����� ���� ����. ')
		wait(2000)
		sampSendChat('/me ������� ��������� ���� ������'..(sex.v==0 and '' or '�')..' ����, ����� ������'..(sex.v==0 and '' or '�')..' ������ ����� ����� ')
		wait(2000)
		sampSendChat('/me ������'..(sex.v==0 and '' or '�')..' �� ����� �����, ����� ���� ��������'..(sex.v==0 and '' or '�')..' ��� ���� �������� ��������. ')
		wait(1000)
		sampSendChat('/invite '..arg)
	end)
 end
end
function cmd_rang(arg)
	if tonumber(my['rang']) < 9 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg:match("%d+") ~= arg then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ (/rang id)')
	else
 	lua_thread.create(function()
		sampSendChat('/do � ����� ���� ����.')
		wait(2000)
		sampSendChat('/me ������� ��������� ���� ������'..(sex.v==0 and '' or '�')..' ����, ����� ������'..(sex.v==0 and '' or '�')..' ������ ����� �������')
		wait(2000)
		sampSendChat('/me ��������'..(sex.v==0 and '' or '�')..' ����� ������� ���������� ��������, ������'..(sex.v==0 and '' or '�')..' ����')
		wait(1000)
		sampSendChat('/rang '..arg)
		end)
 end
end	
function cmd_fwarn(arg)
	arg1, arg2 = string.match(arg, "(%d+) (.+)")
				if my['rc'] == '���������� ��' then
				my['teg'] = 'LS | '
		elseif my['rc'] == '���������� ��' then
				 my['teg'] = 'SF | '
		elseif my['rc'] == '���������� ��' then
				my['teg'] = 'LV | '
			end	
	if tonumber(my['rang']) < 8 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg1 == nil or arg1 == "" or arg2 == nil or arg2 == "" then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ � ������� ��� ���� (/fwarn id �������)')
	else
		lua_thread.create(function()
		sampSendChat('/do � ����� ������� � ��������� �����������.')
		wait(2000)
		sampSendChat('/me ������� ��������� ���� �������������'..(sex.v==0 and '' or '�')..' ���, ����� ���� ��������'..(sex.v==0 and '' or '�')..' ���� ������')
		wait(2000)
		sampSendChat('/me ���'..(sex.v==0 and '��' or '��')..' � ������ ������� ������� ����������, �����'..(sex.v==0 and '' or '�')..' �� ������ ��������, ����� ������������'..(sex.v==0 and '' or '�')..' �������')
		wait(1000)
		sampSendChat('/fwarn '..arg1..' '..my['teg']..''..arg2..(' [')..arg1..(']'))
		end)
	end
end
function cmd_ka(arg)
	arg1, arg2 = string.match(arg, "(%d+) (.+)")
				if my['rc'] == '���������� ��' then
				my['teg'] = 'LS | '
		elseif my['rc'] == '���������� ��' then
				 my['teg'] = 'SF | '
		elseif my['rc'] == '���������� ��' then
				my['teg'] = 'LV | '
			end	
	if tonumber(my['rang']) < 8 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg1 == nil or arg1 == "" or arg2 == nil or arg2 == "" then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ � ������� ��� ���� (/fwarn id �������)')
	else
		lua_thread.create(function()
		sampSendChat('/do � ����� ������� � ��������� �����������.')
		wait(2000)
		sampSendChat('/me ������� ��������� ���� �������������'..(sex.v==0 and '' or '�')..' ���, ����� ���� ��������'..(sex.v==0 and '' or '�')..' ���� ������')
		wait(2000)
		sampSendChat('/me ���'..(sex.v==0 and '��' or '��')..' � ������ ������� ������� ����������, �����'..(sex.v==0 and '' or '�')..' �� ������ ��������, ����� ������������'..(sex.v==0 and '' or '�')..' �������')
		wait(1000)
		sampSendChat('/k '..arg1..' '..my['teg']..''..arg2..(' [')..arg1..(']'))
		end)
	end
end
function cmd_unfwarn(arg)
	arg1, arg2 = string.match(arg, "(%d+) (.+)")
				if my['rc'] == '���������� ��' then
				my['teg'] = 'LS | '
		elseif my['rc'] == '���������� ��' then
				 my['teg'] = 'SF | '
		elseif my['rc'] == '���������� ��' then
				my['teg'] = 'LV | '
			end	
	if tonumber(my['rang']) < 8 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg1 == nil or arg1 == "" or arg2 == nil or arg2 == "" then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ � ������� ��� ���� (/unfwarn id �������)')
	else
		lua_thread.create(function()
		sampSendChat('/do � ����� ������� � ��������� �����������.')
		wait(2000)
		sampSendChat('/me ������� ��������� ���� �������������'..(sex.v==0 and '' or '�')..' ���, ����� ���� ��������'..(sex.v==0 and '' or '�')..' ���� ������')
		wait(2000)
		sampSendChat('/me ���'..(sex.v==0 and '��' or '��')..' � ������ ������� ������� ����������, �����'..(sex.v==0 and '' or '�')..' �� ������ ������ �������, ����� ������������'..(sex.v==0 and '' or '�')..' �������')
		wait(1000)
		sampSendChat('/unfwarn '..arg1..' '..my['teg']..''..arg2..(' [')..arg1..(']'))
		end)
	end
end
function cmd_black(arg)
	if tonumber(my['rang']) < 11 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg:match("%d+") ~= arg then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ (/black id)')
	else 
		lua_thread.create(function()
			sampSendChat('/do � ����� ������� � ��������� �����������.')
			wait(2000)
			sampSendChat('/me ������� ��������� ���� �������������'..(sex.v==0 and '' or '�')..' ���, ����� ���� ��������'..(sex.v==0 and '' or '�')..' ���� ������')
			wait(2000)
			sampSendChat('/me ���'..(sex.v==0 and '��' or '��')..' � ������ ������� ������� ����������, �����'..(sex.v==0 and '' or '�')..' �� ������ �������� � ������ ������, ����� ������������'..(sex.v==0 and '' or '�')..' �������')
			wait(1000)
			sampSendChat('/black '..arg)
		end)
	end
end
function cmd_offblack(arg)
	if tonumber(my['rang']) < 11 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg:match("%d+") ~= arg then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ (/offblack id)')
	else 
		lua_thread.create(function()
			sampSendChat('/do � ����� ������� � ��������� �����������.')
			wait(2000)
			sampSendChat('/me ������� ��������� ���� �������������'..(sex.v==0 and '' or '�')..' ���, ����� ���� ��������'..(sex.v==0 and '' or '�')..' ���� ������')
			wait(2000)
			sampSendChat('/me ���'..(sex.v==0 and '��' or '��')..' � ������ ������� ������� ����������, �����'..(sex.v==0 and '' or '�')..' �� ������ �������� �� ������� ������, ����� ������������'..(sex.v==0 and '' or '�')..' �������')
			wait(1000)
			sampSendChat('/offblack '..arg)
		end)
	end
end
function cmd_setskin(arg)
	if tonumber(my['rang']) < 8 then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ��� ��� �� �������� ������ �������')
	elseif arg:match("%d+") ~= arg then sampAddChatMessage('{ffffff}�{ffcb00} [���������]{ffffff} ������� �������, ����������� ������ id ������ (/setskin id)')
	else
		lua_thread.create(function()
			sampSendChat('/do �� ������ ����� ������ � ��������� �����������.')
			wait(2000)
			sampSendChat('/me �������'..(sex.v==0 and '��' or '���')..' �� ����� �������, ����� ���� ������ �������� ����'..(sex.v==0 and '' or '�')..' ��� � ���� � �������'..(sex.v==0 and '' or '�')..'��� �� �����������')
			wait(2000)
			sampSendChat('/me ������'..(sex.v==0 and '' or '�')..' ������ � �����'..(sex.v==0 and '' or '�')..' ��������� ����� ��� ����������, �������'..(sex.v==0 and '' or '�')..' � �������� ��������')
			wait(2000)
			sampSendChat('/me �������'..(sex.v==0 and '��' or '���')..' �� ������, ����� ���� ������'..(sex.v==0 and '' or '�')..' ��� � �������'..(sex.v==0 and '' or '�')..' �� �����')
			wait(1000)
			sampSendChat('/setskin '..arg)
		end)
	end
end
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('��������� %d �� %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('�������� ���������� ���������.')
                      sampAddChatMessage((prefix..'���������� ���������!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'���������� ������ ��������. �������� ���������� ������..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': ���������� �� ���������.')
            end
          end
        else
          print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

