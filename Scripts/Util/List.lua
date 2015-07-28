
List = {};
List.__index = List;

function List.new()
	local p = {length = 0,pre = nil,next = nil,obj=nil};
	setmetatable(p,List);
	return p;
end

function List:addObject(obj)
	local p = {};
	p.pre = nil;
	p.obj = obj;
	p.next = nil;
	setmetatable(p,List);
	self.length = self.length+1;
	local temp = self;
	if(self.next == nil)then
		p.pre = temp;
		temp.next = p;
		return;
	end
	while temp.next ~= nil do
		temp = temp.next;
		if(temp.next == nil)then--最后一个元素 
			temp.next = p;
			p.pre = temp;
			break;
		end
	end
end

function List:Length()
	return self.length;
end

function List:removeObject(obj)
	local temp = self;
	while temp.next ~=nil do
		local object = temp.next;
		if(obj == object)then
			if(object.next ~= nil)then
				temp.next = object.next;--
				object.next.pre = temp;
			else
				temp.next = nil;
			end
			self.length = self.length-1;
			break;
		else
			temp = temp.next;
		end
	end
end

function List:containObject(obj)
	local temp = self;
	while temp.next ~=nil do
		local object = temp.next;
		if(obj == object)then
			return true;
		end
		temp = temp.next;
	end
	return false;
end

function List:getObject(index)
	if(index > self.length)then
		CCLuaLog("index outof range");
		return nil;
	end
	local ticker = 0;
	local temp = self;
	while temp.next ~= nil do
		local object = temp.next;
		temp = temp.next;
		ticker = ticker + 1;
		if(ticker == index)then
			return object;
		end
	end
	return nil;
end

function List:getObjectIndex(obj)
	local temp = self;
	local index = 0;
	while temp.next ~= nil do
		local object = temp.next;
		index = index + 1;
		if(obj == object)then
			return index;
		end
		temp = temp.next;
	end
	return 0;
end

function List:hasNext()
	if(self.next ~= nil)then
		return true;
	end
	return false;
end

function List:nextObj()
	return self.next;
end