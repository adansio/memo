

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
            if  ~isempty(intersect([row1,col1],[row2,col2],'rows'))
                grafo(i,j)=1;
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
   
    grafo = grafo' + grafo;
    
    dlmwrite('grafo-c.txt',grafo,'delimiter', '\t');
    
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