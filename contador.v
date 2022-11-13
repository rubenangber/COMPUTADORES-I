//Modulo JK
module JK(output reg Q, output wire nQ, input wire J, input wire K, input wire C);
	not(nQ,Q);
	
	initial
	begin
		Q=0;
	end
	
	always @(posedge C) // Se activa por cada flanco de subida
		case ({J,K})
		2'b10: Q=1;
		2'b01: Q=0;
		2'b11: Q=~Q;
		endcase
endmodule
	
//Modulo CONTADOR
module ContadorArbitrario (output wire [3:0] Q, output wire [3:0] I, input wire C);
wire [3:0] nQ;
wire J0,K0,J1,K1,J2,K2,J3,K3;
wire nQ2nQ3,Q0Q3,nQ1nQ3,Q1Q3,nQ3Q2,nQ0Q3,Q0nQ3;

	//J0-K0
	and (nQ3Q2,nQ[3],Q[2]);
	or (K0,nQ3Q2,Q1Q3);//K0
	and (nQ1nQ3,nQ[1],nQ[3]);
	and (Q1Q3,Q[1],Q[3]);
	or (J0,nQ1nQ3,Q1Q3,Q[2]);//J0
	
	//J1-K1
	assign K1=nQ[3];//K1
	and (nQ2nQ3,nQ[2],nQ[3]);
	and (Q0Q3,Q[0],Q[3]);
	or (J1,nQ2nQ3,Q0Q3);//J1
	
	//J2-K2
	assign K2=Q[0];//K2
	and (nQ0Q3,nQ[0],Q[3]);
	and (Q0nQ3,Q[0],nQ[3]);
	or (J2,nQ0Q3,Q0nQ3);//J2
	
	//J3-K3
	and (K3,Q[0],Q[2]); //K3
	assign J3=nQ[0]; //J3
    
    
	JK JK0(Q[0],nQ[0],J0,K0,C);
	JK JK1(Q[1],nQ[1],J1,K1,C);
	JK JK2(Q[2],nQ[2],J2,K2,C);
	JK JK3(Q[3],nQ[3],J3,K3,C);

//Cambio de los numeros repetidos
wire or1, or2, and1, and2;

	//O0
	and (and2,Q[1],nQ[2],Q[3]);
	or (I[0],Q[0],and2);
	
	//O1
	assign I[1]=Q[1];
	
	//O2
	or (or2,nQ[1],nQ[3],nQ[0]);
	and (I[2],Q[2],or2);
	
	//O3
	or (or1, nQ[0],nQ[2],Q[1]);
	and (I[3],Q[3],or1);

endmodule

//Módulo para probar el circuito.
module TestModulo;
reg C;
wire [3:0] Q;
wire [3:0] I;
	ContadorArbitrario counter (Q,I,C);
	
	always #5 C=~C;

	initial
	begin
		$dumpfile("ContadorArbitrarioGTK.dmp"); //Archivo GTKWAVE
		$dumpvars(2, counter, Q);

	counter.JK0.Q<=1; //La serie empezara por el numero
	counter.JK1.Q<=1; // 0011 es decir el 3 en decimal
	counter.JK2.Q<=0;
	counter.JK3.Q<=0;
	C=0;
	
//Para comprobar el programa en el terminal
	$monitor($time, " Reloj C(%b) Contador Q |%d| |%b| Contador I |%d||%b|",C,Q,Q,I,I);
	#100;
		$dumpoff;
		$finish;
	end
endmodule