#include<stdio.h>
#include<stdlib.h>
#include<math.h>

int matriz[20][20];
int apx=5,apy=5,ptox=9,ptoy=16;

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
	int i,m ;	// m pendiente
	
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
				matriz[ptox][ptoy]=1;
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
	//caso 5-6 pendiente >= 1+ >= 1-
	if ( ((ptoy-apy)/(ptox-apx)) >= 1 ){
		m = (int) (ptoy-apy)/(ptox-apx);
		if ( (ptoy>apy) && (ptox>apx) ) {
			while ( ptox>=apx && ptoy>=apy ){
				for (i=0;i<m;i++){
					ptoy--;
					matriz[ptox][ptoy]=1;
				}
				ptox--;
			}
			return 0;
		}
		else {
			while ( ptox<=apx && ptoy<=apy ){
				for (i=0;i<m;i++){
					ptoy++;
					matriz[ptox][ptoy]=1;
				}
				ptox++;
			}
			return 0;
		}
	}

	//caso 7-8 pendiente <= -1+ <= -1-
	if ( ((ptoy-apy)/(ptox-apx)) < -1 )
		if ( (apy<ptoy) && (ptox<apx) ) {

		}
		else {

		}
	
	//caso 9-10 pendiente ]0,1]
//	if ( ((ptoy-apy)/(pto

}


void main(){

	llenar();
	matriz[apx][apy]=1;
	matriz[ptox][ptoy]=1;

	linea();
	mostrar();

}
