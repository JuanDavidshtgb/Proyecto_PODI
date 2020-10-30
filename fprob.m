    Imagen_Brain = imread('pp11.jpg');
    
    %Imagen_Bone = imread('p02.jpg');
    figure(1),
    subplot(2,1,1),imshow(Imagen_Brain)           
    s = size(Imagen_Brain);                                                    %Tama�o de la Imagen
    [T,EM] = graythresh(Imagen_Brain);                                         %Segmentacion OTSU
    BW = imbinarize(Imagen_Brain,T);                                           %Binarizacion de la Imagen con Segmentacion OTSU
    BW2 = imfill(BW,'holes');                                                  %Rellena huecos de BW; BW2=Imagen sin huecos
    BW3 = bwareafilt(BW2,1);                                                   %Mantiene el objeto mas grande(Contorno de la Cabeza); BW3=Imagen del Contorno del Craneo
    BW7 = uint8(BW3);                                                          %BW3 como imagen uint8
    BW4 = BW7 & Imagen_Brain;                                                  %Segmentacion de prueba
    BW_Prueba = uint8(Imagen_Brain.*0);
    for i= 2:s(1)-1
        for j= 2:s(2)-1
           if (Imagen_Brain(i,j)> 240)
             BW_Prueba(i,j) = 1;
           else
            BW_Prueba(i,j) = 0;
           end
        end
    end
    BW_Prueba2 = logical(BW_Prueba);                                           %BW_Prueba2 = Hueso del Craneo + Otros
    BW_Prueba3 = bwareafilt(BW_Prueba2,1);                                     %Mantener el objeto mas grande; BW_Prueba3 = Hueso del Craneo Aislado
    BW_Prueba4 = xor(BW,BW_Prueba3);                                           %Operacion Logica XOR entre BW y Hueso del Craneo Aislado
    BW_Prueba5 = bwareafilt(BW_Prueba4,1);                                     %Mantener el objeto mas grande de XOR
    BW_Prueba6 = BW_Prueba3 + BW_Prueba5;                                      %Hueso del Craneo + Cerebro
    BW_Prueba6_Morph = bwmorph(BW_Prueba6,'remove');                           %Morfoligia del Hueso del craneo y Cerebro
    [Label,n] = bwlabel(BW_Prueba6_Morph,8);                                   %Etiquetado de los contornos
    cc = bwconncomp(BW_Prueba6_Morph);                                         %Cantidad de Objetos con Conectividad 8
    Etiquetas = labelmatrix(cc);                                               %Etiquetado de los Objetos
    Color = label2rgb(Etiquetas);                                              %Aplicacion de Color a las Etiquetas
    Objetos = cc.NumObjects;                                                   %Cantidad del Objetos en la Imagen
    Et_Craneo = (Label==1);                                                    %Etiqueta del Craneo (Primer objeto)
    g = [1 max(max(Label))];                                                   %Vector de tama�o [1 Maximo valor de Label]
    Area = zeros(g);                                                           %Vecotr de Areas
    BW_Areas_Afectadas = (BW_Prueba6_Morph).*0;                                %%
    for j=2:max(max(Label))
        var = (Label== j);
        ar = imfill(var,'holes');
        Area(j) = sum(ar(:));
        BW_Areas_Afectadas = or(BW_Areas_Afectadas,ar);
    end                                                                        %Ciclo para Tomar las Areas de Cada Objeto
    Area_Afectada = sum(Area);                                                 %Total del Area Afectada
    BW_Area_Craneo = imfill(Et_Craneo,'holes');                                %Area del Craneo
    Area_Craneo = bwarea(BW_Area_Craneo);                                      %Tomar Area del Craneo
    Area_Porcentaje = (Area_Afectada/Area_Craneo)* 100;                        %Area Afectada como Porcentaje
    Im_Craneo = uint8(BW_Area_Craneo);
    A = double(Im_Craneo.*Imagen_Brain);
    BW_Areas_Cerebro = Et_Craneo + BW_Areas_Afectadas; 
    BW_Morph_Areas = bwmorph(BW_Areas_Afectadas,'skel',Inf);
    Terminaciones = sum(sum(bwmorph(BW_Morph_Areas,'endpoints')));
    Num_Euler = bweuler(BW_Areas_Cerebro);
    cp1 = [Area_Afectada Objetos Terminaciones Num_Euler]';                                                                       
    resbrain=sim(redDIFBrain,cp1); 
    resbrain=round(resbrain);                                                                       
    subplot(2,1,2),imshow(Imagen_Brain),
    if resbrain == 1
        title('Hay hematoma')
    elseif resbrain==2
        title('Sano')
    else
        title('INDEFINIDO')
    end

%%%BONE%%%    
    %s=size(Imagen_Bone);
    %BW_Prueba_Bone = uint8(Imagen_Bone.*0);
    %for i= 2:s(1)-1
    %    for j= 2:s(2)-1
    %        if (Imagen_Bone(i,j)> 120)
    %        BW_Prueba_Bone(i,j) = 1;
    %        else
    %        BW_Prueba_Bone(i,j) = 0;
    %        end
    %    end
    %end
    %BW_Prueba_Bone2 = logical(BW_Prueba_Bone);                                 %BW_Prueba2 = Hueso del Craneo + Otros
    %BW_Prueba_Bone3 = imfill(BW_Prueba_Bone2,'holes');
    %BW_Morph_Bone = bwmorph(BW_Prueba_Bone3,'skel',Inf);
    %Terminaciones_Bone = sum(sum(bwmorph(BW_Morph_Bone,'endpoints')));
    %Bifurcaciones_Bone = sum(sum(bwmorph(BW_Morph_Bone,'branchpoints')));
    %BW_Morph_Bone2 = bwmorph(BW_Prueba_Bone3,'remove');                    %Morfoligia del Hueso del craneo y Cerebro
    %cc_Bone = bwconncomp(BW_Morph_Bone2);                                  %Cantidad de Objetos con Conectividad 8
    %Etiquetas_Bone = labelmatrix(cc_Bone);                                 %Etiquetado de los Objetos
    %Objetos_Bone = cc_Bone.NumObjects;                                     %Cantidad del Objetos en la Imagen
    %BW_Prueba_Bone4 = not(BW_Prueba_Bone3);
    %cc_Bone2 = bwconncomp(BW_Prueba_Bone4);
    %cp2 = [Bifurcaciones_Bone Terminaciones_Bone Objetos_Bone]';
    %resbone = sim(redDIFBone,cp2);
    %resbone = round(resbone);
    %figure(2), subplot(2,1,1),imshow(Imagen_Bone)
    %subplot(2,1,2),imshow(Imagen_Bone),

    %if resbone == 1
    %    title('Hay fractura')
    %elseif resbone == 2
    %    title('No hay fractura')
    %else
    %    title('INDEFINIDO')
    %end


% Para correr � q=imread('o5.bmp');exprob

