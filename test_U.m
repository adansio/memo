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

function test_U

    global mapa_LOS mapa_NLOS apx apy vary varx Ptx UPr ch
            %  apx posicion del ap en eje x
            %  apy posicion del ap en eje y
            %  varx posicion de analisis en eje x
            %  vary posicion de analisis en eje y
            %  Ptx Potencia de transmision
            %  UPr Umbral de potencia de recepcion minimo [dBm]
            %  ch  channel
    
    % Lectura de mapa imagen, paredes.- escala debe ser 10[px] -> 1[m]
    mapa_NLOS = imread('maps/edifu2.bmp');
    
    % Mapa con aps con linea vista, y luego se llena con NaN 
    mapa_LOS = nan(size(mapa_NLOS,1), size(mapa_NLOS,2));         
    mapa_LOS = llenar(mapa_LOS,size(mapa_NLOS,1), size(mapa_NLOS,2));      
    
    % Umbral de potencia de recepción
    UPr = -85;                               
     
    % Ubicación estática de los access point
    APs = [                           %   eventuales ptos con aps, y sus características x y Ptx[dBm] ch 
        %110 135 9 1;                %piso 0
        %125 80 9 1;                 %piso 1 alta dda
        %295 75 6 1;                 % prestamo - entrada
        %420 150 9 1;                % norte
        %225 155 9 1;                % piso 2 sur
        %400 165 9 1;                % estantes
        %515 155 9 1;                % norte
        %330 50 9 1;                 % piso 3 literatura
        %375 167 6 1;                % estantes
        %480 145 9 1;                % norte
        %87 5 18 1;                  %piso 4
        
        %110 135 9 1;                % actual piso 0
        %190 95 10 1;                %piso 1
        %295 75 6 1;
        %415 140 6 1;
        %510 147 6  1;               %piso 2 norte
        %395 165 6 1;                % estantes
        %225 130 9 1;                % sur
        %475 145 11 1;               % piso 3 norte
        %390 167 3 1;                % centro
        %430 60 9 1;                 % sur
        %87 5 18 1;                  % piso 4   
            
        % 5GHz
        %110 135 18 1;                %piso 0
        %125 80 15 1;                 % piso 1 alta dda
        %295 75 12 1;                 % prestamo - entrada
        %420 150 15 1;                % norte
        %225 155 15 1;                % piso 2 sur
        %400 165 15 1;                % estantes
        %515 155 15 1;                % norte
        %330 50 15 1;                 % piso 3 literatura
        %375 167 12 1;                % estantes
        %480 145 15 1;                % norte
        %87 5 21 1;                  %piso 4
        
        % proyecciones en piso2
        82 85 18 1;             % piso 1 alta dda
        245 80 15 1;            % prestamo - entrada
        440 145 15 1;           % norte
        225 155 15 1;           % piso 2 sur
        400 165 15 1;           % estantes
        515 155 15 1;           % norte
        330 50 15 1;            % piso 3 literatura
        398 166 12 1;           % estantes
        485 145 15 1;           % norte
        215 10 21 1;            %piso 4
        
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
    save('m_ap_U2___5g.mat','m_ap');
    
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
	    %Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 12;
        Prx = Pt + 3 - (46.6 + 31*log10((sqrt(((vx-px)^2+(vy-py)^2))/10)));
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

    % Prx = Pt + 20 * log10(0.125*conversion/(4*pi*sqrt((vx-px)^2+(vy-py)^2))) - 10[path_loss]
    % Prx = Pt + 20 * log10(0.057*conversion/(4*pi*sqrt((vx-px)^2+(vy-py)^2))) - 10[path_loss]
    vy=vy+1;
	if vx > 0 && vx <= size(nlos,2) && vy > 0 && vy <= size(nlos,1)
	    %Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 12;
        Prx = Pt + 3 - (46.6 + 31*log10((sqrt(((vx-px)^2+(vy-py)^2))/10)));
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
        %Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 12;
        Prx = Pt + 3 - (46.6 + 31*log10((sqrt(((vx-px)^2+(vy-py)^2))/10)));
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
	    %Prx = Pt + 20 * log10(0.099471855/(sqrt((vx-px)^2+(vy-py)^2))) - 12;
        Prx = Pt + 3 - (46.6 + 31*log10((sqrt(((vx-px)^2+(vy-py)^2))/10)));
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
            atenuacion = atenuacion + 10;
        case 32     % Pared de concreto media
            atenuacion = atenuacion + 4.5;
        case {46,47,48,49}     % tabiqueria
            atenuacion = atenuacion + 2.5;
        case 80         % estanteria
            atenuacion = atenuacion + 5;    
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
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                    if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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
                        if flag == 0 && ( NLOS(aux_y,aux_x) < 5 || (30 < NLOS(aux_y,aux_x) &&  NLOS(aux_y,aux_x) < 35) || (45 < NLOS(aux_y,aux_x) && NLOS(aux_y,aux_x) < 50) || NLOS(aux_y,aux_x) == 80)
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