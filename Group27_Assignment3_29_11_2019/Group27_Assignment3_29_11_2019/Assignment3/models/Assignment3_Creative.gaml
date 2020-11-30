/***
* Name: Assignment3_Creative
* Author: valeriaBladinieres and raulAznar
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Assignment3_Creative

/* Insert your model definition here */

global {
	int numGuests<-20;
	int numStages<-4;
	list locationStages<-[{25.0,25.0,0.0},{75.0,75.0,0.0},{25.0,75.0,0.0},{75.0,25.0,0.0}];
	list Musicgenres<-['Pop','Rock','Electro','HipHop'];
	int inde<-0;
	list Guestlist;
	
	init {
		create Stages number: numStages{
			location<-locationStages[inde];
			inde<-inde+1;
		}
		
		create Guest number: numGuests{
			add self to: Guestlist;
		}
		create Meteorite;
		
	}
}


species Stages skills: [fipa] { 
	rgb myColor <- #blue;
	float Lights<- rnd(0.0,1.0);
	float Visualeffects<- rnd(0.0,1.0);
	float Sound <- rnd(0.0,1.0);
	float BandPopularity<- rnd(0.0,1.0);
	float Dancechance<-rnd(0.0,1.0);
	float timeduration<-rnd(300.0,500.0);
	float Duration<-rnd(0.0,1.0);
	float importancegenre<-rnd(0.0,1.0);
	string Genre<-'Pop';
	bool over<-true;
	float starttime;
	image_file cave <- image_file("../includes/cave.png");
	image_file plant <- image_file("../includes/plant.png");
	image_file pond <- image_file("../includes/pond.png");
	image_file volcano <- image_file("../includes/volcano.png");
	image_file rock <- image_file("../includes/rock.png");
	image_file car <- image_file("../includes/car.png");
	image_file hotel <- image_file("../includes/hotel.png");
	image_file office <- image_file("../includes/office.png");
	image_file agentsImage;

	
	reflex happens when: (over=true){
		Lights<- rnd(0.0,1.0);
		Visualeffects<- rnd(0.0,1.0);
		Sound <- rnd(0.0,1.0);
		BandPopularity<- rnd(0.0,1.0);
		Dancechance<-rnd(0.0,1.0);
		timeduration<-rnd(200.0,400.0);
		Duration<-timeduration/1000;
		Genre <- Musicgenres[rnd(0,3)];
		over<-false;
		starttime<-time+rnd(10,50);	
	}
	
	reflex startconcert when: (over=false and time=starttime){
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,Lights,Visualeffects,Sound,BandPopularity,Dancechance,Duration,Genre,'Starting Concert', false,2]];
	}
	
	reflex finishconcert when: (time>starttime+timeduration) and over=false{
		over<-true;
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,0,0,0,0,0,0,Genre,'Concert finished', false, 2]];
		
	}
	
	aspect default{
		if Genre='HipHop'{
			if time < 1500{
				agentsImage<- cave;
			}
			else{
				agentsImage<- rock;///////put the robots age
			}
			draw agentsImage size: 15;
		}
		if Genre='Pop'{
			if time < 1500{
				agentsImage<- plant;
			}
			else{
				agentsImage<- hotel;///////put the robots age
			}
			draw agentsImage size: 15;
		}
	
		if Genre='Rock'{
			if time < 1500{
				agentsImage<- pond;
			}
			else{
				agentsImage<- car;///////put the robots age
			}
			draw agentsImage size: 15;
		}
	
		if Genre='Electro'{
			if time < 1500{
				agentsImage<- volcano;
			}
			else{
				agentsImage<- office;///////put the robots age
			}
			draw agentsImage size: 15;
		}
	}
}

