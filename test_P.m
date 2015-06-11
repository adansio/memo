%
%   caracteristicas access point Aruba iap-135
%       GTx 2.4 GHz = max 3.5 -> 3.0dBi
%       GTx 5 GHz = max 4.5 -> 4.0 dBi
%       Loss internal 2.4 GHz = 1.5 dB
%       Loss internal 5 GHz =   3.0 dB
%
%   caracteristicas access point Aruba iap-105
%       GTx 2.4 GHz = max 3.0 -> 2.0 dBi
%       GTx 5 GHz = max 4.5 -> 4.0 dBi
%       Loss internal 2.4 GHz = 1.5 dB
%       Loss internal 5 GHz =   3.0 dB
%

function test_P

    global mapa_LOS mapa_NLOS apx apy vary varx Ptx UPr ch
            %  apx posicion del ap en eje x
            %  apy posicion del ap en eje y
            %  varx posicion de analisis en eje x
            %  vary posicion de analisis en eje y
            %  Ptx Potencia de transmision
            %  UPr Umbral de potencia de recepcion minimo [dBm]
            %  ch  channel
    
    % Lectura de mapa imagen, paredes.- escala debe ser 10[px] -> 1[m]
    mapa_NLOS = imread('maps/edifp0.bmp');
    
    % Mapa con aps con linea vista, y luego se llena con NaN 
    mapa_LOS = nan(size(mapa_NLOS,1), size(mapa_NLOS,2));         
    mapa_LOS = llenar(mapa_LOS,size(mapa_NLOS,1), size(mapa_NLOS,2));      
    
    % Umbral de potencia de recepción
    UPr = -85;                               
     
    % Ubicación estática de los access point
    APs = [                           %   eventuales ptos con aps, y sus características x y Ptx[dBm] ch 
        % Piso0
		340 200 15 11;	% lab_consultas
		635 140 12 11;	% lab_jgodoy
		625 285 9 6;      % sala 011 
 		
		% Piso 1
        %50 270 9 1;     % sala estudio
        %150 110 9 1;    % opc-a sala 105
        %350 130 10 1;   % sala 108
        %480 140 9 1;    % sala 110
        %620 135 21 1;   % sala 114 -> subir potencia a 21 dBm
            %proyecciones
        %150 280 14 1;    % 201 sobre 101
        %45 75 5 1;       % 206 sobre 103
        %350 130 12 1;    % 212 sobre 108
        %480 140 9 1;     % 214 sobre 110
        %695 60 15 1;     % 223 sobre 118
            %proyecciones 
        %140 275 9 1;    % 301 sobre 101
        %25 335 13 1;    % 302 sobre espacio libre
        %115 60 15 1;    % 307 sobre 107
        %475 140 9 1;    % 313 sobre 110
        %475 290 10 1;   % 314 sobre patio
        %340 90 12 1;    % 316 sobre 112
        %695 85 15 1;    % pasillo
            %proyecciones
        %80  105 9 1;    % comedor
        %325 155 12 1;   % 405 sobre 108
        %480 145 9 1;    % 407 sobre 110
        %658 88 12 1;    % pasillo
        
		% Piso 2
        %140 270 15 1;   % sala 201
        %45 195 10 1;    % ---espacio libre
        %65 70 12 1;      % sala 206
        %345 135 12 1;   % sala 212
        %485 140 9 1;    % sala 214
        %700 60 15 1;    % sala 223
            %proyecciones
        %140 270 9 1;   % 301 sobre 201
        %30 335 15 1;    % 302 sobre 202
        %87 100 12 1;    % 307 sobre 207
        %480 140 9 1;    % 313 sobre 214
        %470 295 12 1;   % 314 sobre 217
        %335 85 8 1;    % 316 sobre 215
        %666 88 12 1;    % pasillo sur p3 sobre pasillo sur p2
            %proyecciones
        %65 95 10 1;   % comedor
        %335 150 12 1;   % sala 405
        %480 140 9 1;    % sala 407
        %666 88 12 1;   % sala 411
            %proyecciones
        %45 265 9 1;     % sala 102 bajo 202
        %125 112 12 1;   % sala 105 bajo 207
        %345 135 10 1;   % sala 108 bajo 212
        %480 140 9 1;    % sala 110 bajo 214
        %630 140 18 1;   % sala 114 bajo 219
            %proyecciones
        %130 195 9 1;    % impresiones bajo espacio libre piso2
        %390 130 9 1;    % lab jgodoy
        %444 295 6 1;    % p011 
 
		% Piso 3
		%140 275 9 1;	 % sala 301
        %25 335 15 1;   % sala 302
        %85 105 12 1;   % pasillo 305-308
        %475 140 12 1;   % sala 313
        %475 290 12 1;  % sala 314
        %340 90 12 1;   % sala 316
        %660 87 12 1;   % pasillo sala 319 322
            %proyecciones
        %115 140 10 1;   %comedor sobre 308
        %335 140 12 1;   %405 sobre 311
        %480 135 9 1;    %407 sobre 313
        %625 140 15 1;   %411 sobre 318
        
        % Piso 4
        %115 140 10 1;   % comedor
        %335 140 12 1;  % sala 405
        %480 135 9 1;   % sala 407
        %658 82 12 1;    % sala 411
        
        %situación actual
        %250 185 10 11;  % lab_consultas
		%600 165 12 11;	% lab_jgodoy
		%650 285 9 6;    % sala 011 
        
        %50 270 10 1;    % sala estudio
        %50 105 10 6;    % sala 103
        %320 155 10 6;   % sala 108
        %480 140 10 1;   % sala 110
        %620 135 10 6;   % sala 114
        
        %140 270 10 6;   % sala 201
        %85 220 10 11;   % pasillo
        %50 50 10 1;     % sala 206
        %330 150 10 1;   % sala 212
        %485 140 10 6;   % sala 214
        %540 170 10 11;  % pasillo
        %700 60 10 1;    % sala 223
        
        %140 275 10 1;   % sala 301
        %45 350 10 1;   % sala 302
        %85 130 10 1;   % pasillo
        %475 140 10 1;   % sala 313
        %535 180 10 1;  % pasillo
        %325 85 10 1;   % sala 316
        %695 140 10 1;   % sala 318
        
        %130 175 10 1;   % comedor
        %330 150 12 1;   % sala 405
        %480 135 10 1;   % sala 407
        %625 140 10 1;   % sala 411
        
        ];     
    
    % llena matrices tridimencional a crear con NaN
        m_ap = nan(size(mapa_NLOS,1), size(mapa_NLOS,2),size(APs,1));

    % Analisis de propagacion para cada access point
    for i=1:size(APs,1)
        apx = APs(i,1);
        apy = APs(i,2);
        Ptx = APs(i,3);
        ch =  APs(i,4);
        
        varx = apx;
        vary = apy;
        
        % Analizar radio de propagacion para cada access point
        m_ap(:,:,i) = espiral(mapa_NLOS, m_ap(:,:,i), apx, apy, vary, varx, Ptx, UPr);
        fprintf('%d  ',i);

    end
    
    % Dejar espacios en blanco del mapa como NaN
    mapa_NLOS=reemplazar(mapa_NLOS);
    

    for i = 1:size(mapa_NLOS,1)
        for j = 1:size(mapa_NLOS,2) 
            if  isnan(mapa_NLOS(i,j))
            else
                mapa_LOS(i,j)=max(m_ap(i,j,:));
            end
        end
    end
    
    % Desplegar imagen
    %colormap('default');
    %imagesc(mapa_LOS);
    %colorbar
    %hold on
    %dlmwrite('m_ap.txt',m_ap,'delimiter', '\t');
    save('m_ap_P0.mat','m_ap');
    
    %hImg = imagesc(mapa_NLOS); 
    %set(hImg, 'AlphaData', 0.3)
    
