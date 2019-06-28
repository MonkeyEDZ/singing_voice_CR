function [B,A] = warppoles(a,alpha)
%  [B,A] = warppoles(a,alpha)  warp an all-pole polynomial by substitution
%    Warp all-pole polynomials defined by rows of a by the first-order 
%    warp factor alpha.  Negative alpha shifts poles up in frequency.
%    Output polynomials have zeros too, hence B and A.
% 2003-12-10 dpwe@ee.columbia.edu

% Construct z-hat^-1 polynomial
d = [-alpha 1];
c = [1 -alpha];

[nrows,order] = size(a);

A = zeros(nrows, order);
B = zeros(nrows, order);

B(:,1) = a(:,1);
A(:,1) = ones(nrows,1);

dd = d;
cc = c;

% This code originally mapped zeros.  I adapted it to map
% poles just by interchanging b and a, then swapping again at the 
% end.  Sorry that makes the variables confusing to read.

for n = 2:order

  for row = 1:nrows

    % add another factor to num, den
    B(row,1:order) = conv(B(row,1:(order-1)), c);

  end

  % accumulate terms from this factor
  B(:,1:length(dd)) = B(:,1:length(dd)) + a(:,n)*dd;
    
  dd = conv(dd, d);
  cc = conv(cc, c);

end
    
% Construct the uniform A polynomial (same for all rows)
AA = 1;
for n = 2:order
  AA = conv(AA,c);
end
A = repmat(AA, nrows, 1);
  

% Exchange zeros and poles
T = A; A = B; B = T;
