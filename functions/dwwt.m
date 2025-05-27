function [A,B]=dwwt(R,lod,lhd)

A1=[];
B1=[];
A=[];
B=[];
y1=[];

L=length(lod);

N=length(R);
res=rem(L,N);
co=floor(L/N);

y1=R;

for i=1:co
    y1=[R y1 R];
end;

if res>0
   y1=[R(N-(res-1)+1:N) y1 R(1:res-1)];
end;

[A1,B1]=dwt(y1,lod,lhd);

A=A1(L-1:L+(N/2)-2);
B=B1(L-1:L+(N/2)-2);
