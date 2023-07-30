local Main = require(game:GetService("ReplicatedStorage"):WaitForChild("Fluent"))

local Window = Main:CreateWindow({
    Title = "Fluent " .. Main.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460)
})

local Tabs = {
    Aim = Window:Tab({
        Title = "Aim",
        Icon = "rbxassetid://10709818534"
    }),
    Visual = Window:Tab({
        Title = "Visual",
        Icon = "rbxassetid://10723346959"
    }),
    Movement = Window:Tab({
        Title = "Movement",
        Icon = "rbxassetid://10709751939"
    }),
    Misc = Window:Tab({
        Title = "Misc",
        Icon = "rbxassetid://10734897250"
    }),
    Settings = Window:Tab({
        Title = "Settings",
        Icon = "rbxassetid://10734950020"
    })
}

local function FormatRGB(Value)
    return {math.floor(Value.r * 255), math.floor(Value.g * 255), math.floor(Value.g * 255)}
end

do
    Tabs.Aim:AddParagraph({
        Title = "Paragraph",
        Content = "This is a paragraph.\nSecond line!"
    })

    Tabs.Aim:AddButton({
        Title = "Button",
        Description = "Very important button",
        Callback = function()
            Window:Dialog({
                Title = "New Dialog",
                Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            Window:Dialog({
                                Title = "Another Dialog",
                                Content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse mollis dolor eget erat mattis, id mollis mauris cursus. Proin ornare sollicitudin odio, id posuere diam luctus id.",
                                Buttons = { { Title = "Ok", Callback = function() print("Ok") end} }
                            })
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog")
                        end
                    }
                }
            })
        end
    })

    local Toggle = Tabs.Aim:AddToggle({Title = "Toggle", Default = false })
    
    local Slider = Tabs.Aim:AddSlider({
        Title = "Slider",
        Description = "This is a slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 1
    })


    local Dropdown = Tabs.Aim:AddDropdown({
        Title = "Dropdown",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = false,
        Default = 1,
    })

    Dropdown:SetValue("four")
    
    local MultiDropdown = Tabs.Aim:AddDropdown({
        Title = "Dropdown",
        Description = "You can select multiple values.",
        Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = true,
        Default = {"seven", "twelve"},
    })

    MultiDropdown:SetValue({
        three = true,
        five = true,
        seven = false
    })

    local Colorpicker = Tabs.Aim:AddColorpicker({
        Title = "Colorpicker",
        Default = Color3.fromRGB(96, 205, 255)
    })

    local TColorpicker = Tabs.Aim:AddColorpicker({
        Title = "Colorpicker",
        Description = "but you can change the transparency.",
        Transparency = 0,
        Default = Color3.fromRGB(96, 205, 255)
    })
       
    Toggle:OnChanged(function(Value)
        print("Toggle changed:", Value)
    end)

    Slider:OnChanged(function(Value)
        print("Slider changed:", Value)
    end)

    Dropdown:OnChanged(function(Value)
        print("Dropdown changed:", Value)
    end)

    MultiDropdown:OnChanged(function(Value)
        local Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Mutlidropdown changed:", table.concat(Values, ", "))
    end)

    Colorpicker:OnChanged(function()
        local Color = FormatRGB(Colorpicker.Value)
        print("Colorpicker changed:", Color[1], Color[2], Color[3])
    end)

    TColorpicker:OnChanged(function()
        local Color = FormatRGB(TColorpicker.Value)
        print(
            "TColorpicker changed:", Color[1], Color[2], Color[3],
            "Transparency:", Main:Round(TColorpicker.Transparency, 2) * 100 .. "%"
        )
    end)
end


Window:SelectTab(1)