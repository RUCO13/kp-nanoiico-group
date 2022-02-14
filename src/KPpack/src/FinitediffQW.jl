function mesh(Npts,layer,n)
    len=0
    boundary=zeros(n);
    
    for i in 1:length(layer)
        len += layer[i].size
        boundary[i]=len
    end
    dx=len/Npts; X=zeros(Npts)
    
    for i in 1:Npts
        X[i]=(i-1)*dx
    end
    
    return X, boundary

end

# =================================================================================================================
# The next matrices are taken from:
# *Michał Marchewka, et.al., Finite-difference method applied for eight-band kp model for Hg1−xCdxTe/HgTe quantum well, International Journal of 
#  Modern Physics B, 2017
# ===================================================================================================

function A1(mlayer,n)
    mp=mlayer[n];
    a1diagvec=[2*mp.F+1,2*mp.F+1,-mp.g1-mp.g2,-mp.g1+mp.g2,-mp.g1+mp.g2,-mp.g1-mp.g2,-mp.g1,-mp.g1];
    A1diag=Diagonal(a1diagvec);
    A1aux=zeros(8,8);
    A1aux[4,7]=-sqrt(2)*mp.g2;A1aux[5,8]=sqrt(2)*mp.g2;
    A1=A1aux'+A1aux+A1diag
    return A1
end

function A2(mlayer,n,kx,ky,c,cp)
    #c=0.038;
    mp=mlayer[n]
    kplus=kx+im*ky; kminus=kx-im*ky;
    mu=(mp.g3-mp.g2)/2; gamma=(mp.g3+mp.g2)/2;
    R=-c*sqrt(3)*(mu*kplus*conj(kplus)-gamma*kminus*conj(kminus)); P=sqrt(cp*c*mp.Ep);
    A2aux=im*zeros(8,8)
    A2aux[1,3]=-(1/sqrt(2))*P*kplus; A2aux[1,5]=(1/sqrt(6))*P*kminus; A2aux[1,8]=-(1/sqrt(3))*P*kminus;
    A2aux[2,4]=-(1/sqrt(6))*P*kplus; A2aux[2,6]=(1/sqrt(2))*P*kminus; A2aux[2,7]=-(1/sqrt(3))*P*kplus;
    A2aux[3,5]=R; A2aux[3,8]=-sqrt(2)*R;
    A2aux[4,6]=R;
    A2aux[6,7]=sqrt(2)*R';
    A2=A2aux+A2aux'
    
    return A2
end

function A3(mlayer,n)
    mp=mlayer[n]
    a1diagvec=[2*mp.F+1,2*mp.F+1,-mp.g1+2*mp.g2,-mp.g1-2*mp.g2,-mp.g1-2*mp.g2,-mp.g1+2*mp.g2,-mp.g1,-mp.g1];
    A1diag=Diagonal(a1diagvec);
    A1aux=zeros(8,8);
    A1aux[4,7]=2*sqrt(2)*mp.g2;A1aux[5,8]=-2*sqrt(2)*mp.g2;
    A1=A1aux'+A1aux+A1diag
    return A1
end

function Eq(mlayer,n)
    mp=mlayer[n]
    #a1diagvec=[mp.Eg,mp.Eg,mp.Eg+mp.VBO,mp.Eg-mp.VBO,mp.Eg-mp.VBO,mp.Eg+mp.VBO,mp.VBO-mp.delta,mp.VBO-mp.delta];
    a1diagvec=[mp.Eg,mp.Eg,mp.VBO,mp.VBO,mp.VBO,mp.VBO,mp.VBO-mp.delta,mp.VBO-mp.delta];
    eq=Diagonal(a1diagvec);
    
    return eq 
end

