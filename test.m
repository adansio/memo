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
    
    % Lectura de mapa imagen, paredes.- escala debe ser 10[px] -> 1[m]
    mapa_NLOS = imread('edifc.bmp');
    
    % Mapa con aps con linea vista, y luego se llena con NaN 
    mapa_LOS = nan(size(mapa_NLOS,1), size(mapa_NLOS,2));         
    mapa_LOS = llenar(mapa_LOS,size(mapa_NLOS,1), size(mapa_NLOS,2));   
    current = 0;   
    
    % matriz con traslape de coberturas
    mat_analisis1 = nan(size(mapa_NLOS,1), size(mapa_NLOS,2));    
    mat_analisis1 = llenar0(mat_analisis1,size(mapa_NLOS,1), size(mapa_NLOS,2));
    
    % matriz con promedio de cobertura al traslapar
    mat_analisis2 = nan(size(mapa_NLOS,1), size(mapa_NLOS,2)); 
    
    % Umbral de potencia de recepción
    UPr = -80;                               
     
    % Ubicación estática de los access point
    APs = [                           %   eventuales ptos con aps, y sus características x y Ptx[dBm] ch 
        %220 150 3 1;                 %   pasillo 3
        
        %325 115 3 6;                   % a
        %325 200 3 6;                   % b
        325 150 3 6;                   % c
        
        %430 115 3 11;                  % a
        %430 115 3 11;                  % b
        430 150 3 11;                   % c
        
        %535 115 3 11;                  % a
        %535 200 3 11;                  % b
        535 150 3 11;                   % c
        
        %640 115 3 6;                  % a
        %640 115 3 6;                  % b
        640 150 3 11;                  % c
        
        %800 110 3 11;
        
        %   pasillo 2
        %100 300 3 1;
        %215 300 3 1;
        %365 300 3 6;
        %495 300 3 11;
        %630 300 3 1;
        %800 250 3 6;
        %   pasillo 1
        %740 565 3 1;
        %560 565 3 6;
        %260 340 3 11;
        %260 570 3 1;
        %125 535 3 1;
        %hall
        %1020 430 12 1;
        %1020 295 12 6;
        ];     

    % Analisis para cada access point
    for i=1:size(APs,1)
        apx = APs(i,1);
        apy = APs(i,2);
        Ptx = APs(i,3);
        ch =  APs(i,4);

        varx = apx;
        vary = apy;
        
        % Analizar radio de propagacion para cada access point
        [mapa_LOS, mat_analisis1, mat_analisis2] = espiral(mapa_NLOS, mapa_LOS, current, apx, apy, vary, varx, Ptx, UPr, mat_analisis1, mat_analisis2);
    end
    
    for i=1:size(mapa_NLOS,1)
        for j=1:size(mapa_NLOS,2)
            if isnan(mat_analisis2(i,j))
            else
                mat_analisis2(i,j) = mat_analisis2(i,j)/mat_analisis1(i,j);
            end
        end
    end
    
    
    % Dejar espacios en blanco del mapa como NaN
    mapa_NLOS=reemplazar(mapa_NLOS);
    
    % Desplegar imagen
    colormap('default')
    imagesc(mapa_LOS);
    %imagesc(mat_analisis1);
    %imagesc(mat_analisis2);
    colorbar
    hold on
    
    %dlmwrite('matriz_traslapes.txt',mat_analisis1,'delimiter', '\t');
    %dlmwrite('mapa_LOS.txt',mapa_LOS,'delimiter', '\t');
    %dlmwrite('matriz_traslapes-aver.txt',mat_analisis2,'delimiter', '\t');
    
    hImg = imagesc(mapa_NLOS); 
    set(hImg, 'AlphaData', 0.3)
    
    
end

%llena mapa_LOS con ruido ambiente -90 dB
function mtr = llenar(mtr, dim1, dim2)  
    
    mtr(1:dim1,1:dim2)=-90;

end

function mtr = llenar0(mtr, dim1, dim2)  
    
    mtr(1:dim1,1:dim2)=0;

end

