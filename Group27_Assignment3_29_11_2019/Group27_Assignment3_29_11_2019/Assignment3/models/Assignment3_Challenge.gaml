/***
* Name: Assignment3_Challenge
* Author: valeriaBladinieres and raulAznar
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Assignment3_Challenge

/* Insert your model definition here */

global {
	int numGuests<-20;
	int numStages<-4;
	list locationStages<-[{25.0,25.0,0.0},{75.0,75.0,0.0},{25.0,75.0,0.0},{75.0,25.0,0.0}];
	list Musicgenres<-['Pop','Rock','Electro','HipHop','Latin'];
	int inde<-0;
	list Stageslist<-[];
	list Guestlist<-[];
	list utilitytot<-[];
	list StageGuest<-[];
	list StageSizeG<-[];
	list Desiredcrowdsize<-[];
	list utilitytotcrowd<-[];
	list utilitytotcrowd0<-[];
	list utilitytotcrowd1<-[];
	list utilitytotcrowd2<-[];
	list utilitytotcrowd3<-[];
	int Stage0size<-0;
	int Stage1size<-0;
	int Stage2size<-0;
	int Stage3size<-0;
	list decided<-[];
	
	init {
		create Stages number: numStages{
			location<-locationStages[inde];
			inde<-inde+1;
			add self to: Stageslist;
		}
		
		create Guest number: numGuests{
		add self to: Guestlist;
		add 0.0 to: utilitytot;
		add nil to: StageGuest;
		int CrowdsizeD<-rnd(1,numGuests-10);
		add CrowdsizeD to: Desiredcrowdsize;
		add 0.0 to: utilitytotcrowd;
		add 0.0 to: utilitytotcrowd0;
		add 0.0 to: utilitytotcrowd1;
		add 0.0 to: utilitytotcrowd2;
		add 0.0 to: utilitytotcrowd3;
		add 0 to: StageSizeG;
		
		}
		create Leader number:1;
	}
	
}


