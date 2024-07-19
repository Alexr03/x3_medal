local loggingLevels = {
    [0] = "^8[ERROR]^7",
    [1] = "^3[WARNING]^7",
    [2] = "^7[INFO]^7",
    [3] = "^2[DEBUG]^7",
    [4] = "^9[TRACE]^7"
}

LoggerFactory = {
    Create = function(prefix, level)
        local self = {
            Prefix = '[' .. prefix .. '] ',
            Level = level
        }

        function self:Info(...)
            if(self.Level >= 2) then
                print(self.Prefix .. loggingLevels[2] .. ": ", ...)
            end
        end

        function self:Debug(...)
            if(self.Level >= 3) then
                print(self.Prefix .. loggingLevels[3] .. ": ", ...)
            end
        end

        function self:Error(...)
            if(self.Level >= 0) then
                print(self.Prefix .. loggingLevels[0] .. ": ", ...)
            end
        end

        function self:Warning(...)
            if(self.Level >= 1) then
                print(self.Prefix .. loggingLevels[1] .. ": ", ...)
            end
        end

        function self:Trace(...)
            if(self.Level >= 4) then
                print(self.Prefix .. loggingLevels[4] .. ": ", ...)
            end
        end

        return self
    end
}
