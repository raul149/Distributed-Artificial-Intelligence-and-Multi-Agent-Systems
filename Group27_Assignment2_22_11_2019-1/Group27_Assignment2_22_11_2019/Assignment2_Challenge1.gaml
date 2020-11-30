/***
* Name: dutch
* Author: valeria bladinieres and raul AZNAR
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model challenge1

/* Insert your model definition here */

global {
	int numGuests<-20;
	int numAuct<-2;
	int price<-rnd(80,120);
	int price2<-rnd(150,200);
	list startAuction<-[[],[]];
	list nameInterested<-[[],[]];
	bool end <- false;
	bool end2 <-false;
	
	init {
		create Auctioneer number: numAuct;
		create Guest number: numGuests;
	}
}


species Auctioneer skills: [fipa, moving] { 
	rgb myColor <- #blue;
	bool senProp<- false;
	int priceRed<- price;
	int priceRed2 <- price2;
	
	reflex inform_selling when: (1 = time mod 300) {
		if self = Auctioneer[0]{
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [ 'I am selling caps', location, self]];
		end <- false;
		end2 <- false;
		senProp <- false;
		priceRed <- price;
		
		}
		if self = Auctioneer[1]{
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [ 'I am selling umbrellas', location, self]];
		end <- false;
		senProp <- false;
		priceRed2 <- price2;
		
		}
	}
	
	reflex send_cfp_to_participants when: self = Auctioneer[0] and senProp = false and length(nameInterested[0]) != 0 and length(startAuction[0]) != 0 and length(startAuction[0]) = length(nameInterested[0]) {
		write  "Guests interested in buying the product: " + nameInterested[0];
		write name + ' sends a cfp message to all interested participants';
		do start_conversation (to: list(nameInterested[0]), protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed]);
		senProp<- true;
	}
	
	reflex send_cfp_to_participants1 when: self = Auctioneer[1] and senProp = false and length(nameInterested[1]) != 0 and length(startAuction[1]) != 0 and length(startAuction[1]) = length(nameInterested[1]) {
		write  "Guests interested in buying the product: " + nameInterested[1];
		write name + ' sends a cfp message to all interested participants';
		do start_conversation (to: list(nameInterested[1]), protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed2]);
		senProp<- true;
	}
	
	reflex receive_propose_messages when: !empty(proposes){
		write name + ' receives propose messages';
		write "\t"+ proposes[0].sender + "has won the auction!!!!!!";
		if self = Auctioneer[0]{
		do accept_proposal with: [ message :: proposes[0], contents :: ['I accept proposal']];	
		end <- true;
		loop p over: proposes{
			do reject_proposal with: [ message :: p, contents :: ['I reject proposal']];
		}
		
		}
		if self = Auctioneer[1]{
		do accept_proposal with: [ message :: proposes[0], contents :: ['I accept proposal']];	
		end2 <- true;
		loop w over: proposes{
			do reject_proposal with: [ message :: w, contents :: ['I reject proposal']];
		}
		
		}
		
	}
	
	reflex reduce when: self = Auctioneer[0] and empty(proposes) and (0 = time mod 10) and senProp = true and end=false{
		write "reducir precio";
		if price/2>priceRed{
			do start_conversation (to: nameInterested[0], protocol: 'fipa-contract-net', performative: 'inform', contents: ["The price is at lowest, not selling!!"]);
		}
		priceRed<- priceRed*0.9;
		do start_conversation (to: nameInterested[0], protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed]);
	}
	
	reflex reduce2 when: self = Auctioneer[1] and empty(proposes) and (0 = time mod 10) and senProp = true and end2=false{
		write "reducir precio";
		if price2/2>priceRed2{
			do start_conversation (to: nameInterested[1], protocol: 'fipa-contract-net', performative: 'inform', contents: ["The price is at lowest, not selling!!"]);
		}
		priceRed2<- priceRed2*0.9;
		do start_conversation (to: nameInterested[1], protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed2]);
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
	bool wantUmb<- false;
	bool desicion <-false;
	bool buying<- false;
	float priceb;

	
	reflex likes when: desicion = false and (1 = time mod 300){
		int rand <- rnd(2);
		if (rand = 1){
			wantCap <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price*vari;
		}
		if (rand=2){
			wantUmb <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price2*vari;
		}
		desicion <- true;
	}
	
	reflex beIdle when: targetPoint = nil and buying = false{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex going_to_place when: ( 2 = time mod 300) {
		loop m over: informs {
			write name + ' receives message with content: ' + (string(m.contents));
			if m.contents[0] = 'I am selling caps'{ 
				do inform with: [ message :: m, contents :: [ ('Interest ' + name), wantCap, self]];
				if wantCap= true{
					targetPoint<- m.contents[1];
					buying<-true;
					add self to: nameInterested[0];
				}
			}
			else{
				if m.contents[0] = 'I am selling umbrellas'{ 
					do inform with: [ message :: m, contents :: [ ('Interest ' + name), wantUmb, self]];
					if wantUmb= true{
						targetPoint<- m.contents[1];
						buying<-true;
						add self to: nameInterested[1];	
					}
			}
	}
	}
	}
	
	reflex receive_cfp_from_initiator when: !empty(cfps){
		
		message proposalFromInitiator <- cfps[0];
		
		write name + ' receives a cfp message from ' + agent(proposalFromInitiator.sender).name;
		write (name+ " could pay "+ priceb);
		float priceSeller<- proposalFromInitiator.contents[0];
		write priceSeller;
		write "---------------";
		if priceSeller <= priceb{
			do propose with: [ message :: proposalFromInitiator, contents :: ["I wan to buy the cap"] ];
		}
	}
	
	reflex reset when: end = true and end2=true and (wantCap=true or wantUmb=true) {
		//write "----------reset all----------";
		desicion <- false;
		ask Guest{
			self.desicion <- false;
			self.wantCap <- false;
			self.wantUmb <- false;
			self.buying <- false;
			myself.desicion <- false;
			myself.wantCap <- false;
			myself.wantUmb <- false;
			myself.buying <- false;
			self.myColor <- #gray;
			self.location <- {rnd(100),rnd(100)};
			self.targetPoint <- nil;
			myself.myColor <- #gray;
			myself.location <- {rnd(100),rnd(100)};
			myself.targetPoint <- nil;
		}
		startAuction <- [[],[]];
		nameInterested <- [[],[]];
	}
	
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 7 {
		//start auction when they enter to the mat of Auctioneer
		if wantCap = true{
		write "i am in";
		add name to: startAuction[0];
		targetPoint <- nil;
		myColor <- #purple;
		}
		
		if wantUmb = true{
		write "i am in";
		add name to: startAuction[1];
		targetPoint <- nil;
		myColor <- #purple;
		}
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