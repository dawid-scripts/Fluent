local Main = require(game:GetService("ReplicatedStorage"):WaitForChild("Fluent"))
local Window = Main:CreateWindow({
    Title = "Fluent",
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 450)
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

do
    Tabs.Aim:AddParagraph({
        Title = "Paragraph",
        Content = "This is a paragraph"
    })

    Tabs.Aim:AddButton({
        Title = "Button",
        Description = "Very important button",
        Callback = function()
            print("Button")
        end
    })

    local Toggle = Tabs.Aim:AddToggle({Title = "Toggle", Default = false })
    
    local Slider = Tabs.Aim:AddSlider({
        Title = "Slider",
        Description = "This is a slider",
        Default = 2,
        Min = 0,
        Max = 5,
        Rounding = 0
    })


    local Dropdown = Tabs.Aim:AddDropdown({
        Title = "Dropdown",
        Options = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = false,
        Default = 1,
    })

    Dropdown:SetValue("four")
    
    local MultiDropdown = Tabs.Aim:AddDropdown({
        Title = "Dropdown",
        Description = "You can select multiple options.",
        Options = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
        Multi = true,
        Default = {"seven", "twelve"},
    })

    MultiDropdown:SetValue({
        three = true,
        five = true,
        seven = false
    })
       
    Toggle:OnChanged(function(Value)
        print("Toggle changed: " .. Value)
    end)

    Slider:OnChanged(function(Value)
        print("Slider changed: " .. Value)
    end)

    Dropdown:OnChanged(function(Value)
        print("Dropdown changed: " .. Value)
    end)

    MultiDropdown:OnChanged(function(Value)
        local Values = {}
        for Value, State in next, Value do
            table.insert(Values, Value)
        end
        print("Mutlidropdown changed: " .. table.concat(Values, ", "))
    end)
end