location = xlsread('location1');
demand = xlsread('demand1');
m = size(location, 1);
Alpha = 1;
Beta = 2;
rou = 0.05;
tao_0 = 50;
deltao = 5;
tao = zeros(m,m);
tao = tao + tao_0;
miu = zeros(m,m);
V_cap = 24000;
distance = zeros(m,m);
time = zeros(m,m);
service_time = 0.1;
 mincost = 100000000000;
 mindistance = 100000000000;
 minvariablecost = 1000000000;
taomax = 70;
taomin = 1;
result = zeros(700,2);
for i = 1:m-1
    for j = i+1:m
        if i ~= j
        distance(i,j) = sqrt((location(i,1)-location(j,1))^2+(location(i,2)-location(j,2))^2);
        distance(j,i) = distance(i,j);
        miu(i,j) = 1/distance(i,j);
        miu(j,i) = miu(i,j);
        time(i,j) = distance(i,j)/28;
        time(j,i) = time(i,j);
        else
          distance(i,j) = eps; 
          miu(i,j) = 1/distance(i,j);
        end
    end
end
N_vehicle = max(round(sum(demand)/V_cap)+1,round(((m-1)*service_time+sum(distance)/m/28)/4)+1);
for n_gen = 1:1500
    part_sol = zeros(1,m);
    sumload = 0;
    r = zeros(1,m);
    totaltime = 0;
    totaldistance = 0;
    totalcost = 0;
    totalpartcost = [];
    totalpartdistance = [];
    all_location = 1:m;
    left_node = all_location;
    i = 1;
    q = 1;
    %k = 0;
    vehicle = {};
    while (size(left_node,1)>0)
            if i == 1
                part_sol(1,i) = 1;
            end
            if (i ~= 1)
                miu1 = zeros(1, size(left_node,2));
                tao1 = zeros(1, size(left_node,2));
                for s = 1:size(left_node,2)
                    miu1(1,s) = 1/distance(part_sol(i-1),left_node(1,s));
                    tao1(1,s) = tao(part_sol(i-1),left_node(1,s));
                end
                probability1 = Probability_Computation1(tao1,miu1,left_node,Alpha,Beta);
                %display(probability1);
            end
            probability = Probability_Computation(tao,miu,Alpha,Beta,m);
            while(part_sol(1,i)==0)               
                if i ~=1
                    r = rand;
                    for j = 1:size(left_node,2);
                        %x = left_node(1,j); 
                        
                         if (probability1(1,j)< r <= probability1(1,j+1))
                             part_sol(1,i) = left_node(1,j);
                             %display(x);
                             %display(j);
                             break
                         end
                    end
                end
            end
            
            if i ~= 1
                totaltime = totaltime + service_time + time(part_sol(1,i-1), part_sol(1,i));
                tao(part_sol(1,i-1), part_sol(1,i)) = tao(part_sol(1,i-1), part_sol(1,i)) + deltao;
                totaldistance = totaldistance + distance(part_sol(1,i-1), part_sol(1,i));
            end
            left_node = left_node(left_node ~= part_sol(1,i));
            sumload = sumload + demand(part_sol(1,i),1);
            k = 0;
            i = i+1;
            if (sumload > V_cap || totaltime > 2)
                
                i = i-1;
                totaltime = totaltime -(service_time + time(part_sol(1,i-1), part_sol(1,i)));
                totaldistance = totaldistance - distance(part_sol(1,i-1), part_sol(1,i));
                tao(part_sol(1,i-1), part_sol(1,i)) = tao(part_sol(1,i-1), part_sol(1,i)) - deltao;
                left_node = [left_node  part_sol(1,i)];
                part_sol = part_sol(part_sol ~= 0); 
                part_sol = part_sol(part_sol ~= part_sol(1,i));
                part_sol(1,i) = 1;
                vehicle{q} = part_sol;
                totaltime = totaltime + time(part_sol(1,i-1), part_sol(1,i));
                totaldistance = totaldistance + distance(part_sol(1,i-1), part_sol(1,i));
                totalpartdistance(1,q) = totaldistance;
                totalpartcost(1,q) = 7.25*totaltime + 2.25*max(0,totaltime-2) + 0.2*totaldistance;
                totaldistance = 0;
                totaltime = 0;
                sumload = 0;
                part_sol=zeros(1,m);
                q = q+1;
                i = 1;
            end
    end
    totaltime = totaltime + time(part_sol(1,i-1), 1);
    totaldistance = totaldistance + distance(part_sol(1,i-1), 1);
    totalpartcost = totalpartcost + 0.2*totaldistance + 7.25*totaltime + 2.25*max(0,totaltime-2);
    totalcost = sum(totalpartcost) + 50*(q-1);
    for i = 1:m
        for j = 1:m
            if (tao(i,j) < taomin)
                tao(i,j) = taomin;
            elseif (tao(i,j) > taomax)
                tao(i,j) = taomax;
            end
        end
    end
    tao = (1-rou)*tao; 
    if totalcost < mincost
        mincost = totalcost;
        minvariablecost = sum(totalpartcost);
        mindistance = sum(totalpartdistance);
        best_sol = vehicle;
        best_sol{q} = [part_sol(part_sol ~= 0) 1];
    end
    disp(['Iteration ' num2str(n_gen) ': Best Cost = ' num2str(mincost)]);
    result(n_gen,1) = n_gen;
    result(n_gen,2) = mincost;
end              
                      

            