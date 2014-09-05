function SNR(m_ap)
    
    load('chans.mat');
    mapa_NLOS = imread('edifc.bmp');
    mapa_LOS = nan(size(mapa_NLOS,1), size(mapa_NLOS,2));         
    mapa_LOS = llenar(mapa_LOS,size(mapa_NLOS,1), size(mapa_NLOS,2));
    
    % canal a omitir

        for i = 1:size(mapa_NLOS,1)
            for j = 1:size(mapa_NLOS,2) 
                if  ~isnan(mapa_NLOS(i,j))
                    mapa_LOS(i,j)=max(m_ap(i,j,grado(find(grado(:,4) ~= 1),2)));
                end
            end
        end

    colormap('default');
    imagesc(mapa_LOS);
    colorbar
    
end

function mtr = llenar(mtr, dim1, dim2)  
    
    mtr(1:dim1,1:dim2)=-90;

end