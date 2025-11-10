import std.mem;
import hex.dec;
import type.color;


#pragma array_limit 22097152
#pragma pattern_limit 0x2000000

using ListBlock;

struct SpriteHeader {
    u32 xpos;
    u32 ypos;
    u32 width; 
    u32 height;
    u32 width2;
    u32 height2;
    u32 unknown2;
    u32 unknown3;
    u32 unk_803f;
    u32 unknown4;
    u32 unknown5;
    u32 sheetIndex; // which image is this sprite in? 
    u32 unknown7;
    u32 unknown8;
};


struct SpriteDataSection<auto len> {
    u32 unknown0; // 01 or 04
    u32 unknown1; // 00 01 or 00 04
    u32 spriteCount;
    u32 padding0;
    
    u32 myEnd = addressof(this) + len;
    
    SpriteHeader spriteHeaders[spriteCount] @ myEnd - sizeof(SpriteHeader) * spriteCount;
} [[fixed_size(len)]];


struct Header {
    u32 RIFF; //char blockHeader[4];
    s32 size; //int totalSize; // fileSize - 8 header
    char spriteHeader[4];
    char spriteHeader2[4];
    u32 spriteSize; // blockSize - 12 header

    // char spriteData[spriteSize];
    SpriteDataSection<spriteSize> spriteDataSection;

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

    u32 rgbaLen = listBlockHeader.resX * listBlockHeader.resY;

    if (listBlockHeader.dataType == "lz4 ") {
        std::mem::Section rgba_section = std::mem::create_section("lz4 decompressed");
        std::mem::set_section_size(rgba_section, rgbaLen * 4);

        auto result = hex::dec::lz4_decompress(data, rgba_section, false);

        std::print("rgbaLen: {}, result: {}", rgbaLen, result);
        u32 rgba[rgbaLen] @ 0x0 in rgba_section;
    }
}
[[hex::visualize("bitmap", rgba, listBlockHeader.resX, rgbaLen / listBlockHeader.resX )]];



Header header @ 0;
