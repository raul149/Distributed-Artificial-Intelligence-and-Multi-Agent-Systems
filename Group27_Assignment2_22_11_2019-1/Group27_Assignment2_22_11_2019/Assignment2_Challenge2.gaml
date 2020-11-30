/***
* Name: challenge1
* Author: valeriabladinieres and raul aznar
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model challenge2

/* Insert your model definition here */

global {
	int numGuests<-40;
	int numAuct<-1;
	int price<-500;
	list startAuction <- [[],[],[]];
	list nameInterested <- [[],[],[]];
	bool end <- false;
	bool end2 <- false;
	bool end3 <- false;
	int benDutch<-0;
	int benSealed<-0;
	int benVickrey<-0;
	
	list types <- ["Dutch", "Sealed","Vickrey"];
	int typ <-0;
	
	init {
		create Auctioneer number: numAuct{
			type <-"Dutch" ;
		}
		create Auctioneer number: numAuct{
			type <-"Sealed" ;
		}
		create Auctioneer number: numAuct{
			type <-"Vickrey";
		}
		create Guest number: numGuests;
	}
}


species Auctioneer skills: [fipa, moving] { 
	rgb myColor <- #blue;
	bool senProp<- false;
	float priceRed<- price;
	string type;
		
		reflex results_ben when: ( 0= time mod 300){
			write 'sealed';
			write benSealed;
			write 'dutch';
			write benDutch;
			write 'vickrey';
			write benVickrey;
		}
	
		reflex inform_selling when: (1 = time mod 300) {
			do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [ 'I am selling caps', location,self.type]];
			end <- false;
			end2<- false;
			end3<-false;
			senProp <- false;
			priceRed <- price;
			write nameInterested;
		}
		
		reflex send_cfp_to_participants when: type = "Dutch" and senProp = false and length(nameInterested[0]) != 0 and length(startAuction[0]) != 0 and length(startAuction[0]) = length(nameInterested[0]) and end=false {
			write  "Guests interested in buying the product: " + nameInterested[0];
			write name + ' sends a cfp message to all interested participants';
			do start_conversation (to: list(nameInterested[0]), protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed, type]);
			senProp<- true;
		}
		reflex send_cfp_to_participants2 when: type = "Sealed" and senProp = false and length(nameInterested[1]) != 0 and length(startAuction[1]) != 0 and length(startAuction[1]) = length(nameInterested[1]) and end2=false {
			write  "Guests interested in buying the product: " + nameInterested[1];
			write name + ' sends a cfp message to all interested participants';
			do start_conversation (to: list(nameInterested[1]), protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed, type]);
			senProp<-true;
		}
		reflex send_cfp_to_participants3 when: type = "Vickrey" and senProp = false and length(nameInterested[2]) != 0 and length(startAuction[2]) != 0 and length(startAuction[2]) = length(nameInterested[2]) and end3=false {
			write  "Guests interested in buying the product: " + nameInterested[2];
			write name + ' sends a cfp message to all interested participants';
			do start_conversation (to: list(nameInterested[2]), protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed, type]);
			senProp<-true;
		}
		
		reflex receive_propose_messages when: type = "Dutch" and !empty(proposes){
			write name + ' receives propose messages';
			write "\t"+ proposes[0].sender + "has won the auction!!!!!!";
			do accept_proposal with: [ message :: proposes[0], contents :: ['I accept proposal']];	
			benDutch<-benDutch+priceRed-250;
			end <- true;
			loop p over: proposes{
				do reject_proposal with: [ message :: p, contents :: ['I reject proposal']];
			}
		}
		
		reflex reduce when: type = "Dutch" and empty(proposes) and (0 = time mod 10) and senProp = true and end=false{
			write "reducir precio";
			write price ;
			write priceRed;
			if (price/2+1)>priceRed{
					do start_conversation (to: nameInterested[0], protocol: 'fipa-contract-net', performative: 'inform', contents: ["The price is at lowest, not selling!!", location,self.type]);
					write "The price is at lowest, not selling!!";
					end <- true;
				}
			else {
				if (price/2+1)>priceRed*0.9{
				priceRed<-price/2;
				do start_conversation (to: nameInterested[0], protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed]);
				}
				else{
				priceRed<- priceRed*0.9;
				do start_conversation (to: nameInterested[0], protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed]);
			}
		}
		}
		
		
		reflex receive_propose_messages2 when: type = "Sealed" and !empty(proposes) and end2=false{
			write name + ' receives propose messages';
			write length(proposes);
			int hig <- 0;
			message na;
			list<message> no;
			loop p over: proposes{
				int value <- p.contents[1];
				write p.contents[1];
				if hig < value{
					hig <- p.contents[1];
					na <- p;
				}
				else{
					no <- p;
				}
			}
			write "__________";
			write na;
			write  hig;
			
			benSealed<-benSealed+hig-250;
			write "\t"+ na.sender+ "has won the auction!!!!!!";
			do accept_proposal with: [ message :: na, contents :: ['I accept proposal']];

			
			loop j over: proposes{
				do reject_proposal with: [ message :: j, contents :: ['I reject proposal']];
				
			}
			
			end2 <- true;
		}
		
		reflex receive_propose_messages3 when: type = "Vickrey" and !empty(proposes) and end3=false{
			write name + ' receives propose messages';
			write length(proposes);
			int hig <- 0;
			message na;
			int hig2<- 0;
			list<message> no;
			loop p over: proposes{
				int value <- p.contents[1];
				write p.contents[1];
				if hig < value{
					hig2 <- hig;
					hig <- p.contents[1];
					na <- p;
				}
				else{
					if hig2 <value{
						hig2 <- p.contents[1];
					}
				}
			}
			write "__________";
			write na;
			write  hig2;
			
			benVickrey<-benVickrey+hig2-250;
			write "\t"+ na.sender+ "has won the auction for the following price"+ hig2;
			do accept_proposal with: [ message :: na, contents :: ['I accept proposal',hig2]];
			loop j over: proposes{
				do reject_proposal with: [ message :: j, contents :: ['I reject proposal']];
				
			}
			end3 <- true;
		}
	
	
	aspect default{
			draw square(13) at: location color: #green;
			draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
			draw pyramid(2) at: location color: myColor;
	}
}

