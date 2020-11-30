/***
* Name: projectFinal
* Author: valeriabladinieres and raulaznar
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model projectFinal

/* Insert your model definition here */


global {
	int n <- 10; 
	int numSup <-  5*n;
	int nb_happy_pp <- numSup;
	int nb_not_happy_pp <-numSup-nb_happy_pp;
	float avGlobal;
	geometry shape <- cube(200);
	list JournalistsList <- []; 
	list SecurityList <- [];
	list Bars <- [{10.0,10.0,0.0},{190.0,80.0,0.0},{180.0,170.0,0.0}];
	list Shops <- [{40.0,40.0,0.0},{90.0,20.0,0.0},{20.0,120.0,0.0},{190.0,140.0,0.0},{160.0,180.0,0.0}];
	list LocationJournalists <- [{10.0,10.0,0.0},{190.0,80.0,0.0},{180.0,170.0,0.0},{100.0,140.0,0.0},{100.0,60.0,0.0},{180,20,0},{20,180,0},{80,180,0},{120,10,0}];
	int sele<-0;
	agent cur;
	agent cur2;
	
	init {
		create Supporters number: 5*n{ //Creation of the supporters,, we distinguish them in two teams.
			int aux<-rnd(1);
			if aux=0{
				team<-'Real';
				myColor <- #purple;
			}
			if aux=1{
				team<-'Barca';
				myColor <- #red;
			}
		}
		create Security number: 1{ // We create one security who `secretelly` cheers for barca.
			add self to: SecurityList;
			team<-'Barca';
		}
		create Security number: 1{ // We create one security who `secretelly` cheers for real.
			add self to: SecurityList;
			team<-'Real';
		}
		create Journalists number: n{ // We create a n number of journalists who also have a preferred team.
			int aux<-rnd(1);
			if aux=0{
				team<-'Real';
			}
			if aux=1{
				team<-'Barca';
			}
			add self to: JournalistsList; // We created and add journalists to a list, we will use it to allocate them in differen points
			int aux2<-rnd(8);
			location<-LocationJournalists[aux2] + {rnd(-2.0,2.0),rnd(-2.0,2.0),0}; // Locate them close to some points so that there may be 2 in one place.
		}
		// Create 11 players for each team
		create Players number: 11{
			team<-'Real';
		}
		create Players number: 11{
			team<-'Barca';
		}
		//Create the vendors, in the 5 different locations where we set the Shops list, they also symphatize with one team
		create Vendors number: n/2{
			location<-Shops[sele];
			sele<-sele+1;
			int aux<-rnd(1);
			if aux=0{
				team<-'Real';
			}
			if aux=1{
				team<-'Barca';
			}
		}
		//There are 2 fanzones, here we create them
		create Fanzone number: 1{
			trait<-'Real';
			location<-{180,20,0};
		}
		create Fanzone number: 1{
			trait<-'Barca';
			location<-{20,180,0};
		}
		//We create a virtual betting page(Supposed to be within the stadium also)
			create BettingPage number: 1{
		}
		//Creation of bars
		create Bar number: 1{
		location<-{190.0,80.0,0.0};
		}
		create Bar number: 1{
		location<-{10.0,10.0,0.0};
		}		
		create Bar number: 1{
		location<-{180.0,170.0,0.0};
		}
		//Create the stadium where the match takes place
		create Stadium number:1{
			location<-{100.0,100.0,0.0};
		}
		//We create two hotel where the players stay.
		create Hotel number: 1{
			trait<-'Real';
			location<-{120,10,0};
		}
		create Hotel number: 1{
			trait<-'Barca';
			location<-{80,180,0};
		}
	}
}

