local command = ...

os.execute(command)

love.thread.getChannel('info'):push("finished")
print("[thread] closed")

-- C:\Users\leobe\AppData\Roaming\pico-8\appdata\test_printh
-- local pipe = io.popen(command)
-- if not pipe then
--     print("Cannot popen file")
--     return
-- end
-- local data = pipe:read("*a")
-- print("[thread] data = '" .. data .. "'")
-- love.thread.getChannel('info'):push(data)
-- print("[thread] closed file")
-- pipe:close()


-- local pipe = io.popen'ping google.com'
-- for line in pipe:lines() do
-- 	print(line)
-- end
-- pipe:close()