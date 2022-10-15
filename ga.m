
clc;
clear;
close all;



CostFunction=@(x) Sphere(x);     

nVar=10;             

VarSize=[1 nVar];   

VarMin=-1.28;         
VarMax= 1.28;         


%% GA Parameters

MaxIt=500;     
nPop=100;       

pc=0.7;                 
nc=2*round(pc*nPop/2);  
gamma=0.4;              
pm=0.3;                 
nm=round(pm*nPop);      
mu=0.1;         

ANSWER=questdlg('Choose selection method:','Genetic Algorith',...
    'Roulette Wheel','Tournament','Random','Roulette Wheel');

UseRouletteWheelSelection=strcmp(ANSWER,'Roulette Wheel');
UseTournamentSelection=strcmp(ANSWER,'Tournament');
UseRandomSelection=strcmp(ANSWER,'Random');

if UseRouletteWheelSelection
    beta=8; 
end

if UseTournamentSelection
    TournamentSize=3;   
end

pause(0.01); 

%% Initialization

empty_individual.Position=[];
empty_individual.Cost=[];

pop=repmat(empty_individual,nPop,1);

for i=1:nPop
    
    % Initialize Position
    pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
    
    % Evaluation
    pop(i).Cost=CostFunction(pop(i).Position);
    
end


Costs=[pop.Cost];
[Costs, SortOrder]=sort(Costs);
pop=pop(SortOrder);


BestSol=pop(1);


BestCost=zeros(MaxIt,1);


WorstCost=pop(end).Cost;



for it=1:MaxIt
    
    
    if UseRouletteWheelSelection
        P=exp(-beta*Costs/WorstCost);
        P=P/sum(P);
    end
    
    
    popc=repmat(empty_individual,nc/2,2);
    for k=1:nc/2
        
        
        if UseRouletteWheelSelection
            i1=RouletteWheelSelection(P);
            i2=RouletteWheelSelection(P);
        end
        if UseTournamentSelection
            i1=TournamentSelection(pop,TournamentSize);
            i2=TournamentSelection(pop,TournamentSize);
        end
        if UseRandomSelection
            i1=randi([1 nPop]);
            i2=randi([1 nPop]);
        end

       
        p1=pop(i1);
        p2=pop(i2);
        
       
        [popc(k,1).Position, popc(k,2).Position]=Crossover(p1.Position,p2.Position,gamma,VarMin,VarMax);
        
        
        popc(k,1).Cost=CostFunction(popc(k,1).Position);
        popc(k,2).Cost=CostFunction(popc(k,2).Position);
        
    end
    popc=popc(:);
    
    
   
    popm=repmat(empty_individual,nm,1);
    for k=1:nm
        
        
        i=randi([1 nPop]);
        p=pop(i);
        
        
        popm(k).Position=Mutate(p.Position,mu,VarMin,VarMax);
        
        
        popm(k).Cost=CostFunction(popm(k).Position);
        
    end
    
    
    pop=[pop
         popc
         popm]; 
    
    Costs=[pop.Cost];
    [Costs, SortOrder]=sort(Costs);
    pop=pop(SortOrder);
    
   
    WorstCost=max(WorstCost,pop(end).Cost);
    
    pop=pop(1:nPop);
    Costs=Costs(1:nPop);
    
    BestSol=pop(1);
    
    
    BestCost(it)=BestSol.Cost;
    
    disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(BestCost(it))]);
    
end

%% Results

figure;
semilogy(BestCost,'LineWidth',2);
% plot(BestCost,'LineWidth',2);
xlabel('Iteration');
ylabel('Cost');
grid on;
