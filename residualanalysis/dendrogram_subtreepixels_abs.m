function [Z,H,T,perm] = dendrogram_subtreepixels(data, method, p , x_mu, y_mu, savethis, nameappend)
% [Z,H,T,perm] = dendrogram_subtreepixels(data, method, p , x_mu, y_mu, savethis, nameappend)

% dveccr= reshape(dpixc,15^2, 1000);
if ~exist('savethis', 'var')
    savethis = 0;
end
if ~exist('nameappend', 'var')
    nameappend=[];
else 
    nameappend=['_' nameappend];
end

sized = size(data);
dveccr= reshape(data,sized(1)*sized(2), sized(3));
ccd = (corrcoef(dveccr'));
e=eye(size(ccd));
ccdflip=e-(ccd-e);
ccds=squareform(1-ccdflip);

Z = linkage(ccds,method);
[H,T,perm] = dendrogram(Z,0);
co= get(gca, 'colororder');
set(H,'color','k')
ylim([0 max(Z(:,3))])

zvalues = input('Z values from dendrogram[val1*10^4 val2*10^4 ...]\n');
clear('cl')
for ii=1:length (zvalues)
    cl(ii).ixZ = find(round(10^4*Z(:,3))==zvalues(ii));
end

imz2 = zeros([size(dveccr,1) 1]);
[H,T,perm] = dendrogram(Z,0);
co= get(gca, 'colororder');
set(H,'color','k')
ylim([0 max(Z(:,3))])

lcl=length(cl);
lco=length(co);
rat = lcl/lco;

if rat > 1 %more clusters than colors
    co = repmat(co, ceil(rat), 1);
end

for ii=1:lcl
    [cl(ii).ixZ_vec, cl(ii).endleaves_vec] = recursivesubtree(Z, cl(ii).ixZ, [], []);
    set(H(cl(ii).ixZ_vec), 'color', co(ii,:))
    imz2(cl(ii).endleaves_vec, ii)=1;
end
set(H,'linewidth',2)

if savethis
    name=['dendrogram-' method nameappend];
    fprintf('saving the dendrogram figure:'' %s ''\n',name)
    SaveImageFULL(name)
    save ([name '_zvalues'], 'zvalues')
end


imzRGB = reshape(imz2*co(1:lcl,:),sized(1), sized(2), 3);
dipshow(joinchannels('RGB', imzRGB));
hold on 
if exist ('p', 'var')
    if ~isempty(p)
%         scatter(p.x_vec-0.5, p.y_vec-0.5,200,'xw')
%         scatter(p.x_vec, p.y_vec,'w')
        scatter(p.x_vec, p.y_vec,[],[.9 .9 .9])
    end
end
if and(exist ('x_mu', 'var'), exist ('y_mu', 'var'))
%     scatter(x_mu-1, y_mu-1,[],'xw')
    scatter(x_mu-1, y_mu-1,[],[.9 .9 .9],'x')
end
if savethis
    name=['clustfig-' method nameappend];
    fprintf('saving the clustered figure:'' %s ''\n',name)
    SaveImageFULL(name)
end

