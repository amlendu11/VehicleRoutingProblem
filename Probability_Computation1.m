function[y] = Probability_Computation1(tao1,miu1,left_node,alpha,beta)
numerator = zeros(1,size(left_node,2));
denominator = 0;
for i = 1:size(left_node,2)
     numerator(1,i) = (tao1(1,i)^alpha)*((miu1(1,i))^beta);
     denominator = denominator + numerator(1,i);    
end
y(1,1) = 0;
for j = 1:size(left_node,2)
    y(1,j+1) = y(1,j)+ (numerator(1,j)/denominator);
end

        