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

    global mapa_LOS mapa_NLOS current apx apy vary varx Ptx UPr ch
            %  apx posicion del ap en eje x
            %  apy posicion del ap en eje y
            %  varx posicion de analisis en eje x
            %  vary posicion de analisis en eje y
            %  Ptx Potencia de transmision
            %  UPr Umbral de potencia de recepcion minimo [dBm]
            %  ch  channel

    dim1 = 1000;     %dimensiones del mapa
    dim2 = 1000;
    
    mapa_LOS = nan(dim1, dim2);         %   mapa con aps con linea vista   escala => 1 [pto en matriz] : 1 [m]
    mapa_NLOS = nan(dim1, dim2);        %   mapa con paredes y obstrucciones no linea vista
    current = 0;    
    %limit = 370;                            vuelta limite - Prx minima
    APs = [                             %   eventuales ptos con aps, y sus características
        250 250 15 1;                   %   x y Ptx[dBm] ch 
        400 250 12 6; 
        600 250 6 11
        120 600 9 11
        500 600 12 6];     
    
    %for i=1:800
    %    mapa_NLOS(90, i) = 5;
    %end
    for i=100:800
        mapa_NLOS(i, 100) = 5;
    end
    
    UPr = -71;                               
    mapa_LOS = llenar(mapa_LOS);
    
    for i=1:size(APs,1)
        apx = APs(i,1);
        apy = APs(i,2);
        Ptx = APs(i,3);
        ch =  APs(i,4);

        varx = apx;
        vary = apy;
    
        mapa_LOS = espiral(mapa_NLOS, mapa_LOS, current, apx, apy, vary, varx, Ptx, UPr);
    end

    % mapa_LOS
    colormap('default')
    imagesc(mapa_LOS)
    colorbar

end

%llena mapa_LOS con ruido ambiente -90 dB
function mtr = llenar(mtr)  
    
    mtr(1:1000,1:1000)=-100;

end

%avance en espiral
function mtr = espiral(nlos, mtr, current, px, py, vy, vx, Pt, UPr)
    
    %variable booleana - rango maximo de cobertura para cierta potencia
    aux1 = 1; aux2 = 1; aux3 = 1; aux4 = 1;
    
    
    while aux1 || aux2 || aux3 || aux4 
        
        aux1 = 0; aux2 = 0; aux3 = 0; aux4 = 0;
        %fprintf('wena \n');
        current=current+1;
        step=0;
        while step<current 
            step=step+1;
            [mtr, vx, rm1]=right(nlos, mtr, vx, vy, px, py, Pt, UPr);
            aux1 = aux1 || rm1;
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy, rm2]=down(nlos, mtr, vx, vy, px, py, Pt, UPr);
            aux2 = aux2 || rm2;
        end
        
        current=current+1;
        step=0;
        while step<current
            step=step+1;
            [mtr, vx, rm3] = left(nlos, mtr, vx, vy, px, py, Pt, UPr);
            aux3 = aux3 || rm3;
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy, rm4] = up(nlos, mtr, vx, vy, px, py, Pt, UPr);
            aux4 = aux4 || rm4;
        end
        
    end

end

% avanzar a la derecha
function [mtr, vx, rm1] = right(nlos, mtr, vx, vy, px, py, Pt, UPr)
    
    vx=vx+1;
    Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    atenuacion = linea(nlos, px, py, vx, vy);
    Prx = Prx - atenuacion;
    if Prx > UPr
        mtr(vy,vx) = Prx;
        rm1 = true;
    else
        rm1 = false;
    end 
    

end

%avanzar hacia abajo
function [mtr, vy, rm2] = down(nlos, mtr, vx, vy, px, py, Pt, UPr)

    vy=vy+1;
    Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    atenuacion = linea(nlos, px, py, vx, vy);
    Prx = Prx - atenuacion;
    if Prx > UPr
        mtr(vy,vx) = Prx;
        rm2 = true;
    else
        rm2 = false;
    end
    
end

%avanzar hacia la izquierda
function [mtr, vx, rm3] = left(nlos, mtr, vx, vy, px, py, Pt, UPr)

    vx=vx-1;
    Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    atenuacion = linea(nlos, px, py, vx, vy);
    Prx = Prx - atenuacion;
    if Prx > UPr
        mtr(vy,vx) = Prx;
        rm3 = true;
    else
        rm3 = false;
    end
    
end

%avanzar hacia arriba
function [mtr, vy, rm4] = up(nlos, mtr, vx, vy, px, py, Pt, UPr)

    vy=vy-1;
    Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
    atenuacion = linea(nlos, px, py, vx, vy);
    Prx = Prx - atenuacion;
    if Prx > UPr
        mtr(vy,vx) = Prx;
        rm4 = true;
    else
        rm4 = false;
    end
    
end

