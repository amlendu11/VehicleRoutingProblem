% location = xlsread('location3');
demand = xlsread('demand1');
m = size(demand, 1);
V_cap = 24000;
distance = zeros(m,m);
time = zeros(m,m);
service_time = 0.1;
pop_size = 50;
lmda = 100;
q = 1;
vehicle = {};
vehicle1 = {};
best_sol = {};
n_gen = 1500;
mincost = 100000000000;
mincost = 100000000000;
mindistance = 100000000000;
minvariablecost = 1000000000;
result = zeros(1500,2);

% for i = 1:m-1
%     for j = i+1:m
%         if i ~= j
%             distance(i,j) = sqrt((location(i,1)-location(j,1))^2+(location(i,2)-location(j,2))^2);
%             distance(j,i) = distance(i,j);
%             time(i,j) = distance(i,j)/28;
%             time(j,i) = time(i,j);
%         else
%             distance(i,j) = eps;
%         end
%     end
% end
distance = xlsread('distance1');
distance = distance/1000;
time = xlsread('time1');
time = time/3600;
for i = 1:m
    for j = 1:m
        if i == j
            distance(i,j) = eps;
        end
        if distance(i,j) == 0
            distance(i,j) = 25;
        end
        if (i ~= j && time(i,j) == 0)
            time(i,j) = 0.0001;
        end
    end
end
for i = 1:pop_size
    all_location = 1:m;
    left_node = all_location(all_location ~= 1);
    while (size(left_node,2)>0)
        for j = 1:15
            %         for j = 1:22
            %             if (size(left_node,2) == 0 && j~=22)
            if (size(left_node,2) == 0)
                break
            end
            if j == 1
                vehicle{q}(1,j) = 1;
            elseif j == 15
                %             elseif j == 22
                vehicle{q}(1,j) = 1;
            end
            %             if (j ~= 1 && j ~= 22)
            if (j ~= 1 && j ~= 15)
                r1 = max(1, round(rand*size(left_node,2)));
                vehicle{q}(1,j) = left_node(1,r1);
            end
            if (rem(q,3) == 0 && j == 15)
                r2 = max(1, round(rand*size(left_node,2)));
                vehicle{q}(1,j) = left_node(1,r2);
                vehicle{q}(1,j+1) = 1;
            end
            left_node = left_node(left_node ~= vehicle{q}(1,j));
        end
        q = q + 1;
    end
