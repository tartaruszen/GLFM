function pdf = pdf_n(x,Zp, B, mu, w, s2Y, params)
    %
    % Inputs:
    %   B: K*R
    %   Zp: 1*K, where K: number of latent features

    pdf = normcdf(f_n_1(x+1,mu,w), Zp*B,sqrt(s2Y) ) - ...
        normcdf(f_n_1(x,mu,w), Zp*B, sqrt(s2Y) );
end
