require 'matrix' -- remove later

function new_stack()
	 local stack, i ,copy = makeMatrix(0,0)
	 i = makeMatrix(4,4)	 
	 identify(i)
	 table.insert(stack,i)--first entry is the identity matrix
	
	 --printMatrix(stack[1])--index 1 is the first matrix
	 
	 return stack
	 
end

function push(stack)
	 local matrix
	 matrix = makeMatrix(4,4)
	 --print(sizeOf(stack))
	 matrix =  copyMatrix(stack[sizeOf(stack)])
	 table.insert(stack,matrix)
end

function pop(stack)
	 table.remove(stack,sizeOf(stack))
end

function print_stack(stack)
	 local i
	 for i = 1, sizeOf(stack) do
	     printMatrix(s[i])
	     --print("\n")
	 end

end

--[[tests
print_stack(s)
push(s)
print_stack(s)
pop(s)
print_stack(s)]]--