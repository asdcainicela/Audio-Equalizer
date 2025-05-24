function [X,FREC] = fourier(x,Fs)

    M = length(x);
    n_m = 2^nextpow2(M);

    X = fft(x,n_m);  %Calculo la transformada de Fourier
    X = X(1:n_m/2+1);

    d_f = Fs/n_m;
    FREC = 0:d_f:d_f*(n_m/2);

end