function atenuacion = linea (NLOS, apx, apy, ptox, ptoy)
    
    atenuacion=0;
    % caso 0, pto se encuentra en el mismo que el AP, exit(0)
    if (apx-ptox) == 0 && (apy-ptoy) == 0
        atenuacion=0;
        return
    end
    %ahora
    % caso 1-2 pendiente infinita -> x1 == x2
    if (apx-ptox) == 0
        if ptoy > apy 
            %   si el punto de analisis esta mas abajo que el ap
            while ptoy > apy 
                if NLOS(ptoy,ptox) == 5
                    atenuacion = 10;
                end
                ptoy=ptoy-1;
            end
            return
        else
            %   si el punto de analisis esta mas arriba que el ap
            while ptoy < apy
                if NLOS(ptoy,ptox) == 5
                    atenuacion = 10;
                end
                ptoy=ptoy+1;
            end
            return
        end
    end
       
    % caso 3-4 pendiente 0 -> y1==y2
    if (apy-ptoy) == 0
        if ptox > apx 
            %   si el punto de analisis esta a la derecha del ap
            while ptox > apx 
                if NLOS(ptoy,ptox) == 5
                    atenuacion = 10;
                end
                ptox=ptox-1;
            end
            return
        else
            %    si el punto de analisis esta a la izquierda del ap
            while ptox < apx
                if NLOS(ptoy,ptox) == 5
                    atenuacion = 10;
                end
                ptox=ptox+1;
            end
            return
        end
    end
    
    m = (ptoy-apy)/(ptox-apx);  %   pendiente dy/dx
    ent = floor (m);    %   parte entera de m
    frac = m - ent;     %   parte flotante de m
    add = frac;         %   variable para avanzar en linea recta hacia ap
    
    % caso 5-6 pendiente >= 1+ , >=1-
    if m >= 1
        if ptoy>apy && ptox>apx
            %   si el punto de analisis esta con angulo [45,90[ respecto el
            %   ap y el eje x
            while ptox>=apx && ptoy>=apy 
                for i = 1:ent 
                    if ptox<=apx || ptoy<=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                        atenuacion = 10;
                    end
                    ptoy=ptoy-1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy>apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptoy=ptoy-1;
                        add=frac;
                    end
                end
                ptox=ptox-1;
            end
            return
        else
            %   si el punto de analisis esta con angulo [225,270[ respecto
            %   el ap y el eje x
            while ptox<=apx && ptoy<=apy
                for i = 1:ent
                    if ptox>=apx || ptoy>=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                    end
                    ptoy=ptoy+1;
                    add=add+frac;
                    if add>=ent && ptox<apx && ptoy<apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptoy=ptoy+1;
                        add=frac;
                    end
                end
                ptox=ptox+1;
            end
            return
        end
    end

    % caso 7-8 pendiente <= -1+, <= -1-
    if m <= -1
        ent = floor(abs(ptoy-apy)/abs(ptox-apx));
        frac = abs(m)-ent;
        add = frac;
        
        if apy<ptoy && ptox<apx
            %   si el punto de analisis esta con angulo ]90,135] respecto el
            %   ap y el eje x
            while ptox<=apx && ptoy>=apy
                for i = 1:ent
                    if ptox>=apx || ptoy<=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                        atenuacion = 10;
                    end
                    ptoy=ptoy-1;
                    add=add+frac;
                    if add>=ent  && ptox<apx && ptoy>apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptoy=ptoy-1;
                        add=frac;
                    end
                end
                ptox=ptox+1;
            end
            return
        else
            %   si el punto de analisis esta con angulo ]270,315] respecto
            %   el ap y el eje x
            while ptox>=apx && ptoy<=apy
                for i = 1:ent
                    if ptox<=apx || ptoy >=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                        atenuacion = 10;
                    end
                    ptoy=ptoy+1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy<apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptoy=ptoy+1;
                        add=frac;
                    end
                end
                ptox=ptox-1;
            end
            return
        end
    end
    
    m = (ptox-apx)/(ptoy-apy);
    ent = floor(m);
    frac = m - ent;
    add = frac;

    % caso 9-10 pendiente ]0,1[ ; angulo ]0,45[
    if m > 1
        %   si el punto de analisis esta con angulo ]0,45[ respecto el ap y
        %   el eje x
        if ptoy>apy && ptox>apx
            while ptox>=apx && ptoy>=apy
                for i = 1:ent
                    if ptox<=apx && ptoy<=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                    end
                    ptox=ptox-1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy>apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptox=ptox-1;
                        add = 0;
                    end
                end
                ptoy=ptoy-1;
            end
            return
        else
            %   si el punto de analisis esta con angulo ]180,225[ respecto
            %   el ap y el eje x
            while ptox<=apx && ptoy<=apy
                for i = 1:ent
                    if ptox>=apx && ptoy>=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                    end
                    ptox=ptox+1;
                    add=add+frac;
                    if add>=ent && ptox<apx && ptoy<apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptox=ptox+1;
                        add=0;
                    end
                end
                ptoy=ptoy+1;
            end
            return
        end
    end
    
    % caso 11-12 pendiente ]0,-1[ ; ]-1,0[
    if m < -1 
        ent = floor(abs(ptox-apx)/abs(ptoy-apy));
        frac = abs(m)-ent;
        add = frac;
        
        if apy<ptoy && ptox<apx
            while ptox<=apx && ptoy>=apy
                for i = 1:ent
                    if ptox>=apx && ptoy<=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                    end
                    ptox=ptox+1;
                    add=add+frac;
                    if add>=ent && ptox<apx && ptoy>apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptox=ptox+1;
                        add=0;
                    end
                end
                ptoy=ptoy-1;
            end
            return
        else
             while ptox>=apx && ptoy<=apy
                for i = 1:ent
                    if ptox<=apx && ptoy>=apy
                        return
                    end
                    if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                    end
                    ptox=ptox-1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy<apy
                        if NLOS(ptoy,ptox) == 5
                            atenuacion = 10;
                        end
                        ptox=ptox-1;
                        add=0;
                    end
                end
                ptoy=ptoy+1;
             end
             return
        end
    end

             
    
end