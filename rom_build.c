#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main( int argc, char **argv ) 
{
	

	// Read in font rom, not used, just informative
	FILE *font_fp;
	font_fp = fopen( "font_rom_init.mem", "r" );
	int font[16384];
	char line[128];
	printf("Read font rom mem file\n");
	for( int ii = 0; ii < 16384; ii++ ) {  
		fscanf( font_fp, "%1d", &font[ii] );
	}
	fclose( font_fp );
	printf("\nfont done\n");
	for( int bb = 0; bb < 16; bb++ ) 
		for( int rr = 0; rr < 8; rr++ ) {
			for( int tt = 0; tt < 16; tt++ ) 
				for( int cc = 0; cc < 8; cc++ ) 
					putchar( ( font[ (cc<<11)+(rr<<8) + (bb<<4) + tt ] ) ? '1' : ' ' );
			putchar('|');
			putchar('\n');
		}

	// Read in TEXT overlay and color
	FILE *text_fp;
	text_fp = fopen( "text_overlay_rom_init.txt", "r" );
	printf("Read text overlay file\n");
	for( int ii = 0; ii < 2; ii++ ) // Skip 2 lines
		while( fgetc( text_fp ) != '\n' );
	unsigned char text[32][128];
	unsigned char c;
	int color[32][128];
	for( int row = 0; row < 32; row++ ) {  // clear mems, 32 rows
		for( int col = 0; col < 128; col++ ) {
			text[row][col] = 0; // default
			color[row][col] = 0;
		}
	}
	for( int row = 0; row < 30; row++ ) {  // load 30 rows
		// read text row
		for( int col = 0; col < 129; col++ ) { // 128 char and newline
			c = fgetc( text_fp );
			if( c == '\n' ) 
				break;
			text[row][col] = c;
		}
		// read color row
		for( int col = 0; col < 129; col++ ) {
			c = fgetc( text_fp );
			if( c == '\n' ) 
				break;
			color[row][col] =  
					( c == '0' ) ? 0 :
					( c == '1' ) ? 1 :
					( c == '2' ) ? 2 :
					( c == '3' ) ? 3 :
					( c == '4' ) ? 4 :
					( c == '5' ) ? 5 :
					( c == '6' ) ? 6 :
					( c == '7' ) ? 7 :
					( c == '8' ) ? 8 :
					( c == '9' ) ? 9 :
					( c == 'a' ) ? 10 :
					( c == 'A' ) ? 10 :
					( c == 'b' ) ? 11 :
					( c == 'B' ) ? 11 :
					( c == 'c' ) ? 12 :
					( c == 'C' ) ? 12 :
					( c == 'd' ) ? 13 :
					( c == 'D' ) ? 13 :
					( c == 'e' ) ? 14 :
					( c == 'E' ) ? 14 :
					( c == 'f' ) ? 15 :
					( c == 'F' ) ? 15 : 0;
		}
	}

	for( int row = 0; row < 30; row++ ) {  
		for( int col = 0; col < 128; col++ ) 
			putchar( text[row][col] );
		putchar('|');
		putchar('\n');
		for( int col = 0; col < 128; col++ ) 
			printf( "%1x", color[row][col] );
		putchar('|');
		putchar('\n');
	}
	fclose( text_fp );
	printf("\ntext done\n");

	FILE  *mif_fp;
	mif_fp = fopen( "text_rom_init.mem", "w" );
	 // write text and overlay = 128 * 32 = 4096 words of 12 bits
	 for( int base = 0; base < 4096; base++ ) {
		for( int ii = 3; ii >=0; ii-- )
			fputc( ( color[(base)>>7][(base)&127] & (1<<ii) ) ? '1' : '0', mif_fp );
		for( int ii = 7; ii >=0; ii-- )
			fputc( (  text[(base)>>7][(base)&127] & (1<<ii) ) ? '1' : '0', mif_fp );
		fprintf(mif_fp, "\n");
	 }
	 fclose( mif_fp );
	return( 0 );
}

