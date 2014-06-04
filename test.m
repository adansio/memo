function test

global matriz step current limit posx posy vary varx Ptx

matriz = nan(100, 100);
current = 0;
limit = 70;
posx = 50;
posy = 50;
varx = 50;
vary = 50;
Ptx = 15; %  PTx en dBm

matriz = llenar(matriz);
matriz = espiral(matriz, current, limit, posy, posx, vary, varx, Ptx);
matriz
colormap('default')
imagesc(matriz)
colorbar

end

function mtr = llenar(mtr)  %llena matriz con 0's
    
    mtr(1:100,1:100)=0;

end

function mtr = espiral(mtr, current, limit, px, py, vy, vx, Pt)
    
    while current<limit 
        current=current+1;
        step=0;
        while step<current 
            step=step+1;
            [mtr, vx]=right(mtr, vx, vy, px, py, Pt);
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy]=down(mtr, vx, vy, px, py, Pt);
        end
        
        current=current+1;
        step=0;
        while step<current
            step=step+1;
            [mtr, vx] = left(mtr, vx, vy, px, py, Pt);
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy] = up(mtr, vx, vy, px, py, Pt);
        end
        
    end

end

function [mtr, vx] = right(mtr, vx, vy, px, py, Pt)
    
    vx=vx+1;
    mtr(vy,vx) = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));

end

function [mtr, vy] = down(mtr, vx, vy, px, py, Pt)

    vy=vy+1;
    mtr(vy,vx) = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    
end

function [mtr, vx] = left(mtr, vx, vy, px, py, Pt)

    vx=vx-1;
    mtr(vy,vx) = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    
end

function [mtr, vy] = up(mtr, vx, vy, px, py, Pt)

    vy=vy-1;
    mtr(vy,vx) = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    
end