species Supporters skills: [fipa, moving]{
	point targetPoint <- nil;
	rgb myColor;
	string team;
	float hooliganlevel<-rnd(1.0);
	float happiness<-50.0;
	float generosity<-rnd(1.0);
	float betdesire<-rnd(0.25,1.0);
	float noisy<-rnd(1.0);
	bool thirsty<-false;
	bool inmatch<-false;
	int nDrinks<-0;
	float budget<-rnd(800.0,1600.0);
	bool betting<-false;
	float qbet<-0.0;
	bool tofanzone;
	bool myfz<-false;
	float consumism<-rnd(1.0);
	float counter<-0.0;
	bool buying<-false;
	bool happy <- true;
	int warning <-0;
	bool spotted<- false;
	bool wrongSide;
	bool havetoDie;
	bool reported <- false;
	bool inter <- false;
	bool askedInter <- false;
	
	reflex budgetcheck when: time mod 300 = 0{ // 
		if budget<100.0{
			happiness<-happiness-15.0;
			generosity<-0.0;
		}
		if budget <0.0{
			budget<-0.0;
			havetoDie<-true;
			write 'I am broke, I will kill myself';
		}
	}
	
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}
	
	reflex die when: havetoDie = true{
		do die;
	}
	
	reflex state when: thirsty = false and inmatch = false and inter = false and targetPoint=nil and time mod 5 = 0 and time>counter{
		int rand <- rnd(100);
		if (rand < 15 and rand >5){
			thirsty <- true;
			targetPoint<-Bars[rnd(2)];
			happiness<- happiness-1.0;
		}
		if (rand>3 and rand<5){
			if team='Real'{
				targetPoint<-{20,180,0};
				tofanzone<-true;
			}
			if team='Barca'{
				targetPoint<-{180,20,0};
				tofanzone<-true;
			}
		}	
		if (rand>70){
			if team='Real'{
				targetPoint<-{180,20,0};
				tofanzone<-true;
			}
			if team='Barca'{
				targetPoint<-{20,180,0};
				tofanzone<-true;
			}
		}
		if rand<3{
			targetPoint<-Shops[rnd(4)];
		}
		
	}
	
	reflex utility when: !empty(informs){
		//calcular utility y comparar con la anterior, si es mas grande ir a la location del inform.
		loop m over: informs {
				if m.contents[2]='Match finished'{
					if team='Real'{
						int result <- int(m.contents[3])-int(m.contents[4]);
						happiness<-happiness+hooliganlevel*result*3;
						if happiness>100.0{
							happiness<-100.0;
						}
						if happiness<0.0{
							happiness<-0.0;
						}
						inmatch<-false;
					}	
					if team='Barca'{
						int result <- int(m.contents[4])-int(m.contents[3]);
						happiness<-happiness+hooliganlevel*result*3;
						if happiness>100.0{
							happiness<-100.0;
						}
						if happiness<0.0{
							happiness<-0.0;
						}
						inmatch<-false;
					}
					if betting{
						//We create 25 types of different bets, each of them are individually, combinations and more possibilities can be 
						// add-on later, but Gama has some troubles with memory
						int bet1 <-rnd(5);
						int bet2 <- rnd(14);
						int bet3 <-rnd(15);
						int bet4 <- rnd(14);
						int bet5 <-rnd(15);
						int bet6 <- rnd(14);
						int bet7 <-rnd(15);
						int bet8 <- rnd(14);
						int bet9 <-rnd(5);
						int bet10 <- rnd(14);
						int bet11 <-rnd(15);
						int bet12 <- rnd(14);
						int bet13 <-rnd(15);
						int bet14 <- rnd(14);
						int bet15 <-rnd(4);
						int bet16 <- rnd(14);
						int bet17 <-rnd(5);
						int bet18 <- rnd(14);
						int bet19 <-rnd(15);
						int bet20 <- rnd(14);
						int bet21 <-rnd(15);
						int bet22 <- rnd(14);
						int bet23 <-rnd(15);
						int bet24 <- rnd(14);
						int bet25 <-rnd(15);
						
						//All bets are a bit adapted to the possbility, i.e. If you have to pick over/under in a 50% chance is normaly a odd 2. But 
						// guessing the exact number of goals or the result gives you more happiness and money if the guest wins the bet
						// All the different ones are presented, the qbet, represents the money inverted or possible to win, if the bet is lost
						// the qbet is taken from th ebudget, if it is won we just add up, (We could also take out at the beginning and then add up the double, 
						//but to simplify things we do it like this.
						
						if bet1=4{ //Exact result, if both number of goals are the same as the match result, then wins a good price
							int aux9 <-rnd(5);
							int aux99 <- rnd(5);
							write name + ' Betting ' + qbet + ' to Result' + aux9 + ' - ' + aux99;
							if int(m.contents[3])=aux9 and int(m.contents[4])=aux99{
								budget<-budget+qbet*10;
								happiness<-happiness+10;
								write 'I won!' + qbet*10;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-0.25;
							}
						}
						if bet2=4{ // Exact result Half time. If the result of half time is the same then wins.
							int aux9 <-rnd(3);
							int aux99 <- rnd(3);
							write name + ' Betting ' + qbet + ' to Halftime Result' + aux9 + ' - ' + aux99;
							if int(m.contents[5])=aux9 and int(m.contents[6])=aux99{
								budget<-budget+qbet*4;
								happiness<-happiness+4;
								write 'I won!' + qbet*4;
							}
							else // If not take out the money and decrease happiness
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet3=4{ //Number of corners, bet about the number of corners
						int aux9 <-rnd(10);
						write name + ' Betting ' + qbet + ' to Number of corners' + aux9;
						if int(m.contents[7])+int(m.contents[8])=aux9{
								budget<-budget+qbet*8;
								happiness<-happiness+5;
								write 'I won!' + qbet*8;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-0.5;
							}
						}
						if bet4=4{ // Number of Corners , bet about number of courners in HT
						int aux9 <-rnd(6);
						write name + ' Betting ' + qbet + ' to Number of corners HT' + aux9;
						if int(m.contents[9])+int(m.contents[10])=aux9{
								budget<-budget+qbet*5;
								happiness<-happiness+2.5;
								write 'I won!' + qbet*5;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-0.5;
							}
						}
						if bet5=4{ //Number of Yellow Cards in the match
						int aux9 <-rnd(7);
						write name + ' Betting ' + qbet + ' to Number of Yellow Cards' + aux9;
						if int(m.contents[13])+int(m.contents[14])=aux9{
								budget<-budget+qbet*7;
								happiness<-happiness+3.5;
								write 'I won!' + qbet*7;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-0.5;
							}
						}
						if bet6=4{ //Nr of yellow cards HT.
						int aux9 <-rnd(3); 
						write name + ' Betting ' + qbet + ' to Number of Yellow Cards HT' + aux9;
						if int(m.contents[13])+int(m.contents[14])=aux9{
								budget<-budget+qbet*3;
								happiness<-happiness+1.5;
								write 'I won!' + qbet*3;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-0.5;
							}
						}
						if bet7=4{  //Nr of red cards
						int aux9 <-rnd(2);
						write name + ' Betting ' + qbet + ' to Number of Red Cards' + aux9;
						if int(m.contents[15])+int(m.contents[16])=aux9{
								budget<-budget+qbet*2;
								happiness<-happiness+1.5;
								write 'I won!' + qbet*2;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet8=4{ // NR of red cards HT
						int aux9 <-rnd(1);
						write name + ' Betting ' + qbet + ' to Number of Red Cards HT' + aux9;
						if int(m.contents[17])+int(m.contents[18])=aux9{
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet9=4{ // number of goals
						int aux9 <-rnd(7);
						write name + ' Betting ' + qbet + ' to Number of Goals' + aux9;
						if int(m.contents[3])+int(m.contents[4])=aux9{
								budget<-budget+qbet*5;
								happiness<-happiness+4;
								write 'I won!' + qbet*5;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet10=4{ // number of goals HT
						int aux9 <-rnd(5);
						write name + ' Betting ' + qbet + ' to Number of Goals HT' + aux9;
						if int(m.contents[5])+int(m.contents[6])=aux9{
								budget<-budget+qbet*4;
								happiness<-happiness+4;
								write 'I won!' + qbet*4;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-0.75;
							}
						}
						if bet11=4{ // Result in corners MAdrid
						write name + ' Betting ' + qbet + ' to MAdrid having more corners';
						if int(m.contents[7])>int(m.contents[8]){
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet12=4{ //Result in corners HT Barca
						write name + ' Betting ' + qbet + ' to Barca having more corners in Halftime';
							if int(m.contents[10])>int(m.contents[9]){
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet13=4{ // Result in YCards Madrid
							write name + ' Betting ' + qbet + ' to MAdrid having more yellowcards';
							if int(m.contents[11])>int(m.contents[12]){
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet14=4{ // Winner Barcelona
						write name + ' Betting ' + qbet + ' Barca to win';
						if int(m.contents[3])<int(m.contents[4]){
								budget<-budget+qbet*1.2;
								happiness<-happiness+1.25;
								write 'I won!' + qbet*1.2;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
							}
						if bet15=4{ //Winner Madrid
						write name + ' Betting ' + qbet + ' Madrid to win';
						if int(m.contents[3])>int(m.contents[4]){
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet16=4{ //posesion winner madrid
						write name + ' Betting ' + qbet + ' to Madrid winning posesion';
						if int(m.contents[19])>int(m.contents[20]){
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
							
						}
						if bet17=4{  //more than 2.5 goals
							write name + ' Betting ' + qbet + ' to more than 2.5 goals';
							if int(m.contents[3])+int(m.contents[4])>2{
								budget<-budget+qbet*0.5;
								happiness<-happiness+1;
								write 'I won!' + qbet*0.5;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-2.5;
							}
						}
						if bet18=4{ // more than 3.5 goals
							write name + ' Betting ' + qbet + ' to more than 3.5 goals';
							if int(m.contents[3])+int(m.contents[4])>3{
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						if bet19=4{ // more than 1.5 goal HT
							write name + ' Betting ' + qbet + ' to more than 1.5 goals halftime';
							if int(m.contents[5])+int(m.contents[6])>1{
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1.0;
							}
						}
						if bet20=4{ // more than 8,5 % poss barca
						write name + ' Betting ' + qbet + ' to Barca more than 8,5% possesion than Real in HT';
							if int(m.contents[22])-int(m.contents[21])>8{
								budget<-budget+qbet*2;
								happiness<-happiness+2;
								write 'I won!' + qbet*2;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1.0;
							}
						}
						if bet21=4{ // more than 9,5% diff poss madrid
						write name + ' Betting ' + qbet + ' to Real more than 9,5% possesion than Barca';
							if int(m.contents[19])-int(m.contents[20])>8{
								budget<-budget+qbet*2;
								happiness<-happiness+1.0;
								write 'I won!' + qbet*2;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1.0;
							}
						}
						if bet22=4{ //more than 5,5 corner
						write name + ' Betting ' + qbet + ' to more than 5.5 corners';
						if int(m.contents[7])+int(m.contents[8])>5{
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1.0;
							}
						}
						if bet23=4{ // more than 3.5 corner HT
						write name + ' Betting ' + qbet + ' to more than 3.5 corners HT';
						if int(m.contents[9])+int(m.contents[10])>3{
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness;
							}
						}
						if bet24=4{ // more than 1.5 YCards HT
						write name + ' Betting ' + qbet + ' to more than 1.5 yellow cards HT';
								if int(m.contents[13])+int(m.contents[14])>1{
								budget<-budget+qbet;
								happiness<-happiness+0.5;
								write 'I won!' + qbet;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-0.5;
							}}
						if bet25=4{ // more than 2,5 y cards
						write name + ' Betting ' + qbet + ' to more than 2.5 yellow cards';
						if int(m.contents[11])-int(m.contents[12])>2{
								budget<-budget+qbet;
								happiness<-happiness+1;
								write 'I won! ' + qbet*10;
							}
							else
							{
								budget<-budget-qbet;
								happiness<-happiness-1;
							}
						}
						
						betting<-false;
					}
				}
				if m.contents[2]='Starting Match'{
					inmatch<-true;
					thirsty<-false;
					int aux2 <-rnd(50);
					if aux2<49{
						if team='Real'{
							targetPoint<- {rnd(70.0,130.0),60.0,0.0};
							wrongSide <- false;
						}	
						if team='Barca'{
							targetPoint<- {rnd(70.0,130.0),140.0,0.0};
							wrongSide <- false;
						}
					}
					if aux2>48{
						if team='Real'{
							targetPoint<- {rnd(70.0,130.0),140.0,0.0};
							write name + " I am in the wrong side";
							wrongSide <- true;
						}	
						if team='Barca'{
							targetPoint<- {rnd(70.0,130.0),60.0,0.0};
							write name + " I am in the woing side";
							wrongSide <- true;
						}
					}
					if aux2/8*betdesire>1.7{
						qbet<-betdesire*aux2;
						betting<-true;
						//ir a lugar donde se apuesta
					}
					
					
				}
		}
				
	}
	
	reflex beIdle when: targetPoint = nil{
		do wander(0.5,360.0,square(5));
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex infanzone when: targetPoint != nil and location distance_to(targetPoint) < 5 and tofanzone and inmatch=false{
		spotted <- false;
		ask Fanzone at_distance(7){
			if self.trait=myself.team{
				myself.myfz <-true;
			}
		}
		
		if myfz{
			counter<-time+150.0;
			ask Supporters at_distance(7){
				if myself.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel*0.3;
						self.happiness<-self.happiness+myself.hooliganlevel*0.3;
					}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-2.0;
						//write myself.name;
						//write self.name;
						//write self.spotted;
						if self.spotted = false {
					 		self.spotted <-true;
					 		self.warning <- self.warning +1;
						 	if self.warning = 1{
								//write myself.name + ' Get the hell out of here0 ' + self.name + self.warning;
						 	}
						 	/*if self.warning = 2{
								write myself.name + ' going to fight ' + self.name;
						 	}*/
						 	if self.warning = 2{
								//write myself.name + ' calling security0 ' + self.name;
								do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];
								}
							}
							if self.hooliganlevel+self.noisy>0.8{
								myself.happiness<-myself.happiness-2.0;
						 	}
						}
				}
				if myself.hooliganlevel<0.650 and myself.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel*0.3;
						self.happiness<-self.happiness+myself.hooliganlevel*0.3;
					}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-1.5;
						//write myself.name;
						//write self.name;
						//write self.spotted;
						if self.spotted = false {
					 		self.spotted <-true;
					 		self.warning <- self.warning +1;
						 	if self.warning = 1{
								//write myself.name + ' Get the hell out of here1 ' + self.name + self.warning;
						 	}
						 	/*if self.warning = 2{
								write myself.name + ' going to fight ' + self.name;
						 	}*/
						 	if self.warning = 2{
								//write myself.name + ' calling security1 ' + self.name;
								do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];

						 	}
						}
						if self.hooliganlevel+self.noisy>1.1{
						 	myself.happiness<-myself.happiness-1.5;
						}	
					}
					
				}
				if myself.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel*0.3;
						self.happiness<-self.happiness+myself.hooliganlevel*0.3;
					}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-1.0;
						//write myself.name;
						//write self.name;
						//write self.spotted;
						if self.spotted = false{
					 		self.spotted <-true;
					 		self.warning <- self.warning +1;
						 	if self.warning = 1{
								//write myself.name + ' Get the hell out of here2 ' + self.name + self.warning;
						 	}
						 	/*if self.warning = 2{
								write myself.name + ' going to fight ' + self.name;
						 	}*/
						 	if self.warning = 2{
								//write myself.name + ' calling security2 ' + self.name;
								do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];

						 	}
						}
						if self.hooliganlevel+self.noisy>1.4{
						 	myself.happiness<-myself.happiness-1.0;	
						}
					}
				
				}
			}
		}
		if myfz=false{
			counter<-time+50.0;
			ask Supporters at_distance(5){
				if self.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel;
						self.happiness<-self.happiness+myself.hooliganlevel;
					}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.3;
						self.happiness<-self.happiness-2.0;
						//write myself.name + ' I am in the wrong zone, dotn care' + self.name;
						if myself.hooliganlevel+myself.noisy>0.8{
						 	self.happiness<-self.happiness-2.0;
						}
					}
				}
				if self.hooliganlevel<0.650 and self.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel;
						self.happiness<-self.happiness+myself.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.3;
						self.happiness<-self.happiness-1.5;
						//write myself.name + ' I am in the wrong zone, dotn care ' + self.name;
						if myself.hooliganlevel+myself.noisy>1.1{
						 	self.happiness<-self.happiness-1.5;
						}
					}
					
				}
				if myself.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel;
						self.happiness<-self.happiness+myself.hooliganlevel;
					}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.3;
						self.happiness<-self.happiness-1.0;
						//write myself.name + '  I am in the wrong zone, dotn care' + self.name;
						if myself.hooliganlevel+myself.noisy>0.8{
						 	self.happiness<-self.happiness-1.0;
						}
					}
				}
			}
		}
		
		targetPoint<-nil;
		tofanzone<-false;
		myfz<-false;
		
	}
	
	reflex enterStadium when: targetPoint != nil and location distance_to(targetPoint) < 2 and inmatch{
		spotted <- false;
		askedInter <- false;
		ask Supporters at_distance(7){
			if myself.hooliganlevel>0.650{
				if self.team=myself.team{
					myself.happiness<-myself.happiness+((self.noisy*self.hooliganlevel)/3);
				}
				if self.team!=myself.team {
					if myself.spotted = false and myself.wrongSide = true{
				 		myself.spotted <-true;
				 		myself.warning <- myself.warning +1;
					 	if myself.warning = 1{
							//write self.name + ' Get the hell out of here00 ' + myself.name + myself.warning;
					 	}
					 	/*if myself.warning = 2{
							write self.name + ' going to fight ' + myself.name;
					 	}*/
					 	if myself.warning = 2{
							//write self.name + ' calling security0 ' + myself.name;
							do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [myself, myself.team, self.hooliganlevel]];
					 	}
					}
					
					myself.happiness<-myself.happiness-self.noisy*self.hooliganlevel;
				}
			}
			if myself.hooliganlevel<=0.650 and myself.hooliganlevel>=0.350{
				if self.team=myself.team{
					myself.happiness<-myself.happiness+((self.noisy*self.hooliganlevel)/3);
				}
				if self.team!=myself.team {
					if myself.spotted = false and myself.wrongSide = true{
				 		myself.spotted <-true;
				 		myself.warning <- myself.warning +1;
					 	if myself.warning = 1{
							//write self.name + ' Get the hell out of here11 ' + myself.name + myself.warning;
					 	}
					 	/*if myself.warning = 2{
							write self.name + ' going to fight ' + myself.name;
					 	}*/
					 	if myself.warning = 2{
							//write self.name + ' calling security11 ' + myself.name;
							do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [myself, myself.team, self.hooliganlevel]];
					 	}
					}
					
					myself.happiness<-myself.happiness-self.noisy*self.hooliganlevel;
				}
			}
			if myself.hooliganlevel<0.350{
				if self.team=myself.team{
					myself.happiness<-myself.happiness+((self.noisy*self.hooliganlevel)/3);
				}
				if self.team!=myself.team{
					if myself.spotted = false and myself.wrongSide = true{
				 		myself.spotted <-true;
				 		myself.warning <- myself.warning +1;
					 	if myself.warning = 1{
							//write self.name + ' Get the hell out of here22 ' + myself.name + myself.warning;
					 	}
					 	/*if myself.warning = 2{
							write self.name + ' going to fight ' + myself.name;
					 	}*/
					 	if myself.warning = 2{
							//write "\t"+self.name + ' calling security22 ' + myself.name;
							do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [myself, myself.team, self.hooliganlevel]];
					 	}
					}
					
					myself.happiness<-myself.happiness-self.noisy*self.hooliganlevel;
				}				
			}
		}	
		targetPoint<-nil;
	}
	
	reflex buying when: (location distance_to {40.0,40.0,0.0} < 10) or (location distance_to {90.0,20.0,0.0} < 10) or (location distance_to {20.0,120.0,0.0}<10) or (location distance_to {190.0,140.0,0.0}<10) or (location distance_to {160.0,180.0,0.0}<10){
		point destino;
		spotted <- false;
		if buying=false{
			int aux<-rnd(50);
			ask Vendors at_distance(10){
				if aux*myself.consumism > 20 and myself.budget>(aux*myself.consumism+aux*5) and myself.noisy+0.25<self.intense{
					destino<-myself.targetPoint;
					myself.targetPoint<-nil;
					myself.buying<-true;
					if aux mod 2 = 0 and self.team=myself.team{
						myself.budget<-myself.budget-aux-10*self.hooliganlevel;
						myself.happiness<-myself.happiness+2.0;
						self.money<-self.money+aux+10*self.hooliganlevel;
						self.happiness<-self.happiness+aux/15;
						//write myself.name + ' Bought a TShirt for ' + aux;	
					}
					else{
						if aux mod 2 = 0 and self.team!=myself.team{
							myself.budget<-myself.budget-aux+10*myself.hooliganlevel;
							myself.happiness<-myself.happiness+0.5;
							self.money<-self.money+aux-10*myself.hooliganlevel;
							self.happiness<-self.happiness+aux/25;
						}
						//write myself.name + ' did not buy a TShirt for ' + aux;	
						self.happiness<-self.happiness-0.5;
					}
						
				}
				else{
					self.happiness<-self.happiness-0.2;
				}		
			}
		}
		//este nuca se usa
		
		 if buying=true{
			int conta<-rnd(10);
			if conta=10{
				buying<-false;
				targetPoint<-destino;
				if destino=nil{
					if team='Real'{
						targetPoint<-{180,20,0};
						tofanzone<-true;
					}
					if team='Barca'{
						targetPoint<-{20,180,0};
						tofanzone<-true;
					}
				}
			}
		} 
		 
		
	}
	
	reflex enterBar when: targetPoint != nil and location distance_to(targetPoint) < 2 and thirsty{

		if thirsty=true{
			nDrinks <- nDrinks +1;
			budget <- budget -2.0;
			happiness<-happiness+1.0;
			
			ask Journalists at_distance(7){
				if myself.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+0.30;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.30;
						}
					if generosity>0.7{
						if self.team=myself.team{
							int aux<-rnd(1);
							if aux=0{
								//write myself.name + 'Buying a drink to ' + self.name;
								self.nDrinks<-self.nDrinks+1;
								myself.budget<-myself.budget-2.0;
								self.happiness<-self.happiness+2.0;
								}
							}
						}
					}
				if myself.hooliganlevel<0.650 and myself.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+0.20;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.20;
						}
					if generosity>0.7{
						if self.team=myself.team or self.hooliganlevel<0.350{
							int aux<-rnd(1);
							if aux=0{
								//write myself.name + 'Buying a drink to' + self.name;
								self.nDrinks<-self.nDrinks+1;
								myself.budget<-myself.budget-2.0;
								self.happiness<-self.happiness+5;
								}
							}
						}
					}
				if myself.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+0.10;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.10;
						}
					if generosity>0.7{
						int aux<-rnd(1);
							if aux=0{
								//write myself.name + 'Buying a drink to' + self.name;
								self.nDrinks<-self.nDrinks+1;
								myself.budget<-myself.budget-2.0;
								self.happiness<-self.happiness+5;
								}
							}
					}
			
				}
			
			ask Supporters at_distance(7){
				if myself.noisy<0.5{
					if self.noisy<0.5{
						myself.happiness<-myself.happiness+0.4;
						self.happiness<-self.happiness+0.4;
					}
					else{
						myself.happiness<-myself.happiness-0.4;
					}
				}
				
				if myself.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+0.30;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.30;
						}
					if generosity>0.8{
						if self.team=myself.team{
							int aux<-rnd(1);
							if aux=0{
								//write myself.name + 'Buying a drink to' + self.name;
								self.nDrinks<-self.nDrinks+1;
								myself.budget<-myself.budget-2.0;
								self.happiness<-self.happiness+0.5;
								}
							}
						}
					}
				if myself.hooliganlevel<0.650 and myself.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+0.20;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.20;
						}
					if generosity>0.8{
						if self.team=myself.team or self.hooliganlevel<0.350{
							int aux<-rnd(1);
							if aux=0{
								//write myself.name + 'Buying a drink to' + self.name;
								self.nDrinks<-self.nDrinks+1;
								myself.budget<-myself.budget-2.0;
								self.happiness<-self.happiness+0.5;
								}
							}
						}
					}
				if myself.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+0.10;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-0.10;
						}
					if generosity>0.7{
						int aux<-rnd(1);
						if aux=0{
							//write myself.name + 'Buying a drink to' + self.name;
							self.nDrinks<-self.nDrinks+1;
							myself.budget<-myself.budget-2.0;
							self.happiness<-self.happiness+0.5;
							}
						}	
					}
				}
		
		}
		targetPoint<-nil;
		thirsty<-false;				
	}
	
	reflex drunk{
		ask Supporters at_distance(7){
			if (self.nDrinks > 3 and self.reported = false and self.noisy>0.4) or (self.warning = 2 and self.reported = false) {
				self.reported <- true;
				//write "\t"+"send name to guard of: "+ self.name;
				//write "\t"+"from"+ myself.name;
				do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];
			}
			
		}
		ask Journalists at_distance(7){
			if self.nDrinks > 5 and self.reported = false and self.intense>0.4{
				self.reported <- true;
				//write "\t"+"send name to guard of: "+ self.name;
				//write "\t"+"from"+ myself.name;
				do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];
			}
		}
	}
	
	reflex statistics{
		float av;
		float c;
		ask Supporters {
			av <- av + self.happiness;
			c <- c +1;
		}
		av <- av/c;
		avGlobal <- av ;	
		
		if happiness >= 50{
			happy <-true;
		}
		else{
			happy <-false;
		}
	}
	
	aspect default{
		draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
		draw pyramid(2) at: location color: myColor;
	}

}