function B1(mlayer,n,kx,ky,c,cp)
   #c=0.038;
    mp=mlayer[n]
    kplus=kx+im*ky; kminus=kx-im*ky;
    P=sqrt(cp*c*mp.Ep);
    
    B1=zeros(8,8)*im;
    
    B1[1,4]=sqrt(2/3)*P; B1[1,7]=-sqrt(1/3)*P; 
    B1[2,5]=sqrt(2/3)*P; B1[2,8]=sqrt(1/3)*P;
    #B1[3,4]=2*sqrt(3)*mp.g3*kminus; B1[3,7]=-sqrt(6)*mp.g3*kminus;
    B1[4,1]=sqrt(2/3)*P; #B1[4,8]=sqrt(3)*sqrt(6)*mp.g3*kminus;
    B1[5,2]=sqrt(2/3)*P; #B1[5,7]=sqrt(3)*sqrt(6)*mp.g3*kplus;
    #B1[6,5]=-2*sqrt(3)*mp.g3*kplus; B1[6,8]=-sqrt(6)*mp.g3*kplus;
    B1[7,1]=-sqrt(1/3)*P;
    B1[8,2]=sqrt(1/3)*P;
    
    return B1
end 

function B1wb(mlayer,n,kx,ky,c,cp)
    #c=0.038;
    mp=mlayer[n]; mp1=mlayer[n+1];
    kplus=kx+im*ky; kminus=kx-im*ky;
    P=sqrt(cp*c*mp.Ep);
    
    B1=zeros(8,8)*im;
    
    B1[1,4]=sqrt(2/3)*P; B1[1,7]=-sqrt(1/3)*P; 
    B1[2,5]=sqrt(2/3)*P; B1[2,8]=sqrt(1/3)*P;
    #B1[3,4]=2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus; B1[3,7]=-sqrt(6)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus;
    B1[4,1]=sqrt(2/3)*P; #B1[4,5]=2*kminus*(mp.k-mp1.k); B1[4,8]=sqrt(3)*sqrt(6)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kminus;
    B1[5,2]=sqrt(2/3)*P; #B1[5,7]=sqrt(3)*sqrt(6)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kplus;
    #B1[6,5]=-2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus; B1[6,8]=-sqrt(6)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus;
    B1[7,1]=-sqrt(1/3)*P; #B1[7,8]=2*kminus*(mp.k-mp1.k);
    B1[8,2]=sqrt(1/3)*P;
    
    return B1
end

function C1wb(mlayer,n,kx,ky,c,cp)
    #c=0.038;
    mp=mlayer[n]; mp1=mlayer[n-1];
    kplus=kx+im*ky; kminus=kx-im*ky;
    P=sqrt(cp*c*mp.Ep);
    
    B1=zeros(8,8)*im;
    
    B1[1,4]=sqrt(2/3)*P; B1[1,7]=-sqrt(1/3)*P; 
    B1[2,5]=sqrt(2/3)*P; B1[2,8]=sqrt(1/3)*P;
    #B1[3,4]=2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus; B1[3,7]=-sqrt(6)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus;
    B1[4,1]=sqrt(2/3)*P; #B1[4,5]=2*kminus*(mp.k-mp1.k); B1[4,8]=sqrt(3)*sqrt(6)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kminus;
    B1[5,2]=sqrt(2/3)*P; #B1[5,7]=sqrt(3)*sqrt(6)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kplus;
    #B1[6,5]=-2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus; B1[6,8]=-sqrt(6)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus;
    B1[7,1]=-sqrt(1/3)*P; #B1[7,8]=2*kminus*(mp.k-mp1.k);
    B1[8,2]=sqrt(1/3)*P;
    
    return B1
end

function B2(mlayer,n,kx,ky,dx)
    mp=mlayer[n]
    kplus=kx+im*ky; kminus=kx-im*ky;
    B2a=zeros(8,8)*im;
    B2a[4,3]=-2*sqrt(3)*mp.g3*kminus; 
    B2a[5,6]=2*sqrt(3)*mp.g3*kplus;
    B2a[7,3]=-sqrt(2)*sqrt(3)*mp.g3*kminus; B2a[7,5]=-sqrt(6)*sqrt(3)*mp.g3*kplus;
    B2a[8,4]=-sqrt(6)*sqrt(3)*mp.g3*kminus; B2a[8,6]=sqrt(2)*sqrt(3)*mp.g3*kplus;
    
    #B2=(im/(2*dx))*B2a'
    B2=B2a'
    return B2