species Stages skills: [fipa] { 
	rgb myColor <- #blue;
	float Lights<- rnd(0.0,1.0);
	float Visualeffects<- rnd(0.0,1.0);
	float Sound <- rnd(0.0,1.0);
	float BandPopularity<- rnd(0.0,1.0);
	float Dancechance<-rnd(0.0,1.0);
	float timeduration<-rnd(200.0,1000.0);
	float Duration<-rnd(0.0,1.0);
	float importancegenre<-rnd(0.0,1.0);
	string Genre<-'Pop';
	bool over<-true;
	float starttime;
	
	reflex happens when: (over=true){
			
	Lights<- rnd(0.0,1.0);
	Visualeffects<- rnd(0.0,1.0);
	Sound <- rnd(0.0,1.0);
	BandPopularity<- rnd(0.0,1.0);
	Dancechance<-rnd(0.0,1.0);
	timeduration<-rnd(150.0,500.0);
	Duration<-timeduration/2000;
	Genre <- Musicgenres[rnd(0,4)];
	over<-false;
	starttime<-time+rnd(5,50);	
	}
	
	reflex startconcert when: (over=false and time=starttime){
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,Lights,Visualeffects,Sound,BandPopularity,Dancechance,Duration,Genre,'Starting Concert']];
	}
	
	reflex finishconcert when: (time>starttime+timeduration) and over=false{
		over<-true;
		do start_conversation with: [ to :: list(Guest), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,0,0,0,0,0,0,Genre,'Concert finished']];
		
	}
	
	aspect default{
		if Genre='HipHop'{
			draw square(13) at: location color: #black;	
		}
		if Genre='Pop'{
			draw square(13) at: location color: #salmon;	
		}
		
		if Genre='Rock'{
			draw square(13) at: location color: #green;	
		}
		
		if Genre='Latin'{
			draw square(13) at: location color: #red;	
		}
		
	if Genre='Electro'{
			draw square(13) at: location color: #yellow;	
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
	float utilitycrowd<-0.0;
	list utilitylist<- [0.0,0.0,0.0,0.0];
	agent concert;
	int yaaa<-0;
	int CrowdSizeD;
	
	
	reflex utility when: !empty(informs){
		//calcular utility y comparar con la anterior, si es mas ggrande ir a la location del inform.
		loop m over: informs {
				if m.contents[9]='Concert finished'{
					agent compare<-m.contents[0];
					int aux <- Stageslist index_of compare;
					if concert=m.contents[0]{
						utility<-0.0;
						//write'I gotta leave!!!';
					}
					utilitylist[aux]<-0.0;	
					if concert=m.contents[0]{
						if concert=Stageslist[0]{
							Stage0size<-Stage0size-1;
						}
						if concert=Stageslist[1]{
							Stage1size<-Stage1size-1;
						}
						if concert=Stageslist[2]{
							Stage2size<-Stage2size-1;
						}
						if concert=Stageslist[3]{
							Stage3size<-Stage3size-1;
						}
						int aux10 <- utilitylist index_of max(utilitylist);
						utility<-utilitylist[aux10];
						targetPoint<-locationStages[aux10];
						concert<-Stageslist[aux10];	
						if concert=Stageslist[0]{
							Stage0size<-Stage0size+1;
						}
						if concert=Stageslist[1]{
							Stage1size<-Stage1size+1;
						}
						if concert=Stageslist[2]{
							Stage2size<-Stage2size+1;
						}
						if concert=Stageslist[3]{
							Stage3size<-Stage3size+1;
						}	
				}		
			}
			if m.contents[9]='Starting Concert' and time<100{
				utility2<-Lights*float(m.contents[2])+Visualeffects*float(m.contents[3])+Sound*float(m.contents[4])+BandPopularity*float(m.contents[5])+Dancechance*float(m.contents[6])+Duration*float(m.contents[7]);
				string mgenre<-string(m.contents[8]);
				int result <- Musicgenres index_of mgenre;
				utility2<-utility2*(importancegenre*float(Musictaste[result]));
				agent compare<-m.contents[0];
				int aux <- Stageslist index_of compare;
				utilitylist[aux]<-utility2;
				//write utilitylist;
				if utility2>utility{
					int aux2 <- utilitylist index_of max(utilitylist);
					utility<-utilitylist[aux2];
					//Goes to this concert
					targetPoint<-locationStages[aux2];
					concert<-Stageslist[aux2];		
					//write concert;
					if yaaa>3{
						//write name + 'going to' + concert;
						//write utilitylist;
						do start_conversation with: [ to :: list(Leader), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, targetPoint,concert,utility,utilitylist[0],utilitylist[1],utilitylist[2],utilitylist[3],0,'Going to concert']];
					}
				}
				yaaa<-yaaa+1;	
				if yaaa>3{
					if length(decided)<numGuests{
						add self to: decided;
						if concert=Stageslist[0]{
							Stage0size<-Stage0size+1;
							int aux8<-Guestlist index_of self;
							StageGuest[aux8]<-concert; 
						}
						if concert=Stageslist[1]{
							Stage1size<-Stage1size+1;
							int aux8<-Guestlist index_of self;
							StageGuest[aux8]<-concert; 
						}
						if concert=Stageslist[2]{
							Stage2size<-Stage2size+1;
							int aux8<-Guestlist index_of self;
							StageGuest[aux8]<-concert; 
						}
						if concert=Stageslist[3]{
							Stage3size<-Stage3size+1;
							int aux8<-Guestlist index_of self;
							StageGuest[aux8]<-concert; 
						}
			
					}		
				}
				if (length(decided)=numGuests and yaaa=4){
					//write utilitylist;
					if concert=Stageslist[0]{
						Stage0size<-Stage0size-1;
					}
					if concert=Stageslist[1]{
						Stage1size<-Stage1size-1;
					}
					if concert=Stageslist[2]{
						Stage2size<-Stage2size-1;
					}
					if concert=Stageslist[3]{
						Stage3size<-Stage3size-1;
					}
					do start_conversation with: [ to :: list(Leader), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, targetPoint,concert,utility,utilitylist[0],utilitylist[1],utilitylist[2],utilitylist[3],0,'Going to concert']];
				}
			}
					
			if m.contents[9]='Starting Concert' and time>100{
				utility2<-Lights*float(m.contents[2])+Visualeffects*float(m.contents[3])+Sound*float(m.contents[4])+BandPopularity*float(m.contents[5])+Dancechance*float(m.contents[6])+Duration*float(m.contents[7]);
				string mgenre<-string(m.contents[8]);
				int result <- Musicgenres index_of mgenre;
				utility2<-utility2*(importancegenre*float(Musictaste[result]));
				agent compare<-m.contents[0];
				int aux <- Stageslist index_of compare;
				utilitylist[aux]<-utility2;
				//write utilitylist;
				if utility2>utility{
					if concert=Stageslist[0]{
						Stage0size<-Stage0size-1;
					}
					if concert=Stageslist[1]{
						Stage1size<-Stage1size-1;
	
					}
					if concert=Stageslist[2]{
						Stage2size<-Stage2size-1;
					}
					if concert=Stageslist[3]{
						Stage3size<-Stage3size-1;
					}
					int aux12 <- utilitylist index_of max(utilitylist);
					utility<-utilitylist[aux12];
					//Goes to this concert
					targetPoint<-locationStages[aux12];
					concert<-Stageslist[aux12];	
					do start_conversation with: [ to :: list(Leader), protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, targetPoint,concert,utility,utilitylist[0],utilitylist[1],utilitylist[2],utilitylist[3],0,'Going to concert']];
				}
			}		
			if m.contents[9]='Change Concert'{
				concert<-m.contents[2];
				targetPoint<-m.contents[3];
				utility<-float(m.contents[4]);
				utilitycrowd<-float(m.contents[5]);
			}
		}
	}
		
	reflex beIdle when: targetPoint = nil{
		do wander(0.5,360.0,square(5));
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
		speed<-1.0;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		targetPoint<-nil;
	}
	
	aspect default{
		draw sphere(1) at: location + {0.0,0.0,1.0} color: myColor;
		draw pyramid(2) at: location color: myColor;
	}
	
}

