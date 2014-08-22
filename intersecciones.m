

% Determinar las intersecciones entre access points
function intersecciones(m_ap)

    mapa_NLOS = imread('edifc.bmp');
    mapa_LOS = nan(size(mapa_NLOS,1), size(mapa_NLOS,2));         
    mapa_LOS = llenar(mapa_LOS,size(mapa_NLOS,1), size(mapa_NLOS,2));      

    for i = 1:size(mapa_NLOS,1)
        for j = 1:size(mapa_NLOS,2) 
            if  isnan(mapa_NLOS(i,j))
            else
                mapa_LOS(i,j)=max(m_ap(i,j,:));
            end
        end
    end

    grafo(size(m_ap,3),size(m_ap,3))=0;
    for i=1:(size(m_ap,3) - 1)
        [row1,col1] = find(isfinite(m_ap(:,:,i)));
        for j=i+1:size(m_ap,3)
            [row2,col2] = find(isfinite(m_ap(:,:,j)));
            % si existe interseccion o traslapes de coberturas, entonces
            % se establece enlaces entre nodos
            aux = intersect([row1,col1],[row2,col2],'rows');
            if  ~isempty(aux)
                grafo(i,j)=size(aux,1);
            end
        end
    end
    
    %mapa_NLOS=reemplazar(mapa_NLOS);
    
    %colormap('default');
    %imagesc(mapa_LOS);
    %colorbar
    %hold on
    
    %hImg = imagesc(mapa_NLOS); 
    %set(hImg, 'AlphaData', 0.3)
   
    % repliega matriz triangular superior en matriz triangular inferior
    grafo = grafo' + grafo
    fprintf('\n ');
    
    % cuenta cuantos nodos se interfieren en total
    size(find(grafo),1)
    
    % grado: 1 -> almacena cuantos nodos se interfieren por cada fila.
    %       2 -> indice de correspondencia en grafo.
    %       3 -> suma de la columna, para determinar cual columna presenta
    %           mas traslape que otra.
    %       4 -> para posteriormente asignar el canal correspondiente
    grado(size(m_ap,3),4)=0;
    
    for i=1:size(m_ap,3)
        grado(i,1) = size(find(grafo(:,i)),1);
        grado(i,2) = i;
        grado(i,3) = sum(grafo(:,i));
    end
    
    grado = ordenar(sortrows(grado,-1));
    
    grado = asignar(grafo, grado, size(m_ap,3));
    grado
    
    %dlmwrite('grafo-c.txt',grafo,'delimiter', '\t');
    
end

% ordena en orden decreciente la matriz grado, primero por la cantidad de
% nodos que se interfieren por cada fila y luego por la cantidad de espacio
% traslapado en total
function grado_ = ordenar(grado_)
    
    flag =0;
    for i=1:size(grado_,1)-1
        if grado_(i,1)==grado_(i+1,1) && flag==0
            up=i;
            down=i+1;
            flag = 1;
            while down<size(grado_,1) && grado_(up,1)==grado_(down+1,1)
                down = down+1;
            end
            grado_(up:down,:)=sortrows(grado_(up:down,:),-3);
        elseif grado_(i,1)~=grado_(i+1,1)
            flag=0;
        end
    end

end

% Asignar canales a los access point
function grado_ = asignar(grafo_, grado_, num_ap)


    num_chan=4;             % numero de canales disponibles
    canales(num_chan)=0;    % conteo de canales utilizados
    
    % Determinar que canales estan utilizando los vecinos del nodo en
    % cuestion
    % recorrer matriz grado
    for i=1:num_ap
        % recorrer matriz grafo, analizar cada interseccion
        for j=1:num_ap
            if grafo_(grado_(i,2),j)~=0 
                % si ya tiene un canal asignado
                if grado_(find(grado_(:,2),j),4)~=0
                    canales(grado_(find(grado_(:,2),j),4)) = canales(grado_(find(grado_(:,2),j),4)) + 1;
                end
            end
        end
        
        % maximo, almacena maximo espacio de traslape de superficies,
        % se inicializa con 0
        maximo=0;
        % asigna el primer canal (1)
        if nnz(canales)==0
            grado_(i,4) = 1;
        % asigna si hay canales libres, prioriza orden 1 a 4
        elseif nnz(canales)>=1 && nnz(canales)<4
            flag=0;
            for j=1:num_chan
                if flag==0 && canales(j)==0
                    grado_(i,4) = j;
                    flag=1;
                end
            end
        % asigna cuando no quedan canales libres
        elseif nnz(canales)==4
            k=1;
            while size(find(canales==12),2)<num_chan && k<(i-1)
                for j=k:i-1
                    % aux almacena superficie de contacto entre los 2 valores
                    % involucrados
                    aux=grafo_(grado_(i,2),grado_(j,2));
                    if aux > maximo
                        maximo=max(maximo, aux);
                        row_selected = j;
                    end
                end
                canales(grado_(row_selected,4))=num_chan;
                k=k+1;
            end
            [val, grado_(i,4)]=min(canales);
        end
        
        canales(:)=0;
        % verificar si algun vecino de i tiene ID asignado
        %   si no existe vecino con asignacion, asignar el primero
        %   si existen 3 o menos vecinos asignados, asignar el sgte ID
        %   si existe 4 o mas vecinos asignados, asignar ID del nodo con
        %       menor superficie traslapada o el menos ocupado?
    end
    fprintf('ok \n');
    
end

function mapa_nlos = reemplazar(mapa_nlos)

    for i = 1:size(mapa_nlos,1)
        for j = 1:size(mapa_nlos,2)
            if mapa_nlos(i,j) > 200
                mapa_nlos(i,j)=NaN;
            end
        end
    end
end

function mtr = llenar(mtr, dim1, dim2)  
    
    mtr(1:dim1,1:dim2)=-90;

end