% espacios en blanco los deja como NaN
function mapa_nlos = reemplazar(mapa_nlos)

    for i = 1:size(mapa_nlos,1)
        for j = 1:size(mapa_nlos,2)
            if mapa_nlos(i,j) > 200
                mapa_nlos(i,j)=NaN;
            end
        end
    end
end


%avance en espiral
function [mtr, mat_analisis1, mat_analisis2] = espiral(nlos, mtr, current, px, py, vy, vx, Pt, UPr, mat_analisis1, mat_analisis2)
    
    %variable booleana - rango maximo de cobertura para cierta potencia
    aux1 = 1; aux2 = 1; aux3 = 1; aux4 = 1;
    
    
    while aux1 || aux2 || aux3 || aux4 
        
        aux1 = 0; aux2 = 0; aux3 = 0; aux4 = 0;
        current=current+1;
        step=0;
        while step<current 
            step=step+1;
            [mtr, vx, rm1, mat_analisis1, mat_analisis2]=right(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2);
            aux1 = aux1 || rm1;
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy, rm2, mat_analisis1, mat_analisis2]=down(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2);
            aux2 = aux2 || rm2;
        end
        
        current=current+1;
        step=0;
        while step<current
            step=step+1;
            [mtr, vx, rm3, mat_analisis1, mat_analisis2] = left(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2);
            aux3 = aux3 || rm3;
        end
        
        step=0;
        while step<current
            step=step+1;
            [mtr, vy, rm4, mat_analisis1, mat_analisis2] = up(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2);
            aux4 = aux4 || rm4;
        end
        
    end

end

% avanzar a la derecha
function [mtr, vx, rm1, mat_analisis1, mat_analisis2] = right(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2)

	if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
	    vx=vx+1;
	    Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
	    atenuacion = linea(nlos, px, py, vx, vy);
	    Prx = Prx - atenuacion;
	    if Prx > UPr
	        mtr(vy,vx) = Prx;
            mat_analisis1(vy,vx) = mat_analisis1(vy,vx) + 1;
	        rm1 = true;
            if isnan(mat_analisis2(vy,vx))
                mat_analisis2(vy,vx) = Prx;
            else
                mat_analisis2(vy,vx) = mat_analisis2(vy,vx) + Prx;
            end  
	    else
	        rm1 = false;
	    end 
	else
		rm1 = false;
	end

end

%avanzar hacia abajo
function [mtr, vy, rm2, mat_analisis1, mat_analisis2] = down(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2)

    vy=vy+1;
	if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
	    Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
	    atenuacion = linea(nlos, px, py, vx, vy);
	    Prx = Prx - atenuacion;
	    if Prx > UPr
	        mtr(vy,vx) = Prx;
            mat_analisis1(vy,vx) = mat_analisis1(vy,vx) + 1;
	        rm2 = true;
            if isnan(mat_analisis2(vy,vx))
                mat_analisis2(vy,vx) = Prx;
            else
                mat_analisis2(vy,vx) = mat_analisis2(vy,vx) + Prx;
            end
	    else
	        rm2 = false;
	    end
	else
		rm2 = false;
	end
    
end

%avanzar hacia la izquierda
function [mtr, vx, rm3, mat_analisis1, mat_analisis2] = left(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2)

    vx=vx-1;
    if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
        Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
        atenuacion = linea(nlos, px, py, vx, vy);
        Prx = Prx - atenuacion;
        if Prx > UPr
            mtr(vy,vx) = Prx;
            mat_analisis1(vy,vx) = mat_analisis1(vy,vx) + 1;
            rm3 = true;
            if isnan(mat_analisis2(vy,vx))
                mat_analisis2(vy,vx) = Prx;
            else
                mat_analisis2(vy,vx) = mat_analisis2(vy,vx) + Prx;
            end
        else
            rm3 = false;
        end
    else
        rm3 = false;
    end
    
end

