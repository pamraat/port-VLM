function [a,b,nor]=infcoeffunsteadyback(x,y,z,stepno)
n=size(x,1)-stepno;
m=(size(x,2)-1)/2;
for i=1:n+stepno-1
for j=1:2*m
    if(i~=n+stepno-1)
    h(i,:,j)=[x(i,j)+(x(i+1,j)-x(i,j))/4 y(i,j)+(y(i+1,j)-y(i,j))/4 z(i,j)+(z(i+1,j)-z(i,j))/4];
    h(i+1,:,j)=[x(i+1,j)+(x(i+2,j)-x(i+1,j))/4 y(i+1,j)+(y(i+2,j)-y(i+1,j))/4 z(i+1,j)+(z(i+2,j)-z(i+1,j))/4];
    h(i,:,j+1)=[x(i,j+1)+(x(i+1,j+1)-x(i,j+1))/4 y(i,j+1)+(y(i+1,j+1)-y(i,j+1))/4 z(i,j+1)+(z(i+1,j+1)-z(i,j+1))/4];
    h(i+1,:,j+1)=[x(i+1,j+1)+(x(i+2,j+1)-x(i+1,j+1))/4 y(i+1,j+1)+(y(i+2,j+1)-y(i+1,j+1))/4 z(i+1,j+1)+(z(i+2,j+1)-z(i+1,j+1))/4];
    h32=h(i,:,j+1)-h(i+1,:,j);
    h41=h(i+1,:,j+1)-h(i,:,j);
    coll(i,:,j)=(h(i,:,j)+h(i+1,:,j+1)+h(i+1,:,j)+h(i,:,j+1))/4;
    nor(i,:,j)=cross(h41,h32)/norm(cross(h41,h32));
    else
    h(n+stepno,:,j)=[x(n+stepno,j)+(x(n+stepno,j)-x(n+stepno-1,j))/4 y(n+stepno,j)+(y(n+stepno,j)-y(n+stepno-1,j))/4 z(n+stepno,j)+(z(n+stepno,j)-z(n+stepno-1,j))/4];
    h(n+stepno,:,j+1)=[x(n+stepno,j+1)+(x(n+stepno,j+1)-x(n+stepno-1,j+1))/4 y(n+stepno,j+1)+(y(n+stepno,j+1)-y(n+stepno-1,j+1))/4 z(n+stepno,j+1)+(z(n+stepno,j+1)-z(n+stepno-1,j+1))/4];
    h32=h(n+stepno-1,:,j+1)-h(n+stepno,:,j);
    h41=h(n+stepno,:,j+1)-h(n+stepno-1,:,j);
    coll(i,:,j)=(h(n+stepno-1,:,j)+h(n+stepno,:,j+1)+h(n+stepno-1,:,j+1)+h(n+stepno,:,j))/4;
    nor(i,:,j)=cross(h41,h32)/norm(cross(h41,h32));
    end
end
end

for i=1:n
for j=1:2*m
    for k=1:n
    for l=1:2*m
        [v,vw]=vortring(h(k,1,l),h(k,2,l),h(k,3,l),h(k+1,1,l),h(k+1,2,l),h(k+1,3,l),h(k+1,1,l+1),h(k+1,2,l+1),h(k+1,3,l+1),h(k,1,l+1),h(k,2,l+1),h(k,3,l+1),coll(i,1,j),coll(i,2,j),coll(i,3,j));
        a(2*m*(i-1)+j,2*m*(k-1)+l)=dot(v,nor(i,:,j));
        b(2*m*(i-1)+j,2*m*(k-1)+l)=dot(vw,nor(i,:,j));
    end
    end
end
end