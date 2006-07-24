InstallGlobalFunction(ProductOfChainMaps,function(E,e,F,f,C)
  # e=Deg(E),f=Deg(F). 
  return List([1..Size(E)-f],
    j->E[j+f]*LiftHom(C!.L[1],F[j],C!.K));
  end
);

InstallGlobalFunction(NiceIndeterminate,function(C,n)
  # Because I can't spell the alphabet backwards without looking.
  local L;
  L:=["z","y","x","w","v","u","t","s","r","q","p"];
  return X(C!.K,L[n]);
  end
);

InstallGlobalFunction(Intersperse,function(C,M,x)
  # Every time we commute an element of degree d with an element
  # of degree e, we have to multiply the product by (-1)^(d*e).
  # This function returns the factor +-1 resulting from moving
  # x from the RIGHT into its proper position in the monomial M.
  local e,f,g,fe,fo;
  e:=IndeterminateNumberOfUnivariateRationalFunction(x);
  f:=ExtRepPolynomialRatFun(M)[1];
  g:=First([1..Size(f)],x->IsOddInt(x) and f[x]>e);
  if fail=g then return 1;fi;
  fo:=f{[g,g+2..Size(f)-1]};
  fe:=f{[g+1,g+3..Size(f)]};
  return (-1)^(C!.D[e]*Sum(List([1..Size(fo)],x->C!.D[fo[x]]*fe[x])));
  end
);

InstallMethod(CohomologyRelators,
"Computes cohomology relators to degree n",
[IsCObject,IsPosInt], 

function(C,n)
local F,G,M,S,I,d,L,c,x,y,z,w,N,s,k;
CohomologyGenerators(C,n);

if not IsBound(C!.V) or Size(C!.V) < Size(C!.D) then 
  if(Size(C!.D)>11) then
    C!.V:=List([1..Size(C!.D)],x->X(C!.K,x));
  else
    C!.V:=List([1..Size(C!.D)],x->NiceIndeterminate(C,x));
  fi;
fi;
F:=PolynomialRing(C!.K,C!.V);

G:=List([1..Size(C!.D)],           # The cohomology generators.
  j->[C!.D[j],C!.V[j],C!.H[j]]);
M:=ListX(G,x->x[1]=1,ShallowCopy); # The monomials that remain.
S:=[];                             # The final answer goes here.
I:=[];                             # The leading monomials of S.
for d in [2..n] do
  L:=Set([]);                      # To be considered later.
  c:=[];                           # Already considered this round.
  for x in M do
    for y in G do
      if x[1]+y[1]=d then
        z:=x[2]*y[2];
        if not z in c then
          Append(c,[z]);
          if not IsZero(PolynomialReducedRemainder(z,I,
            MonomialLexOrdering())) then
            w:=ExtractColumn(LiftHom(C!.L[1],
              x[3][y[1]+1]
                *LiftHom(C!.L[1],y[3][1],C!.K),C!.K),1)
              *Intersperse(C,x[2],y[2]);
            if IsZero(w) then 
              Append(I,[z]);
              Append(S,[z]);
            else
              Append(L,[[z,w,x,y]]);
            fi;
          fi;
        fi;
      fi;
    od; # end y
  od; # end x
  Sort(L); # What is this all about?
  L:=Reversed(L);
  if(Size(L)<>0) then 
    N:=TriangulizedNullspaceMat(List(L,x->x[2]));
    s:=List(N,k->Sum([1..Size(L)],j->k[j]*L[j][1]));
    for x in s do
      k:=LeadingMonomialOfPolynomial(x,MonomialLexOrdering());
      RemoveElmList(L,Position(L,First(L,j->k=j[1])));
      Append(S,[x]);
      Append(I,[k]);
    od;
  fi;
  Append(M,Concatenation(
    List(L,j->[j[3][1]+j[4][1],j[1],ProductOfChainMaps(
      j[3][3],j[3][1],j[4][3],j[4][1],C)]),
    Filtered(G,j->d=j[1]))
    );
od; # end d

return [C!.V,S];
end
);
