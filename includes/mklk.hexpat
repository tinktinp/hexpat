// main area for sprite
import std.mem;
import hex.dec;
import type.color;

using ListBlock;

struct Header {
    u32 RIFF; //char blockHeader[4];
    s32 size; //int totalSize; // fileSize - 8 header
    char spriteHeader[4];
    char spriteHeader2[4];
    u32 spriteSize; // blockSize - 12 header

    char spriteData[spriteSize];

    char listHeader[4];
    u32  listSize;
    char listTypeHeader[4];
    ListBlock listBlock[];
};


struct ListBlockHeader {
 char blockHeader[4];
 u32 blockSize;
 char imageType[12];
 char imageName[24];
 u32 unknown_hash;
 u32 unk2;
 char pad[32];
 u32 hash2;
 char dataType[4];
 u16 resX;
 u16 resY;
 char dataHeader[4];
 u32  dataSize;
};


struct ListBlock {
    if (std::mem::size() - $ < sizeof(ListBlockHeader)) {
        break;
    }

    ListBlockHeader listBlockHeader;
    u8 data[listBlockHeader.dataSize];

    if (listBlockHeader.dataType == "lz4 ") {
        std::mem::Section rgba_section = std::mem::create_section("lz4 decompressed");
        hex::dec::lz4_decompress(data, rgba_section, false);
        u32 rgbaLen = listBlockHeader.resX * listBlockHeader.resY / 4;
        u32 rgba[rgbaLen] @ 0x0 in rgba_section;
    }
}
[[hex::visualize("bitmap", rgba, listBlockHeader.resX, listBlockHeader.resX)]];



Header header @ 0;




// in the decompressed buffer:
import type.color;

#pragma array_limit 0x100000

struct image {
    u32 pixels[std::mem::size() / 4];
}
[[hex::visualize("bitmap", pixels, 1024, sizeof(pixels) / 1024)]];

image i @ 0x0;