species Guest skills: [fipa, moving] {
	rgb myColor <- #gray;
	point targetPoint <- nil;
	bool wantCap<- false;
	bool desicion <-false;
	bool buying<- false;
	float priceb;
	string auctionT;
	
	reflex likes when: desicion = false and 1 = time mod 300{
		int rand <- rnd(20);
		if (rand < 15){
			wantCap <- true;
		}
		
		auctionT <- types[rnd(length(types) - 1)];
		if auctionT = "Dutch"{
			float vari<-rnd(0.4,0.6);
			priceb <-price*vari;
			desicion <- true;
		}
		if auctionT = "Sealed"{
			float vari<-rnd(0.35,0.55);
			priceb<- price*vari;
			desicion <- true;
		}
		if  auctionT = "Vickrey"{
			float vari<-rnd(0.4,0.6);
			priceb<- price*vari;
			desicion <- true;
		}
	}
	
	reflex beIdle when: targetPoint = nil and buying = false{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex going_to_place when: ( 2 = time mod 300){
		loop mess over: informs {
			//write name + ' receives message with content: ' + (string(mess.contents[0]));
			//write mess;
			write mess.contents[2];
			if auctionT = mess.contents[2]{
				if wantCap= true and end = false{
					write name + " going to location of Auction";
					targetPoint<- mess.contents[1];
					if auctionT = "Dutch"{
						add self to: nameInterested[0];
						myColor <- #purple;
						buying <-true;
					}
				if wantCap= true and end2 = false{
					write name + " going to location of Auction";
					targetPoint<- mess.contents[1];	
					if auctionT = "Sealed"{
						add self to: nameInterested[1];
						myColor <- #green;
						buying <-true;
					}
					
					}
				if wantCap= true and end3 = false{
					write name + " going to location of Auction";
					targetPoint<- mess.contents[1];
					if auctionT = "Vickrey"{
						add self to: nameInterested[2];
						myColor <- #yellow;
						buying <-true;
					}
					
				}
			}
			}
		}
	}
	
	reflex receive_cfp_from_initiator when: !empty(cfps) and buying=true{
		
		message proposalFromInitiator <- cfps[0];
		//write auctionT + "-------------";
		if auctionT = "Dutch" and end=false{
			write name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name;
			write (name+ " could pay "+ priceb);
			float priceSeller<- proposalFromInitiator.contents[0];
			write priceSeller;
			if priceSeller <= priceb{
				do propose with: [ message :: proposalFromInitiator, contents :: ["I wan to buy the cap"] ];
			}
		}
		if auctionT="Sealed" and end2=false{
			write "sending proposal for " + auctionT;
			do propose with: [ message :: proposalFromInitiator, contents :: ["I wan to buy the cap", priceb] ];

		}
		if auctionT="Vickrey" and end3=false{
			write "sending proposal for " + auctionT;
			do propose with: [ message :: proposalFromInitiator, contents :: ["I wan to buy the cap", priceb] ];
				}
		
	}
	
	reflex reset when: end = true and end2 = true and end3= true and wantCap=true {
		//write "----------reset all----------";
		desicion <- false;
		ask Guest{
			self.desicion <- false;
			self.wantCap <- false;
			self.buying <- false;
			myself.desicion <- false;
			myself.wantCap <- false;
			myself.buying <- false;
			self.myColor <- #gray;
			self.location <- {rnd(100),rnd(100)};
			self.targetPoint <- nil;
			myself.myColor <- #gray;
			myself.location <- {rnd(100),rnd(100)};
			myself.targetPoint <- nil;
		}
		startAuction <- [[],[],[]];
		nameInterested <- [[],[],[]];
	}
	
	reflex resettwo when:  0 = time mod 299{
		cfps<-nil;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 7 {
		//start auction when they enter to the mat of Auctioneer
		write "I am at the acutions place";
		if auctionT = "Dutch" and end=false and wantCap=true{
			//write"------Dutch-------"; 
			add name to: startAuction[0];
			targetPoint <- nil;
		}
		if auctionT = "Sealed" and end2=false and wantCap = true{
			//write"------Sealed-------"; 
			add name to: startAuction[1];
			targetPoint <- nil;
		}
		if auctionT = "Vickrey" and end3=false and wantCap=true{
			//write"------Vickrey-------"; 
			add name to: startAuction[2];
			targetPoint <- nil;
		}
		targetPoint <- nil;
	}
	
	aspect default{
		draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
		draw pyramid(2) at: location color: myColor;
	}
	
}

experiment main type: gui {
	output{
		display map type: opengl{
			species Auctioneer;
			species Guest;
		}
	}
}