%avanzar hacia arriba
function [mtr, vy, rm4, mat_analisis1, mat_analisis2] = up(nlos, mtr, vx, vy, px, py, Pt, UPr, mat_analisis1, mat_analisis2)

    vy=vy-1;
	if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
	    Prx = Pt + 20 * log10(0.125/(4*pi*sqrt((vx-px)^2+(vy-py)^2)));
	    atenuacion = linea(nlos, px, py, vx, vy);
	    Prx = Prx - atenuacion;
	    if Prx > UPr
	        mtr(vy,vx) = Prx;
            mat_analisis1(vy,vx) = mat_analisis1(vy,vx) + 1;
	        rm4 = true;
            if isnan(mat_analisis2(vy,vx))
                mat_analisis2(vy,vx) = Prx;
            else
                mat_analisis2(vy,vx) = mat_analisis2(vy,vx) + Prx;
            end
	    else
	        rm4 = false;
	    end
	else
		rm4 = false;
	end
    
end

function atenuacion = atenua(atenuacion, tipo)

    switch tipo
        case 0
            atenuacion = atenuacion + 12;
            %fprintf('1 %d   ', atenuacion);
        case 32
            atenuacion = atenuacion + 6;
            %fprintf('2 %d   ', atenuacion);
        case 48
            atenuacion = atenuacion + 3;
            %fprintf('3 %d   ', atenuacion);
        otherwise
            fprintf('%d  ',tipo);
            
    end
end

% Analiza ruta en direccion hacia AP, verificando si existe una pared en
% curso
function atenuacion = linea(NLOS, apx, apy, ptox, ptoy)
    
    atenuacion=0;   % atenuacion inicial 0 dB
    flag = 0;       % flag para determinar si quedan puntos donde aun llega señal, y continuar con algoritmo
    tipo = 0;       % tipo de pared en base al color
    
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
                if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                    tipo = NLOS(ptoy, ptox);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(ptoy,ptox) == 255
                    flag=0;
                end
                ptoy=ptoy-1;
            end
            return
        else
            %   si el punto de analisis esta mas arriba que el ap
            while ptoy < apy
                if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                    tipo = NLOS(ptoy, ptox);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(ptoy,ptox) == 255
                    flag=0;
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
                if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                    tipo = NLOS(ptoy, ptox);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(ptoy,ptox) == 255
                    flag=0;
                end
                ptox=ptox-1;
            end
            return
        else
            %    si el punto de analisis esta a la izquierda del ap
            while ptox < apx
                if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                    tipo = NLOS(ptoy, ptox);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(ptoy,ptox) == 255
                    flag=0;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptoy=ptoy-1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy>apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                            tipo = NLOS(ptoy, ptox);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptoy=ptoy-1;
                        add=add-ent;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptoy=ptoy+1;
                    add=add+frac;
                    if add>=ent && ptox<apx && ptoy<apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                            tipo = NLOS(ptoy, ptox);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptoy=ptoy+1;
                        add=add-ent;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptoy=ptoy-1;
                    add=add+frac;
                    if add>=ent  && ptox<apx && ptoy>apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                            tipo = NLOS(ptoy, ptox);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptoy=ptoy-1;
                        add=add-ent;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptoy=ptoy+1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy<apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                           tipo = NLOS(ptoy, ptox);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptoy=ptoy+1;
                        add=add-ent;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptox=ptox-1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy>apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                            tipo = NLOS(ptoy, ptox);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptox=ptox-1;
                        add=add-ent;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptox=ptox+1;
                    add=add+frac;
                    if add>=ent && ptox<apx && ptoy<apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                            tipo = NLOS(ptoy, ptox);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptox=ptox+1;
                        add=add-ent;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptox=ptox+1;
                    add=add+frac;
                    if add>=ent && ptox<apx && ptoy>apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                            tipo = NLOS(ptoy, ptox);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptox=ptox+1;
                        add=add-ent;
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
                    if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                        tipo = NLOS(ptoy, ptox);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(ptoy,ptox) == 255
                        flag=0;
                    end
                    ptox=ptox-1;
                    add=add+frac;
                    if add>=ent && ptox>apx && ptoy<apy
                        if flag == 0 && ( NLOS(ptoy,ptox) == 0 || NLOS(ptoy,ptox) == 32 || NLOS(ptoy,ptox) == 48 )
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(ptoy,ptox) == 255
                            flag=0;
                        end
                        ptox=ptox-1;
                        add=add-ent;
                    end
                end
                ptoy=ptoy+1;
             end
             return
        end
    end

             
    
end
