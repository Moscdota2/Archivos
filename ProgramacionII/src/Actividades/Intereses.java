package Actividades;
import java.util.Scanner;

public class Intereses {

	public static void main(String[] args) {
	
		double a, b, c;
		int a�;
		int x= 0, p = 0;
	
		Scanner entrada = new Scanner (System.in);
		//Declaro variables
		System.out.println("Programa de generaci�n de Intereses!");
		
		System.out.println("Ingrese el monto total del capital: ");
		a = entrada.nextInt();
		
		System.out.println("Ingrese el monto total de la tasa de interes: ");
		b = entrada.nextInt();
		
		System.out.println("Ingrese la cantidad de a�os para generar el interes: ");
		a� = entrada.nextInt();
		//Pongo una ciclo repetitivo para sacar la cuenta de los intereses
		while (x < a�) {
			x ++;
			p = 1;
			while(p <=4 ) {
				c= a * b/100;
				a=a + c;
				System.out.println("El primer periodo de inter�ss " + p + " Del a�o " + x + "  El Capital a pagar va a ser de:  " + a );
				p++;
				//Aqui se imprime finalmente 
				
			}
			
			
		}
		
	}

}