end

%llena mapa_LOS con ruido ambiente -90 dB
function mtr = llenar(mtr, dim1, dim2)  
    
    mtr(1:dim1,1:dim2)=-90;

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
function mtr = espiral(nlos, mtr, px, py, vy, vx, Pt, UPr)
    
    current = 0;

    %variable booleana - rango maximo de cobertura para cierta potencia
    aux1 = 1; aux2 = 1; aux3 = 1; aux4 = 1;
    
    
    while aux1 || aux2 || aux3 || aux4 
        
        aux1 = 0; aux2 = 0; aux3 = 0; aux4 = 0;
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
    if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)  
	    % friis
		% Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 10;
		% ITU
		% Prx = Pt + 2 - 39.6 - ( 28 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
        % modelo propio
        Prx = Pt + 2 - (41.5 + 32.8 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
	    atenuacion = linea(nlos, px, py, vx, vy);
	    Prx = Prx - atenuacion;
        if Prx > UPr
	        mtr(vy,vx) = Prx;
	        rm1 = true;
        else
	        rm1 = false;
        end 
    else
		rm1 = false;
    end

end

%avanzar hacia abajo
function [mtr, vy, rm2] = down(nlos, mtr, vx, vy, px, py, Pt, UPr)

    vy=vy+1;
	if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
	    % friis
		% Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 10;
	    % ITU
		%Prx = Pt + 2 - 39.6 - ( 28 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
        % modelo propio
        Prx = Pt + 2 - (41.5 + 32.8 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
		atenuacion = linea(nlos, px, py, vx, vy);
	    Prx = Prx - atenuacion;
	    if Prx > UPr 
	        mtr(vy,vx) = Prx;
	        rm2 = true;
	    else
	        rm2 = false;
	    end
	else
		rm2 = false;
	end
    
end

%avanzar hacia la izquierda
function [mtr, vx, rm3] = left(nlos, mtr, vx, vy, px, py, Pt, UPr)

    vx=vx-1;
    if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
        % friis
		% Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 10;
        % ITU
		%Prx = Pt + 2 - 39.6 - ( 28 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
        % modelo propio
        Prx = Pt + 2 - (41.5 + 32.8 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
		atenuacion = linea(nlos, px, py, vx, vy);
        Prx = Prx - atenuacion;
        if Prx > UPr 
            mtr(vy,vx) = Prx;
            rm3 = true;
        else
            rm3 = false;
        end
    else
        rm3 = false;
    end
    
end

%avanzar hacia arriba
function [mtr, vy, rm4] = up(nlos, mtr, vx, vy, px, py, Pt, UPr)

    vy=vy-1;
	if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
		% friis
	    % Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 10;
	    % ITU
		% Prx = Pt + 2 - 39.6 - ( 28 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
        % modelo propio
        Prx = Pt + 2 - (41.5 + 32.8 * log10((sqrt((vx-px)^2+(vy-py)^2))/10));
		atenuacion = linea(nlos, px, py, vx, vy);
	    Prx = Prx - atenuacion;
	    if Prx > UPr 
	        mtr(vy,vx) = Prx;
	        rm4 = true;
	    else
	        rm4 = false;
	    end
	else
		rm4 = false;
	end
    
end

function atenuacion = atenua(atenuacion, tipo)

    switch tipo
        case {0,1,2}      % Pared de concreto gruesa
            atenuacion = atenuacion + 11;
        case 32     % Pared vidrio
            atenuacion = atenuacion + 8.7;
        case {46,47,48,49}     % tabiqueria
            atenuacion = atenuacion + 3.4;
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
    aux_y = apy;
    aux_x = apx;
    
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
            
            while aux_y < ptoy
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                end
                aux_y=aux_y+1;
            end
            return
        else
            %   si el punto de analisis esta mas arriba que el ap
            while aux_y > ptoy
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                end
                aux_y=aux_y-1;
            end
            return
        end
    end
       
    % caso 3-4 pendiente 0 -> y1==y2
    if (apy-ptoy) == 0
        if ptox > apx
            %   si el punto de analisis esta a la derecha del ap
            while aux_x < ptox
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                end
                aux_x = aux_x + 1;
            end
            return
        else
            %    si el punto de analisis esta a la izquierda del ap
            while aux_x > ptox
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                    tipo = NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                end
                aux_x = aux_x - 1;
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
            while aux_x<=ptox && aux_y<=ptoy
                for i = 1:ent 
                    if aux_x>=ptox || aux_y>=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y+1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y<ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_y=aux_y+1;
                        add=add-ent;
                    end
                end
                aux_x=aux_x+1;
            end
            return
        else
            %   si el punto de analisis esta con angulo [225,270[ respecto
            %   el ap y el eje x
            while aux_x>=ptox && aux_y>=ptoy
                for i = 1:ent
                    if aux_x<=ptox || aux_y<=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y-1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y>ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_y=aux_y-1;
                        add=add-ent;
                    end
                end
                aux_x=aux_x-1;
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
            while aux_x>=ptox && aux_y<=ptoy
                for i = 1:ent
                    if aux_x<=ptox || aux_y>=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y+1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y<ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_y=aux_y+1;
                        add=add-ent;
                    end
                end
                aux_x=aux_x-1;
            end
            return
        else
            %   si el punto de analisis esta con angulo ]270,315] respecto
            %   el ap y el eje x
            while aux_x<=ptox && aux_y>=ptoy
                for i = 1:ent
                    if aux_x>=ptox || aux_y<=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y-1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y>ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_y=aux_y-1;
                        add=add-ent;
                    end
                end
                aux_x=aux_x+1;
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
            while aux_x<=ptox && aux_y<=ptoy
                for i = 1:ent
                    if aux_x>=ptox && aux_y>=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x+1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y<ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_x=aux_x+1;
                        add=add-ent;
                    end
                end
                aux_y=aux_y+1;
            end
            return
        else
            %   si el punto de analisis esta con angulo ]180,225[ respecto
            %   el ap y el eje x
            while aux_x>=ptox && aux_y>=ptoy
                for i = 1:ent
                    if aux_x<=ptox && aux_y<=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x-1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y>ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_x=aux_x-1;
                        add=add-ent;
                    end
                end
                aux_y=aux_y-1;
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
            while aux_x>=ptox && aux_y<=ptoy
                for i = 1:ent
                    if aux_x<=ptox && aux_y>=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x-1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y<ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_x=aux_x-1;
                        add=add-ent;
                    end
                end
                aux_y=aux_y+1;
            end
            return
        else
             while aux_x<=ptox && aux_y>=ptoy
                for i = 1:ent
                    if aux_x>=ptox && aux_y<=ptoy
                        return
                    end
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                        tipo = NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x+1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y>ptoy
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) )
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && NLOS(aux_y,aux_x) < tipo
                            tipo = NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        end
                        aux_x=aux_x+1;
                        add=add-ent;
                    end
                end
                aux_y=aux_y-1;
             end
             return
        end
    end

             
    
end
