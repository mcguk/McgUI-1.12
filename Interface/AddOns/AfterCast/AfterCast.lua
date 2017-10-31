-- AfterCast support code
-- 
-- iriel@vigilance-committee.org
---------------------------------------------------------------------------

local lastStop = nil; -- Which event type was the last terminal one

local knownEvents = {
   ["start"] = "Start of cast",
   ["done"] = "End of cast",
   ["fail"] = "Failed cast",
   ["interrupt"] = "Interrupted cast",
   ["delayed"] = "Delated cast (first delay)"
};

local castEvents = {};

local function AfterCast_DoEvent(event)
   if (event == nil) then
      return;
   end

   local eBox = AfterCastEditBox;

   eBox.chatType  = "SAY";
   eBox.chatFrame = DEFAULT_CHAT_FRAME;
   eBox.language  = ChatFrameEditBox.language;

   eBox:SetText(event);

   ChatEdit_SendText(eBox, nil);
end

local function Error(msg)
   DEFAULT_CHAT_FRAME:AddMessage("AfterCast: " .. msg);
end

local StateObject = {
   state = "Init";
   
   Event = function(self, event, args) 
	      local terminal = nil;
	      if ((event ~= "start") and (event ~= "delayed")) then
		 lastStop = event;
		 terminal = true;
	      end
	      local cmd = castEvents[event];
	      if (terminal) then
		 for k,v in pairs(castEvents) do castEvents[k] = nil; end
	      end
	      if (cmd) then
		 AfterCast_DoEvent(cmd);
	      end
	   end;

   ResetState = function(self, eventTable)
		   if (self.state == "Init") then
		      return;
		   end
		   self:ProcessEvent("__INIT__", eventTable);
		   return true;
		end;

   StartTimer = function(self, seconds)
		   --DEFAULT_CHAT_FRAME:AddMessage("  Timer " ..seconds);
		   self.fireAt = GetTime() + seconds;
		   AfterCastFrame:Show();
		end;

   ProcessEvent = function(self, event, eventTable, fireEntry)
		     local oldState = self.state;

		     --Error("State=" .. oldState .. " Event="
		     --.. (event or "nil"));
		     
		     local tbl = eventTable[oldState];
		     if (not tbl) then
			Error("Unexpected state " .. oldState);
			if (oldState == 'Init') then
			   return;
			end
			self.state = "Init";
			return self:ProcessEvent(event, eventTable, true);
		     end
		     
		     if (fireEntry and tbl._ENTRY) then
			tbl._ENTRY(self);
		     end

		     if (not event) then return; end;
		     
		     local func = tbl[event];
		     if (not func) then
			if (event == "__TIMER__") then
			   return;
			end
			func = tbl["*"];
			if (not func) then
			   if (event ~= "__INIT__") then
			      Error("Unexpected event " .. event
				    .. " in " .. oldState);
			   end
			   if (oldState == 'Init') then
			      return;
			   end
			   self.state = "Init";
			   return self:ProcessEvent(event, eventTable, true);
			end
		     end

		     local noConsume = func(self);
		     if (oldState == self.state) then
			-- We're done
			return;
		     elseif (not noConsume) then
			event = nil;
		     end
		     return self:ProcessEvent(event, eventTable, true);
		  end;
}


-- each entry function is called as:
--
-- noConsume = func(stateObject)
--
-- stateObject.state = .. <set new state>
-- stateObject:Event(event, args) = Dispatch event
-- stateObject:StartTimer(seconds) = Schedule __TIMER__ event

