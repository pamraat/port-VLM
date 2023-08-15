function [a,b,nor]=infcoeffblk(x,y,z,aoa)
n=size(x,1)-1;
m=(size(x,2)-1)/2;
for k=1:5
for i=1:n
for j=1:2*m
    if(i~=n)
    h(i,:,j,k)=[x(i,j,k)+(x(i+1,j,k)-x(i,j,k))/4 y(i,j,k)+(y(i+1,j,k)-y(i,j,k))/4 z(i,j,k)+(z(i+1,j,k)-z(i,j,k))/4];
    h(i+1,:,j,k)=[x(i+1,j,k)+(x(i+2,j,k)-x(i+1,j,k))/4 y(i+1,j,k)+(y(i+2,j,k)-y(i+1,j,k))/4 z(i+1,j,k)+(z(i+2,j,k)-z(i+1,j,k))/4];
    h(i,:,j+1,k)=[x(i,j+1,k)+(x(i+1,j+1,k)-x(i,j+1,k))/4 y(i,j+1,k)+(y(i+1,j+1,k)-y(i,j+1,k))/4 z(i,j+1,k)+(z(i+1,j+1,k)-z(i,j+1,k))/4];
    h(i+1,:,j+1,k)=[x(i+1,j+1,k)+(x(i+2,j+1,k)-x(i+1,j+1,k))/4 y(i+1,j+1,k)+(y(i+2,j+1,k)-y(i+1,j+1,k))/4 z(i+1,j+1,k)+(z(i+2,j+1,k)-z(i+1,j+1,k))/4];
    h32=h(i,:,j+1,k)-h(i+1,:,j,k);
    h41=h(i+1,:,j+1,k)-h(i,:,j,k);
    coll(i,:,j,k)=(h(i,:,j,k)+h(i+1,:,j+1,k)+h(i+1,:,j,k)+h(i,:,j+1,k))/4;
    if(k==3||k==5)
    nor(i,:,j,k)=-cross(h41,h32)/norm(cross(h41,h32));
    else
    nor(i,:,j,k)=cross(h41,h32)/norm(cross(h41,h32));    
    end
    else
    h(n+1,:,j,k)=[x(n+1,j,k)+(x(n+1,j,k)-x(n,j,k))/4 y(n+1,j,k)+(y(n+1,j,k)-y(n,j,k))/4 z(n+1,j,k)+(z(n+1,j,k)-z(n,j,k))/4];
    h(n+1,:,j+1)=[x(n+1,j+1,k)+(x(n+1,j+1,k)-x(n,j+1,k))/4 y(n+1,j+1,k)+(y(n+1,j+1,k)-y(n,j+1,k))/4 z(n+1,j+1,k)+(z(n+1,j+1,k)-z(n,j+1,k))/4];
    h32=h(n,:,j+1,k)-h(n+1,:,j,k);
    h41=h(n+1,:,j+1,k)-h(n,:,j,k);
    coll(i,:,j,k)=(h(n,:,j,k)+h(n+1,:,j+1,k)+h(n,:,j+1,k)+h(n+1,:,j,k))/4;
    if(k==3||k==5)
    nor(i,:,j,k)=-cross(h41,h32)/norm(cross(h41,h32));
    else
    nor(i,:,j,k)=cross(h41,h32)/norm(cross(h41,h32));    
    end
    end
end
end
end

for g=1:5
for i=1:n
for j=1:2*m 
    for g1=1:5
    for k=1:n
    for l=1:2*m
        if(k~=n)
        [v,vw]=vortring(h(k,1,l,g1),h(k,2,l,g1),h(k,3,l,g1),h(k+1,1,l,g1),h(k+1,2,l,g1),h(k+1,3,l,g1),h(k+1,1,l+1,g1),h(k+1,2,l+1,g1),h(k+1,3,l+1,g1),h(k,1,l+1,g1),h(k,2,l+1,g1),h(k,3,l+1,g1),coll(i,1,j,g),coll(i,2,j,g),coll(i,3,j,g));
        else
        const=10^10;
        [v,vw]=vortring(h(k,1,l,g1),h(k,2,l,g1),h(k,3,l,g1),h(k+1,1,l,g1),h(k+1,2,l,g1),h(k+1,3,l,g1),h(k+1,1,l+1,g1),h(k+1,2,l+1,g1),h(k+1,3,l+1,g1),h(k,1,l+1,g1),h(k,2,l+1,g1),h(k,3,l+1,g1),coll(i,1,j,g),coll(i,2,j,g),coll(i,3,j,g));
        v1=v;
        vw1=vw;
        if(g1~=3||g1~=5)
        [v,vw]=vortring(h(k+1,1,l,g1),h(k+1,2,l,g1),h(k+1,3,l,g1),h(k+1,1,l,g1)+const,h(k+1,2,l,g1),h(k+1,3,l,g1)+const*tan(aoa),h(k+1,1,l+1,g1)+const,h(k+1,2,l+1,g1),h(k+1,3,l+1,g1)+const*tan(aoa),h(k+1,1,l+1,g1),h(k+1,2,l+1,g1),h(k+1,3,l+1,g1),coll(i,1,j,g),coll(i,2,j,g),coll(i,3,j,g));
        v=v+v1;
        vw=vw+vw1;
        else
        [v,vw]=vortring(h(k+1,1,l,g1),h(k+1,2,l,g1),h(k+1,3,l,g1),h(k+1,1,l,g1)+const,h(k+1,2,l,g1),h(k+1,3,l,g1)+const*tan(-aoa),h(k+1,1,l+1,g1)+const,h(k+1,2,l+1),h(k+1,3,l+1,g1)+const*tan(-aoa),h(k+1,1,l+1,g1),h(k+1,2,l+1,g1),h(k+1,3,l+1,g1),coll(i,1,j,g),coll(i,2,j,g),coll(i,3,j,g));
        v=v+v1;
        vw=vw+vw1;
        end
        end
        a(2*m*(i-1)+j+(g-1)*2*m*n,2*m*(k-1)+l+(g1-1)*2*m*n)=dot(v,nor(i,:,j,g));
        b(2*m*(i-1)+j+(g-1)*2*m*n,2*m*(k-1)+l+(g1-1)*2*m*n)=dot(vw,nor(i,:,j,g));
    end
    end
    end
end
end
end