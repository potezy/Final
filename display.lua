--reset the screen
function clear_screen(s)
	 for i = 0 , XRES-1 do
	     for k = 0 , YRES -1 do
	     	 s[i][k].red = 0
		 s[i][k].green = 0
		 s[i][k].blue = 0
	     end
	 end
end

function plot(s ,zb,  c , x , y, z)
	 local newy =  math.floor(x) 
	 local newx = math.floor(YRES - y -1) 
	 --if(newy<0 or newx<0 or newy > YRES or newx > XRES) then print(newx , newy) end
	 --print(newx,newy)
	 --x = math.abs(x - XRES)
	 --print(x,y)
	 if (newx >0 and newx<XRES and newy >0 and newy<YRES) then
	    if (z >= zbuffer[newx][newy]) then	 
	      zbuffer[newx][newy] = z 
	      s[newx][newy].red = c.red
	      s[newx][newy].green = c.green
	      s[newx][newy].blue = c.blue
	    end  
	 end
end

--creates the ppm file
function save(s)
	 --print(name)
	 file = io.open("line.ppm" , "w")
	 file:write("P3\n" , XRES , "\n" , YRES , "\n" , MAX_COLOR, "\n")
	 for x = 0, XRES - 1 do
	     for y = 0 , YRES - 1 do
	     	 file:write(s[x][y].red, " " ,s[x][y].green," ",s[x][y].blue ," ")
	     end
	     file:write("\n")
	 end 
	 io.close(file)
	 
end