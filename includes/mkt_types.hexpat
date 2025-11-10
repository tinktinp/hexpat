#pragma once
#pragma endian little

import std.mem;
import std.core;
import type.base;
//import type.color;


bitfield RGBA<auto R, auto G, auto B, auto A> {
    r : R;
    g : G;
    b : B;
    if (A > 0) a : A;
} [[sealed, color(std::format("{0:02X}{1:02X}{2:02X}", r * 8, g * 8, b * 8))]];

using RGB555 = RGBA<5, 5, 5, 1>;


namespace auto mkt {

    struct Palette {
        u16 paletteSize;
        RGB555 paletteData[paletteSize];
    };

    //RGB555 testFoo @ 0;
    //std::print(sizeof(testFoo));

    struct PaletteList {
        u32 byteLength;
        Palette palettes[while(std::mem::read_unsigned($, 2) != 0x00)];
    };



    fn getCompType(u8 type) {
        if (type & 0x60 == 0) return "Huffman";
        if (type & 0x20 == 0) return "PovBq";
        return "RLE";
    };


    struct ImageHeader {
        u8 *imageOffset: u24;
        type::Hex<u8> type;
        type::Hex<u8> type2 = type & 0xE0 [[export]];
        str compType = mkt::getCompType(type) [[export]];
        u8 width;
        u8 height;
        s16 xOffset;
        s16 yOffset;
        u16 paletteId;
        
        //u8 *data : u24; // = imageOffset;
        //std::core::array_index() + 1]

        // u8 data[width * height] @ imageOffset + 4 + parent.endOfImageHeaders;// [[hidden]];

        //Palette palette = parent.palette_section.palettes[paletteId];
        // PaletteList* pl = addressof(parent.palette_section);
    }; // [[hex::visualize("bitmap", data, width, height, parent.palette_section.palettes[paletteId].paletteData)]] ;

    using MktPcFile;

    fn imageLens(ref MktPcFile file ) {
        for (u16 i = 1, i < len, i += 1) {
            return 0;
        }
    };

    struct BackgroundHeader {
        u32 palettesOffset;
        PaletteList palette_section @ palettesOffset + $;

        u32 unknown1; // 0x4
        if (unknown1 != 4 && unknown1 != 0) {
            //u32 xyz[65535*10]; // force an error
        }
        u32 unknown2; // 0x2
        u32 endOfImageHeaders;

        u32 nHeaders = endOfImageHeaders / 12 [[export]];
        u32 floorHeight = palettesOffset / 0x3c0 [[export]];
        u32 floor1Pos = palettesOffset + palette_section.byteLength + 8 [[export]];
        try {
        ImageHeader imageHeaders[nHeaders];
        } catch {

        }

        try {
        u32 floorOneLen @ floor1Pos;
        u32 floorOneData[floorOneLen / 4] @ addressof(floorOneLen) + 4;
        Palette floorOnePalette @ addressof(floorOneData) + sizeof(floorOneData) + 4;
        } catch {

        }

    };

    struct BgPreheader {
        u32 bgHeaderOffset;
        BackgroundHeader backgroundHeader @ $ +  bgHeaderOffset;
    };

    struct MktPcFile {
        try {
            BackgroundHeader backgroundHeader;
        } catch {
            u32 bgPreheaderOffset;
            BgPreheader bgPreheader @ $ + bgPreheaderOffset;
            Palette floorPalette @ $ + bgPreheaderOffset + 4;

            u32 floorData[while($ < addressof(bgPreheader))];

            u32 nextOffset @ addressof(bgPreheader.backgroundHeader.palette_section) + sizeof(bgPreheader.backgroundHeader.palette_section) + 2;

            u32 foo @ addressof(nextOffset) + nextOffset + 4;
            Palette floor2Palette @ addressof(foo) + 4;
        }
        
        //u16 tables[while($ < (imageHeaders[0].imageOffset + 4))] @ tables_offset + 4;

        
    };



    struct MktPcCharacterFile {
        u32 offset_to_palette_section;
        u32 offset_to_tables_section;

        ImageHeader imageHeaders[while($ < offset_to_tables_section)];

        u16 tables[while($ < (imageHeaders[0].imageOffset + 4))] @ offset_to_tables_section + 4;

        PaletteList palette_section @ offset_to_palette_section + 4;
    };


}