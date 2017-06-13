
function sizeOf(matrix)
	 local size = 0
	 for _ in pairs(matrix) do size = size + 1 end
	 return size
end

function string:split(sep) --credit to lua user manual
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
 end

function make_int(matrix)
	 for i = 1, sizeOf(matrix)+1 do
	     matrix[i] = tonumber(matrix[i])
	     --print(i)
	 end
	 return matrix
end

function parseFile(f)
	 local lines,s,n,lstack,sizeL,top,temp = {},0,"pic.png"
	 local basename, frames = 0,1
	 lstack = new_stack()

	 for line in io.lines(f) do
	     table.insert(lines, line)
	     s = s + 1
	 end

	 --first pass
	 for i = 1, s do
	     ln = lines[i]:split(" ")
	     if (ln[1] == "basename") then basename = ln[2]
	     elseif (ln[1] == "frames") then frames = tonumber(ln[2])
	     elseif (ln[1] == "move") then
	     	    if (ln[5]) then print(ln[5]) end
	     
	     elseif (ln[1] == "scale") then
	     	    if (ln[5]) then print(ln[5]) end
	     
	     elseif (ln[1] == "rotate") then
	     	    if (ln[4]) then print(ln[4]) end
	     end
	 end

	 local framesMatrix = {}
	 for i = 1 , frames do
	     framesMatrix[i] = {}
	     --print(i)
	 end

	 local knobs = {}
	 

	 --second pass
	 local start_frame, end_frame
	 local start_value, end_value, delta
	 local curr
	 for i = 1 , s do
	     ln = lines[i]:split(" ")
	     if (ln[1] == "vary") then
	     	start_frame = ln[3]
		end_frame = ln[4]
		start_value = ln[5]
		end_value = ln[6]
		delta = (end_value - start_value) / (end_frame - start_frame)
		
		for k = 1, frames do
		    if k == start_frame then framesMatrix[k][ln[2]] = start_value
		    else framesMatrix[k][ln[2]] = start_value + (k - start_frame) * delta
		    end  
		     
		end    	
		
		
             end
	 end
	 
	 local xval, yval, zval, theta
	 for k = 1 , frames  do 
	 --print(k)	 
	 for i = 1, s do 
	     top = lstack[sizeOf(lstack)]
	     ln = lines[i]:split(" ")

	     if (ln[1] == "line") then
	     	addEdge(eMatrix, ln[2],ln[3],ln[4],ln[5],ln[6],ln[7])
		matrixMult(top , eMatrix)
		draw(board,eMatrix)
		eMatrix = makeMatrix(4,0)		

	     elseif (ln[1] == "ident") then
	     	    identify(tMatrix)
	
	     elseif (ln[1] == "scale") then
	     	    xval = ln[2]
		    yval = ln[3]
		    zval = ln[4]
		    
		    temp = scale(xval, yval, zval)
		    top =matrixMult(top,temp)
		    lstack[sizeOf(lstack)] = top		    

	     elseif (ln[1] == "move") then
		    xval = ln[2]
		    yval = ln[3]
		    zval = ln[4]
		    		    

	     	    temp = translate(xval, yval, zval)	
		    top = matrixMult(top,temp)		    		    	      
		    lstack[sizeOf(lstack)] = top		    

	     elseif (ln[1] == "rotate") then
	     	    xval = ln[2]
		    theta = math.rad(ln[3])



	     	    temp = rotate(xval, theta)
		    top = matrixMult(top,temp)		   	
		    lstack[sizeOf(lstack)] = top		    

             elseif (ln[1] == "apply") then
	     	    eMatrix = matrixMult(tMatrix, eMatrix)
		    poly_matrix = matrixMult(tMatrix,poly_matrix)	

	     elseif (ln[1] == "save") then
		    save(board)
		    n = ln[2]
		    os.execute("convert line.ppm " .. n) 
	
	     elseif (ln[1] == "display") then
	     	    save(board)
	     	    local a = "display line.ppm" 
		    print(a)
	     	    os.execute(a) 
	
	     elseif (ln[1] == "circle") then
		    circle(ln[2], ln[3], ln[4], ln[5])	
		    eMatrix =matrixMult(top,eMatrix)
		    draw(board,eMatrix)
		    eMatrix = makeMatrix(4,0)	    	    

	     elseif (ln[1] == "hermite" or ln[1] == "bezier") then
		    add_curve(ln[2],ln[3],ln[4],ln[5],ln[6],ln[7],ln[8],ln[9], ln[1])
		    eMatrix =matrixMult(top,eMatrix)
		    draw(board, eMatrix)
		    eMatrix = makeMatrix(4,0)		    

	     elseif (ln[1] == "clear") then
	     	    eMatrix = {{},{},{},{}}
		    poly_matrix = makeMatrix(4,0)		    

	     elseif (ln[1] == "sphere") then
		    add_sphere(ln[2],ln[3],ln[4],ln[5])
		    poly_matrix = matrixMult(top,poly_matrix)
		    draw_polygons(poly_matrix,board,4)
		    poly_matrix = makeMatrix(4,0)		    

	     elseif (ln[1] == "torus") then
		    add_torus(ln[2],ln[3],ln[4],ln[5],ln[6])	     	    
		    
		    poly_matrix = matrixMult(top,poly_matrix)
		    draw_polygons(poly_matrix,board,4)
		    poly_matrix = makeMatrix(4,0)

	     elseif (ln[1] == "box") then
		    --print(args[6])
		    add_box(ln[2],ln[3],ln[4],ln[5],ln[6],ln[7])
		    
		    --printMatrix(poly_matrix)
		    --printMatrix(top)
		    --printMatrix(poly_matrix)

		    poly_matrix = matrixMult(top,poly_matrix)
		    --printMatrix(poly_matrix)
		    draw_polygons(poly_matrix,board,4)		    
		    poly_matrix = makeMatrix(4,0)

             elseif (ln[1] == "push") then
	     	    push(lstack)

	     elseif (ln[1] == "pop") then
	     	    pop(lstack)
	     
	     elseif (ln[1] == "clearanim") then 
	     	    os.execute("rm -rf anim")
		    os.execute("mkdir anim")	     
	     end
	     end
	     
	     --[[
	     os.execute("convert line.ppm " .. name)
	     os.execute("mv " .. name .. " anim")
	     os.execute("rm line.ppm")
	     ]]--
	     --print("saving " .. name)
 	 end
end

--parseFile("commands")