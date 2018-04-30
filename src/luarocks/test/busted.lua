
local busted = {}

local fs = require("luarocks.fs")
local deps = require("luarocks.deps")
local path = require("luarocks.path")
local dir = require("luarocks.dir")
local queries = require("luarocks.queries")

local unpack = table.unpack or unpack

function busted.detect_type()
   if fs.exists(".busted") then
      return true
   end
   return false
end

function busted.run_tests(test, args)
   if not test then
      test = {}
   end

   local ok, bustedver, where = deps.fulfill_dependency(queries.new("busted"))
   if not ok then
      return nil, bustedver
   end

   local busted_exe
   if test.busted_executable then
      busted_exe = test.busted_executable
   else
      busted_exe = dir.path(path.root_dir(where), "bin", "busted")

      -- Windows fallback
      local busted_bat = dir.path(path.root_dir(where), "bin", "busted.bat")

      if not fs.exists(busted_exe) and not fs.exists(busted_bat) then
         return nil, "'busted' executable failed to be installed"
      end
   end

   if type(test.flags) == "table" then
      -- insert any flags given in test.flags at the front of args
      for i = 1, #test.flags do
         table.insert(args, i, test.flags[i])
      end
   end
   
   local ok, err = fs.execute(busted_exe, unpack(args))
   if ok then
      return true
   else
      return nil, err or "test suite failed."
   end
end


return busted
