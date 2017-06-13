--globals
XRES = 500
YRES = 500
step = .1
MAX_COLOR = 255

zbuffer = {{}}
for i = 1, XRES do
    zbuffer[i] = {}
    for k = 1, YRES do
    	zbuffer[i][k] = -100000000
    end
end

--print(zbuffer[4][4])

poly_matrix = {{},{},{},{}}

function add_box(x , y , z , width , height, depth)
	 local x1,y1,z1
	 x1 = x + width
	 y1 = y - height
	 z1 = z - depth
	 --front
  	 add_polygon(poly_matrix, x, y, z, x1, y1, z, x1, y, z)
  	 add_polygon(poly_matrix, x, y, z, x, y1, z, x1, y1, z)
  
	 --back
  	 add_polygon(poly_matrix, x1, y, z1, x, y1, z1, x, y, z1)
  	 add_polygon(poly_matrix, x1, y, z1, x1, y1, z1, x, y1, z1)
  
	 --right side
  	 add_polygon(poly_matrix, x1, y, z, x1, y1, z1, x1, y, z1)
  	 add_polygon(poly_matrix, x1, y, z, x1, y1, z, x1, y1, z1)

  	 --left side
  	 add_polygon(poly_matrix, x, y, z1, x, y1, z, x, y, z)
  	 add_polygon(poly_matrix, x, y, z1, x, y1, z1, x, y1, z)
  
	 --top
  	 add_polygon(poly_matrix, x, y, z1, x1, y, z, x1, y, z1)
  	 add_polygon(poly_matrix, x, y, z1, x, y, z, x1, y, z)

  	 --bottom
  	 add_polygon(poly_matrix, x, y1, z, x1, y1, z1, x1, y1, z)
  	 add_polygon(poly_matrix, x, y1, z, x, y1, z1, x1, y1, z1)
end

function add_polygon(matrix,x0,y0,z0, x1,y1,z1, x2,y2,z2,c)
	 local temp = sizeOf(matrix[1])
	 addPoint(matrix, x0,y0,z0)
	 addPoint(matrix, x1,y1,z1)
	 addPoint(matrix, x2,y2,z2)
end

function vertices(x0,x1,x2,y0,y1,y2,z0,z1,z2)
	 local top,mid,bot
	 if (y0>=y1 and y0>=y2) then
	    top = {x0,y0,z0}
	    if (y1 >= y2) then
	       mid = {x1,y1,z1}
	       bot = {x2,y2,z2}
	    else
	       mid = {x2,y2,z2}
	       bot = {x2,y1,z1}
	    end

	 elseif (y1>=y2 and y1>=y0) then	
	    top = {x1,y1,z1}
	    if (y0 >= y2) then
	       mid = {x0,y0,z0}
	       bot = {x2,y2,z2}
	    else
	       mid = {x2,y2,z2}
	       bot = {x0,y0,z0} 		
	    end

	 else
	    top = {x2,y2,z2}
	    if (y0 >= y1) then
	       mid = {x0,y0,z0} 
	       bot = {x1,y1,z1}
	    else 
	       mid = {x1,y1,z1}
	       bot = {x0,y0,z0}	    
	    end

	  end
	  --print("bot:",bot[1],bot[2], "\nmid:",mid[1],mid[2], "\ntop",top[1],top[2])
	  return bot,mid,top 	 
end

