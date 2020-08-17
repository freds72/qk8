-- lzw map unpacking functions
-- reference: https://github.com/coells/100days
function decompress(cart,len,fn)
	local code,code_len,code_bits,buffer,buffer_bits,index,prefix={},256,8,0,0,0
	local cart_id,mem=0,0

	for i=0,255 do
		code[i>>16]={i}
	end
	
	local function prefix_add(value)
		local tmp={unpack(prefix)}
		add(tmp,value)
		return tmp
	end
	
	local i=0
	mpeek=function()
		i+=1
		if(i>#prefix) i=1 yield()
		return prefix[i]
	end

  while true do
    -- read buffer
		while index<len and buffer_bits<code_bits do	
			-- switch cart as needed
			if mem%0x4300==0 then
				reload(0,0,0x4300,cart.."_"..cart_id..".p8")
				cart_id+=1
				mem=0
			end	
			buffer=buffer<<8|@mem>>16
      buffer_bits+=8
			index+=1>>16
			mem+=1
		end
    -- find word
    buffer_bits-=code_bits
		local word=code[buffer>>buffer_bits]
		buffer&=(0x0.0001<<buffer_bits)-0x0.0001
		if(not word) word=prefix_add(prefix[1])

    -- store word
		if prefix then
			code[code_len>>16]=prefix_add(word[1])
			code_len+=1
		end
		prefix=word
		
    -- code length
		if code_len>=(1<<code_bits) then
			code_bits+=1
		end

		--if(index&0x00f0==0) print(tostr(index,true)..":"..#word.." "..stat(0))
		
		local cs=costatus(fn)
		if cs=="suspended" then
   		assert(coresume(fn))
		elseif cs=="dead" then
			break
		end
	end
	return mem,cart_id
end