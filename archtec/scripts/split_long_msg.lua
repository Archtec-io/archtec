
local old_chat_send_player = minetest.chat_send_player

function minetest.chat_send_player(name, text)
	if #text > 65000 then
        old_chat_send_player("Message blocked because it's to long!")
	end

	if #text > 0 then
		old_chat_send_player(name, text)
	end
end

local old_chat_send_all = minetest.chat_send_all

function minetest.chat_send_all(text)
	if #text > 65000 then
        old_chat_send_player("Message blocked because it's to long!")
	end

	if #text > 0 then
		old_chat_send_all(text)
	end
end