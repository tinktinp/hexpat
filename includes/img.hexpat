import std.mem;

namespace auto Img {

    struct ImgLibraryHeader {
        u16 imageCount;
        u16 paletteCount;
        u32 offset;
        u16 version;
        u16 sequenceCount;
        u16 scriptCount;
        u16 damageTableCount;
        u16 format;
        u8 bufferScripts[4];
        u16 _padding[3];
    };

    struct ImgHeader {
        char name[16];
        u16 flags;
        s16 xOffset;
        s16 yOffset;
        u16 xSize;
        u16 ySize;
        u16 palette;
        u32 imageDataOffset;
        u32 dataPointer;
        u16 unused;
        u8 damageTable[6];
        s16 frameNumber;
        s16 ptTable;
        s16 otherPalettes;

        try {
            u8 data[((xSize + 3) & ~0x3) * ySize] @ imageDataOffset;
        }
    };

    fn paletteToRgba32(auto name, ref auto inData, u32 len) {
        std::mem::Section palSection = std::mem::create_section(name);
        std::mem::set_section_size(palSection, len * 4);

        u32 sectionData[len] @ 0x0 in palSection;

        u8 a = 0xff;
        for (u8 i = 0, i < len, i = i + 1) {
            u16 d = inData[i];
            u16 r = 8 * ((d >> 10) & 0x1f);
            u16 g = 8 * ((d >> 5) & 0x1f);
            u16 b = 8 * ((d >> 0) & 0x1f);
            sectionData[i] = (a << 24) | (r << 0) | (g << 8) | (b << 16);
        }
        sectionData[0] = sectionData[0] & ~0xFF; // zero alpha for index 0
        return palSection;
    };

    struct PaletteHeader {
        char name[10];
        u8 flags;
        u8 bitsPerPixel;
        u16 numberOfColors;
        u32 offset;
        u16 dataPointer;
        u16 unused0;
        u8 colorIndicator;
        s8 colorMap;
        u16 unused1;

        try {
            u16 data[numberOfColors] @ offset;
        }
        //try {
            auto rgba32Section = Img::paletteToRgba32(name, data, numberOfColors) [[export]];
            u32 rgba32[numberOfColors] @ 0x0 in rgba32Section [[export]];
        //}
    };

    


    struct Entry {
        u32 itemPointer;
        s16 itemIndex;
        u8 ticks;
        u8 _padding;
        s16 deltaX;
        s16 deltaY;
        s16 spare1;
        s16 spare2;
        s16 spare3;
    };

    struct SequenceScript {
        char name[16];
        u16 flags;
        s16 number;
        u8 entryPointers[64];
        s16 startX;
        s16 startY;
        u8 damageTable[6];
        u16 spare0;
        u16 spare1;

        Entry entries[number];
    };

    struct HeadersSection<auto imageCount, auto paletteCount, auto sequenceCount, auto scriptCount> {
        ImgHeader imgHeaders[imageCount];
        PaletteHeader paletteHeaders[paletteCount];
        SequenceScript sequences[sequenceCount];
        SequenceScript scripts[scriptCount];

        auto ps = paletteHeaders[imgHeaders[0].palette - 3].rgba32Section;
        u32 p[64] @  0x0 in ps [[export]];
    }
    [[hex::visualize("bitmap", imgHeaders[0].data, (imgHeaders[0].xSize + 3) & ~0x3, imgHeaders[0].ySize, p)]] 
    ;

    struct ImgFile {
        ImgLibraryHeader imgLibraryHeader;

        HeadersSection<imgLibraryHeader.imageCount, imgLibraryHeader.paletteCount - 3, imgLibraryHeader.sequenceCount, imgLibraryHeader.scriptCount> headersSection @ imgLibraryHeader.offset;
    };

}

Img::ImgFile imgFile @ 0x0;