local TRANSITION_TABLE = {
   Init = {
      _ENTRY = function(self)
		  self.isDelayed = false;
	       end,
		  
      SPELLCAST_STOP = function(self)
			  -- Instant cast
			  self:Event("start", "Instant")
			  self:Event("done")
		       end,

      SPELLCAST_FAILED = function(self)
			    -- Failed cast
			    self:Event("fail")
			 end,

      SPELLCAST_START = function(self)
			    -- Normal cast
			   self:Event("start", arg1)
			   self.state = "NormalCast";
			end,

      SPELLCAST_CHANNEL_START = function(self)
				   -- Channeled cast
				   self:Event("start", arg2)
				   self.state = "ChannelCast";
				end,

      ["*"] = function(self) end;
   },

   NormalCast = {
      SPELLCAST_STOP = function(self)
			  -- Cast ended for some reason
			  self.state = "StopOrInterrupt";
		       end,

      SPELLCAST_DELAYED = function(self)
			     -- Delay during cast
			     if (not self.isDelayed) then
				self.isDelayed = true;
				self:Event("delayed");
			     end
			  end,

      SPELLCAST_FAILED = function(self)
			    -- Failed during cast (target death?)
			    self:Event("Failed");
			    self.state = "Init";
			 end,
   },

   StopOrInterrupt = {
      _ENTRY = function(self) 
		  self:StartTimer(1.0);
	       end,
      SPELLCAST_INTERRUPTED = function(self)
				 -- Interrupted normal cast
				 self:Event("interrupt");
				 self.state = "Init";
			      end,
      __TIMER__ = function(self)
		     -- Normal termination
		     self:Event("done");
		     self.state = "Init";
		  end,
      ["*"] = function(self)
		 -- Normal termination
		 self:Event("done");
		 self.state = "Init";
		 return true; -- No consume
	      end,
   },

   ChannelCast = {
      SPELLCAST_STOP = function(self) end,
      
      SPELLCAST_DELAYED = function(self)
			     -- Delay during cast
			     if (not self.isDelayed) then
				self.isDelayed = true;
				self:Event("delayed");
			     end
			  end,

      SPELLCAST_CHANNEL_STOP = function(self)
				  -- Cast ended for some reason
				  self.state = "ChannelStopOrInterrupt";
			       end,

      SPELLCAST_FAILED = function(self)
			    -- Failed during channel (target death?)
			    self:Event("Failed");
			    self.state = "Init";
			 end,
   },

   ChannelStopOrInterrupt = {
      _ENTRY = function(self) 
		  self:StartTimer(1.0);
	       end,

      __TIMER__ = function(self)
		     -- Normal termination
		     self:Event("interrupt");
		     self.state = "Init";
		  end,

      SPELLCAST_STOP = function(self)
		     -- Normal termination
		     self:Event("done");
		     self.state = "Init";
		  end,

      ["*"] = function(self)
		 -- Normal termination
		 self:Event("interrupt");
		 self.state = "Init";
		 return true; -- No consume
	      end,
   }
}

local function ShowArg(label,value)
   if (value ~= nil) then
      DEFAULT_CHAT_FRAME:AddMessage("[" .. label .. "] " .. value);
   end
end

function AfterCast_OnUpdate(interval)
   local at = StateObject.fireAt;
   if (not at) then
      this:Hide();
      return;
   end
   if (GetTime() < at) then
      return;
   end
   this:Hide();
   StateObject.fireAt = nil;
   StateObject:ProcessEvent("__TIMER__", TRANSITION_TABLE);
end

function AfterCast_OnEvent(event)
   -- ShowArg("event", event);
   -- ShowArg("time", GetTime());
   StateObject:ProcessEvent(event, TRANSITION_TABLE);
end

function AfterCast(doneEvent,failEvent)
   StateObject:ResetState(TRANSITION_TABLE);
   for k,v in pairs(castEvents) do castEvents[k] = nil; end
   castEvents["done"] = doneEvent;
   castEvents["fail"] = failEvent;
end

function AfterCastOn(type, event)
   if (StateObject:ResetState(TRANSITION_TABLE)) then
      for k,v in pairs(castEvents) do castEvents[k] = nil; end
   end
   castEvents[type] = event;
end

function AfterCastLastStop(clearFlag)
   local ret = lastStop;
   if (clearFlag) then
      lastStop = nil;
   end
   return ret;
end

local function AfterCast_Command(msg)
   local err = nil;
   local s,e,etype,event = string.find(msg, "^%s*[+]([^%s]+)%s+(.*)$");
   if (s) then
      etype = string.lower(etype);
      if (knownEvents[etype]) then
	 AfterCastOn(etype, event);
	 return;
      else
	 err = true;
	 DEFAULT_CHAT_FRAME:AddMessage("AfterCast: Invalid event type '" .. etype .. "'");
      end
   end

   if (not err) then
      s,e,event = string.find(msg, "^%s*([^%s+].*)$");
      if (s) then
	 AfterCast(event);
	 return;
      end;
   end

   DEFAULT_CHAT_FRAME:AddMessage("AfterCast: [+eventType] <command>");
   local etlist = "";
   for k, v in pairs(knownEvents) do
      if (etlist ~= "") then
	 etlist = etlist .. ", ";
      end
      etlist = etlist .. k;
   end
   DEFAULT_CHAT_FRAME:AddMessage("           eventTypes: " .. etlist);
end

function AfterCast_OnLoad()
   this:RegisterEvent("SPELLCAST_CHANNEL_START");
   this:RegisterEvent("SPELLCAST_CHANNEL_UPDATE");
   this:RegisterEvent("SPELLCAST_CHANNEL_STOP");
   this:RegisterEvent("SPELLCAST_DELAYED");
   this:RegisterEvent("SPELLCAST_FAILED");
   this:RegisterEvent("SPELLCAST_INTERRUPTED");
   this:RegisterEvent("SPELLCAST_START");
   this:RegisterEvent("SPELLCAST_STOP");

   SLASH_AFTERCAST1 = "/aftercast";
   SlashCmdList["AFTERCAST"] =
      function(msg)
	 AfterCast_Command(msg);
      end
end

function AfterCastDebug()
   for k, v in pairs(knownEvents) do
      AfterCastOn(k, "/script ChatFrame1:AddMessage(\"" .. k .. "\")");
   end
end