function scan_line( matrix, board,i,c)
	 local x0,x1,x2,y0,y1,y2,z0,z1,z2,bot,top,mid
	 x0 = matrix[1][i]
	 x1 = matrix[1][i+1]
	 x2 = matrix[1][i+2]
	 y0 = matrix[2][i]
	 y1 = matrix[2][i+1]
	 y2 = matrix[2][i+2]
	 z0 = matrix[3][i]
	 z1 = matrix[3][i+1]
	 z2 = matrix[3][i+2]
	 bot,mid,top = vertices(x0,x1,x2,y0,y1,y2,z0,z1,z2)
	 --print(i)
	 local deltaY,dx1,dx0,color, dz
	 if (i > 28) then color = Color:new(0,0,222)
	 else color = Color:new(222,0,0) end
	 color = Color:new(50,7 * i^2 % 255, 100)
	 deltaY = 1
	 
	 --if (i == 25) then print("bot:",bot[1],bot[2],bot[3], "\nmid:",mid[1],mid[2],mid[3], "\ntop",top[1],top[2],top[3]) end

	 if (top[2] - bot[2] == 0) then dx0 = top[1] - bot[1] 
	 else dx0 = (top[1] - bot[1]) / (top[2] - bot[2]) end

	 if (mid[2] - bot[2] == 0) then dx1 = mid[1] - bot[1] 
	 else dx1 = (mid[1] - bot[1]) / (mid[2] - bot[2]) end
	 --dx1 is the shorter side
	 
	 if (top[2] - bot[2] == 0) then dz0 = top[3] - bot[3]
	 else dz0 = (top[3] - bot[3]) / (top[2] - bot[2]) end

	 if (mid[2] - bot[2] == 0) then dz1 = mid[3] - bot[3]
	 else dz1 = (mid[3] - bot[3]) / (mid[2] - bot[2]) end

	 --print(mid[3] , bot[3] , mid[2] , bot[2])	 

	 --top[2] - bot[2] is how many Y values we go up
	 --bot[2] is the beginning Y value max[2] is the end Y value

	 local cx0,cx1,cz0,cz1
 	 if (mid[2] == bot[2]) then cx1 =  mid[1] cz1 = mid[3]
	 else cx1 = bot[1] cz1 = bot[3] end

	 cx0 = bot[1]
	 cz0 = bot[3]
	 --print(bot[1],bot[2])
	 --print(cz0, cz1)
	 for minY = 0, top[2]-bot[2], deltaY do
	     local currY = minY + bot[2]
	     if (currY >= mid[2]) then
	     	if(top[2] - mid[2] == 0) then dx1 = 0 dz1 = 0
		else dx1 = (top[1] - mid[1]) / (top[2] - mid[2]) dz1 = (top[3] - mid[3]) / (top[2] - mid[2]) end
	     end
	     
	     draw_line(cx0, currY,cz0, cx1, currY,cz1,color,board,zb)   	
	     cx0 = cx0 + dx0
	     cx1 = cx1 + dx1
	     cz0 = cz0 + dz0
	     cz1 = cz1 + dz1
	     --print(dz0 , dz1)
	 end 
end

function draw_polygons(matrix,board,c)
	  for i = 1, sizeOf(matrix[1]) ,3 do
	      n = backface_cull(matrix[1][i],matrix[2][i],matrix[3][i], matrix[1][i+1],matrix[2][i+1],matrix[3][i+1],matrix[1][i+2],matrix[2][i+2],matrix[3][i+2]) 
	      if (n > 0) then  
	      --print(n , i)
	      --print("scanning line", i)
	      --scan_line(matrix,board,i)
	      --[[ 
	      draw_line(matrix[1][i],
			matrix[2][i],
	   		matrix[1][i+1],
	   		matrix[2][i+1],
			color,board)

	      draw_line(matrix[1][i+1],
			matrix[2][i+1],
	   		matrix[1][i+2],
	   		matrix[2][i+2],
			color,board)

	      draw_line(matrix[1][i+2],
			matrix[2][i+2],
	   		matrix[1][i],
	   		matrix[2][i],
			color,board)	
			]]--
		scan_line(matrix,board,i,c)	
	 end

	 end
end

--object to store color
Color = {red = 0, green = 0 , blue = 0}

--constructors 
function Color:new ( r , g ,b )
	 local color = {}
	 setmetatable(color , self)
	 self.__index = self 
	 self.red = r 
	 self.green = g
	 self.blue = b
	 return color
end

--create the array to store pixels 
board = {}
for i = 0, XRES-1 do
    board[i] = {}
    for k = 0, YRES -1 do
    	board[i][k] = Color:new(0,0,0)
    end
end



--function to draw line
function draw_line(x0 , y0, z0 , x1, y1 ,z1 , c , s ,zb)
	 local x,y,d,A,B
	 local dy_east, dy_northeast, dx,east ,dx_northeast, d_east, d_northeast 
	 local loop_start, loop_end
	 local distance , z , dx
	 local xt,yt
	 local dz
	 if (x0>x1) then
	    xt = x0
	    yt = y0
	    z = z0
	    x0 = x1
	    y0 = y1
	    z0 = z1
	    x1 = xt
	    y1 = yt
	    z1 = z
	 end
	 
	 x = x0
	 y = y0
	 z = z0
	 A = 2 * (y1 - y0)
	 B = -2 * (x1 - x0)
	 local wide, tall = 0,0
	 --octant 1 and 8
	 --print(z1,z0 ,dz)
	 if (math.abs(x1-x0) >= math.abs(y1-y0)) then
	    wide = 1
	    loop_start = x
	    loop_end = x1
	    dx_east, dx_northeast = 1,1
	    dy_east = 0
 	    d_east = A
    	    distance = x1 - x
	    if (x1 - x0 == 0) then dz = (z1 - z0)
	    else dz = (z1 - z0) / (x1 - x0) end
    	    if ( A > 0 ) then --octant 1
      	        d = A + B/2
      		dy_northeast = 1
      		d_northeast = A + B
	    else
		d = A - B/2
		dy_northeast = -1
		d_northeast = A + B
	    end
	 
	 --octant 2 and 7
	 else
	    if (y1 - y0 == 0) then dz = (z1 - z0)
	    else dz = (z1 - z0) / (y1 - y0) end
	    tall = 1
	    dx_east = 0
	    dx_northeast = 1
	    distance = math.abs(y1-y)
	    if (A > 0) then
	       d = A/2 + B
	       dy_east , dy_northeast = 1,1
	       d_northeast = A + B
	       d_east = B
	       loop_start = y
	       loop_end = y1
	    else
	       d = A/2 - B
	       dy_east , dy_northeast = -1,-1
	       d_northeast = A - B
	       d_east = -1 * B
	       loop_start = y1
	       loop_end = y
	    end
	  end
	  while ( loop_start < loop_end) do
	  	plot(s,zb,c,x,y,z)
		if ((wide and ((A > 0 and d > 0) or 
		   	       (A < 0 and d < 0)))
	            or 
		    (tall and ((A > 0 and d < 0) or
		    	       (A < 0 and d > 0) ))) then
	       	   y = y + dy_northeast
		   d = d + d_northeast
		   x = x + dx_northeast
		   z = z + dz
		else
		   x = x + dx_east
		   d = d + d_east
		   y = y + dy_east
		   z = z + dz
		end
		loop_start = loop_start +1
	 end 	
	 plot(s , zb , c , x1 , y1 , z)
