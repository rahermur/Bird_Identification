function W = lda(xin,y,ncomps)

%**************************************************************************
%   function W = lda(x,y,ncomps)
%
%   Linear Discriminant Analysis
%
%   ENTRADAS
%   x       es el conjunto de datos. Cada columna, una muestra
%   y       es el vector de clases
%   ncomps  es el numero de componentes a extraer. Lo que va a hacer es
%           aplicar el procedimiento iterativamente, y buscando en los
%           espacios complementarios generados, donde busca sucesivas
%           componentes
%   SALIDA
%   W       matriz de transformacion (z=Wx)
%
%   Referencia: Pattern Classification, R. Duda and P. Hart
%**************************************************************************

min_eigv = 0;
xin = xin';
[ndims,N] = size(xin);
clases = unique(y);
n_clases = length(clases);

I = eye(ndims);
W = [];
B = I;

    M = mean(xin,2);
    Sw = zeros(ndims);
    Sb = zeros(ndims);
    for i=1:n_clases
        %   Subconjuntos de muestras
        xc{i}   = xin(:,find(y==clases(i)));
        n{i}  = size(xc{i},2);
        
        %   Probabilidades de cada clase
        p{i}  = n{i}/N;
        %   Matrices de autocorrelaci´on
        c{i}  = cov(xc{i}');
        
        m{i} = mean(xc{i},2);
        Sw   = Sw + p{i}*c{i};
        Sb   = Sb + p{i}*(m{i} - M)*(m{i} - M)';
    end
    
    [V,D] = eig(Sb,Sw);
    % Nos quedamos con el autovalor de mayor valor
    
    % Expandimos en la base
    inds = find((diag(D)>min_eigv)&(imag(diag(D))==0));
    %     if length(inds)<1 
    %         fprintf('LDA no ha encontrado autovalores positivos\n');
    %         keyboard;
    %     end
    V = V(:,inds);
    d = diag(D(inds,inds));
%     % Los ordenamos
    [kk,inds] = sort(d);
%     
%     w = V(:,inds(end));
%     % Expandimos
%     
%    
%     w = B*w;
%     w = w/norm(w);
%     
% 
%     W = [W w];
%     T = gram_schmidt([W I(:,k+1:end)]);
%     B = T(:,k+1:end);


W = fliplr(V(:,inds))';
W = W(1:ncomps,:);
% W = (W*W')^(-1/2)*W;
