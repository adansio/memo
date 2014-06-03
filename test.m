function test

global matriz step current limit posx posy vary varx

matriz = nan(10, 10)
current = 0
limit = 5
posx = 5
posy = 5
varx = 5
vary = 5

matriz = llenar(matriz)
matriz = espiral(matriz)

end

function mtr = llenar(mtr)
    
    mtr(1:10,1:10)=0

end

