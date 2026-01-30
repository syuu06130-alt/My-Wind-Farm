-- [[ Rayfield UI統合スクリプト - Signal Spoofer V3 ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- サービス
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- コンフィグ（アイテム特定用）
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Configs = Shared:WaitForChild("Configs")
local BatteryConfig = require(Configs:WaitForChild("Batteries")).Config
local WindmillConfig = require(Configs:WaitForChild("Windmills")).Config

-- ウィンドウ作成
local Window = Rayfield:CreateWindow({
   Name = "Energy Tycoon: Signal Spoofer V3",
   LoadingTitle = "Turbine/Battery Hack...",
   LoadingSubtitle = "Multi-Signal Active",
   ConfigurationSaving = { Enabled = true, FolderName = "EnergyTycoon", FileName = "SpooferV3" },
   KeySystem = false
})

-- グローバル変数
local _G_Status = {
    AutoBattery = false,
    AutoTurbine = false,
    Multiplier = 5,       -- デフォルト倍率
    BruteForce = false,   -- 全パーツ接触モード
}

-- ユーティリティ: 接触信号送信関数
local function SpoofTouch(targetPart)
    if not targetPart or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return end
    
    -- 設定された倍率分ループして信号を送信
    for i = 1, _G_Status.Multiplier do
        firetouchinterest(LocalPlayer.Character.PrimaryPart, targetPart, 0) -- Touch Start
        firetouchinterest(LocalPlayer.Character.PrimaryPart, targetPart, 1) -- Touch End
    end
end

-- ===== ⚡ メインタブ =====
local MainTab = Window:CreateTab("⚡ 信号偽装", 4483362458)

MainTab:CreateSection("信号設定")

-- 倍率スライダー (1〜50回)
MainTab:CreateSlider({
   Name = "信号増幅倍率 (Loop Multiplier)",
   Range = {1, 50},
   Increment = 1,
   Suffix = "x Hits",
   CurrentValue = 5,
   Flag = "Multiplier",
   Callback = function(Value)
      _G_Status.Multiplier = Value
   end,
})

MainTab:CreateToggle({
   Name = "精密接触モード (Brute Force)",
   CurrentValue = false,
   Flag = "BruteForce",
   Callback = function(Value)
      _G_Status.BruteForce = Value
      -- ONにすると、PrimaryPartだけでなくモデル内の全パーツに接触を試みます
      -- (重くなりますが、当たり判定の漏れがなくなります)
   end,
})

MainTab:CreateSection("自動回収ターゲット")

-- バッテリー回収
MainTab:CreateToggle({
   Name = "バッテリー自動回収 (Battery)",
   CurrentValue = false,
   Flag = "AutoBattery",
   Callback = function(Value)
      _G_Status.AutoBattery = Value
   end,
})

-- 発電機回収 (新規追加)
MainTab:CreateToggle({
   Name = "発電機/タービン自動回収 (Turbine)",
   CurrentValue = false,
   Flag = "AutoTurbine",
   Callback = function(Value)
      _G_Status.AutoTurbine = Value
   end,
})

-- ===== 🚀 メインループ処理 =====
spawn(function()
    while true do
        wait(0.1) -- ループ速度 (早すぎるとクラッシュするため0.1秒)
        
        if _G_Status.AutoBattery or _G_Status.AutoTurbine then
            pcall(function()
                -- Workspace内の自分の所有物を検索
                for _, item in pairs(workspace:GetDescendants()) do
                    if item:IsA("Model") and item:GetAttribute("Owner") == LocalPlayer.Name then
                        
                        local ItemName = item:GetAttribute("Item")
                        local isTarget = false

                        -- ターゲット判定
                        if _G_Status.AutoBattery and BatteryConfig[ItemName] then
                            -- バッテリーかつ中身がある場合
                            local filled = item:GetAttribute("Filled")
                            if filled and filled > 0 then
                                isTarget = true
                            end
                        elseif _G_Status.AutoTurbine and WindmillConfig[ItemName] then
                            -- 発電機の場合 (常に試行)
                            isTarget = true
                        end

                        -- 実行処理
                        if isTarget then
                            if _G_Status.BruteForce then
                                -- 精密モード: 中にあるBasePartすべてにタッチ
                                for _, part in pairs(item:GetChildren()) do
                                    if part:IsA("BasePart") then
                                        SpoofTouch(part)
                                    end
                                end
                            else
                                -- 通常モード: PrimaryPartのみタッチ
                                if item.PrimaryPart then
                                    SpoofTouch(item.PrimaryPart)
                                end
                            end
                        end
                        
                    end
                end
            end)
        end
    end
end)

-- ===== ⚙️ その他 =====
local MiscTab = Window:CreateTab("⚙️ 設定", 4483362458)

MiscTab:CreateButton({
   Name = "UIを閉じる",
   Callback = function()
      Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