species Security skills: [fipa, moving]{
	
	rgb myColor <- #black;
	agent nameBadGuy;
	string teamBG;
	float hoolig <- 0.0;
	string team;
	float happiness <- rnd(35.0,80.0);
	
	point targetPoint <- nil;
	bool doingSomething<- false ;
	list nextTn;
	list nextTnT;
	
	point targetPoint2 <- nil;
	bool doingSomething2<- false ;
	list nextTn2;
	list nextTnT2;
	
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}
	
	reflex mood when: time mod 300 = 0 {
	 	happiness <- rnd(35.0,65.0);
	}
		
	reflex beIdle when: targetPoint = nil and team = "Barca"{
		do wander;
	}
	reflex beIdle2 when: targetPoint2 = nil and team = "Real"{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil and team = "Barca"{
		do goto target:targetPoint;
	}
	reflex moveToTarget2 when: targetPoint2 != nil and team = "Real"{
		do goto target:targetPoint2;
	}
	
	reflex utility when: !empty(informs){
		loop m over: informs {
			//guy reported
			int r <- rnd(1);
			//if the random is 0 goes to the barca guard
			//if the random is 1 goes to the real  guard
			if r = 1 and team = "Barca" and cur2 != m.contents[0] and cur != m.contents[0]{
				cur <- m.contents[0];
				hoolig <- float(m.contents[2]);
				//if guard really happy(above average), his team(Real) and guy not very hooligan
				if happiness > 40 and m.contents[1] = team and hoolig < 0.75{
					ask Supporters{
						//let go, and reset warnings
						if m.contents[0] = self{
							self.warning <- 0;
							//write "\t"+ myself.name +": He is not a bad guy, I let "+ self.name + "("+ self.team+")"+" go!---------" ;
							myself.doingSomething <- false;
							myself.nameBadGuy <- nil;
							myself.teamBG <- nil;
							myself.targetPoint <- nil;
						}
					}
				}
				else{
					if doingSomething = true{
						if  m.contents[0] != nameBadGuy{
							//write "\t"+"added to waiting list of " + name;
							add m.contents[0] to: nextTn;
							add m.contents[1] to: nextTnT;
						}
					}
					if doingSomething = false{
						nameBadGuy <- (m.contents[0]);
						teamBG <- (m.contents[1]);
						targetPoint <- nameBadGuy.location;
						//write "\t"+name +": going to get: " + nameBadGuy;
						doingSomething <-true;
					}
				}
			}
			if r = 0 and team = "Real" and cur2 != m.contents[0] and cur != m.contents[0]{
				cur2 <- m.contents[0];
				hoolig <- float(m.contents[2]);
				//if guard really happy(above average), his team(Real) and guy not very hooligan
				if happiness > 40 and m.contents[1] = team and hoolig < 0.75 {
					ask Supporters{
						//let go, and reset warnings
						if m.contents[0] = self{
							self.warning <- 0;
							//write "\t"+ myself.name +": He is not a bad guy, I let "+ self.name + "("+ self.team+")"+" go!---------" ;
							myself.doingSomething <- false;
							myself.nameBadGuy <- nil;
							myself.teamBG <- nil;
							myself.targetPoint <- nil;
						}
					}
				}
				else{
					if doingSomething2 = true{
						if  m.contents[0] != nameBadGuy{
							//write "\t"+"added to waiting list of " + name;
							add m.contents[0] to: nextTn2;
							add m.contents[1] to: nextTnT2;
						}
					}
					if doingSomething2 = false{
						nameBadGuy <- (m.contents[0]);
						teamBG <- (m.contents[1]);
						targetPoint2 <- nameBadGuy.location;
						//write "\t"+name +": going to get: " + nameBadGuy;
						doingSomething2 <-true;
					}
				}
			}
		}
	}
	
	reflex chase when: doingSomething and nameBadGuy != nil and team = "Barca"{
		ask Supporters {
			if myself.nameBadGuy.name = self.name and myself.doingSomething and myself.nameBadGuy != nil and myself.team = "Barca"{
				myself.targetPoint <- self.location;
			}
		}
	}
	reflex chase2 when: doingSomething2 and nameBadGuy != nil and team = "Real"{
		ask Supporters {
			if myself.nameBadGuy.name = self.name and myself.doingSomething2 and myself.nameBadGuy != nil and myself.team = "Real"{
				myself.targetPoint2 <- self.location;
			}
		}
	}
	
	reflex foundBadGuy when: targetPoint != nil and location distance_to(targetPoint) < 2 and team = "Barca"{
		ask Supporters{
			if myself.doingSomething = true and myself.nameBadGuy.name = self.name {
				myself.doingSomething <- false;
				myself.nameBadGuy <- nil;
				myself.teamBG <- nil;
				myself.targetPoint <- nil;
				//write "\t"+myself.name+" killed: "+ self.name +"-------------";
				self.havetoDie <- true;
				cur <- nil;
			}
			
		}
		ask Journalists{
			if myself.doingSomething = true and myself.nameBadGuy.name = self.name {
				myself.doingSomething <- false;
				myself.nameBadGuy <- nil;
				myself.targetPoint <- nil;
				myself.teamBG <- nil;
				//write "\t"+myself.name+" killed: "+ self.name +"-------------";
				self.havetoDie <- true;
				cur <- nil;
			}
		}
		
		if doingSomething = false and !empty(nextTn){
			nameBadGuy <- first(nextTn);
			remove first(nextTn) from: nextTn;
			teamBG <- first(nextTnT);
			remove first(nextTnT) from: nextTnT;
			targetPoint <- nameBadGuy.location;
			doingSomething <- true;
		}
	}
	
	reflex foundBadGuy2 when: targetPoint2 != nil and location distance_to(targetPoint2) < 2 and team = "Real"{
		ask Supporters{
			if myself.doingSomething2 = true and myself.nameBadGuy.name = self.name {
				myself.doingSomething2 <- false;
				myself.nameBadGuy <- nil;
				myself.teamBG <- nil;
				myself.targetPoint2 <- nil;
				//write "\t"+myself.name+" killed: "+ self.name +"-------------";
				self.havetoDie <- true;	
				cur2 <- nil;
			}
			
		}
		ask Journalists{
			if myself.doingSomething2 = true and myself.nameBadGuy.name = self.name {
				myself.nameBadGuy <- nil;
				myself.teamBG <- nil;
				myself.targetPoint2 <- nil;
				self.havetoDie <- true;
				//write "\t"+myself.name+" killed: "+ self.name +"-------------";
				myself.doingSomething2 <- false;
				cur2 <- nil;
			}
		}
		if doingSomething2 = false and !empty(nextTn2){
			nameBadGuy <- first(nextTn2);
			remove first(nextTn2) from: nextTn2;
			teamBG <- first(nextTnT2);
			remove first(nextTnT2) from: nextTnT2;
			
			targetPoint2 <- nameBadGuy.location;
			doingSomething2 <- true;
		}
	}
	
	aspect default{
		draw sphere(3) at: location + {0.0,0.0,2.0} color: myColor;
		draw pyramid(4) at: location color: myColor;
	}
}

