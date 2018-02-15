function[y] = Probability_Computation(tao,miu,alpha,beta,m)
numerator = zeros(m,m);
denominator = zeros(1,m);
for i = 1:m
    for j = 1:m
        if i ~=j
        numerator(i,j) = (tao(i,j)^alpha)*((miu(i,j))^beta);
        denominator(1,i) = denominator(1,i) + numerator(i,j);
        else
            numerator(i,j) = 0;
        end
    end
end
for i = 1:m
    y(i,1) = 0;
    for j = 1:m
        y(i,j+1) = y(i,j)+ (numerator(i,j)/denominator(1,i));
    end
end
        