end

function B2wb(mlayer,n,kx,ky,dx)
    mp=mlayer[n]; mp1=mlayer[n+1];
    kplus=kx+im*ky; kminus=kx-im*ky;
    B2a=zeros(8,8)*im;
    B2a[4,3]=-2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus; 
    B2a[5,4]=2*kminus*(mp.k-mp1.k); B2a[5,6]=2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus;
    B2a[7,3]=-sqrt(2)*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus; B2a[7,5]=-sqrt(6)*sqrt(3)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kplus;
    B2a[8,4]=-sqrt(6)*sqrt(3)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kminus; B2a[8,6]=sqrt(2)*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus; B2a[8,7]=2*kminus*(mp.k-mp1.k);
    
    B2=B2a'
    return B2
end

function C2wb(mlayer,n,kx,ky,dx)
    mp=mlayer[n]; mp1=mlayer[n-1];
    kplus=kx+im*ky; kminus=kx-im*ky;
    B2a=zeros(8,8)*im;
    B2a[4,3]=-2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus; 
    B2a[5,4]=2*kminus*(mp.k-mp1.k); B2a[5,6]=2*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus;
    B2a[7,3]=-sqrt(2)*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kminus; B2a[7,5]=-sqrt(6)*sqrt(3)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kplus;
    B2a[8,4]=-sqrt(6)*sqrt(3)*(mp.g3+mp1.g3-(1/3)*(mp.k-mp1.k))*kminus; B2a[8,6]=sqrt(2)*sqrt(3)*(mp.g3+mp1.g3+mp.k-mp1.k)*kplus; B2a[8,7]=2*kminus*(mp.k-mp1.k);
    
    B2=B2a'
    return B2
end
#===========================================#

function A(mlayer,n, kx, ky,dx,c,cp)
    #c=0.038;
    kpar=kx^2+ky^2;
    a1=A1(mlayer,n);
    a2=(1/c)*A2(mlayer,n,kx,ky,c,cp);
    #a2=A2(mlayer,n,kx,ky,c,cp);
    a3=A3(mlayer,n);
    eq=Eq(mlayer,n);
    A=c*(a1*kpar+a2+(2/dx^2)*a3) + eq
    return A
end

function Ab1(mlayer,n,kx,ky,dx,c,cp)
    #c=0.038;
    kpar=kx^2+ky^2;
    a1b=A1(mlayer,n);
    a2b=(1/c)*A2(mlayer,n,kx,ky,c,cp);
    #a2b=A2(mlayer,n,kx,ky,c,cp);
    a3b=A3(mlayer,n); a3w=A3(mlayer,n+1);
    eq=Eq(mlayer,n);
    A=c*(a1b*kpar+a2b+a3b*(1/dx^2)+(a3b+a3w)*(1/(2*dx^2))) + eq
    return A
end

function Ab2(mlayer,n,kx,ky,dx,c,cp)
    #c=0.038;
    kpar=kx^2+ky^2;
    a1w=A1(mlayer,n);
    a2w=(1/c)*A2(mlayer,n,kx,ky,c,cp);
    #a2w=A2(mlayer,n,kx,ky,c,cp);
    a3w=A3(mlayer,n); a3b=A3(mlayer,n-1);
    eq=Eq(mlayer,n);
    A=c*(a1w*kpar+a2w+a3w*(1/dx^2)+(a3b+a3w)*(1/(2*dx^2))) + eq
    return A
end

function B(mlayer,n,kx,ky,dx,c,cp)
    #c=0.038;
    a3=A3(mlayer,n); b1=(1/c)*B1(mlayer,n,kx,ky,c,cp); b2=B2(mlayer,n,kx,ky,dx);
    
    b=c*((-1/(dx*dx))*a3+(-im/(2*dx))*b1+(im/(2*dx))*b2);
    
    return b
