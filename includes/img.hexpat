
namespace auto Img {
    struct ImgLibraryFile {
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
    };

}

Img::ImgLibraryFile imgLibraryFile @ 0x0;
