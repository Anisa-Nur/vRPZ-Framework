----------------------------------------------------------------
--[[ Resource: Config Loader
     Script: configs: character: character.lua
     Author: vStudio
     Developer(s): Mario, Tron, Aviril
     DOC: 31/01/2022
     Desc: Character Configns ]]--
----------------------------------------------------------------


------------------
--[[ Configns ]]--
------------------

configVars["Character"] = {

    ["Datas"] = {
        "blood",
        "armor",
        "thirst",
        "hunger"
    },

    ["Identity"] = {
        ["Tone"] = {},
        ["Gender"] = {
            ["Male"] = {assetName = "vRPZ_Male", ["EN"] = "Male", ["TR"] = "Erkek"},
            --["Female"] = {assetName = "vRPZ_Female", ["EN"] = "Female", ["TR"] = "Dişi"}
        }
    },

    ["Clothing"] = {
        ["Facial"] = {
            ["Hair"] = {
                ["Male"] = {
                    {["EN"] = "None", ["TR"] = "Hiçbiri"},
                    {["EN"] = "Casual", ["TR"] = "Gündelik"}
                }
            }
        },
        ["Upper"] = {
            ["Male"] = {
                {clumpName = "TS1", clumpTexture = {"cj_tshrt_1", 1}, ["EN"] = "T-Shirt (White)", ["TR"] = "Tişört (Beyaz)"},
                {clumpName = "TS1", clumpTexture = {"cj_tshrt_1", 2}, ["EN"] = "T-Shirt (Black)", ["TR"] = "Tişört (Siyah)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 1}, ["EN"] = "Hoody (Camo#1)", ["TR"] = "Kapüşonlu (Camo#1)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 2}, ["EN"] = "Hoody (Camo#2)", ["TR"] = "Kapüşonlu (Camo#2)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 3}, ["EN"] = "Hoody (Camo#3)", ["TR"] = "Kapüşonlu (Camo#3)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 4}, ["EN"] = "Hoody (Camo#4)", ["TR"] = "Kapüşonlu (Camo#4)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 5}, ["EN"] = "Hoody (Camo#5)", ["TR"] = "Kapüşonlu (Camo#5)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 6}, ["EN"] = "Hoody (Camo#6)", ["TR"] = "Kapüşonlu (Camo#6)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 7}, ["EN"] = "Hoody (Camo#7)", ["TR"] = "Kapüşonlu (Camo#7)"},
                {clumpName = "H1", clumpTexture = {"cj_hdy_1", 8}, ["EN"] = "Hoody (Camo#8)", ["TR"] = "Kapüşonlu (Camo#8)"}
            },
            ["Female"] = {}
        },
        ["Lower"] = {
            ["Male"] = {
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 1}, ["EN"] = "Jeans (Black)", ["TR"] = "Kot (Siyah)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 2}, ["EN"] = "Jeans (Red)", ["TR"] = "Kot (Kırmızı)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 3}, ["EN"] = "Jeans (Blue)", ["TR"] = "Kot (Mavi)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 4}, ["EN"] = "Jeans (Purple)", ["TR"] = "Kot (Mor)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 5}, ["EN"] = "Jeans (Green)", ["TR"] = "Kot (Yeşil)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 6}, ["EN"] = "Pant (Camo#1)", ["TR"] = "Pantolon (Camo#1)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 7}, ["EN"] = "Pant (Camo#2)", ["TR"] = "Pantolon (Camo#2)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 8}, ["EN"] = "Pant (Camo#3)", ["TR"] = "Pantolon (Camo#3)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 9}, ["EN"] = "Pant (Camo#4)", ["TR"] = "Pantolon (Camo#4)"},
                {clumpName = "P1", clumpTexture = {"cj_pnt_1", 10}, ["EN"] = "Pant (Camo#5)", ["TR"] = "Pantolon (Camo#5)"},
                {clumpName = "T1", clumpTexture = {"cj_trsr_1", 1}, ["EN"] = "Trouser (Green)", ["TR"] = "Pantolon (Yeşil)"}
            },
            ["Female"] = {}
        },
        ["Shoes"] = {
            ["Male"] = {
                {clumpName = "", clumpTexture = {"cj_shoe_1", 1}, ["EN"] = "Sneakers (Black)", ["TR"] = "Spor Ayakkabı (Siyah)"},
                {clumpName = "", clumpTexture = {"cj_shoe_1", 2}, ["EN"] = "Sneakers (Red)", ["TR"] = "Spor Ayakkabı (Red)"}
            },
            ["Female"] = {}
        }
    }

}