species Guest skills: [fipa, moving] {
	rgb myColor <- #gray;
	point targetPoint <- nil;
	float Lights<- rnd(0.0,1.0);
	float Visualeffects<- rnd(0.0,1.0);
	float Sound <- rnd(0.0,1.0);
	float BandPopularity<- rnd(0.0,1.0);
	float Dancechance<-rnd(0.0,1.0);
	float Duration<-rnd(0.0,1.0);
	list Musictaste<-[rnd(0.0,1.0),rnd(0.0,1.0),rnd(0.0,1.0),rnd(0.0,1.0),rnd(0.0,1.0)];
	float importancegenre<-rnd(0.5,1.5);
	float utility<-0.0;
	float utility2<-0.0;
	agent concert;
	
	///
	bool loving<-false;
	bool declaring<-false;
	agent beloved;
	bool inlove1<-false;
	bool inlove2 <- false;
	int comp;
	image_file dino <- image_file("../includes/dino.png");
	image_file dinoLove <- image_file("../includes/dinoLove.png");
	image_file robot <- image_file("../includes/robot.png");
	image_file robotLove <- image_file("../includes/robotLove.png");
	image_file agentsImage <- dino;
	
	
	reflex begin_love when: time mod 30=0 and loving=false and inlove1=false and inlove2 = false{
		int aux<-rnd(2000);
		if time >1500{
			dino <- robot;
			dinoLove <- robotLove;
		}
		if aux < numGuests{
			beloved<-Guestlist[aux];
			if beloved=self{
				beloved<-Guestlist[aux+1];
			}
			agentsImage <- dinoLove;
			targetPoint<-beloved.location;
			write name + ': I am in love with '+ beloved.name;
			declaring<-true;
			loving<-true;
			agentsImage<-dinoLove;
		}
	}
	
	reflex utility when: !empty(informs){
		//calcular utility y comparar con la anterior, si es mas grande ir a la location del inform.
		loop m over: informs {
			if int(m.contents[11]) = 1{
				write '\t'+ string(m.sender) + " has said YES to me "+ name;
				inlove2 <-true;
				beloved <- m.sender;
			}
			if int(m.contents[11]) = 0{
				write '\t'+ string(m.sender) + " has said NO to me "+ name;
				agentsImage<-dino;
				beloved<-nil;
			}
			if (inlove1 =true or inlove2 =true) and bool(m.contents[10]) = true{
				write name+ ": I already have a partner, sorry "+ m.sender;
				loving <-false;
				agentsImage<-dino;
				do start_conversation with: [ to :: list(m.sender), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,Lights,Visualeffects,Sound,BandPopularity,Dancechance,Duration,"Pop","",false, 0]];		
			}
			else{
				if m.contents[10] = true and (inlove1 =false or inlove2 =false){
					loving <- true;
					write name + ": being notified i have been liked from " +string(m.sender);
					write"------------";
						write "Likes of guest in love with me, "+ m.sender+ ":";
						write "Lights: " +(m.contents[2]);
						write "Visualeffects: "+ float(m.contents[3]);
						write "Sound: " +float(m.contents[4]);
						write "BandPopularity: " +float(m.contents[5]);
						write "Dancechance: " +float(m.contents[6]);
						write "Duration: " +float(m.contents[7]);
						
						write "My ikes :";
						write "Lights: " + Lights;
						write "Visualeffects: "+ Visualeffects;
						write "Sound: " + Sound;
						write "BandPopularity: " + BandPopularity;
						write "Dancechance: " + Dancechance;
						write "Duration: " + Duration;
						
						if (Lights +0.3) > float(m.contents[2]) and float(m.contents[2]) >= Lights-0.3{
							comp <- comp +1;
						}
						if (Visualeffects +0.3) > float(m.contents[3]) and float(m.contents[3]) >= Visualeffects-0.3{
							comp <- comp +1;
						}
						if (Sound +0.3) > float(m.contents[4]) and float(m.contents[4]) >= Sound-0.3{
							comp <- comp +1;
						}
						if (BandPopularity +0.3) > float(m.contents[5]) and float(m.contents[5]) >= BandPopularity-0.3{
							comp <- comp +1;
						}
						if (Dancechance +0.3) > float(m.contents[6]) and float(m.contents[6]) >= Dancechance-0.3{
							comp <- comp +1;
						}
						if (Duration +0.3) > float(m.contents[7]) and float(m.contents[7]) >= Duration-0.3{
							comp <- comp +1;
						}
						write "Their compabality is: "+ comp;
						if comp >3{
							write "they are a couple: " +name + " and "+ m.sender;
							inlove1 <- true;
							loving <- false;
							do start_conversation with: [ to :: list(m.sender), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,Lights,Visualeffects,Sound,BandPopularity,Dancechance,Duration,"Pop","",false, 1]];
							agentsImage<-dinoLove;
						}
						else{
							loving <- false;
							do start_conversation with: [ to :: list(m.sender), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,Lights,Visualeffects,Sound,BandPopularity,Dancechance,Duration,"Pop","",false, 0]];	
						}
					write"------------";
				}
			}
			
			
			if concert=m.contents[0]{
				if m.contents[9]='Concert finished'{
					utility<-0.0;
				}
				
			}
			else{
				utility2<-Lights*float(m.contents[2])+Visualeffects*float(m.contents[3])+Sound*float(m.contents[4])+BandPopularity*float(m.contents[5])+Dancechance*float(m.contents[6])+Duration*float(m.contents[7]);
				string mgenre<-string(m.contents[8]);
				int result <- Musicgenres index_of mgenre;
				utility2<-utility2*(importancegenre*float(Musictaste[result]));
				if utility2>utility{
					utility<-utility2;
					targetPoint<-m.contents[1];
					concert<-m.contents[0];
				}
			}
			
		}	
	}
	
	reflex beIdle when: targetPoint = nil{
		do wander(0.5,360.0,square(5));
		if time = 1500{
			agentsImage <- robot;
			//
			dino <- robot;
			dinoLove <- robotLove;
			comp <-0;
		}
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
		speed<-1.0;
		if time = 1500{
			agentsImage <- robot;
			inlove2 <- false;
			beloved <- nil;
			comp <-0;
		}
	}
	
	reflex following when: inlove2 = true{
		do goto target:beloved.location - {-2,-2,0};
		if time =1590{
			inlove2 <- false;
			beloved <- nil;
			agentsImage <- robot;
			comp <-0;
		}
	}
	reflex imgaChange when: inlove1 = true{
		if time =1590{
			inlove1 <- false;
			agentsImage <- robot;
			comp <-0;
		}
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		if declaring=false{
			targetPoint<-nil;
		}	
		if declaring=true{
			write name+ ": telling "+ beloved.name + " I am in love" ;
			declaring <- false;
			do start_conversation with: [ to :: list(beloved), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,Lights,Visualeffects,Sound,BandPopularity,Dancechance,Duration,"Pop","",true, 2]];
		}
	}
	
	aspect default{
		draw agentsImage size: 7;
	}
	
}

species Meteorite{
	int val<-100;
	
	reflex drop when: time > 1400 and time < 1600{
	 	val <- val-2;
	}
	
	reflex dissapear when: time > 1600{
		do die;
	}
	
	aspect default{
		draw sphere(50) at:{50,50,val} color: #red;
		if time >1480 and time < 1600{
			draw square(100) at:{50,50,2} color: #green;
		}
	}
	
	
}

experiment main type: gui {
	output{
		display map type: opengl{
			species Stages;
			species Guest;
			species Meteorite;
		}
	}
	
}
