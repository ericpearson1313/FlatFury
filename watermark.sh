#!/bin/bash
cp text_rom_init.mem save_text_rom_init.mem
cat text_rom_init.mem | head -n 3832 > temp_seg1
git rev-parse HEAD | head -c7 | basenc --base2msbf --wrap=8 | awk -f format_commit.awk > temp_seg2
cat text_rom_init.mem| tail -n +3840 > temp_seg3
cat temp_seg1 temp_seg2 temp_seg3 > text_rom_init.mem

