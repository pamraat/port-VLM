function v=locvelo(x,y,z,t,vinf)

    [x0, y0, z0, x0dot, y0dot, z0dot, phi, theta, psi, p, q, r]=rates(vinf,t);
    
    R1=[cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];
    R2=[cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];
    R3=[1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];
    R=R3*R2*R1;
    
    v=R*[-x0dot; -y0dot; -z0dot]+[-q*x+r*y; -r*x+p*z; -p*y+q*x];
    v=v';
end
    
    