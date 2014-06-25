#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int matriz[20][20];
int apx=15,apy=6,ptox=6,ptoy=11;

void llenar() {
	int x,y;

	for(y=0;y<20;y++)
		for(x=0;x<20;x++)
			matriz[x][y]=0;
}

void mostrar() {
	int x,y;
	for(y=0;y<20;y++){
		for(x=0;x<20;x++)
			printf("%d ", matriz[x][y]);
		printf("\n");
	}
}

int linea () {
	int i, ent;	//parte entera de m,
	float m,add=0,frac; //m pendiente, frac parte fraccionaria de m, add suma de las partes fraccionarias
	
	// caso 0 pto se encuentra en el mismo que el AP, exit(0)
	if ( (apx-ptox) == 0 && (apy-ptoy) == 0)	{
		printf("pared en mismo lugar que el AP \n");
		exit(0);
	}
	
	// caso 1-2 pendiente infinita -> x1 == x2
	if ( (apx-ptox) == 0 )
		if ( ptoy > apy ) {
			while ( ptoy>apy ){
				ptoy--;
				matriz[ptox][ptoy]=1;
			}
			return 0;
		}
		else {
			while ( ptoy<apy ){
				ptoy++;
				matriz[ptox][ptoy]=1;
			}
			return 0;
		}
	
	//caso 3-4 pendiente 0 -> y1 == y2
	if ( (apy-ptoy) == 0 )
		if ( ptox > apx ) {
			while ( ptox>apx ){
				ptox--;
				matriz[ptox][ptoy]=0;
			}
			return 0;
		}
		else {
			while ( ptox<apx ){
				ptox++;
				matriz[ptox][ptoy]=1;
			}
			return 0;
		}

	m = (float) (ptoy-apy)/(ptox-apx);
	ent = (int) (ptoy-apy)/(ptox-apx);
	frac = m - ent;
	add = frac;
//	printf("ent= %d add= %f \n",ent,add);

	//caso 5-6 pendiente >= 1+ >= 1-
	if ( m >= 1 ){
		if ( (ptoy>apy) && (ptox>apx) ) {
			while ( ptox>=apx && ptoy>=apy ){
				for (i=0;i<ent;i++){
					if (ptox<=apx && ptoy<=apy)
						return 0;
					ptoy--;
					matriz[ptox][ptoy]=1;
					add=add+frac;
//					printf(" %f \n",add);
					if ( add > ent && ptox>apx && ptoy>apy) {
						ptoy--;
						matriz[ptox][ptoy]=1;
						add = 0;
					//	printf("add del if  %f\n",add);
					}
				}
				ptox--;
			}
			return 0;
		}
		else {
			while ( ptox<=apx && ptoy<=apy ){
				for (i=0;i<ent;i++){
					if (ptox>=apx && ptoy>=apy)
						return 0;
					ptoy++;
					matriz[ptox][ptoy]=1;
					add=add+frac;
					if ( add > ent && ptox<apx && ptoy<apy ) {
						ptoy++;
						matriz[ptox][ptoy]=1;
						add=0;
					}
				}
				ptox++;
			}
			return 0;
		}
	}

	//caso 7-8 pendiente <= -1+ <= -1-
	if ( m <= -1 ){
		if ( (apy<ptoy) && (ptox<apx) ) {
			while ( ptox<=apx && ptoy>=apy ){
				for (i=0;i>ent;i--){
					if (ptox>=apx && ptoy<=apy)
						return 0;
					ptoy--;
					matriz[ptox][ptoy]=1;
					add=add+frac;
					if ( add < ent  && ptox<apx && ptoy>apy ) {
						ptoy--;
						matriz[ptox][ptoy]=1;
						add=0;
					}
				}
				ptox++;
			}
			return 0;
		}
		else {
			while ( ptox>=apx && ptoy<=apy ){
				for (i=0;i>ent;i--){
					if (ptox<=apx && ptoy >=apy)
						return 0;
					ptoy++;
					matriz[ptox][ptoy]=1;
					add=add+frac;
					if ( add < ent && ptox>apx && ptoy<apy ) {
						ptoy++;
						matriz[ptox][ptoy]=1;
						add=0;
					}
				}
				ptox--;
			}
			return 0;
		}
	}
	
	m = (float) (ptox-apx)/(ptoy-apy);
	ent = (int) (ptox-apx)/(ptoy-apy);
	frac = m - ent;
	add = frac;
		
	//caso 9-10 pendiente ]0,1[ hacia origen, desde origen
	if ( m > 1 ) { 
		if ( (ptoy>apy) && (ptox>apx) ) {
			while ( ptox>=apx && ptoy>=apy ){
				for (i=0;i<ent;i++){
					if (ptox<=apx && ptoy<=apy)
						return 0;
					ptox--;
					matriz[ptox][ptoy]=1;
					add=add+frac;
					printf(" %f \n",add);
					if ( add > ent && ptox>apx && ptoy>apy) {
						ptox--;
						matriz[ptox][ptoy]=1;
						add = 0;
						printf("add del if  %f\n",add);
					}
				}
				ptoy--;
			}
			return 0;
		}
		else {
			while ( ptox<=apx && ptoy<=apy ){
				for (i=0;i<ent;i++){
					if (ptox>=apx && ptoy>=apy)
						return 0;
					ptox++;
					matriz[ptox][ptoy]=1;
					add=add+frac;
					if ( add > ent && ptox<apx && ptoy<apy ) {
						ptox++;
						matriz[ptox][ptoy]=1;
						add=0;
					}
				}
				ptoy++;
			}
			return 0;
		}
	}

	//caso 11-12 pendiente ]-1,0[ con x aumentando , con x disminuyendo
	if ( m < -1 ){
		if ( (apy<ptoy) && (ptox<apx) ) {
			while ( ptox<=apx && ptoy>=apy ){
				for (i=0;i>ent;i--){
					if (ptox>=apx && ptoy<=apy)
						return 0;
					ptox++;
					matriz[ptox][ptoy]=1;
					add=add+frac;
					if ( add < ent  && ptox<apx && ptoy>apy ) {
						ptox++;
						matriz[ptox][ptoy]=1;
						add=0;
					}
				}
				ptoy--;
			}
			return 0;
		}
		else {
			while ( ptox>=apx && ptoy<=apy ){
				for (i=0;i>ent;i--){
					if (ptox<=apx && ptoy >=apy)
						return 0;
					ptox--;
					matriz[ptox][ptoy]=1;
					add=add+frac;
					if ( add < ent && ptox>apx && ptoy<apy ) {
						ptox--;
						matriz[ptox][ptoy]=1;
						add=0;
					}
				}
				ptoy++;
			}
			return 0;
		}
	}

}


void main(){

	llenar();
	matriz[apx][apy]=3;
	matriz[ptox][ptoy]=2;

	linea();
	mostrar();

}