species Journalists skills: [fipa, moving]{
	point targetPoint <- nil;
	rgb myColor <- #darkgreen;
	float hooliganlevel<-rnd(1.0);
	float happiness<-50.0;
	float generosity<-rnd(1.0);
	string team;
	int nDrinks<-0;
	float intense<-rnd(1.0);
	float acceptnoisy<-rnd(1.0);
	float changeplace<-time + rnd(150,250);
	bool working<-true;
	bool havetoDie;
	bool reported <- false;
	bool inter <- false;
	float t <- float(rnd(70,100));
	agent sinter <- nil;
	point sloc;
	
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}
	
	reflex die when: havetoDie = true{
		do die;
	}
	reflex moveToTarget when: targetPoint != nil and inter = false{
		do goto target:targetPoint;
	}
	
	reflex newplace when: time > changeplace and inter = false{
			int aux<-rnd(3);
			if aux<3{
				int aux2<-rnd(8);
				targetPoint<-LocationJournalists[aux2] + {rnd(-2.0,2.0),rnd(-2.0,2.0),0};
				changeplace<-time + rnd(70.0,200.0);
			}
			if aux=3{
				targetPoint<-Bars[rnd(2)];
				changeplace<-time + rnd(70.0,200.0);
				working<-false;
				happiness<-happiness+2.0;
			}
	}
	
	reflex askSupp when: inter = false {
		ask Supporters at_distance(5){
			if self.askedInter = false and myself.inter = false and self.inmatch = false and (self.noisy<(myself.acceptnoisy+0.25)){
				int res <- rnd(20);
				self.askedInter <- true;
				if res = 0 and self.inter = false {
					if self.team = myself.team and myself.intense-0.4<self.noisy{
							//write self.name + " accepts interview to: " + myself.name;
							myself.inter <- true;
							self.inter <- true;
							myself.sloc <- self.targetPoint;
							self.targetPoint <- myself.location + {0,2,0}; 
							myself.sinter <- self;
							myself.t <- time + myself.t;
						}
						else{
							if self.hooliganlevel+0.3 > myself.hooliganlevel and self.hooliganlevel-0.3 < myself.hooliganlevel and myself.intense-0.4<self.noisy{
								//write self.name + " accepts interview even is not on my team to: " + myself.name;
								myself.inter <- true;
								self.inter <- true;
								myself.sloc <- self.targetPoint;
								self.targetPoint <- myself.location + {0,2,0}; 
								myself.sinter <- self;
								myself.t <- time + myself.t;
							}
						}	
				}
				else {
					//write self.name + " declines interview to: "+ myself.name;
				}
			}
		}
	}
	
	reflex askPlay when: inter = false{
		ask Players at_distance(5){
			if self.askedInter = false and myself.inter = false and self.matchs = false{
				int res <- rnd(10);
				self.askedInter <- true;
				if res = 0 and self.inter = false {
					if self.team = self.team{
							//write self.name + " accepts interview to: " + myself.name;
							myself.inter <- true;
							self.inter <- true;
							myself.sloc <- self.targetPoint;
							self.targetPoint <- myself.location + {0,2,0}; 
							myself.sinter <- self;
							myself.t <- time + myself.t;
						}
						else{
							if self.happiness > 50 and myself.intense<0.6 and myself.hooliganlevel<0.7{
								//write self.name + " accepts interview even is not on my team to: " + myself.name;
								myself.inter <- true;
								self.inter <- true;
								myself.sloc <- self.targetPoint;
								self.targetPoint <- myself.location + {0,2,0}; 
								myself.sinter <- self;
								myself.t <- time + myself.t;
							}
						}	
				}
				else {
					//write self.name + " declines interview to: "+ myself.name;
				}
			}
		}
	}
	
	reflex changeInter when: inter = true and time = t{
		ask Supporters{
			if self = myself.sinter{
				//write self.name + " finished interview: "+ myself.name;
				self.targetPoint <- myself.sloc;
				self.inter <- false;
				myself.inter <- false;
				myself.sinter <- nil;
				myself.t <-0.0;
				myself.sloc <- {0,0,0};
				myself.changeplace<-time + rnd(70,200);
			}
		}
		ask Players{
			if self = myself.sinter{
				//write self.name + " finished interview: "+ myself.name;
				self.targetPoint <- myself.sloc;
				self.inter <- false;
				myself.inter <- false;
				myself.sinter <- nil;
				myself.t <-0.0;
				myself.sloc <- {0,0,0};
				myself.changeplace<-time + rnd(70,200);
				
			}
		}
	}
	
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		targetPoint<-nil;
	}
	

	aspect default{
		draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
		draw pyramid(2) at: location color: myColor;
	}
}

