--[[
Title: Document
Author(s): LiXizhi
Date: 2015/4/27
Desc: The Document object represents the entire MCML document and can be used to access all elements in a page.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/DOM.lua");
local Document = commonlib.gettable("System.Windows.mcml.Document");
local elem = Document:new();
------------------------------------------------------------
]]
local mcml = commonlib.gettable("System.Windows.mcml");

local Document = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.createtable("System.Windows.mcml.Document", {
	-- Returns the domain name for the current document
	domain = nil,
	-- Returns the date and time a document was last modified
	lastModified = nil,
	-- Returns the title of the current document
	title = nil,
	-- Returns the URL of the current document
	URL = nil,
	-- gives direct access to the root mcml object, usually <pe:mcml> 
	body = nil,
	-- text Buffer
	textbuffer_ = nil,
}));

Document:Property("Name", "Document");

-- constructor
function Document:ctor()
end

-- Opens a stream to collect the output from any document.write() or document.writeln() methods
function Document:open()
end

-- Closes an output stream opened with the document.open() method, and displays the collected data
function Document:close()
end

-- Writes HTML expressions or JavaScript code to a document 
-- tricky code: we can call document:write("hello") or document.write("hello"). they are the same. 
-- @param self: string or self.
-- @param code: string
function Document.write(self, code) 
	if(type(self) ~= "table") then
		code = self;
		self = document;
		if(self == nil) then
			self = Document:new(o);
		end
	end
	if(code) then
		if(not self.textbuffer_) then
			self.textbuffer_ = tostring(code);
		else
			self.textbuffer_ = self.textbuffer_..code;
		end
	end
end

-- private: never call this function from MCML script yourself. This function is called automatically.
-- flush all previous write operations to create a node 
-- @return: return nil or the root MCML node containing MCML node contents from previous write functions. The root node name is always "p"
function Document:flush() 
	if(self.textbuffer_~=nil) then
		self.textbuffer_ = "<p>"..self.textbuffer_.."</p>";
		--self.textbuffer_ = ParaMisc.EncodingConvert("", "HTML", self.textbuffer_);
		local xmlRoot = ParaXML.LuaXML_ParseString(self.textbuffer_);
		if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
			local xmlRoot = mcml:createFromXmlNode(xmlRoot);
			return xmlRoot[1];
		end
	end	
end

-- return the page control. document.GetPageCtrl() or document:GetPageCtrl() both works. 
function Document.GetPageCtrl(self)
	if(self == nil) then
		self = document;
	end
	if(self and self.body) then
		return self.body:GetPageCtrl();
	end
end