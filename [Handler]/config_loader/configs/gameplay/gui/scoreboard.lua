----------------------------------------------------------------
--[[ Resource: Config Loader
     Script: configs: gameplay: gui: scoreboard.lua
     Author: vStudio
     Developer(s): Mario, Tron, Aviril
     DOC: 31/01/2022
     Desc: Scoreboard UI Configns ]]--
----------------------------------------------------------------


------------------
--[[ Configns ]]--
------------------

configVars["UI"]["Scoreboard"] = {

    ["Toggle_Key"] = "tab",

    marginY = 25,
    width = 1282, height = 525,
    bgColor = {0, 0, 0, 250},

    banner = {
        title = "#C81E1E↪  v R P Z   #C8C8C8F R A M E W O R K",
        height = 35, dividerSize = 1,
        fontColor = {175, 175, 175, 255}, dividerColor = {0, 0, 0, 200}, bgColor = {0, 0, 0, 255}
    },

    columns = {
        height = 25, dividerSize = 2,
        fontColor = {0, 0, 0, 255}, bgColor = {100, 100, 100, 255}, dividerColor = {15, 15, 15, 200},
        data = {
            fontColor = {100, 100, 100, 255},
            bgColor = {10, 10, 10, 255}
        },
        {
            title = {["EN"] = "ID", ["TR"] = "ID", ["RU"] = "ID"},
            dataType = "serial_number",
            width = 60
        },
        {
            title = {["EN"] = "Name", ["TR"] = "İsim", ["RU"] = "Имя"},
            dataType = "name",
            width = 240
        },
        {
            title = {["EN"] = "Level", ["TR"] = "Seviye", ["RU"] = "Уровень"},
            dataType = "level",
            width = 100
        },
        {
            title = {["EN"] = "Rank", ["TR"] = "Rank", ["RU"] = "Ранг"},
            dataType = "rank",
            width = 135
        },
        {
            title = {["EN"] = "Reputation", ["TR"] = "İtibar", ["RU"] = "Репутация"},
            dataType = "reputation",
            width = 125
        },
        {
            title = {["EN"] = "Party", ["TR"] = "Takım", ["RU"] = "Отряд"},
            dataType = "party",
            width = 125
        },
        {
            title = {["EN"] = "Group", ["TR"] = "Grup", ["RU"] = "Группа"},
            dataType = "group",
            width = 155
        },
        {
            title = {["EN"] = "K:D", ["TR"] = "K:D", ["RU"] = "У:С"},
            dataType = "kd",
            width = 100
        },
        {
            title = {["EN"] = "Survival", ["TR"] = "Hayatta Kalma", ["RU"] = "Прожито Времени"},
            dataType = "survival",
            width = 140
        },
        {
            title = {["EN"] = "Ping", ["TR"] = "Ping", ["RU"] = "Пинг"},
            dataType = "ping",
            width = 80
        }
    },

    scroller = {
        width = 2,
        thumbHeight = 245,
        bgColor = {0, 0, 0, 255},
        thumbColor = {175, 175, 175, 255}
    }

}