end


function draw(board, eMatrix)
	 for i = 1 , sizeOf(eMatrix[1]) , 2 do
	     local x1 = math.floor(eMatrix[1][i])
	     local x2 = math.floor(eMatrix[1][i+1])
	     local y1 = math.floor(eMatrix[2][i])
	     local y2 = math.floor(eMatrix[2][i+1])
	     --print(x1,y1,x2,y2)
	     color = Color:new((x1+x2)%255, (y1+y2)%255, (x1+x2+y1+y2)%255)
	     draw_line(x1,y1,x2,y2,color,board)
	 end
	 
	 --printMatrix(eMatrix)
end

function addPoint(matrix, x,y,z)
	 table.insert(matrix[1],x) 	 
	 table.insert(matrix[2],y)
	 table.insert(matrix[3],z)
	 table.insert(matrix[4],1)
end

function addEdge(matrix, x1,y1,z1,x2,y2,z2)
	 addPoint(matrix,x1,y1,z1)
	 addPoint(matrix,x2,y2,z2)
end

function add_curve(x0,y0,x1,y1,x2,y2,x3,y3,t)
	 local xcoef,ycoef,xcor0,ycor0,xcor1,ycor1
	 xcoef , ycoef = coef(x0,y0,x1,y1,x2,y2,x3,y3,t)
	 xcor0 = xcoef[4][1]
	 ycor0 = ycoef[4][1]
	 for t = 0, 1 ,step do
	     xcor1 = xcoef[1][1] * t^3 + xcoef[2][1] * t^2 +xcoef[3][1] *t + xcoef[4][1]
	     ycor1 = ycoef[1][1] * t^3 + ycoef[2][1] * t^2 +ycoef[3][1] *t + ycoef[4][1]
	     addEdge(eMatrix, xcor0,ycor0,0,xcor1,ycor1,0)
	     xcor0 = xcor1
	     ycor0 = ycor1
	 end
end

function circle(cx , cy , cz , r)
	 --print("potato")
	 local step = .01
	 local xcor, ycor, xcor0, ycor0
	 xcor0 = r + cx --first point
	 ycor0 = cy     --first point
	 for t = 0, 1+step, step do
	     theta = 2 * pi * t
	     xcor1 = r * cos(theta) + cx
	     ycor1 = r * sin(theta) + cy
	     addEdge(eMatrix, xcor0 , ycor0 , 0 , xcor1 , ycor1, 0)
	     ycor0 = ycor1
	     xcor0 = xcor1
	 end
	 
end

