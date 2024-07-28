---@class TwitchCollector
---@field vote_score { [string]: number }
---@field vote_variants string[]
---@field users { [string]: { [string]: number } }
---@field single_use { [string]: boolean }
---@field can_collect { [string]: boolean }
---@field channel_name string?
---@field socket wsclient?
---@field connection_status integer
---@field STATUS table<string, integer>
TwitchCollector = {}
TwitchCollector.__index = TwitchCollector

---@return TwitchCollector
function TwitchCollector.new()
    local collector = {
        --- List of usernames who use commands
        --- @type { [string]: { [string]: number } }
        users = {},

        --- Can user use commands more than one time
        --- @type { [string]: boolean }
        single_use = {},

        --- Can collector process commands
        --- @type { [string]: boolean }
        can_collect = {},

        --- Twitch channel name connected to
        --- @type string?
        channel_name = nil,

        --- Web socket connected to twitch chat
        --- @type table?
        socket = nil,

        --- Connection status
        --- @type integer
        connection_status = 0,

        STATUS = {
            NO_CHANNEL_NAME = -1,
            DISCONNECTED = 0,
            CONNECTING = 1,
            CONNECTED = 2,
        }
    }

    setmetatable(collector, TwitchCollector)
    return collector;
end

--- Called every time when message is collected
--- @param username string Twitch username
--- @param message string Message content
function TwitchCollector:onmessage(username, message)
end

--- Called when socket is closed
function TwitchCollector:ondisconnect()
end

--- Called when connection status is changed
--- @param status integer New status
function TwitchCollector:onnewconnectionstatus(status)
end

function TwitchCollector:set_connection_status(status)
    if self.connection_status ~= status then
        self.connection_status = status
        self:onnewconnectionstatus(status)
    end
end

--- Connect to Twitch chat
--- @param channel_name string Channel name
--- @param silent boolean? Supress onclose event
function TwitchCollector:connect(channel_name, silent)
    local selfRef = self

    if selfRef.socket then
        -- Ignore this event
        if silent then
            function selfRef.socket:onclose() end
        end

        selfRef.socket:close()
    end

    selfRef.channel_name = channel_name

    if not channel_name or channel_name == '' then
        print('Connecting to [nothing]')
        return selfRef:set_connection_status(selfRef.STATUS.NO_CHANNEL_NAME)
    end
    print('Connecting to ' .. channel_name)

    local socket = WebSocket.new("irc-ws.chat.twitch.tv", 80, '/')

    function socket:onmessage(message)
        if string_starts(message, ":justinfan13847!justinfan13847@justinfan13847.tmi.twitch.tv JOIN #") then
            selfRef:set_connection_status(selfRef.STATUS.CONNECTED)
            return
        end
        local display_name = message:match("display%-name=([^;]+)")
        local privmsg_content = message:match("PRIVMSG #" .. channel_name .. " :(.+)")
        if display_name and privmsg_content then
            selfRef:onmessage(display_name, privmsg_content:sub(1, -3))
        end
    end

    function socket:onopen()
        selfRef:set_connection_status(selfRef.STATUS.CONNECTING)
        socket:send("CAP REQ :twitch.tv/tags twitch.tv/commands")
        socket:send("PASS SCHMOOPIIE")
        socket:send("NICK justinfan13847")
        socket:send("USER justinfan13847 8 * :justinfan13847")
        socket:send("JOIN #" .. channel_name)
    end

    function socket:onclose(code, reason)
        selfRef:ondisconnect()
        selfRef.socket = nil
        selfRef:set_connection_status(selfRef.STATUS.DISCONNECTED)
    end

    selfRef.socket = socket
end

--- Disconnect
--- @param silent boolean? Supress onclose event
function TwitchCollector:disconnect(silent)
    if self.socket then
        if silent then
            function self.socket:onclose() end
        end
        self.socket:close()
    end
    self.socket = nil
    self:set_connection_status(self.STATUS.DISCONNECTED)
end

--- Reconnect
function TwitchCollector:reconnect()
    self:connect(self.channel_name, true)
end

--- Update socket status. Should be called inside `love.update()`
function TwitchCollector:update()
    if self.socket then self.socket:update() end
end
