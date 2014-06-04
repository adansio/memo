function test

global matriz step current limit posx posy vary varx

matriz = nan(10, 10);
current = 0;
limit = 5;
posx = 5;
posy = 5;
varx = 5;
vary = 5;

matriz = llenar(matriz);
matriz = espiral(matriz, current, limit, step, posy, posx, vary, varx);
matriz

end

function mtr = llenar(mtr)
    
    mtr(1:10,1:10)=0;

end

function mtr = espiral(mtr, current, limit, step, px, py, vy, vx)
    
    while current<limit 
        current=current+1;
        step=0;
        while step<current 
            step=step+1;
            [mtr, vx]=right(mtr, vx, vy, step);
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy]=down(mtr, vx, vy, step);
        end
        
        current=current+1;
        step=0;
        while step<current
            step=step+1;
            [mtr, vx] = left(mtr, vx, vy, step);
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy] = up(mtr, vx, vy, step);
        end
        
    end

end

function [mtr, vx] = right(mtr, vx, vy, step)
    
    vx=vx+1;
    mtr(vy,vx) = step;

end

function [mtr, vy] = down(mtr, vx, vy, step)

    vy=vy+1;
    mtr(vy,vx) = step;
    
end

function [mtr, vx] = left(mtr, vx, vy, step)

    vx=vx-1;
    mtr(vy,vx) = step;
    
end

function [mtr, vy] = up(mtr, vx, vy, step)

    vy=vy-1;
    mtr(vy,vx) = step;
    
end

