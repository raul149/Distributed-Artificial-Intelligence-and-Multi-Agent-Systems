/***
* Name: Project1
* Author: valeriabladinieres
* Description: Festival
* Tags: Tag1, Tag2, TagN
***/

model project

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
			location <- {rnd(100), rnd(100)};
			trait <- "Food";
		}
		create Store number: numStores{
			location <- {rnd(100), rnd(100)};
			trait <- "Drink";
		}
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
	
	reflex beIdle when: targetPoint = nil{
		do wander;
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
	}
	
	reflex state when: thirsty = false and hungry = false{
		int rand <- rnd(1000);
		if (rand = 1){
			thirsty <- true;
			myColor <- #yellow;	
			write name + " going to Info Center and I am thirsty";
			ask InfoCenter {
				myself.targetPoint <- self.location;
				
			}
		}
		if (rand = 2){
			hungry <- true;
			myColor <- #yellow;	
			write name + " going to Info Center and I am hungry";
			ask InfoCenter {
				myself.targetPoint <- self.location;
				
			}
		}	
	}

	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		
		if myColor != #gray{
			if thirsty = true and myColor = #blue{
				write name + " found drinking store";
					myColor <- #gray;
					thirsty <- false;
					targetPoint <- {rnd(100),rnd(100)};
			}
			if hungry = true and myColor = #red{
				write name + " found food store";
					myColor <- #gray;
					hungry <- false;
					targetPoint <- {rnd(100),rnd(100)};
			}
				
			if thirsty = true and myColor = #yellow{
				write name + " on the way to drinking store";
				ask InfoCenter {
					myself.targetPoint <- self.storesDrink[rnd(numStores-1)];
					myself.myColor <- #blue;
				}
			}
			if hungry = true and myColor = #yellow{
				write name + " on the way to food store";
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