end
for i = 1:n_gen
    sumload = zeros(1,pop_size);
    totaltime = zeros(1,pop_size);
    totaldistance = zeros(1,pop_size);
    totalcost = zeros(1,pop_size);
    totalparttime = zeros(1,size(vehicle,2));
    totalpartdistance = zeros(1,size(vehicle,2));
    totalpartcost = zeros(1,size(vehicle,2));
    partsumload = zeros(1,size(vehicle,2));
    numerator = zeros(1,pop_size);
    probability = zeros(1,pop_size+1);
    denominator = 0;
    next_gen = zeros(1,pop_size);
    temp1 = 0;
    temp2 = 0;
    temp3 = 0;
    x = 1;
    m = 1;
    a = 1;
    b = 1;
    s = 1;
    for j = 1:size(vehicle,2)
        for k = 1:(size(vehicle{j},2)-1)
            totalpartdistance(1,j) = totalpartdistance(1,j) + distance(vehicle{j}(1,k),vehicle{j}(1,k+1));
            totalparttime(1,j) = totalparttime(1,j) + time(vehicle{j}(1,k),vehicle{j}(1,k+1)) + service_time;
            partsumload(1,j) = partsumload(1,j) + demand(vehicle{j}(1,k),1);
        end
        totalparttime(1,j) = totalparttime(1,j) - service_time;
        totalpartcost(1,j) = 7.25*totalparttime(1,j)  + 0.2*totalpartdistance(1,j);
    end
    while (m <= pop_size)
        sumload(1,m) = sumload(1,m) + partsumload(1,s);
        totaltime(1,m) = totaltime(1,m) + totalparttime(1,s);
        totaldistance(1,m) = totaldistance(1,m) + totalpartdistance(1,s);
        totalcost(1,m) = totalcost(1,m) + totalpartcost(1,s) + .225*max(0,totaltime(1,m)-2) + 0.002*max(0,sumload(1,m)-V_cap);
        if (rem(s,3)==0)
            m = m+1;
        end
        s = s+1;
        if(s == 151)
            break
        end
    end
    for t = 1:pop_size
        numerator(1,t) = 1/(totalcost(1,t) + lmda*max(0,totalparttime(1,t)-2));
        denominator = denominator + numerator(1,t);
    end
    for f = 1:(pop_size)
        probability(1,f+1) = probability(1,f) + (numerator(1,f)/denominator);
    end
    while(next_gen(1,x) == 0)
        r = rand;
        for p = 1:pop_size
            if probability(1,p)< r <= probability(1,p+1)
                next_gen(1,x) = p;
                x = min(x+1,pop_size);
            end
        end
    end
    [localmincost,localindex] = min(totalcost);
    if localmincost < mincost
        mincost = localmincost;
        best_sol{1} = vehicle{(3*(localindex-1)+1)};
        best_sol{2} = vehicle{(3*(localindex-1)+2)};
        best_sol{3} = vehicle{(3*(localindex-1)+3)};
        %         best_sol{4} = vehicle{(4*(localindex-1)+4)};
        %         best_sol{5} = vehicle{(8*(localindex-1)+5)};
        %         best_sol{6} = vehicle{(8*(localindex-1)+6)};
        %         best_sol{7} = vehicle{(8*(localindex-1)+7)};
        %         best_sol{8} = vehicle{(8*(localindex-1)+8)};
    end
    while (a < size(vehicle,2))
        vehicle1{a} = vehicle{(next_gen(1,b)-1)*3+1};
        vehicle1{a+1} = vehicle{(next_gen(1,b)-1)*3+2};
        vehicle1{a+2} = vehicle{(next_gen(1,b)-1)*3+3};
        %         vehicle1{a+3} = vehicle{(next_gen(1,b)-1)*4+4};
        %         vehicle1{a+4} = vehicle{(next_gen(1,b)-1)*8+5};
        %         vehicle1{a+5} = vehicle{(next_gen(1,b)-1)*8+6};
        %         vehicle1{a+6} = vehicle{(next_gen(1,b)-1)*8+7};
        %         vehicle1{a+7} = vehicle{(next_gen(1,b)-1)*8+8};
        b = b+1;
        a = a+3;
    end
    for r = 1:pop_size
        r1 = rand;
        r2 = rand;
        if r1 <= 0.8
            for nn = 1:6
                rand2 = 2 + round(rand*12);
                rand3 = 2 + round(rand*12);
                if (rand2 ~= rand3)
                    for jjj = 1:3
                        temp2 = vehicle1{3*(pop_size-1)+jjj}(1,rand2);
                        %                     temp3 = vehicle1{8*(pop_size-1)+2}(1,rand2);
                        %                     temp4 = vehicle1{8*(pop_size-1)+3}(1,rand2);
                        %                     temp5 = vehicle1{8*(pop_size-1)+4}(1,rand2);
                        vehicle1{3*(pop_size-1)+jjj}(1,rand2) = vehicle1{3*(pop_size-1)+jjj}(1,rand3);
                        %                     vehicle1{8*(pop_size-1)+2}(1,rand2) = vehicle1{8*(pop_size-1)+2}(1,rand3);
                        %                     vehicle1{8*(pop_size-1)+3}(1,rand2) = vehicle1{8*(pop_size-1)+3}(1,rand3);
                        %                     vehicle1{8*(pop_size-1)+4}(1,rand2) = vehicle1{8*(pop_size-1)+4}(1,rand3);
                        vehicle1{3*(pop_size-1)+jjj}(1,rand3) = temp2;
                        %                     vehicle1{8*(pop_size-1)+2}(1,rand3) = temp3;
                        %                     vehicle1{8*(pop_size-1)+3}(1,rand3) = temp4;
                        %                     vehicle1{8*(pop_size-1)+4}(1,rand3) = temp5;
                    end
                end
            end
            for jj = 1:6
                rand1 = 2 + round(rand*12);
                temp1 = vehicle1{3*(pop_size-1)+1}(1,rand1);
                if (jj <= 3)
                    vehicle1{3*(pop_size-1)+1}(1,rand1) = vehicle1{3*(pop_size-1)+2}(1,rand1);
                    vehicle1{3*(pop_size-1)+2}(1,rand1) = temp1;
                elseif (jj > 3 && jj<=6)
                    vehicle1{3*(pop_size-1)+1}(1,rand1) = vehicle1{3*(pop_size-1)+3}(1,rand1);
                    vehicle1{3*(pop_size-1)+3}(1,rand1) = temp1;
                    %                 elseif (jj > 6 && jj<=9)
                    %                     vehicle1{4*(pop_size-1)+1}(1,rand1) = vehicle1{4*(pop_size-1)+4}(1,rand1);
                    %                     vehicle1{4*(pop_size-1)+4}(1,rand1) = temp1;
                    %                 elseif (jj > 9 && jj<=12)
                    %                     vehicle1{4*(pop_size-1)+1}(1,rand1) = vehicle1{4*(pop_size-1)+5}(1,rand1);
                    %                     vehicle1{8*(pop_size-1)+5}(1,rand1) = temp1;
                    %                 elseif (jj > 12 && jj<=15)
                    %                     vehicle1{8*(pop_size-1)+1}(1,rand1) = vehicle1{8*(pop_size-1)+6}(1,rand1);
                    %                     vehicle1{8*(pop_size-1)+6}(1,rand1) = temp1;
                    %                 elseif (jj > 15 && jj<=18)
                    %                     vehicle1{8*(pop_size-1)+1}(1,rand1) = vehicle1{8*(pop_size-1)+7}(1,rand1);
                    %                     vehicle1{8*(pop_size-1)+7}(1,rand1) = temp1;
                    %                 else
                    %                     vehicle1{8*(pop_size-1)+1}(1,rand1) = vehicle1{8*(pop_size-1)+8}(1,rand1);
                    %                     vehicle1{8*(pop_size-1)+8}(1,rand1) = temp1;
                end
            end
            %         if r2 <= .5
            %             temp1 = vehicle1{3*(pop_size-1)+1}(1,3);
            %             temp2 = vehicle1{3*(pop_size-1)+1}(1,9);
            %             temp3 = vehicle1{3*(pop_size-1)+1}(1,6);
            %             temp4 = vehicle1{3*(pop_size-1)+2}(1,5);
            %             temp5 = vehicle1{3*(pop_size-1)+2}(1,8);
            %             temp6 = vehicle1{3*(pop_size-1)+2}(1,13);
            %             vehicle1{3*(pop_size-1)+1}(1,3) = vehicle1{3*(pop_size-1)+2}(1,3);
            %             vehicle1{3*(pop_size-1)+1}(1,9) = vehicle1{3*(pop_size-1)+2}(1,9);
            %             vehicle1{3*(pop_size-1)+1}(1,6) = vehicle1{3*(pop_size-1)+2}(1,6);
            %             vehicle1{3*(pop_size-1)+2}(1,5) = vehicle1{3*(pop_size-1)+3}(1,5);
            %             vehicle1{3*(pop_size-1)+2}(1,8) = vehicle1{3*(pop_size-1)+3}(1,8);
            %             vehicle1{3*(pop_size-1)+2}(1,13) = vehicle1{3*(pop_size-1)+3}(1,13);
            %             vehicle1{3*(pop_size-1)+2}(1,3) = temp1;
            %             vehicle1{3*(pop_size-1)+2}(1,9) = temp2;
            %             vehicle1{3*(pop_size-1)+2}(1,6) = temp3;
            %             vehicle1{3*(pop_size-1)+3}(1,5) = temp4;
            %             vehicle1{3*(pop_size-1)+3}(1,8) = temp5;
            %             vehicle1{3*(pop_size-1)+3}(1,13) = temp6;
            %         end
        end
    end
    
    vehicle = vehicle1;
    result(i,1) = i;
    result(i,2) = 100+mincost;
    disp(['Iteration ' num2str(i) ': Best Cost = ' num2str(mincost)]);
end
