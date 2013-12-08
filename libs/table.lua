local fcomp_default = function( a,b ) return a < b end
function table.bininsert(t, value, fcomp)
    local fcomp = fcomp or fcomp_default
    local iStart,iEnd,iMid,iState = 1,#t,1,0
    while iStart <= iEnd do
        iMid = math.floor( (iStart+iEnd)/2 )
        if fcomp( value,t[iMid] ) then
            iEnd,iState = iMid - 1,0
        else
            iStart,iState = iMid + 1,1
        end
    end
    return (iMid+iState)
end
