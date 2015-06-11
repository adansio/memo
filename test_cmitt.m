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

function test_cmitt

    global mapa_NLOS dim_y dim_x m_ap AP_COUNT apx apy Ptx UPr ch
            %  apx posicion del ap en eje x
            %  apy posicion del ap en eje y
            %  varx posicion de analisis en eje x
            %  vary posicion de analisis en eje y
            %  Ptx Potencia de transmision
            %  UPr Umbral de potencia de recepcion minimo [dBm]
            %  ch  channel
    
    % Lectura de mapa imagen, paredes.- escala debe ser 1[px] -> 0.1[m]
    
    mapa_NLOS = imread('cmitt_n3.bmp');
    dim_y=size(mapa_NLOS,1);
    dim_x=size(mapa_NLOS,2);
    
    % Mapa con aps con linea vista, y luego se llena con NaN 
    mapa_LOS = nan(dim_y, dim_x);         
    mapa_LOS = llenar(mapa_LOS);      
    
    % Umbral de potencia de recepción
    UPr = -65;                               
     
    % Ubicación estática de los access point
    APs = [                          %   eventuales ptos con aps, y sus características x y Ptx[dBm] ch 
        %293 115 17 1;                % piso1
        %520 115 14 1;
    
        %160 108 17 1;               % piso2
        %365 108 14 1;
        
        140 95 17 1;                % piso3
        400 95 14 1;
        

        ];     
    
    % llena matrices tridimencional a crear con NaN
        m_ap = nan(dim_y, dim_x ,size(APs,1));

    % Analisis de propagacion para cada access point
    for AP_COUNT=1:size(APs,1)
        apx = APs(AP_COUNT,1);
        apy = APs(AP_COUNT,2);
        Ptx = APs(AP_COUNT,3);
        ch =  APs(AP_COUNT,4);
        
        varx = apx;
        vary = apy;
        
        % Analizar radio de propagacion para cada access point
        espiral(vary, varx);
        fprintf('%d  ',AP_COUNT);

    end
    
    % Dejar espacios en blanco del mapa como NaN
    reemplazar;
    

    %for i = 1:dim_y
    %    for j = 1:dim_x
    %        if  isnan(mapa_NLOS(i,j))
    %        else
    %            mapa_LOS(i,j)=max(m_ap(i,j,:));
    %        end
    %    end
    %end
    
    % Desplegar imagen
    %colormap('default');
    %imagesc(mapa_LOS);
    %colorbar
    %hold on
    %dlmwrite('m_ap.txt',m_ap,'delimiter', '\t');
    save('m_ap-CMITTp3.mat','m_ap');
    
    %hImg = imagesc(mapa_NLOS); 
    %set(hImg, 'AlphaData', 0.3)
    
end

%llena mapa_LOS con ruido ambiente -90 dB
function mapa_LOS = llenar(mapa_LOS)  
    global dim_y dim_x

    mapa_LOS(1:dim_y,1:dim_x)=-90;

end

% espacios en blanco los deja como NaN
function reemplazar
    global mapa_NLOS
    
    for i = 1:size(mapa_NLOS,1)
        for j = 1:size(mapa_NLOS,2)
            if mapa_NLOS(i,j) > 200
                mapa_NLOS(i,j)=NaN;
            end
        end
    end
end


%avance en espiral
function espiral(vy, vx)
    
    % si borde es 1, aun quedan pixeles por analizar
    % si borde es 0, no quedan pixeles por analizar
    borde = 1;
    current = 0;
    
    % variables para determinar si en dicho sentido quedan pixeles por 
    % analizar, caso contrario solo se incrementa vx.
    edge_r=false; edge_d=false; edge_l=false; edge_u=false;
    aux1=true; aux2=true; aux3=true; aux4=true;
    
    while borde
        
        borde=0;
        current=current+1;
        step=0;
        
        while step<current 
            step=step+1;
            if aux1
                [vx, rm1]=right(vx, vy);
                borde = borde || rm1;
                edge_r = edge_r || rm1;
            else
                vx=vx+1;
            end
        end
        
        step=0;
        while step<current
            step=step+1;
            if aux2
                [vy, rm2]=down(vx, vy);
                borde = borde || rm2;
                edge_d = edge_d || rm2;
            else
                vy=vy+1;
            end
        end
        
        current=current+1;
        step=0;
        while step<current
            step=step+1;
            if aux3
                [vx, rm3] = left(vx, vy);
                borde= borde || rm3;
                edge_l = edge_l || rm3;
            else
                vx=vx-1;
            end
        end
        
        step=0;
        while step<current
            step=step+1;
            if aux4
                [vy, rm4] = up(vx, vy);
                borde = borde || rm4;
                edge_u = edge_u || rm4;
            else
                vy=vy-1;
            end
        end
        aux1=edge_r; aux2=edge_d; aux3=edge_l; aux4=edge_u; 
    end
end

