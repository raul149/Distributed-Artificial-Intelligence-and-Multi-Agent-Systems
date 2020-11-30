/***
* Name: dutch
* Author: valeria bladinieres and raul AZNAR
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model dutch

/* Insert your model definition here */

global {
	int numGuests<-20;
	int numAuct<-1;
	int price<-500;
	list startAuction;
	list<agent> nameInterested;
	bool end <- false;
	
	init {
		create Auctioneer number: numAuct;
		create Guest number: numGuests;
	}
}


species Auctioneer skills: [fipa, moving] { 
	rgb myColor <- #blue;
	bool senProp<- false;
	float priceRed<- price;
	
	reflex inform_selling when: (1 = time mod 300) {
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [ 'I am selling caps', location]];
		end <- false;
		senProp <- false;
		priceRed <- price;
	}
	
	reflex send_cfp_to_participants when: senProp = false and length(nameInterested) != 0 and length(startAuction) != 0 and length(startAuction) = length(nameInterested) {
		write  "Guests interested in buying the product: " + nameInterested;
		write name + ' sends a cfp message to all interested participants';
		do start_conversation (to: list(nameInterested), protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed]);
		senProp<- true;
	}
	
	reflex receive_propose_messages when: !empty(proposes){
		write name + ' receives propose messages';
		write "\t"+ proposes[0].sender + "has won the auction!!!!!!";
		do accept_proposal with: [ message :: proposes[0], contents :: ['I accept proposal']];	
		end <- true;
		loop p over: proposes{
			do reject_proposal with: [ message :: p, contents :: ['I reject proposal']];
		}
	}
	
	reflex reduce when: empty(proposes) and (0 = time mod 10) and senProp = true and end=false{
		write "reducir precio";
		write price ;
		write priceRed;
		if price/2>priceRed*0.9{
			do start_conversation (to: nameInterested, protocol: 'fipa-contract-net', performative: 'inform', contents: ["The price is at lowest, not selling!!"]);
			write "The price is at lowest, not selling!!";
			end <- true;
		}
		else{
			priceRed<- priceRed*0.9;
			do start_conversation (to: nameInterested, protocol: 'fipa-contract-net', performative: 'cfp', contents: [priceRed]);
		}
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

	
	reflex likes when: desicion = false{
		int rand <- rnd(2);
		if (rand = 1){
			wantCap <- true;
			//write name +" like caps";
		}
		float vari<-rnd(0.3,0.6);
		priceb <-price*vari;
		desicion <- true;
	}
	
	reflex beIdle when: targetPoint = nil and buying = false{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex going_to_place when: !empty(informs) or ( 2 = time mod 300) {
		loop mess over: informs {
			write name + ' receives message with content: ' + (string(mess.contents[0]));
			if wantCap= true and end = false{
				write name + " going to location of Auction";
				targetPoint<- mess.contents[1];
				add self to: nameInterested;
				myColor <- #purple;
				buying <-true;
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
	
	reflex reset when: end = true {
		//write "----------reset all----------";
		desicion <- false;
		ask Guest{
			self.desicion <- false;
			self.wantCap <- false;
			self.buying <- false;
			self.myColor <- #gray;
		}
		startAuction <- [];
		nameInterested <- [];
	}
	
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 7 {
		//start auction when they enter to the mat of Auctioneer
		write "I am at the acutions place";
		add name to: startAuction;
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