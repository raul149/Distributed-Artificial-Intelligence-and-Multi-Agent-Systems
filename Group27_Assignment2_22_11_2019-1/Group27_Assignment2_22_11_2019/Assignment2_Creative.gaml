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
	int price;
	int price2;
	list startAuction<-[[],[]];
	list nameInterested<-[[],[]];
	bool end <- false;
	bool end2 <-false;
	int aux <- rnd(2);
	list tiempo <-['Rainy','Normal Sun','High Sun'];
	int luz;
	int rojo<-255;
	int verde<-255;
	int azul<-0;
	
	init {
		create Auctioneer number: numAuct;
		create Guest number: numGuests;
		create Weather number:1{
			trait <- tiempo[aux];
		}
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
		if aux=0{
		price<-rnd(800,1200);
		}
		if aux=1{
		price<-rnd(1200,1800);
		}
		if aux=2{
		price<-rnd(1800,2200);
		}
		
		priceRed <- price;
		
		}
		if self = Auctioneer[1]{
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [ 'I am selling umbrellas', location, self]];
		end <- false;
		senProp <- false;
		if aux=1{
		price2<-rnd(800,1200);
		}
		if aux=1{
		price2<-rnd(1200,1800);
		}
		if aux=0{
		price2<-rnd(1800,2200);
		}
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
			if self = Auctioneer[0]{
			draw square(13) at: location color: #red;
			draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
			draw pyramid(2) at: location color: myColor;
			}
			if self = Auctioneer[1]{
			draw square(13) at: location color: #black;
			draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
			draw pyramid(2) at: location color: myColor;
			}
		
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
		int rand <- rnd(20);
		if aux=0{
		if (rand < 3){
			wantCap <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price*vari;
		}
		if (rand>8){
			wantUmb <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price2*vari;
		}
		}
		if aux=1{
		if (rand > 14){
			wantCap <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price*vari;
		}
		if (rand<6){
			wantUmb <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price2*vari;
		}
		}
		if aux=2{
		if (rand > 7){
			wantCap <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price*vari;
		}
		if (rand<1){
			wantUmb <- true;
			//write name +" like caps";
			float vari<-rnd(0.3,0.7);
				priceb <-price2*vari;
		}
		}
		desicion <- true;
	}
	
	reflex beIdle when: targetPoint = nil and buying = false{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	
	/*loop m over: informs {
			write name + ' receives message with content: ' + (string(m.contents));
			if m.contents[0] = 'I am selling caps'{ 
			do inform with: [ message :: m, contents :: [ ('Interest ' + name), wantCap, self]];
			if wantCap= true{
				targetPoint<- m.contents[1];
			}}
			else{
			if m.contents[0] = 'I am selling umbrellas'{ 
			do inform with: [ message :: m, contents :: [ ('Interest ' + name), wantUmb, self]];
			if wantUmb= true{
				targetPoint<- m.contents[1];	
			}
		}
	}
	}
	* loop mess over: informs {
			write name + ' receives message with content: ' + (string(mess.contents[0]));
			if wantCap= true{
				write name + " going to location of Auction";
				targetPoint<- mess.contents[1];
				add self to: nameInterested;
				myColor <- #purple;
				buying <-true;
	* 
	* 
	* */
	
	reflex going_to_place when: ( 2 = time mod 300) {
		loop m over: informs {
			write name + ' receives message with content: ' + (string(m.contents));
			if m.contents[0] = 'I am selling caps'{ 
			do inform with: [ message :: m, contents :: [ ('Interest ' + name), wantCap, self]];
			if wantCap= true{
				targetPoint<- m.contents[1];
				buying<-true;
				add self to: nameInterested[0];
			}}
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
	
	reflex endiiit when: ( 0 = time mod 290){
		end<-true;
		end2<-true;
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
		write "I am ready to buy a Cap";
		add name to: startAuction[0];
		targetPoint <- nil;
		myColor <- #purple;
		}
		
		if wantUmb = true{
		write "I want an umbrella!!";
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

species Weather{
	string trait;
	
	reflex changeweather when: ( 0 = time mod 600) {
		aux <- rnd(2);
		trait<-tiempo[aux];
	}
	
	aspect default{
		if (self.trait = "High Sun"){
		draw sphere(10) at: {50.0,50.0,15.0} color: #red;
		luz<-180;
		rojo<-255;
		verde<-0;
		azul<-0;
		}
		if (self.trait = "Rainy"){
			loop i from: 0 to:30{
				int l <- rnd(-40,50);
				int k <- rnd(-40,50);
				//loop j from: 1 to: 4{
					draw sphere(3) at: {50.0+l,50.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {51.0+l,51.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {52.0+l,52.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,52.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,53.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {54.0+l,53.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {55.0+l,55.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {56.0+l,57.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {58.0+l,58.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {59.0+l,59.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {60.0+l,60.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {61.0+l,62.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,55.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,53.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,51.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,57.0+k,15.0} color: rgb(20,20,50,255); //#darkgray;
				//}
				luz<-180;
				rojo<-0;
		 		verde<-0;
				azul<-250;
			}
		/*draw sphere(3) at: {30.0,30.0,10.0} color: #gray;
		draw sphere(3) at: {31.0,31.0,10.0} color: #gray;
		draw sphere(3) at: {32.0,32.0,10.0} color: #gray;
		draw sphere(3) at: {33.0,32.0,10.0} color: #gray;
		draw sphere(3) at: {33.0,33.0,10.0} color: #gray;
		draw sphere(3) at: {34.0,33.0,10.0} color: #gray;
		draw sphere(3) at: {35.0,35.0,10.0} color: #gray;
		draw sphere(3) at: {36.0,37.0,10.0} color: #gray;
		*/
		}
		if (self.trait = "Normal Sun"){
		draw sphere(10) at: {50.0,50.0,15.0} color: #yellow;
				loop i from: 0 to:20{
				int l <- rnd(-40,50);
				int k <- rnd(-40,50);
				//loop j from: 1 to: 4{
					draw sphere(3) at: {50.0+l,50.0+k,15.0} color: #white; //rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {51.0+l,51.0+k,15.0} color: #white; //rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {52.0+l,52.0+k,15.0} color: #white; //rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,52.0+k,15.0} color: #white; //rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,53.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {54.0+l,53.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {55.0+l,55.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {56.0+l,57.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {58.0+l,58.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {59.0+l,59.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {60.0+l,60.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {61.0+l,62.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,55.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,53.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,51.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					draw sphere(3) at: {53.0+l,57.0+k,15.0} color: #white; // rgb(20,20,50,255); //#darkgray;
					}
		luz<-180;
		rojo<-255;
		verde<-255;
		azul<-0;
		}
		}
}

experiment main type: gui {
	output{
		display map type: opengl {
			//light id: 1 type: point position: {50,50,2} color: rgb(255,0,0);
			light id: 1 type: spot position: {50,50,10} direction: {1,1,1} color: rgb(rojo,verde,azul) spot_angle: luz;
			light id: 2 type: spot position: {30,30,10} direction: {1,1,1} color: rgb(rojo,verde,azul) spot_angle: luz;
			light id: 3 type: spot position: {70,70,10} direction: {1,1,1} color: rgb(rojo,verde,azul) spot_angle: luz;
			species Auctioneer;
			species Guest;
			species Weather;
		}
	}
}