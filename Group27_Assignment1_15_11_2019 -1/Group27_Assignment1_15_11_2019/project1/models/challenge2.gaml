/***
* Name: challenge2
* Author: valeriabladinieres
* Description: body guard
* Tags: Tag1, Tag2, TagN
***/

model challenge2

/* Insert your model definition here */


global {
	int numStores<-2;
	init
	{
		create InfoCenter number: 1{
			location <- {50, 50};
		}
		create Guest number: 20{
			
		}
		create Store number: numStores{
			trait <- "Food";
		}
		create Store number: numStores{
			trait <- "Drink";
		}
		create Security{
			
		}

	}

}

species InfoCenter{
	
	list storesDrink;
	point locStoreD;
	list storesFood;
	point locStoreF;
	point securityLoc <- nil;
	bool securitBussy <- false;
	
	
	reflex storeLoc when: length(storesDrink) < numStores  or length(storesFood) < numStores{
		ask Store {
			if (self.trait = "Drink"){
				myself.locStoreD <- self.location;
				add myself.locStoreD to: myself.storesDrink;
			}
			else{
				myself.locStoreF <- self.location;
				add myself.locStoreF to: myself.storesFood;	
			}
		}
	}
	
	reflex secLoc{
		ask Security {
				myself.securityLoc <- self.location;
				if myself.securitBussy = true{
					self.doingSomething <- myself.securitBussy;
				}
			}
	} 
	
	aspect default{
		draw pyramid(5) at: location color: #yellow;
		}
}

species Guest skills:[moving]{
	
	point targetPoint <- nil;
	bool hungry <- false;
	bool thirsty <- false;
	rgb myColor <- #gray;
	bool good <- true;
	bool occupiedAll<- false;
	bool occupied<- false;
	bool reporting;
	bool notify;
	string nameBadGuy;
	bool found;
	bool tellS;
	bool havetoDie;
	bool spotedAsBad;
	
	reflex die when: havetoDie = true{
		do die;
	}
	
	reflex beIdle when: targetPoint = nil{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex state when: myColor = #grey{
		int rand <- rnd(1000);
		if (rand = 1){
			thirsty <- true;
			myColor <- #yellow;
			ask InfoCenter {
				myself.targetPoint <- self.location;		
			}
		}
		if (rand = 2){
			hungry <- true;
				myColor <- #yellow;
			ask InfoCenter {
				myself.targetPoint <- self.location;
			}
		}
	}
	
	
	reflex agentclose when: occupied =false and good = true and occupiedAll = false{
		ask Guest at_distance 5 {
			if self.good = false and self.spotedAsBad = false{
				myself.nameBadGuy <- self.name;
				myself.occupied <- true;
				myself.occupiedAll <- true;
				self.spotedAsBad<- true;
				write "found bad guy: " + myself.nameBadGuy;
			}
		}
	}
	
	reflex goToGuard when: occupied = true and occupiedAll = true{
		ask InfoCenter {
			myself.targetPoint <- self.location;
			myself.myColor <- #green;
			myself.occupied <- false;
			myself.reporting <- true;
		}
	}
	
	reflex sideGuest when: myColor = #grey {
		good <- flip(0.001) ? false : true;
		if good = false{
			myColor <- #black;
		}
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		
		if found = true and occupiedAll= true{
			//write "found by person and just leave--------------";
			myColor <- #grey;
			//targetPoint <- {rnd(100),rnd(100)};
			found <- false;
			occupiedAll <- false;
		}
		
		if notify = true and myColor = #darkgreen and occupiedAll = true{
			ask Guest {
				if myself.nameBadGuy = self.name{
					//write "found sec location bad guy and going: "+ myself.nameBadGuy;
					myself.targetPoint <- self.location;
					myself.tellS <- true;
				}
			}
			if tellS = true{
				//write "notified secu secu on the way--------------";
				tellS <-false;
				notify <- false;
				found <- true;
				ask Security{
					self.targetPoint<- myself.targetPoint;
					self.nameBadGuy<- myself.nameBadGuy;
				}
			}
		}
		if reporting = true and myColor = #green and occupiedAll = true{
			//write "going to security guy--------------";
			ask InfoCenter {
				if self.securitBussy = true{
					//write "----------";
				}
				else{
					myself.targetPoint <- self.securityLoc;
					myself.notify <- true; 
					myself.myColor <- #darkgreen;
					myself.reporting <- false;
					self.securitBussy <- true;
				}
			}	
		}
	
		
		if myColor != #gray{
			if thirsty = true and myColor = #blue{
				myColor <- #gray;
				thirsty <- false;
				targetPoint <- {rnd(100),rnd(100)};
			}
			if hungry = true and myColor = #red{
				myColor <- #gray;
				hungry <- false;
				targetPoint <- {rnd(100),rnd(100)};
			}
			if thirsty = true and myColor = #yellow{
				ask InfoCenter {
					myself.targetPoint <- self.storesDrink[rnd(numStores-1)];
					myself.myColor <- #blue;
				}
			}
			if hungry = true and myColor = #yellow{
				ask InfoCenter {
					myself.targetPoint <- self.storesFood[rnd(numStores-1)];
					myself.myColor <- #red;
				}
			}
		}
		else{
			targetPoint <- nil;
		}
		
	}
	
	aspect default{
		draw sphere(1) at: location+{0,0,1} color: myColor;
		draw pyramid(2) at: location color: myColor;
	}
}

species Security skills:[moving]{
	
	point targetPoint <- nil;
	string nameBadGuy;
	bool doingSomething<- false ;
	
	reflex beIdle when: targetPoint = nil{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex foundBadGuy when: targetPoint != nil and location distance_to(targetPoint) < 2{
		if doingSomething = true {
			ask Guest {
				if myself.nameBadGuy = self.name and myself.doingSomething = true{
					write "killed by the guard-------: "+ self.name;
					self.havetoDie <- true;
					myself.doingSomething <- false;
					ask InfoCenter{
						self.securitBussy <- false;
					}
				}
			}
		}
	}
	
	aspect default{
		draw sphere(2) at: location+{0,0,2} color: #black;
		draw pyramid(4) at: location color: #black;
	}
}


species Store{
	string trait;
	
	aspect default{
		if (self.trait = "Drink"){
			draw cube(5) at: location color: #blue;
		}
		if (self.trait = "Food"){
			draw cube(5) at: location color: #red;
		}
	}
}


experiment main type: gui {
	output{
		display map type: opengl{
			species InfoCenter;
			species Guest;
			species Store;
			species Security;
		}
	}
}