function add_sphere(cx , cy , cz , r )
	 local sphere_points,num_steps, x0 , y0 , z0 ,x1,y1,z1,x2,y2,z2,x3,y3,z3
	 sphere_points = generate_sphere(cx,cy,cz,r)
	 ss = sizeOf(sphere_points[1])

	 num_steps = 1/step 
	 local lat, longt = 0,0
	 for i = 0, num_steps -1  do
	     lat = lat +1
	     for l = 0, num_steps-1  do
	     	 local index = i * num_steps + l +1
		 index = math.floor(index)
		 --print(index)
		 longt = longt +1
		 add_polygon( poly_matrix,
			      sphere_points[1][index],
			      sphere_points[2][index],
			      sphere_points[3][index],
			      sphere_points[1][index +1],
			      sphere_points[2][index +1],
			      sphere_points[3][index +1],
			      sphere_points[1][index + num_steps +1],
			      sphere_points[2][index + num_steps +1],
			      sphere_points[3][index + num_steps +1])
	         add_polygon( poly_matrix,
		 	      sphere_points[1][index],
			      sphere_points[2][index],
			      sphere_points[3][index],
			      sphere_points[1][index +1 +num_steps],
			      sphere_points[2][index +1 +num_steps],
			      sphere_points[3][index +1 +num_steps],
			      sphere_points[1][index +num_steps], 	
			      sphere_points[2][index +num_steps],
			      sphere_points[3][index +num_steps])
			     
	      end
          end
	  
	  for longt = 1, num_steps  do
	      index = lat * num_steps + longt 
	      index = math.floor(index)
	      add_polygon( poly_matrix,           
	      		    sphere_points[1][index],
			    sphere_points[2][index],
			    sphere_points[3][index],
			    sphere_points[1][index +1],
			    sphere_points[2][index +1],
			    sphere_points[3][index +1],
			    sphere_points[1][longt+1],
			    sphere_points[2][longt+1],
			    sphere_points[3][longt+1])
	      add_polygon( poly_matrix,
	      		   sphere_points[1][index],
			   sphere_points[2][index],
			   sphere_points[3][index],
			   sphere_points[1][longt+1],
			   sphere_points[2][longt+1],
			   sphere_points[3][longt+1],
			   sphere_points[1][longt],
			   sphere_points[2][longt],
			   sphere_points[3][longt])
               end
end

function generate_sphere(cx , cy , cz , r)
         local rot,rotation,circlec,circ,x,y,z,num_steps, point_matrix
         point_matrix = makeMatrix(4,0)
	 local i = 0
	 num_steps = (1/step )
         for rotation = 0, num_steps-1, 1 do
	     rot = rotation/num_steps
             for circlec = 0, num_steps -1, 1 do
	     	 circ = circlec/num_steps 
                 x = r * cos(circ * pi) + cx
                 y = r * sin(circ * pi) * cos(rot * 2 * pi) + cy
                 z = r * sin(circ * pi) * sin(rot * 2 * pi) + cz
                 addPoint(point_matrix, x,y,z)
		 i = i +1
             end
	     --print(i)
         end
         return point_matrix
end



function add_torus(cx , cy , cz , r1 , r2)
	 local tPoints,x0,x1,x2,x3,y0,y1,y2,y3,z0,z1,z2,z3,size,lat,longt,num_steps
	 tPoints = generate_torus(cx,cy,cz,r1,r2)
	 num_steps = 1/step
	 for lat = 0, num_steps -1 do
	     for longt = 0, num_steps-1  do
	     	 local index = lat * num_steps +longt
		 add_polygon( poly_matrix,
		 	      tPoints[1][index],
			      tPoints[2][index],
			      tPoints[3][index],
			      tPoints[1][index +1],
			      tPoints[2][index +1],
			      tPoints[3][index +1],
			      tPoints[1][index + num_steps],
			      tPoints[2][index + num_steps],
			      tPoints[3][index + num_steps])
	         add_polygon( poly_matrix,
		 	      tPoints[1][index +1 +num_steps],
			      tPoints[2][index +1 +num_steps],
			      tPoints[3][index +1 +num_steps],
			      tPoints[1][index + num_steps],
			      tPoints[2][index + num_steps],
			      tPoints[3][index + num_steps],
			      tPoints[1][index +1],
			      tPoints[2][index +1],
			      tPoints[3][index +1])
	     end 		      
	 end
	 
end

function generate_torus(cx , cy , cz , r1 , r2)
	 local rot,circ,x,y,z, torus_points,r,c
	 torus_points = makeMatrix(4,0)
	 num_steps = math.floor(1/step +.1)
	 local i = 0 
	 for r = 0, num_steps do
	     rot = r /num_steps
	     for c = 0, num_steps -1 do
	     	 circ = c/num_steps
	     	 x = cos(rot * 2 * pi) * (r1 * cos(circ * 2 * pi) + r2) + cx
		 y = r1 * sin(circ * 2 * pi) + cy
		 z = -1 * sin(rot * 2 * pi) * (r1 * cos(circ * 2 * pi) + r2) + cz
		 addPoint(torus_points, x ,y ,z)
	      end
	   --   print(i)
	 end
	 --print(i)
	 return torus_points
end

function backface_cull(x0,y0,z0,x1,y1,z1,x2,y2,z2)
	 local dx0,dx1,dy1,dy0,n
	 dx0 = x1-x0
	 dx1 = x2-x0
	 dy1 = y2-y0
	 dy0 = y1-y0
	 n = dx0*dy1 - dy0*dx1 
	 return n
end