end

function Bb1(mlayer,n,kx,ky,dx,c,cp)
    #c=0.038;
    a3b=A3(mlayer,n); a3w=A3(mlayer,n+1);
    b1wb=(1/c)*B1wb(mlayer,n,kx,ky,c,cp); b2wb=B2wb(mlayer,n,kx,ky,dx);
    
    B1b=c*(-(a3b+a3w)*(1/(2*dx*dx))+b1wb*(im/(2*dx))+b2wb*(-im/(2*dx)));
    
    return B1b

end

function C(mlayer,n,kx,ky,dx,c,cp)
    #c=0.038;
    a3=A3(mlayer,n); b1=(1/c)*B1(mlayer,n,kx,ky,c,cp); b2=B2(mlayer,n,kx,ky,dx);
    
    c=c*((-1/(dx*dx))*a3+(im/(2*dx))*b1+(-im/(2*dx))*b2);
    
    return c
end

function Cb2(mlayer,n,kx,ky,dx,c,cp)
    #c=0.038;
    a3b=A3(mlayer,n); a3w=A3(mlayer,n-1);
    c1wb=(1/c)*C1wb(mlayer,n,kx,ky,c,cp); c2wb=C2wb(mlayer,n,kx,ky,dx);
    
    B1b=c*(-(a3b+a3w)*(1/(2*dx*dx))+c1wb*(-im/(2*dx))+c2wb*(im/(2*dx)));
    
    return B1b

end

# =================================================================================================================
# Matrix Hamiltonian 
# =================================================================================================================

function QWHamiltonianMatrix(mlayer,kx,ky,dx,len,bP,c,cp)
    AmV=Array{Matrix{ComplexF64}}(undef, len); CmV=Array{Matrix{ComplexF64}}(undef, len-1); BmV=Array{Matrix{ComplexF64}}(undef, len-1)  
    j=1
    for i in 1:len
        boundP=bP[j]
        if i==1
            AmV[i]=A(mlayer,i,kx,ky,dx,c,cp)
            BmV[i]=B(mlayer,i+1,kx,ky,dx,c,cp)
        elseif i==len
            AmV[i]=A(mlayer,i,kx,ky,dx,c,cp)
            CmV[i-1]=C(mlayer,i-1,kx,ky,dx,c,cp)
        elseif i==boundP-1
            AmV[i]=A(mlayer,i,kx,ky,dx,c,cp)
            BmV[i]=Bb1(mlayer,i+1,kx,ky,dx,c,cp)
            CmV[i-1]=C(mlayer,i-1,kx,ky,dx,c,cp)
        elseif i==boundP
            AmV[i]=Ab1(mlayer,i,kx,ky,dx,c,cp)
            BmV[i]=B(mlayer,i+1,kx,ky,dx,c,cp)
            CmV[i-1]=C(mlayer,i-1,kx,ky,dx,c,cp)
        elseif i==boundP+1
            AmV[i]=Ab2(mlayer,i,kx,ky,dx,c,cp)
            BmV[i]=B(mlayer,i+1,kx,ky,dx,c,cp)
            CmV[i-1]=C(mlayer,i-1,kx,ky,dx,c,cp)
        elseif i==boundP+2
            AmV[i]=A(mlayer,i,kx,ky,dx,c,cp)
            BmV[i]=B(mlayer,i+1,kx,ky,dx,c,cp)
            CmV[i-1]=Cb2(mlayer,i-1,kx,ky,dx,c,cp)

            if j!=length(bP)   j+=1 end
            
        else
            AmV[i]=A(mlayer,i,kx,ky,dx,c,cp)
            BmV[i]=B(mlayer,i+1,kx,ky,dx,c,cp)
            CmV[i-1]=C(mlayer,i-1,kx,ky,dx,c,cp)
        end
    end

    return sparse(BlockTridiagonal(CmV, AmV, BmV))
end