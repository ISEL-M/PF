clear all
close all
clc

path(path, "C:\Users\Mihail Ababii\Desktop\Mestrado\S2\PF - Processamento de Fala\Ficheiros de fala\Trabalho 2\professor\")


global wa  ws k1 k2 p;
wa = 120;
ws = 80;
k1 = 0.0001;
k2 = k1*10;
p=16;

% test1()

[matrix, predict] = confusionTest();
confusionchart(matrix,'ColumnSummary','column-normalized')
    

function [matrix, predict] = confusionTest()
    global wa  ws k1 k2 p;
    
    soundDirTrain = './sound/training examples/';
    folderTrain = './sound/training examples/*A.wav';
    filesTrain = dir(folderTrain);

    soundDirTest = './sound/test examples/';
    folderTest = './sound/test examples/*A.wav';
    filesTest = dir(folderTest);

    matrix = zeros(11, 11);
    predict = [];
    k_train = 0;
    for train_all = 1:11:length(filesTrain)
        for train = 1:11
            file = strcat(soundDirTrain, filesTrain(train + k_train * 11).name);
            [x1, Fs] = audioread(file);
            x1 = x1/max(abs(x1));
            lsps1 = getLsps(x1, wa, ws, k1, k2, p);
            for test_all = 1:11:length(filesTest)
                bestTest = 1;
                bestDg = inf;
                k_test=0;
                for test = 1:11
                    file = strcat(soundDirTest, filesTest(test + k_test * 11).name);
                    [x2, Fs] = audioread(file);
                    x2 = x2/max(abs(x2));
                    lsps2 = getLsps(x2, wa, ws, k1, k2, p);

                    [d] = localDistance(lsps1, lsps2, p);

                    [D] = accumulatedDistance(d);

                    [Dg] = globalDistance(D);
                    if bestDg > Dg
                       bestDg = Dg;
                       bestTest = test;
                    end
                end
                predict = [predict bestTest];
                k_test = k_test + 1;
                matrix(bestTest, train) = matrix(bestTest, train)+1;
            end
        end
        k_train = k_train + 1;
    end
end

function test1()
    global wa  ws k1 k2 p;
    [x1, Fs] = audioread('sound/training examples/FAC_1A.wav');
    x1 = x1/max(abs(x1));
    lsps1 = getLsps(x1, wa, ws, k1, k2, p);

    [x2,Fs] = audioread('sound/test examples/FDC_1A.wav');
    x2 = x2/max(abs(x2));
    lsps2 = getLsps(x2, wa, ws, k1, k2, p);

    figure;
    plot(x1);
    figure;
    plot(x2);


    [d] = localDistance(lsps1, lsps2, p);
    figure;
    surf(d);

    [D] = accumulatedDistance(d);
    figure;
    surf(D);

    [Dg] = globalDistance(D);
end

function [Dg] = globalDistance(D)
    Dg=0;
    i= size(D,2);
    j= size(D,1);
    while i~=1 & j~=1
        previous = [D(j-1,i-1), D(j-1,i), D(j,i-1)];
        Dmin = min(previous);
        if(Dmin < inf)
            [j, i] = find(D==Dmin);
            Dg = Dg +1;
        else
            j = j-1;
            i = i-1;
        end
    end
    Dg = Dg +1;
    Dg = D(size(D,1)-1, size(D,2)-1) / Dg;
end

function [D] = accumulatedDistance(D)
    for i= 2:size(D,2)
        for j= 2:size(D,1)
            Dmin = min([D(j-1,i-1), D(j-1,i), D(j,i-1)]);
            D(j,i) = D(j,i) + Dmin;
        end
    end
end

function [d] = localDistance(lsps1, lsps2, p)
    I = size(lsps1,1);
    J = size(lsps2,1);
    d = ones(length(lsps2),length(lsps1))*inf;
    for j = 1:J
        for i = 1:I
            A = .5 * i - .5 * I + J;
            B = 2 * i - 2 * I + J;
            C = .5 * i;
            D = 2 * i;
            if j < A && j > B && j > C && j < D
                d(j,i)=0;
                for g = 1:p
                    aux = lsps1(i, g) - lsps2(j, g);
                    aux = aux.^2;
                    d(j,i)= d(j,i) + aux;
                end
                d(j,i) = sqrt(d(j,i));
            end
        end
    end
end

function [lsps] = getLsps(x, wa, ws, k1, k2, p)
    power = Power(x, wa, ws);
%     figure;
%     plot(power);
    [s, e] = Limit(power, k1, k2);

    lsps=[];
    for i = (s-1)*ws+1:ws:(e)*ws
        trama = x(i:i+wa-1);
        corr = autocorr(trama);
        t = toeplitz(corr(1:p));
        t2 = inv(t);

        ak = -t2 * corr(2:p+1);
        lsp = lpc2lsp([1 ak']);
        lsps = [lsps; lsp];
    end
end

function [s, e] = Limit(p, k1, k2)
    s = 1;
    e = length(p);
    for i = 1:length(p)
        if p(i) > k1
            found = 0;
            for j = i:length(p)
                if p(j) > k2
                    s = i;
                    found = 1;
                    break
                end
                if p(j) < k1
                    break
                end
            end
            if found==1
               break 
            end
        end
    end
    for i = length(p):-1:1
        if p(i) > k1
            found = 0;
            for j = i:length(p)
                if p(j) > k2
                    e = i+1;
                    found = 1;
                    break
                end
                if p(j) < k1
                    break
                end
            end
            if found==1
               break 
            end
        end
    end
end

function [power] = Power(x, wa, ws)
    power = [];
    for start_x=1:ws:length(x)
        end_x = start_x + wa -1;
        if end_x > length(x)
            break
        end
        trama = x(start_x:end_x);
        e = trama.^2;
        e = sum(e);
        p = e/wa;
        power = [power p];
    end
end