% avanzar a la derecha
function [vx, rm1] = right(vx, vy)
    global m_ap AP_COUNT dim_y dim_x apy apx Ptx UPr
    
    % Prx = Pt + 20 * log10(0.125*conversion/(4*pi*sqrt((vx-px)^2+(vy-py)^2))) - 10[path_loss]
	vx=vx+1;
    if vx > 0 && vx <= dim_x && vy > 0 && vy <=  dim_y
	    Prx = Ptx + 20 * log10(0.099471855/(sqrt((vx-apx)^2+(vy-apy)^2))) - 10;   
	    atenuacion = linea(vx, vy);
	    Prx = Prx - atenuacion;
        if Prx > UPr
	        m_ap(vy,vx,AP_COUNT) = Prx;
	        rm1 = true;
        else
	        rm1 = false;
        end 
    else
		rm1 = false;
    end

end

%avanzar hacia abajo
function [vy, rm2] = down(vx, vy)
    global m_ap AP_COUNT dim_y apx apy dim_x Ptx UPr

    vy=vy+1;
	if vx > 0 && vx <= dim_x && vy > 0 && vy <= dim_y
	    Prx = Ptx + 20 * log10(0.099471855/(sqrt((vx-apx)^2+(vy-apy)^2))) - 10;
	    atenuacion = linea(vx, vy);
	    Prx = Prx - atenuacion;
	    if Prx > UPr 
	        m_ap(vy,vx,AP_COUNT) = Prx;
	        rm2 = true;
	    else
	        rm2 = false;
	    end
	else
		rm2 = false;
	end
    
end

%avanzar hacia la izquierda
function [vx, rm3] = left(vx, vy)

    global m_ap AP_COUNT dim_y dim_x apx apy Ptx UPr
    vx=vx-1;
    if vx > 0 && vx <= dim_x && vy > 0 && vy <= dim_y
        Prx = Ptx + 20 * log10(0.099471855/(sqrt((vx-apx)^2+(vy-apy)^2))) - 10;
        atenuacion = linea(vx, vy);
        Prx = Prx - atenuacion;
        if Prx > UPr 
            m_ap(vy,vx,AP_COUNT) = Prx;
            rm3 = true;
        else
            rm3 = false;
        end
    else
        rm3 = false;
    end
    
end

%avanzar hacia arriba
function [vy, rm4] = up(vx, vy)

    global m_ap AP_COUNT dim_y dim_x apy apx Ptx UPr
    vy=vy-1;
	if vx > 0 && vx <= dim_x && vy > 0 && vy <= dim_y
	    Prx = Ptx + 20 * log10(0.099471855/(sqrt((vx-apx)^2+(vy-apy)^2))) - 10;
	    atenuacion = linea(vx, vy);
	    Prx = Prx - atenuacion;
	    if Prx > UPr 
	        m_ap(vy,vx,AP_COUNT) = Prx;
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
            atenuacion = atenuacion + 12;
        case 32     % Pared de concreto media
            atenuacion = atenuacion + 7;
        case {46,47,48,49}     % Pared de concreto delgada
            atenuacion = atenuacion + 4;
        otherwise
            fprintf('%d  ',tipo);
            
    end
end

% Analiza ruta en direccion hacia AP, verificando si existe una pared en
% curso
function atenuacion = linea(ptox, ptoy)

    global mapa_NLOS apy apx
    
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
                if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                    tipo = mapa_NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                    tipo = mapa_NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                end
                aux_y=aux_y+1;
            end
            return
        else
            %   si el punto de analisis esta mas arriba que el ap
            while aux_y > ptoy
                if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                    tipo = mapa_NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                    tipo = mapa_NLOS(aux_y, aux_x);
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
                if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                    tipo = mapa_NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                    tipo = mapa_NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                end
                aux_x = aux_x + 1;
            end
            return
        else
            %    si el punto de analisis esta a la izquierda del ap
            while aux_x > ptox
                if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                    tipo = mapa_NLOS(aux_y, aux_x);
                    atenuacion = atenua(atenuacion, tipo);
                    flag = 1;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                    flag = 0;
                elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                    tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y+1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y<ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y-1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y>ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y+1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y<ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_y=aux_y-1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y>ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x+1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y<ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x-1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y>ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x-1;
                    add=add+frac;
                    if add>=ent && aux_x>ptox && aux_y<ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
                    if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                        flag = 0;
                    elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                        tipo = mapa_NLOS(aux_y, aux_x);
                        atenuacion = atenua(atenuacion, tipo);
                        flag = 1;
                    end
                    aux_x=aux_x+1;
                    add=add+frac;
                    if add>=ent && aux_x<ptox && aux_y>ptoy
                        if flag == 0 && ( mapa_NLOS(aux_y,aux_x) < 5 || (30 < mapa_NLOS(aux_y,aux_x) &&  mapa_NLOS(aux_y,aux_x) < 35) || (45 < mapa_NLOS(aux_y,aux_x) && mapa_NLOS(aux_y,aux_x) < 50) )
                            tipo = mapa_NLOS(aux_y, aux_x);
                            atenuacion = atenua(atenuacion, tipo);
                            flag = 1;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) == 255
                            flag = 0;
                        elseif flag == 1 && mapa_NLOS(aux_y,aux_x) < tipo
                            tipo = mapa_NLOS(aux_y, aux_x);
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
