function [G]=rwwt(A2,B2,lor,lhr)

% AA2=[]; old code
% BB2=[]; old code
% AA=[]; old code
% BB=[]; old code
% C=[]; old code
% G=[]; old code


AA2=A2;
BB2=B2;

L=length(lor);
N = 2*length(A2);
res=rem(L,N);
co=floor(L/N);

for i=1:co
   AA2=[A2 AA2 A2];
   BB2=[B2 BB2 B2];
end

AA=[A2(floor((N-(res-1))/2)+1:length(A2)) AA2 A2(1:floor((res-1)/2))];
BB=[B2(floor((N-(res-1))/2)+1:length(B2)) BB2 B2(1:floor((res-1)/2))];

% if L<N
%    D=L;
% else
%    D=N;
% end;   
%AA=AA*D;
%BB=BB*D;

%-----------Parche start
minLen = min(length(AA), length(BB));
AA = AA(1:minLen);
BB = BB(1:minLen);
%------------Parche end

% Reconstrucción con la IDWT usando los filtros de reconstrucción
[C]=idwt(AA,BB,lor,lhr);


if res==0
   fac=1;
else
   fac=0;
end

r=3+fac; %-- old code
%G=C(r+1:r+N); %--old code

%--- start parche 2
if (r+N) > length(C)
    warning('r+N=%d exceeds length(C)=%d. Truncating.', r+N, length(C));
    G = C(r+1:end);
else
    G = C(r+1 : r+N);
end

%--- end parche

