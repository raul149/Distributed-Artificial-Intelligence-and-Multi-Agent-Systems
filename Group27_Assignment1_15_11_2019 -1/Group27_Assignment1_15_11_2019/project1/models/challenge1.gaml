/***
* Name: Project1
* Author: valeriabladinieres
* Description: Festival
* Tags: Tag1, Tag2, TagN
***/

model challenge1

/* Insert your model definition here */



global {
	float dw;
	float dwo;
	int numStores<-2;
	init {
		create InfoCenter number: 1{
			location <- {50, 50};
		}
		create Guest number: 20{
			
		}
		create Store number: numStores{
			location <- {rnd(100), rnd(100)};
			trait <- "Food";
		}
		create Store number: numStores{
			location <- {rnd(100), rnd(100)};
			trait <- "Drink";
		}

	}
	reflex globalPrint{
		//write "Step of simulation" + time;
		//write "Step of simulation" + dwo;
		//write "Step of simulation" + dw;
	}

}

species InfoCenter{
	
	list storesDrink;
	point locStoreD;
	list storesFood;
	point locStoreF;
	
	reflex when: length(storesDrink) < numStores  or length(storesFood) < numStores{
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
	
	
	aspect default{
		draw pyramid(5) at: location color: #yellow;
		}
}

species Guest skills:[moving]{
	
	point targetPoint <- nil;
	bool hungry <- false;
	bool thirsty <- false;
	rgb myColor <- #gray;
	list storesDrink;
	point locStoreD;
	list storesFood;
	point locStoreF;
	float dist <-0.0;
	
	reflex beIdle when: targetPoint = nil{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		dist <- location distance_to(targetPoint);
		dwo <- dwo +dist;
		dw <- dw + dist;
		do goto target:targetPoint;
	}
	
	reflex state when: thirsty = false and hungry = false{
		int rand <- rnd(1000);
		if (rand = 1){
			thirsty <- true;
			myColor <- #yellow;
			
			if length(storesDrink) > 0{
				int rand2 <- rnd(numStores-1);
				if rand2 > numStores{
					ask InfoCenter {
						myself.targetPoint <- self.location;	
					}
				}
				else{
					targetPoint <- storesDrink[0];
					myColor <- #blue;
				}
			}
			else{	
				ask InfoCenter {
					myself.targetPoint <- self.location;
				}
			}	
		}
		if (rand = 2){
			hungry <- true;
			myColor <- #yellow;
			
			if length(storesFood) > 0{
				int rand3 <- rnd(numStores-1);
				if rand3 > numStores{
					ask InfoCenter {
						myself.targetPoint <- self.location;	
					}
				}
				else{
					targetPoint <- storesFood[0];
					myColor <- #red;
				}
			}
			else{	
				ask InfoCenter {
					myself.targetPoint <- self.location;
				}
			}	
		}	
	}
	
	reflex agentclose when: myColor = #yellow{
		ask Guest at_distance(5) {
			if (myself.hungry = true){
				if self.locStoreF != nil{
					dist <- myself.location distance_to(myself.targetPoint);
					dw <- dw - dist;
					myself.targetPoint <- self.locStoreF;				
					myself.myColor <- #red;	
					write self.locStoreF;	
					write "Thanks for the food-tip";
					write "Distance without help: " + dwo;
					write "Distance with help:    " + dw;
				}
			}
			if (myself.thirsty = true){
				if self.locStoreD != nil{
					dist <- myself.location distance_to(myself.targetPoint);
					dw <- dw - dist;
					myself.targetPoint <- self.locStoreD;
					myself.myColor <- #blue;	
					write "Thanks for the drink-tip";
					write "Distance without help: " + dwo;
					write "Distance with help:    " + dw;
				}
			}
		}	
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		
		if myColor != #gray{
			if thirsty = true and myColor = #blue{
					myColor <- #gray;
					thirsty <- false;
					locStoreD <- targetPoint;
					targetPoint <- {rnd(100),rnd(100)};
			}
			if hungry = true and myColor = #red{
					myColor <- #gray;
					hungry <- false;
					locStoreF <- targetPoint;
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
		draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
		draw pyramid(2) at: location color: myColor;
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
		}
	}


}