species Players skills: [fipa, moving]{
	point targetPoint <- nil;
	string team;
	float happiness<-50.0;
	bool matchs<-false;
	bool thirsty<-false;
	float counter<-0.0;
	bool tofanzone<-false;
	bool inter;
	bool askedInter;
	bool tohotel<-false;
	
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}
	
	reflex state when: thirsty = false and matchs = false and inter = false and targetPoint=nil and time mod 15 = 0 and time>counter{
		int rand <- rnd(1500);
		if (rand < 15 and rand >5){
			thirsty <- true;
			targetPoint<-Bars[rnd(2)];
			happiness<- happiness-1.0;
		}
		if (rand>1450){
			if team='Real'{
				targetPoint<-{180,20,0};
				tohotel<-false;
				tofanzone<-true;
			}
			if team='Barca'{
				targetPoint<-{20,180,0};
				tofanzone<-true;
				tohotel<-false;
			}
		}
		if(rand<230 and rand>80){
			tohotel<-true;
			if team='Real'
			{
			targetPoint<-{120,10,0};
		}
		else{
			targetPoint<-{80,180,0};
		}
		}
		
	}
	
	reflex partido when: !empty(informs){
		//calcular utility y comparar con la anterior, si es mas grande ir a la location del inform.
		loop m over: informs {
				if m.contents[2]='Starting Match'{
					targetPoint<- {rnd(70.0,130.0),rnd(70.0,130.0),0.0};
					matchs<-true;
				}
				if m.contents[2]='Match finished'{
					if team='Real'{
						targetPoint<-{120,10,0};
						int result <- int(m.contents[3])-int(m.contents[4]);
						happiness<-happiness+result*6;
						if happiness>100.0{
							happiness<-100.0;
						}
						if happiness<0.0{
							happiness<-0.0;
						}
						//write happiness;
						matchs<-false;
					}	
					if team='Barca'{
						int result <- int(m.contents[4])-int(m.contents[3]);
						happiness<-happiness+result*6;
						targetPoint<-{80,180,0};
						if happiness>100.0{
							happiness<-100.0;
						}
						if happiness<0.0{
							happiness<-0.0;
						}
						//write happiness;
						matchs<-false;
					}
				}
	
	
	}
	
	}
	
	
	
	reflex beIdle when: targetPoint = nil{
		do wander(0.5,360.0,square(5));
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex enterStadium when: targetPoint != nil and location distance_to(targetPoint) < 2  and matchs{
		askedInter <- false;
		ask Supporters at_distance(50){
				if self.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.noisy*self.hooliganlevel*3;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy*self.hooliganlevel*3;
						}
					}
				if self.hooliganlevel<0.650 and self.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.noisy*self.hooliganlevel*2;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy*self.hooliganlevel*2;
						}
					}
				if self.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.noisy*self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy*self.hooliganlevel;
						}				
					}
				}
			
				targetPoint<-nil;
	}
	
	reflex enterBar when: targetPoint != nil and location distance_to(targetPoint) < 2 and thirsty=true{
			ask Supporters at_distance(7){
				if self.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness-self.noisy-self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy-self.hooliganlevel*2;
						}
					}
				if self.hooliganlevel<0.650 and self.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness-self.noisy;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy;
						}
					}
				if self.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel+self.generosity;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness;
						}				
					}
				}
				}
		
	reflex enterZone when: targetPoint != nil and location distance_to(targetPoint) < 2 and tofanzone=true{
			ask Supporters at_distance(7){
				if self.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.noisy+self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy-self.hooliganlevel*10;
						}
					}
				if self.hooliganlevel<0.650 and self.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.noisy+self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy-self.hooliganlevel*10;
						}
					}
				if self.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.hooliganlevel*3-self.noisy;
						}				
					}
				}
				
		}
				
	reflex enterHotel when: targetPoint != nil and location distance_to(targetPoint) < 2 and tohotel=true{
			ask Supporters at_distance(7){
				if self.hooliganlevel>0.650{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.noisy+self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy-self.hooliganlevel*3;
						}
					}
				if self.hooliganlevel<0.650 and self.hooliganlevel>0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.noisy+self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.noisy-self.hooliganlevel*3;
						}
					}
				if self.hooliganlevel<0.350{
					if self.team=myself.team{
						myself.happiness<-myself.happiness+self.hooliganlevel;
						}
					if self.team!=myself.team{
						myself.happiness<-myself.happiness-self.hooliganlevel*3-self.noisy;
						}				
					}
				}
				
		targetPoint<-nil;
		counter<-time+rnd(30.0,150.0); // A counter to stay in a place, otherwise they would be switching all the time.
		
	}
	
	aspect default{
		if team='Real'{
		draw sphere(2) at: location + {0.0,0.0,1.0} color: #white;
		draw pyramid(4) at: location color: #white;
		}
		if team='Barca'{
		draw sphere(2) at: location + {0.0,0.0,1.0} color: #blue;
		draw pyramid(4) at: location color: #red;
		}
		
	}
}

