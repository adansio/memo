%
%   caracteristicas access point Aruba iap-135
%       GTx 2.4 GHz = max 3.5 -> 3.0dBi
%       GTx 5 GHz = max 4.5 -> 4.0 dBi
%       Loss internal 2.4 GHz = 1.5 dB
%       Loss internal 5 GHz =   3.0 dB
%
%   caracteristicas access point Aruba iap-105
%       GTx 2.4 GHz = max 3.0 -> 2.0dBi
%       GTx 5 GHz = max 4.5 -> 4.0 dBi
%       Loss internal 2.4 GHz = 1.5 dB
%       Loss internal 5 GHz =   3.0 dB
%

function test

    global matriz current limit posx posy vary varx Ptx

    matriz = nan(300, 300);     %   escala => 1 : 0.1 [m]
    current = 0;
    limit = 90;    %   vuelta limite - Prx minima
    ptos = [50 50; 110 110; 170 170];   %   eventuales ptos con aps

    matriz = llenar(matriz);
    Ptx = 15;   %  Ptx en dBm
    
    for i=1:3
        posx = ptos(i,1);
        posy = ptos(i,2);

        varx = posx;
        vary = posy;
    
        matriz = espiral(matriz, current, limit, posy, posx, vary, varx, Ptx);
    end

    % matriz
    colormap('default')
    imagesc(matriz)
    colorbar

end

function mtr = llenar(mtr)  %llena matriz con ruido ambiente -90 dB
    
    mtr(1:100,1:100)=-90;

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
    aux = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    if aux > -57
        mtr(vy,vx) = aux;
    end        

end

function [mtr, vy] = down(mtr, vx, vy, px, py, Pt)

    vy=vy+1;
    aux = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    if aux > -57 
        mtr(vy,vx) = aux;
    end
    
end

function [mtr, vx] = left(mtr, vx, vy, px, py, Pt)

    vx=vx-1;
    aux = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    if aux > -57
        mtr(vy,vx) = aux;
    end
    
end

function [mtr, vy] = up(mtr, vx, vy, px, py, Pt)

    vy=vy-1;
    aux = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    if aux > -57
        mtr(vy,vx) = aux;
    end
    
end

