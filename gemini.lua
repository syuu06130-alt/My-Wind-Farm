-- [[ Rayfield UI統合スクリプト - Physical Force Edition V4 ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- サービス
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- コンフィグ取得
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Configs = Shared:WaitForChild("Configs")
local BatteryConfig = require(Configs:WaitForChild("Batteries")).Config
local WindmillConfig = require(Configs:WaitForChild("Windmills")).Config

local Window = Rayfield:CreateWindow({
   Name = "Energy Tycoon: Physical Multiplier V4",
   LoadingTitle = "Bypassing Debounce...",
   LoadingSubtitle = "Physical Teleport Mode",
   ConfigurationSaving = { Enabled = true, FolderName = "EnergyTycoon", FileName = "PhysicalV4" },
   KeySystem = false
})

-- グローバル変数
local _G_Status = {
    Active = false,
    Multiplier = 3,       -- 往復回数（倍率）
    Delay = 0.15,         -- 往復の間隔（秒）
    ReturnToPos = true,   -- 元の位置に戻るか
    TargetBatteries = true,
    TargetTurbines = false,
}

-- 物理タッチ関数（テレポート往復）
local function PhysicalTouch(targetPart)
    local character = LocalPlayer.Character
    if not character or not character.PrimaryPart or not targetPart then return end
    
    local originalCFrame = character.PrimaryPart.CFrame
    
    -- 設定された倍率分、物理的に往復する
    for i = 1, _G_Status.Multiplier do
        if not _G_Status.Active then break end

        -- 1. 対象の内部へテレポート (Touch Start)
        character:SetPrimaryPartCFrame(targetPart.CFrame)
        
        -- 念のため仮想タッチも送信
        firetouchinterest(character.PrimaryPart, targetPart, 0) 
        
        task.wait(_G_Status.Delay) -- サーバー認識待ち
        
        -- 2. 少しずらした位置へ退避 (Touch Endを強制認識させる)
        character:SetPrimaryPartCFrame(targetPart.CFrame * CFrame.new(0, 10, 0))
        
        firetouchinterest(character.PrimaryPart, targetPart, 1)
        
        task.wait(_G_Status.Delay)
    end
    
    -- 元の位置に戻す（オプション）
    if _G_Status.ReturnToPos then
        character:SetPrimaryPartCFrame(originalCFrame)
    end
end

-- ===== ⚡ メインタブ =====
local MainTab = Window:CreateTab("⚡ 物理増殖回収", 4483362458)

MainTab:CreateSection("倍率設定 (Physical)")

MainTab:CreateSlider({
   Name = "物理往復回数 (Multiplier)",
   Range = {1, 10},
   Increment = 1,
   Suffix = "回/セット",
   CurrentValue = 3,
   Flag = "Multiplier",
   Callback = function(Value)
      _G_Status.Multiplier = Value
   end,
})

MainTab:CreateSlider({
   Name = "通信間隔 (Delay)",
   Range = {0.05, 0.5},
   Increment = 0.01,
   Suffix = "秒",
   CurrentValue = 0.15,
   Flag = "Delay",
   Callback = function(Value)
      -- 早すぎるとサーバーが認識しないため、0.1〜0.2推奨
      _G_Status.Delay = Value
   end,
})

MainTab:CreateSection("実行制御")

MainTab:CreateToggle({
   Name = "バッテリー回収 (Batteries)",
   CurrentValue = true,
   Flag = "TargetBatteries",
   Callback = function(Value)
      _G_Status.TargetBatteries = Value
   end,
})

MainTab:CreateToggle({
   Name = "発電機回収 (Turbines)",
   CurrentValue = false,
   Flag = "TargetTurbines",
   Callback = function(Value)
      _G_Status.TargetTurbines = Value
   end,
})

MainTab:CreateToggle({
   Name = "稼働開始 (Start Loop)",
   CurrentValue = false,
   Flag = "Active",
   Callback = function(Value)
      _G_Status.Active = Value
      
      if Value then
         spawn(function()
            while _G_Status.Active do
               pcall(function()
                  local targets = {}
                  
                  -- ターゲット収集
                  for _, item in pairs(workspace:GetDescendants()) do
                     if item:IsA("Model") and item:GetAttribute("Owner") == LocalPlayer.Name then
                        local ItemName = item:GetAttribute("Item")
                        
                        -- バッテリー判定
                        if _G_Status.TargetBatteries and BatteryConfig[ItemName] then
                           local filled = item:GetAttribute("Filled")
                           -- 0より多ければ対象
                           if filled and filled > 0 and item.PrimaryPart then
                              table.insert(targets, item.PrimaryPart)
                           end
                        
                        -- 発電機判定
                        elseif _G_Status.TargetTurbines and WindmillConfig[ItemName] then
                           if item.PrimaryPart then
                              table.insert(targets, item.PrimaryPart)
                           end
                        end
                     end
                  end

                  -- 収集したターゲットに対して物理攻撃を実行
                  for _, target in pairs(targets) do
                     if not _G_Status.Active then break end
                     PhysicalTouch(target)
                     task.wait(0.1) -- 次のアイテムへの移動待ち
                  end
                  
               end)
               task.wait(1) -- 全アイテム巡回後の休憩
            end
         end)
      end
   end,
})

-- ===== 📡 レコーダー (上級者向け) =====
local AdvTab = Window:CreateTab("📡 信号解析", 4483362458)

AdvTab:CreateLabel("Remote Eventが見つからない場合の解析用")

AdvTab:CreateButton({
   Name = "F9コンソールにRemoteログを表示",
   Callback = function()
       -- RemoteSpyの簡易版
       local meta = getrawmetatable(game)
       local old = meta.__namecall
       setreadonly(meta, false)
       
       meta.__namecall = newcclosure(function(self, ...)
           local method = getnamecallmethod()
           local args = {...}
           
           if method == "FireServer" or method == "InvokeServer" then
               print("Remote Detected:", self.Name, "Args:", unpack(args))
           end
           
           return old(self, ...)
       end)
       
       Rayfield:Notify({Title = "Logger Active", Content = "F9キーを押してコンソールを確認し、\n手動で回収した時のログを見てください。", Duration = 5})
   end,
})

-- ===== ⚙️ 設定 =====
local MiscTab = Window:CreateTab("⚙️ 設定", 4483362458)
MiscTab:CreateButton({ Name = "UIを閉じる", Callback = function() Rayfield:Destroy() end })

Rayfield:LoadConfiguration()
