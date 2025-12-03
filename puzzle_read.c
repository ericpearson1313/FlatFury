#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>

#define PAGE_SIZE 4096

int get_pagemap_entry(void *vaddr, long *entry) {
    int fd = open("/proc/self/pagemap",  O_RDONLY);
    if (fd == -1) {
        perror("open /proc/self/pagemap");
        return -1;
    }

    // Calculate the offset in the pagemap file
    off_t offset = (uintptr_t)vaddr / PAGE_SIZE * sizeof(uint64_t);

    // Seek to the correct position in the file
    if (lseek(fd, offset, SEEK_SET) == -1) {
        perror("lseek");
        close(fd);
        return -1;
    }

    // Read the pagemap entry
    if (read(fd, entry, sizeof(uint64_t)) != sizeof(uint64_t)) {
        perror("read");
        close(fd);
        return -1;
    }
    close(fd);
    return 0;
}

int main( int argc, char **argv )
{
	FILE *fp;
	char r, g, b; // 8 bits each RGB
	long mem_buffer[65536+1024]; // array of 64 bit words with room for 4K alignment
	long *buffer; // 256x256 of longs
	long *rat; // row address table 256 long word array 
	long val;
	long entry;

	// Find first 4K aligned word and use that as start of our actual buffer
	// We'll work with 4K pages knowing they are mapped randomly to physical memory
	// WIth out test image of 256pels*64bits it takes 1/2 a 4K page
	// We'll write the physcal row address nto the rat tablel which is again 256x64b.
	// The physical address of the rat table will be writen into a fpga reg
	// Hardware will read the rat table at the start of each vsync, 
	// and then read and display(hdmi) each row of the rgb24 image within a 256x256 window

	// Align the image buffer and rat table  on 4k page boundaries.
	buffer = &mem_buffer[(0x1000-(((long)mem_buffer)&0xfff))>>3];
	rat = buffer + 65536; 
	
	// Load the puzzle array into a buffer as BCD 
	printf("Reading img/puzzle.txt, into buffer\n");
	fp = fopen( "img/puzzle.txt", "rb" );

	
	int xx, yy;
	long bdc;
	char c;
	yy = 0;
	c = fgetc( fp );
	while( !feof( fp ) ) {
		printf("%02x ", yy);
		// read in up to CR
		xx = 0;
		while( c != 0x0A ) {
			printf("%c",c);
			bdc = c - '0';
			bdc = ( bdc > 0 && bdc < 10 ) ? bdc : 0; // only keep digits, else zero
			val = (bdc<<60)+(bdc<<52)+(bdc<<44); // pack into high nibble of R,G,B
			buffer[(yy<<8)+xx] = val;
			xx++;
			c = fgetc( fp );
		}
		while( xx < 256 ) {
			printf("%c",'0');
			buffer[(yy<<8)+xx] = 0;
			xx++;
		}
		yy++;
		printf("\n");
		c = fgetc( fp );
	}
	while( yy < 256 ) {
		printf("%02x ", yy);
		for( xx = 0; xx < 256; xx++ ) {
			printf("%c",'0');
			buffer[(yy<<8)+xx] = 0;
		}
		yy++;
		printf("\n");
	}
			
	printf("Build physical rat (row address table)\n");
	for( int ii = 0; ii < 256; ii++) { // step through the 256 rows of 2Kbytes and get real addresses
		get_pagemap_entry( &(buffer[ii*256]), &entry );
		rat[ii] = ( entry & 0xFFFFFFFFFFFFL ) << 12 | ( (long)&(buffer[ii*256]) & 0xfff);
//		printf("idx %04x ptr %lx pagemap %016lx rat %lx\n", ii, (long)&(buffer[ii*256]), entry, rat[ii] );
	}
	// Extract rat physical address 
	get_pagemap_entry( rat, &entry );
	long rat_addr;
	rat_addr = (( entry & 0xFFFFFFFFFFFFL ) << 12) | ((long)rat & 0xfffL);
	printf("Rat addr: %lx\n", rat_addr );
	
	// stay here with image in memory until done
	printf("Press enter key to exit\n");
	getchar();
	return( 0 );
}