species Leader skills: [fipa, moving] {
	rgb myColor <- #gray;
	point targetPoint <- nil;
	list sumcrowd<-[0.0,0.0,0.0,0.0];
	point newTarget<-nil;
	agent auxconcert;
	agent stageantiguo;
	float sumucrowd0<- 0.0;
	float sumucrowd1<- 0.0;
	float sumucrowd2<- 0.0;
	float sumucrowd3<- 0.0;
	
	reflex when: time mod 100 = 0{
		write Stage0size;
		write Stage1size;
		write Stage2size;
		write Stage3size;
	}

	reflex calculate_utility_acnd_compare when: !empty(informs){
		//calcular utility y comparar con la anterior, si es mas ggrande ir a la location del inform.
		loop m over: informs {
			//write'Here!!';
			agent nameG <- m.contents[0];
			int  aux3 <- Guestlist index_of nameG;
			utilitytot[aux3]<-m.contents[3];
			stageantiguo<-StageGuest[aux3];
			StageGuest[aux3]<-m.contents[2];
			
			write'-----UTILITY WITHOUT CROWD------';
			write m.contents[4];
			write m.contents[5];
			write m.contents[6];
			write m.contents[7];
			write'--------------------------------';
			write Stage0size;
			write Stage1size;
			write Stage2size;
			write Stage3size;
			write'That was the Size of the Stage';	
			
			loop u from: 0 to: length(StageGuest) -1{
				if StageGuest[u]=Stageslist[0]{
					StageSizeG[u]<-Stage0size;
				}
				if StageGuest[u]=Stageslist[1]{		
					StageSizeG[u]<-Stage1size;
				}
				if StageGuest[u]=Stageslist[2]{		
					StageSizeG[u]<-Stage2size;
				}
				if StageGuest[u]=Stageslist[3]{			
					StageSizeG[u]<-Stage3size;
				}
			}
			float auxutilitytotcrowd0<-0.0;
			auxutilitytotcrowd0<-float(m.contents[4])*5/(0.1+sqrt((int(Stage0size)+1-int(Desiredcrowdsize[aux3]))*(int(Stage0size)+1-int(Desiredcrowdsize[aux3]))));
			//write'AQUIIII';
			write auxutilitytotcrowd0;
			float auxutilitytotcrowd1<-float(m.contents[5])*5/(0.1+sqrt((int(Stage1size)+1-int(Desiredcrowdsize[aux3]))*(int(Stage1size)+1-int(Desiredcrowdsize[aux3]))));
			write auxutilitytotcrowd1;
			float auxutilitytotcrowd2<-float(m.contents[6])*5/(0.1+sqrt((int(Stage2size)+1-int(Desiredcrowdsize[aux3]))*(int(Stage2size)+1-int(Desiredcrowdsize[aux3]))));
			write auxutilitytotcrowd2;
			float auxutilitytotcrowd3<-float(m.contents[7])*5/(0.1+sqrt((int(Stage3size)+1-int(Desiredcrowdsize[aux3]))*(int(Stage3size)+1-int(Desiredcrowdsize[aux3]))));
			write auxutilitytotcrowd3;
			write 'END UTILITY CROWD PERSONAL';
			write Desiredcrowdsize[aux3];
			write Desiredcrowdsize;
			write 'THIS WAS THE DESIRED CROWD SIZE';
			
			utilitytotcrowd[aux3]<-utilitytotcrowd0[aux3];
			utilitytot[aux3]<-m.contents[4];
			if float(utilitytotcrowd1[aux3])>float(utilitytotcrowd[aux3]){
				utilitytotcrowd[aux3]<-utilitytotcrowd1[aux3];
				utilitytot[aux3]<-m.contents[5];
			}
			if float(utilitytotcrowd2[aux3])>float(utilitytotcrowd[aux3]){
				utilitytotcrowd[aux3]<-utilitytotcrowd2[aux3];
				utilitytot[aux3]<-m.contents[6];
			}
			if float(utilitytotcrowd3[aux3])>float(utilitytotcrowd[aux3]){
				utilitytotcrowd[aux3]<-utilitytotcrowd3[aux3];
				utilitytot[aux3]<-m.contents[7];
			}
			
			//Selected the best utility counting the people in the stages!
			sumcrowd<-[0.0,0.0,0.0,0.0];
			sumucrowd0<-0.0;
			sumucrowd1<-0.0;
			sumucrowd2<-0.0;
			sumucrowd3<-0.0;
			
			loop aux4 from: 0 to: length(utilitytotcrowd0) -1{
				//int aux4<-utilitytotcrowd0 index_of w
				if StageGuest[aux4]=Stageslist[0]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])+1;
				}
				utilitytotcrowd0[aux4]<-float(utilitytot[aux4])*5/(0.1+sqrt((int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))*(int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))));
				if StageGuest[aux4]=Stageslist[0]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])-1;
				}
				
				if StageGuest[aux4]=Stageslist[1]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])+1;
				}
				utilitytotcrowd1[aux4]<-float(utilitytot[aux4])*5/(0.1+sqrt((int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))*(int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))));
				if StageGuest[aux4]=Stageslist[1]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])-1;
				}

				if StageGuest[aux4]=Stageslist[2]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])+1;
				}
				utilitytotcrowd2[aux4]<-float(utilitytot[aux4])*5/(0.1+sqrt((int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))*(int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))));
					if StageGuest[aux4]=Stageslist[2]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])-1;
				}
				if StageGuest[aux4]=Stageslist[3]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])+1;
				}
				utilitytotcrowd3[aux4]<-float(utilitytot[aux4])*5/(0.1+sqrt((int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))*(int(StageSizeG[aux4])-int(Desiredcrowdsize[aux4]))));
				if StageGuest[aux4]=Stageslist[3]{
					StageSizeG[aux4]<-int(StageSizeG[aux4])-1;
				}
				//write 'sumucrowd';
				sumucrowd0<-float(utilitytotcrowd0[aux4])+sumucrowd0;
				//write sumucrowd0;
				sumucrowd1<-float(utilitytotcrowd1[aux4])+sumucrowd1; 
				//write sumucrowd1;
				sumucrowd2<-float(utilitytotcrowd2[aux4])+sumucrowd2;
				//write sumucrowd2;
				sumucrowd3<-float(utilitytotcrowd3[aux4])+sumucrowd3;
				//write sumucrowd3;
				                                                                                  
			}
			
			sumucrowd0<-sumucrowd0-float(utilitytot[aux3])*5/(0.1+sqrt((int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))*(int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))));
			sumucrowd0<-sumucrowd0+auxutilitytotcrowd0;
			
			sumucrowd1<-sumucrowd1-float(utilitytot[aux3])*5/(0.1+sqrt((int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))*(int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))));
			sumucrowd1<-sumucrowd1+auxutilitytotcrowd1;
			
			sumucrowd2<-sumucrowd2-float(utilitytot[aux3])*5/(0.1+sqrt((int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))*(int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))));
			sumucrowd2<-sumucrowd2+auxutilitytotcrowd2;
			
			sumucrowd3<-sumucrowd3-float(utilitytot[aux3])*5/(0.1+sqrt((int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))*(int(StageSizeG[aux3])-int(Desiredcrowdsize[aux3]))));
			sumucrowd3<-sumucrowd3+auxutilitytotcrowd3;
			
			
			sumcrowd<-[sumucrowd0,sumucrowd1,sumucrowd2,sumucrowd3];
			write sumcrowd;
			float valor2<-0.0;
			int aux6 <- 0;
			
			loop q over: sumcrowd{
				if q>valor2{
					valor2<-q;
					aux6 <- sumcrowd index_of q;
				}
			}
			//write aux6;
			
			if aux6=0{
				utilitytot[aux3]<-m.contents[4];
				utilitytotcrowd<-utilitytotcrowd0;
				Stage0size<-Stage0size+1;
				auxconcert<-Stageslist[0];
				newTarget<-locationStages[0];
				write m.contents[0];
				write'Going to Stage 0';
				do start_conversation with: [ to :: m.contents[0], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,auxconcert,newTarget,utilitytot[aux3],utilitytotcrowd[aux3],0,0,0,'Change Concert']];			
			}
			if aux6=1{
				utilitytot[aux3]<-m.contents[5];
				utilitytotcrowd<-utilitytotcrowd1;
				Stage1size<-Stage1size+1;
				auxconcert<-Stageslist[1];
				newTarget<-locationStages[1];
				write m.contents[0];
				write'Going to Stage 1';
				do start_conversation with: [ to :: m.contents[0], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,auxconcert,newTarget,utilitytot[aux3],utilitytotcrowd[aux3],0,0,0,'Change Concert']];			
			}
			if aux6=2{
				utilitytot[aux3]<-m.contents[6];
				utilitytotcrowd<-utilitytotcrowd2;
				Stage2size<-Stage2size+1;
				auxconcert<-Stageslist[2];
				newTarget<-locationStages[2];
				write m.contents[0];
				write'Going to Stage 2';
				do start_conversation with: [ to :: m.contents[0], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,auxconcert,newTarget,utilitytot[aux3],utilitytotcrowd[aux3],0,0,0,'Change Concert']];			
			}
			if aux6=3{
				utilitytot[aux3]<-m.contents[7];
				utilitytotcrowd<-utilitytotcrowd3;
				Stage3size<-Stage3size+1;
				auxconcert<-Stageslist[3];
				newTarget<-locationStages[3];
				write m.contents[0];
				write'Going to Stage 3';
				do start_conversation with: [ to :: m.contents[0], protocol :: 'fipa-contract-net', performative :: 'inform', contents :: [self, location,auxconcert,newTarget,utilitytot[aux3],utilitytotcrowd[aux3],0,0,0,'Change Concert']];			
			}
			
			
		}
	}
		
	reflex beIdle when: targetPoint = nil{
		do wander(0.5,360.0,square(5));
	}
	
	reflex moveToTarget when: targetPoint != nil{
		do goto target:targetPoint;
		speed<-1.0;
	}
	
	reflex enterStore when: targetPoint != nil and location distance_to(targetPoint) < 2 {
		targetPoint<-nil;
		
	}
	
	aspect default{
		draw sphere(1) at: location + {0.0,0.0,1.0} color: #gold;
		draw pyramid(2) at: location color: #gold;
	}
	
}

experiment main type: gui {
	output{
		display map type: opengl{
			species Stages;
			species Guest;
		}
	}
	
}