species Vendors skills: [fipa, moving]{
	point targetPoint <- nil;
	rgb myColor <- #salmon;
	float happiness<-50.0;
	float money<-0.0; // the money he has.
	string team;
	float hooliganlevel<-rnd(1.0); // hOw much hooligan it is from his team
	float intense<-rnd(1.0); // How mucho noise and sort of an intense person is the vendor
	
	
	// The happiness of the vendor has to be between 0 and 100, if due to a situation it increases this reflex will correct it immediately.
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}


	aspect default{
		draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
		draw pyramid(2) at: location color: myColor;
		draw square(14) at: location color: #brown;
	}
}

species Stadium skills: [fipa]{
	image_file pitch <- image_file("../includes/football.png");
	float timeduration<-180.0;
	bool over<-true;
	float starttime;
	int goalreal<-0;
	int goalbarca<-0;
	int cornerreal<-0;
	int cornerbarca<-0;
	int yellowreal<-0;
	int yellowbarca<-0;
	int redreal<-0;
	int redbarca<-0;
	int posesionreal<-0;
	int posesionbarca<-0;
	int min<-5;
	
	reflex happens when: (over=true){
		over<-false;
		starttime<-time+rnd(500,650);	
		goalreal<-0;
		goalbarca<-0;
			 goalreal<-0;
	goalbarca<-0;
	cornerreal<-0;
	cornerbarca<-0;
	yellowreal<-0;
	 yellowbarca<-0;
	 redreal<-0;
	 redbarca<-0;
	posesionreal<-0;
	 posesionbarca<-0;
	 min<-5;
	 // When the game is over, we reset the variables in order to be ready for the next game, starttime, creates a random start
	 // to start the new game
	}
	
	reflex startGame when: (over=false and time=starttime-200){
		do start_conversation with: [ to :: list(Supporters), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Starting Match']];
		do start_conversation with: [ to :: list(Players), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Starting Match']];	
		do start_conversation with: [ to :: list(Journalists), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Starting Match']];	
		do start_conversation with: [ to :: list(BettingPage), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Starting Match']];	
		//When starting the match, the information is sent to all interested parts on it, supporters, players journalists and bettingpage.
		
	}
	
	reflex min5 when: time>starttime and time mod 10 = 0 and time <starttime+timeduration+2{
		//Every 10 time iterations, simulating 5 minutes of the game, we simulate a randome possibility of scoring goal within 5 minutes
		//  yellow card within those 5 minutes, red cards within the 5 minutes, corners, and we estimate the ball posession also there for both teams.
		// the values used for random variables, have been tuned in order to obtain accurate and real results.
		int auxgoalreal<-rnd(250);
		if auxgoalreal=220{
			goalreal<-goalreal+2;
		}
		if auxgoalreal>200 and auxgoalreal<220{
			goalreal<-goalreal+1;
		}
		int auxgoalbarca<-rnd(270);
		if auxgoalbarca=220{
			goalbarca<-goalbarca+2;
		}
		if auxgoalbarca>200 and auxgoalbarca<220{
			goalbarca<-goalbarca+1;
		}
		int auxcornerreal<-rnd(120);
		if auxcornerreal=120{
			cornerreal<-cornerreal+2;
		}
		if auxcornerreal>100 and auxcornerreal<120{
			cornerreal<-cornerreal+1;
		}
		int auxcornerbarca<-rnd(130);
		if auxcornerbarca=120{
			cornerbarca<-cornerbarca+2;
		}
		if auxcornerbarca>100 and auxcornerbarca<120{
			cornerbarca<-cornerbarca+1;
		}
				
		int auxyellowreal<-rnd(230);
		if auxyellowreal=220{
			yellowreal<-yellowreal+2;
		}
		if auxyellowreal>200 and auxyellowreal<220{
			yellowreal<-yellowreal+1;
		}
		int auxyellowbarca<-rnd(220);
		if auxyellowbarca=220{
			yellowbarca<-yellowbarca+2;
		}
		if auxyellowbarca>200 and auxyellowbarca<220{
			yellowbarca<-yellowbarca+1;
		}
		int auxredreal<-rnd(500);
		if auxredreal=120{
			redreal<-redreal+2;
		}
		if auxredreal>100 and auxredreal<120{
			redreal<-redreal+1;
		}
		int auxredbarca<-rnd(500);
		if auxredbarca=120{
			redbarca<-redbarca+2;
		}
		if auxredbarca>100 and auxredbarca<120{
			redbarca<-redbarca+1;
		}
		float auxposesion<-gauss(50.0,10.0);
		posesionreal<-int(auxposesion);
		posesionbarca<-100-posesionreal;
		// WE calculate the posession,  and we send to the betting page the results obtained for those 5 minutes.
		do start_conversation with: [ to :: list(BettingPage), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [min,self,'Playing', goalreal, goalbarca ,cornerreal, cornerbarca, yellowreal, yellowbarca, redreal, redbarca, posesionreal, posesionbarca]];	
		min<-min+5;
				goalreal<-0;
		goalbarca<-0;
			 goalreal<-0;
	goalbarca<-0;
	cornerreal<-0;
	cornerbarca<-0;
	yellowreal<-0;
	 yellowbarca<-0;
	 redreal<-0;
	 redbarca<-0;
	posesionreal<-0;
	 posesionbarca<-0;
	 //as we want to further improve in the future, we reset every 5 minutes the variables, so that in the future the supporters can bet on the minue of the first goal and so on.
	}
	
		reflex Resultbetting when: !empty(informs){ // Once the game is finished and we sent an inform to Betting page, we will
		   // receive one back, with the results of the variables of the game, whch will be sent to the supporters
			loop m over: informs {
					do start_conversation with: [ to :: list(Supporters), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self,location,'Match finished',m.contents[0],m.contents[1],m.contents[2],m.contents[3],m.contents[4],m.contents[5],m.contents[6],m.contents[7],m.contents[8],m.contents[9],m.contents[10],m.contents[11],m.contents[12],m.contents[13],m.contents[14],m.contents[15],m.contents[16],m.contents[17],m.contents[18],m.contents[19]]];		
		}
	}
	
	reflex finishGame when: (time>starttime+timeduration+5) and over=false{
		//Once the game is over, when time= to start time plus the duration of a game, we declare tha game as over, and send players betting page and hjournalists the information.
		over<-true;
		do start_conversation with: [ to :: list(Players), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Match finished',goalreal,goalbarca]];
		do start_conversation with: [ to :: list(BettingPage), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Match finished',goalreal,goalbarca]];		
		do start_conversation with: [ to :: list(Journalists), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Match finished',goalreal,goalbarca]];		
	}
	

	
	aspect default{
		draw pitch size: 75;
		//Creation of the picture above, and the surroundings of the staium, simulating the sitting places.
		loop i over: [-40,-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40]{
		draw square(6) at: location - {i,40.0,0.0} color: #orange;
		draw square(6) at: location + {i,40.0,0.0} color: #orange;
		draw square(6) at: location - {40.0,i,0.0} color: #orange;
		draw square(6) at: location + {40.0,i,0.0} color: #orange;
		}
	}
}

species Bar skills: [fipa]{
	rgb myColor <- #yellow;

	aspect default{
		draw square(18) at: location  color: myColor;
	}
}

species Fanzone skills: [fipa]{
	image_file zone1 <- image_file("../includes/real.png");
	image_file zone2 <- image_file("../includes/barca.png");
	string trait;
	
	aspect default{
		if trait='Real'{
				draw zone1 size: 30;	
		}
		if trait='Barca'{
				draw zone2 size: 30;	
		}

	}
}

species Hotel skills: [fipa]{

	string trait;
	
	aspect default{
		if trait='Real'{
				draw square(18) at: location  color: #chocolate;	
		}
		if trait='Barca'{
				draw square(18) at: location  color: #chocolate;	
		}

	}
}

species BettingPage skills: [fipa]{
	int aux2<-0;
	int goalreal<-0;
	int goalbarca<-0;
	int cornerreal<-0;
	int cornerbarca<-0;
	int yellowreal<-0;
	int yellowbarca<-0;
	int redreal<-0;
	int redbarca<-0;
	int posesionreal<-0;
	int posesionbarca<-0;
	int goalrealht<-0;
	int goalbarcaht<-0;
	int cornerrealht<-0;
	int cornerbarcaht<-0;
	int yellowrealht<-0;
	int yellowbarcaht<-0;
	int redrealht<-0;
	int redbarcaht<-0;
	int posesionrealht<-0;
	int posesionbarcaht<-0;
	list gameresult<-[[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0]];
	list totalresult<-[[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0]];

	
		reflex partido when: !empty(informs){
		loop m over: informs {
				if m.contents[2]='Playing'{ // When the match is playing we will receive a fipa with the update every 5 minutes, to know what is happening
				// we pass the data to the two lists, this is done so if in the future new betting modalities want to be added!!!.
					gameresult[aux2][0]<-m.contents[0];
					gameresult[aux2][1]<-m.contents[3];
					gameresult[aux2][2]<-m.contents[4];
					gameresult[aux2][3]<-m.contents[5];
					gameresult[aux2][4]<-m.contents[6];
					gameresult[aux2][5]<-m.contents[7];
					gameresult[aux2][6]<-m.contents[8];
					gameresult[aux2][7]<-m.contents[9];
					gameresult[aux2][8]<-m.contents[10];
					gameresult[aux2][9]<-m.contents[11];
					totalresult[aux2][0]<-m.contents[0];
					if aux2=0{
					totalresult[aux2][0]<-m.contents[0];
					totalresult[aux2][1]<-int(m.contents[3]);
					totalresult[aux2][2]<-int(m.contents[4]);
					totalresult[aux2][3]<-int(m.contents[5]);
					totalresult[aux2][4]<-int(m.contents[6]);
					totalresult[aux2][5]<-int(m.contents[7]);
					totalresult[aux2][6]<-int(m.contents[8]);
					totalresult[aux2][7]<-int(m.contents[9]);
					totalresult[aux2][8]<-int(m.contents[10]);
					totalresult[aux2][9]<-int(m.contents[11]);
					}
					if aux2>0{
						//We continue to add the data for each 5 minutes together, so that we have the sum the real result in real time.
					totalresult[aux2][0]<-m.contents[0];
					totalresult[aux2][1]<-int(totalresult[aux2-1][1])+int(m.contents[3]);
					totalresult[aux2][2]<-int(totalresult[aux2-1][2])+int(m.contents[4]);
					totalresult[aux2][3]<-int(totalresult[aux2-1][3])+int(m.contents[5]);
					totalresult[aux2][4]<-int(totalresult[aux2-1][4])+int(m.contents[6]);
					totalresult[aux2][5]<-int(totalresult[aux2-1][5])+int(m.contents[7]);
					totalresult[aux2][6]<-int(totalresult[aux2-1][6])+int(m.contents[8]);
					totalresult[aux2][7]<-int(totalresult[aux2-1][7])+int(m.contents[9]);
					totalresult[aux2][8]<-int(totalresult[aux2-1][8])+int(m.contents[10]);
					totalresult[aux2][9]<-int(totalresult[aux2-1][9])+int(m.contents[11]);
					
					}
					if aux2=8{
						//after 45 min, of the game we give the report to have a little spoiler!
						write 'HalfTime Report';
						write 'Result HT: ' + 'Real ' + totalresult[8][1] + ' - ' +  totalresult[8][2] + ' Barca';
						write 'Yellow Cards HT: ' + 'Real ' + totalresult[8][5] + ' - ' +  totalresult[8][6] + ' Barca';
						write 'Red Cards HT: ' + 'Real ' + totalresult[8][7] + ' - ' +  totalresult[8][8] + ' Barca';
						write 'Corners HT: ' + 'Real ' + totalresult[8][3] + ' - ' +  totalresult[8][4] + ' Barca';
						write 'Possession HT: ' + 'Real ' + totalresult[8][9]/9 + ' - ' +  (100-int(totalresult[8][9])/9) + ' Barca';
						
					}
					
					if aux2=17{
						// We show here the result of all our variables when the match is finishedº
						write 'FullTime Report';
						write 'Result: ' + 'Real ' + totalresult[17][1] + ' - ' +  totalresult[17][2] + ' Barca';
						write 'Yellow Cards: ' + 'Real ' + totalresult[17][5] + ' - ' +  totalresult[17][6] + ' Barca';
						write 'Red Cards: ' + 'Real ' + totalresult[17][7] + ' - ' +  totalresult[17][8] + ' Barca';
						write 'Corners: ' + 'Real ' + totalresult[17][3] + ' - ' +  totalresult[17][4] + ' Barca';
						write 'Possession: ' + 'Real ' + totalresult[17][9]/18 + ' - ' +  (100-int(totalresult[17][9])/18) + ' Barca';
						
					}
					aux2<-aux2+1;
				}
				if m.contents[2]='Starting Match'{
					aux2<-0;
					// When a match starts, we reset the auxiliar, in order to rewrite over the matrix
				}
				if m.contents[2]='Match finished'{
					// When the stadium informs us about the end of the match, we gather all information, and inform them back with the important information
					totalresult[17][9]<-totalresult[17][9]/18;
					totalresult[8][9]<-totalresult[8][9]/9;
					write gameresult;
					write totalresult;
					//This variables can be cleaned and sent directly, however we are working with many data, and is clear to show what we are sending and using to have it like this.
					posesionreal<-totalresult[17][9];
					posesionbarca<-100-posesionreal;
					goalreal<-totalresult[17][1];
					goalbarca<-totalresult[17][2];
	  				cornerreal<-totalresult[17][3];
					cornerbarca<-totalresult[17][4];
					yellowreal<-totalresult[17][5];
					yellowbarca<-totalresult[17][6];
					redreal<-totalresult[17][7];
					redbarca<-totalresult[17][8];
					goalrealht<-totalresult[8][1];
					goalbarcaht<-totalresult[8][2];
					cornerrealht<-totalresult[8][3];
					cornerbarcaht<-totalresult[8][4];
					yellowrealht<-totalresult[8][5];
					yellowbarcaht<-totalresult[8][6];
					redrealht<-totalresult[8][7];
					redbarcaht<-totalresult[8][8];
					posesionrealht<-totalresult[8][9];
					posesionbarcaht<-100-posesionrealht;
					//We sent to the stadium the information, they will announce it to the Supports together with the end of the match (FIPA).
					do start_conversation with: [ to :: list(Stadium), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [goalreal,goalbarca,goalrealht,goalbarcaht,cornerreal,cornerbarca,cornerrealht,cornerbarcaht,yellowreal,yellowbarca,yellowrealht,yellowbarcaht,redreal,redbarca,redrealht,redbarcaht,posesionreal,posesionbarca,posesionrealht,posesionbarcaht]];		
					
					}	

				}
	
	
	}
	
	}


experiment main type: gui {
	output{		
	    monitor "Current hour" value: current_date.hour;
	    monitor "Average of happiness value" value: avGlobal;
	    monitor "Number of HAPPY people" value: Supporters count (each.happy=true);
	    monitor "Number of SAD people" value: Supporters count (each.happy=false);
	    
	    
	    display chart refresh: every(5 #cycles) {
	        chart "Happiness Rate" type: pie style: spline {
	        data "Happy" value: Supporters count (each.happy=true) color: #green marker: false;
	        data "Sad" value: Supporters count (each.happy=false) color: #red marker: false;
	        }
	    }
		display map type: opengl{
			species Supporters;
			species Security;
			species Journalists;
			species Players;
			species Vendors;
			species Stadium;
			species Fanzone;
			species Bar;
			species BettingPage;
			species Hotel;	
		}
	}
}