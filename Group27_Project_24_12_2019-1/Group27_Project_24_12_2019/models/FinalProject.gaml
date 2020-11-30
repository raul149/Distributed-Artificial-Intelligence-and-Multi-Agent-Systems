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
	int numSup <-  5*n+2+n+22;
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
		//Create the bars
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
	float betdesire<-rnd(1.0);
	float noisy<-rnd(1.0);
	bool thirsty<-false;
	bool inmatch<-false;
	int nDrinks<-0;
	float budget<-rnd(1000.0);
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
	
	//constantly checking if the budget and updating generosity and hapiness
	reflex budgetcheck when: time mod 300 = 0{
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
	
	//update happiness if the threshold is violated.
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}
	
	//instructed to die by the guard
	reflex die when: havetoDie = true{
		do die;
	}
	
	//check if they are going to be thirsty and go to the bar, going to fan-zone his or opponents or shopping.
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
	
	//recieves messages from the Stadium about the games,and update happines depending the final score
	reflex utility when: !empty(informs){
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
						// Created a small betting they can bet to an exact result. If they win they get money and happiness, if they don't they decrease happiness and budget.
						int rm <-rnd(5);
						int fcb <- rnd(4);
						write rm;
						write fcb;
						if rm = m.contents[3] or fcb = m.contents[4]{
							budget<-budget+qbet;
							happiness<-happiness+qbet/12;
						}
						if rm = m.contents[3] and fcb = m.contents[4]{
							budget<-budget+qbet*50;
							happiness<-happiness+20.0;
							write 'I got the exact result';
						}
						if rm != m.contents[3] and fcb != m.contents[4]{
							happiness<-happiness-qbet/12;
						}
						betting<-false;
					}
				}
				if m.contents[2]='Starting Match'{
					inmatch<-true;
					thirsty<-false;
					//When the match is starting all suporters go to the match, and randomly decide where they sit. and IF they are going to bet. According also to some attributes
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
					if aux2/8*betdesire>2{
						qbet<-betdesire*aux2;
						betting<-true;
						budget<-budget-qbet;
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
	
	//interactions depending on their personalities, When in the fanzone.
	reflex infanzone when: targetPoint != nil and location distance_to(targetPoint) < 5 and tofanzone and inmatch=false{
		spotted <- false;
		// First is important to know to which fan zone the suppoter went, to the one from its own team or the other one.
		ask Fanzone at_distance(7){
			if self.trait=myself.team{
				myself.myfz <-true;
			}
		}
		
		if myfz{
			counter<-time+150.0;
			//we establish a time that the supporter is in the fanzone. And the interaction starts, depending on the team of the other supporters, their hooliganlevel
			// how noisy they are, all this affects, and if they are from another team they will call security for example. If they are from the same team they will be happier than before
			//the attributes of the supporters create a set of interactions to affect the happiness of them
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
								write myself.name + ': get the hell out of here ' + self.name;
						 	}
						 	/*if self.warning = 2{
								write myself.name + ' going to fight ' + self.name;
						 	}*/
						 	if self.warning = 2{
								write myself.name + ': calling security ' + self.name+ " has "+ self.warning +" warignings";
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
								write myself.name + ': get the hell out of here ' + self.name;
						 	}
						 	/*if self.warning = 2{
								write myself.name + ' going to fight ' + self.name;
						 	}*/
						 	if self.warning = 2{
								write myself.name + ': calling security ' + self.name+ " has "+ self.warning +" warignings";
								do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];
								self.warning <- 2;
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
								write myself.name + ': get the hell out of here ' + self.name;
						 	}
						 	/*if self.warning = 2{
								write myself.name + ' going to fight ' + self.name;
						 	}*/
						 	if self.warning = 2{
								write myself.name + ': calling security ' + self.name+ " has "+ self.warning +" warignings";
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
	
	//interactions depending on their personalities when in the stadium
	//Again It changes, whereas somewhere you do not want noisy people for example in the bar
	// in the stadium that changes you want supporters from your team cheering from it
	// and will hate even more noisy supporters from the other team.
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
							write self.name + ': get the hell out of here ' + myself.name;
					 	}
					 	/*if myself.warning = 2{
							write self.name + ' going to fight ' + myself.name;
					 	}*/
					 	if myself.warning = 2{
							write self.name + ': calling security ' + myself.name+ " has "+ myself.warning +" warignings";
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
							write self.name + ': get the hell out of here ' + myself.name;
					 	}
					 	/*if myself.warning = 2{
							write self.name + ' going to fight ' + myself.name;
					 	}*/
					 	if myself.warning = 2{
							write self.name + ': calling security ' + myself.name+ " has "+ myself.warning +" warignings";
							do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [myself, myself.team, self.hooliganlevel]];
					 		myself.warning <- 2;
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
							write self.name + ': get the hell out of here ' + myself.name;
					 	}
					 	/*if myself.warning = 2{
							write self.name + ' going to fight ' + myself.name;
					 	}*/
					 	if myself.warning = 2{
							write self.name + ': calling security ' + myself.name+ " has "+ myself.warning +" warignings";
							do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [myself, myself.team, self.hooliganlevel]];
					 	}
					}
					
					myself.happiness<-myself.happiness-self.noisy*self.hooliganlevel;
				}				
			}
		}	
		targetPoint<-nil;
	}
	
	//WE cosnider two ways of shopping the first one that someone is passing by, the next one that someones goes to buy.
	// This is also based on the attribute consumism that creates a chance or if the team is the same than the vendor.
	reflex buying when: (location distance_to {40.0,40.0,0.0} < 10) or (location distance_to {90.0,20.0,0.0} < 10) or (location distance_to {20.0,120.0,0.0}<10) or (location distance_to {190.0,140.0,0.0}<10) or (location distance_to {160.0,180.0,0.0}<10){
		point destino;
		spotted <- false;
		if buying=false{
			int aux<-rnd(50);
			ask Vendors at_distance(10){
				//heuristic cosumism, budget, noise and intesivness play a role.
				if aux*myself.consumism > 20 and myself.budget>(aux*myself.consumism+aux*5) and myself.noisy+0.25<self.intense{
					destino<-myself.targetPoint;
					myself.targetPoint<-nil;
					myself.buying<-true;
					//heuritcis that sells for same team 
					if aux mod 2 = 0 and self.team=myself.team{
						myself.budget<-myself.budget-aux-10*self.hooliganlevel;
						myself.happiness<-myself.happiness+2.0;
						self.money<-self.money+aux+10*self.hooliganlevel;
						self.happiness<-self.happiness+aux/15;
						write myself.name + ' Bought a TShirt for ' + (aux+10*self.hooliganlevel) + " in "+ self.name;	
					}
					else{
						if aux mod 2 = 0 and self.team!=myself.team{
							//heuritcis that sells to diferent team
							myself.budget<-myself.budget-aux+10*myself.hooliganlevel;
							myself.happiness<-myself.happiness+0.5;
							self.money<-self.money+aux-10*myself.hooliganlevel;
							self.happiness<-self.happiness+aux/25;
							write myself.name + ' Bought a TShirt for ' + (aux-10*myself.hooliganlevel) + " in "+ self.name;	
						}
						write myself.name + ' did not buy a TShirt for ' + aux+" in "+ self.name;	
						self.happiness<-self.happiness-0.5;
					}
						
				}
				else{
					self.happiness<-self.happiness-0.2;
				}		
			}
		}
		//this part below is used so that the supporter visually remains in the shop when buying and is not actually just passing by.
		
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
	
	//when enter to a bar this reflex is used
	// HEre the intereaction changes and it may be ok to interact with someone from the other team
	// it is more as a neutral point, however the High hooligans never will accept that, but medium hooligan will be happier
	// to interact with calm people and if they are generous maybe invite them to a beer while chatting about the match.
	reflex enterBar when: targetPoint != nil and location distance_to(targetPoint) < 2 and thirsty{

		if thirsty=true{
			//Buys a drink for itself
			nDrinks <- nDrinks +1;
			budget <- budget -2.0;
			happiness<-happiness+1.0;
			
			//buys a drink for journalist depending on its personality
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
				
			//buys a drink for another supporter depending on its personality
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
	
	//checking for drunk journalists or supporters around them.
	reflex drunk{
		ask Supporters at_distance(7){
			if (self.nDrinks > 3 and self.reported = false and self.noisy>0.4){
				self.reported <- true;
				write "\t"+"send name to guard of: "+ self.name;
				write "\t"+"from"+ myself.name;
				do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];
			}
			
		}
		ask Journalists at_distance(7){
			if self.nDrinks > 5 and self.reported = false and self.intense>0.4{
				self.reported <- true;
				write "\t"+"send name to guard of: "+ self.name;
				write "\t"+"from"+ myself.name;
				do start_conversation with: [ to :: list(Security), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, self.team, self.hooliganlevel]];
			}
		}
	}
	
	// This reflex measures the happy supporters and the sad ones to be displayed in the chart.
	reflex statistics{
		float av;
		float c;
		ask Supporters {
			av <- av + self.happiness;
			c <- c +1;
		}
		av <- av/c;
		avGlobal <- av ;
		
		if happiness >= av{
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
	float happines <- rnd(35.0,80.0);
	
	point targetPoint <- nil;
	bool doingSomething<- false ;
	list nextTn;
	list nextTnT;
	
	point targetPoint2 <- nil;
	bool doingSomething2<- false ;
	list nextTn2;
	list nextTnT2;
	
	
	
	reflex mood when: time mod 300 = 0 {
	 	happines <- rnd(45.0,55.0);
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
				if happines > 40 and m.contents[1] = team and hoolig < 0.75{
					ask Supporters{
						//let go, and reset warnings
						if m.contents[0] = self{
							write self.name +" number of warnings "+ self.warning;
							self.warning <- 0;
							write "\t"+ myself.name +": he is not a bad guy, I let "+ self.name + "("+ self.team+")"+" go!" ;
							write self.name +" number of warnings "+ self.warning;
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
							write "\t"+"added to waiting list of " + name;
							add m.contents[0] to: nextTn;
							add m.contents[1] to: nextTnT;
						}
					}
					if doingSomething = false{
						nameBadGuy <- (m.contents[0]);
						teamBG <- (m.contents[1]);
						targetPoint <- nameBadGuy.location;
						write "\t"+name +": going to get: " + nameBadGuy;
						doingSomething <-true;
					}
				}
			}
			if r = 0 and team = "Real" and cur2 != m.contents[0] and cur != m.contents[0]{
				cur2 <- m.contents[0];
				hoolig <- float(m.contents[2]);
				//if guard really happy(above average), his team(Real) and guy not very hooligan
				if happines > 40 and m.contents[1] = team and hoolig < 0.75 {
					ask Supporters{
						//let go, and reset warnings
						if m.contents[0] = self{
							write self.name +" number of warnings "+ self.warning;
							self.warning <- 0;
							write "\t"+ myself.name +": he is not a bad guy, I let "+ self.name + "("+ self.team+")"+" go!" ;
							write self.name +" number of warnings "+ self.warning;
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
							write "\t"+"added to waiting list of " + name;
							add m.contents[0] to: nextTn2;
							add m.contents[1] to: nextTnT2;
						}
					}
					if doingSomething2 = false{
						nameBadGuy <- (m.contents[0]);
						teamBG <- (m.contents[1]);
						targetPoint2 <- nameBadGuy.location;
						write "\t"+name +": going to get: " + nameBadGuy;
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
				write "\t"+myself.name+" killed: "+ self.name +"--";
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
				write "\t"+myself.name+" killed: "+ self.name +"--";
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
				write "\t"+myself.name+" killed: "+ self.name +"-------------";
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
				write "\t"+myself.name+" killed: "+ self.name +"-------------";
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
	
	//This reflex is used to go for a new place and not staying always static
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
	
	//ask supporters for interview
	reflex askSupp when: inter = false {
		ask Supporters at_distance(5){
			if self.askedInter = false and myself.inter = false and self.inmatch = false and (self.noisy<(myself.acceptnoisy+0.25)){
				//ask supporters for interview randomly choose if the  agent will accept or not, but also an extra interaction is addded
				//if journalists is more intenses or hooligan or not the same team, that also affects the decision. 
				int res <- rnd(20);
				self.askedInter <- true;
				if res = 0 and self.inter = false {
					if self.team = myself.team and myself.intense-0.4<self.noisy{
							write self.name+"("+self.team+")" + " accepts interview to becasue is on my team: " + myself.name +"("+myself.team+")";
							write "Time: "+time;
							myself.inter <- true;
							self.inter <- true;
							myself.sloc <- self.targetPoint;
							self.targetPoint <- myself.location + {0,2,0}; 
							myself.sinter <- self;
							myself.t <- time + myself.t;
						}
						else{
							if self.hooliganlevel+0.3 > myself.hooliganlevel and self.hooliganlevel-0.3 < myself.hooliganlevel and myself.intense-0.4<self.noisy{
								write self.name+"("+self.team+")" + " accepts interview even is not on my team to: " + myself.name+"("+myself.team+")";
								//write "Time: "+time;
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
	
	//ask players for interview
	reflex askPlay when: inter = false{
		ask Players at_distance(5){
			if self.askedInter = false and myself.inter = false and self.matchs = false{
				//ask supporters for interview randomly choose if the  agent will accept or not
				// In addition some attributes are used, the happiness and how intense or hooligan the journalist is.
				int res <- rnd(10);
				self.askedInter <- true;
				if res = 0 and self.inter = false {
					if self.team = myself.team{
							write self.name + " accepts interview to: " + myself.name;
							write "Time: "+time;
							myself.inter <- true;
							self.inter <- true;
							myself.sloc <- self.targetPoint;
							self.targetPoint <- myself.location + {0,2,0}; 
							myself.sinter <- self;
							myself.t <- time + myself.t;
						}
						else{
							if self.happiness > 50 and myself.intense<0.6 and myself.hooliganlevel<0.7{
								write self.name + " accepts interview even is not on my team to: " + myself.name;
								//write "Time: "+time;
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
	
	//When an interview is finished the reflex pops up to resets the variables, in order to change to a new one
	reflex changeInter when: inter = true and time = t{
		ask Supporters{
			if self = myself.sinter{
				write self.name + " finished interview: "+ myself.name;
				write "Time: "+time;
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
				write self.name + " finished interview: "+ myself.name;
				write "Time: "+time;
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
	
	//constantly checking if the budget and updating generosity and hapiness
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}
	
	//check if they are going to be thirsty going to the bar, going to fan-zone or the hotel.
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
	
	//recieves messages from the Stadium about the games,and update happines depending the final score
	reflex partido when: !empty(informs){
		loop m over: informs {
				if m.contents[2]='Starting Match'{
					//when the match starts, the players go to the stadium: TIME TO PLAY!!
					targetPoint<- {rnd(70.0,130.0),rnd(70.0,130.0),0.0};
					matchs<-true;
				}
				if m.contents[2]='Match finished'{
					// Once the match is finished the happiness is updated depending on the result and players go to their respective hotels.
					if team='Real'{
						targetPoint<-{120,10,0};
						int result <- int(m.contents[3])-int(m.contents[4]);
						happiness<-happiness+result*3;
						if happiness>100.0{
							happiness<-100.0;
						}
						if happiness<0.0{
							happiness<-0.0;
						}
						write happiness;
						matchs<-false;
					}	
					if team='Barca'{
						int result <- int(m.contents[4])-int(m.contents[3]);
						happiness<-happiness+result*3;
						targetPoint<-{80,180,0};
						if happiness>100.0{
							happiness<-100.0;
						}
						if happiness<0.0{
							happiness<-0.0;
						}
						write happiness;
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
	
	//interactions depending on their personalities
	// In the stadium the players are happier of noisy and hooligan supporters of their team
	// Whereas they are sad for opposite thing.
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
	
	//In a bar that changes and they do not want hooligans aroung from any team, they want to chill in the bar
	// Where in a stadium they prefer noisy and hooligan in  abar they prefer chill people.
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
				
				
	// In the fanzone again changes and they want people from their team equally no matter what!	
	reflex enterZone when: targetPoint != nil and location distance_to(targetPoint) < 2 and tofanzone=true{
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
		counter<-time+rnd(30.0,150.0);
		
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
	float money<-0.0;
	string team;
	float hooliganlevel<-rnd(1.0);
	float intense<-rnd(1.0);
	
	reflex updatehappiness when: happiness<0.0 or happiness>100.0{
		if happiness<0{
			happiness<-0.0;
		}
		if happiness>100{
			happiness<-100.0;
		}
	}
	
	reflex printMoney when: int(time) mod 1000 = 0{
		write "The "+name+" has: "+ money +" euros";
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
	
	//When the match is over the variables are reset and a new one is scheduled!
	reflex happens when: (over=true){
		over<-false;
		starttime<-time+rnd(500,650);	
		goalreal<-0;
		goalbarca<-0;
	}
	
	reflex startGame when: (over=false and time=starttime-200){
		//Before  agame starts all the interested parts are called before to gather in the stadium 
		do start_conversation with: [ to :: list(Supporters), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Starting Match']];
		do start_conversation with: [ to :: list(Players), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Starting Match']];	
		do start_conversation with: [ to :: list(Journalists), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Starting Match']];	
		// the result is already calculated.
		goalreal<-rnd(5);
		goalbarca<-rnd(4);
	}
	
	reflex finishGame when: (time>starttime+timeduration) and over=false{
		// when the game is finish the stadium send the information via FIPA to all the interested parts.
		over<-true;
		do start_conversation with: [ to :: list(Supporters), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Match finished',goalreal,goalbarca]];
		write '------------';
		write 'Real';
		write goalreal;
		write 'Barca';
		write goalbarca;
		write '------------';
		do start_conversation with: [ to :: list(Players), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Match finished',goalreal,goalbarca]];
		do start_conversation with: [ to :: list(Journalists), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,'Match finished',goalreal,goalbarca]];		
	}
	
	aspect default{
		draw pitch size: 75;
		//Drawing the stadium and the seat
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
			species Hotel;	
		}
	}
}