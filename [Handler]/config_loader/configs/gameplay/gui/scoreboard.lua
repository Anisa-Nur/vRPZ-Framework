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
            title = "S.No",
            dataType = "serial_number",
            width = 75
        },
        {
            title = "Name",
            dataType = "name",
            width = 250
        },
        {
            title = "Level",
            dataType = "level",
            width = 125
        },
        {
            title = "Rank",
            dataType = "rank",
            width = 125
        },
        {
            title = "Reputation",
            dataType = "reputation",
            width = 125
        },
        {
            title = "Party",
            dataType = "party",
            width = 125
        },
        {
            title = "Group",
            dataType = "group",
            width = 150
        },
        {
            title = "K:D",
            dataType = "kd",
            width = 100
        },
        {
            title = "Survival Time",
            dataType = "survival_time",
            width = 125
        },
        {
            title = "Ping",
            dataType = "ping",
            width = 60
        }
    },

    scroller = {
        width = 5,
        thumbHeight = 100,
        bgColor = {0, 0, 0, 255},
        thumbColor = {175, 35, 35, 255}
    }

}