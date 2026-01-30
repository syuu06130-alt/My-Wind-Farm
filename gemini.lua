-- [[ Rayfield UI統合スクリプト - Battery Increase Update ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- サービス & 基本設定
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- フォルダ構造の特定 (提供コードに基づく)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Functions = Shared:WaitForChild("Functions")
local Events = Shared:WaitForChild("Events")
local Configs = Shared:WaitForChild("Configs")

-- 設定ファイルの読み込み (バッテリーリスト取得用)
local BatteriesConfig = require(Configs:WaitForChild("Batteries")).Config
local BatteryNames = {}
for name, _ in pairs(BatteriesConfig) do
    table.insert(BatteryNames, name)
end
table.sort(BatteryNames) -- 名前順にソート

local Window = Rayfield:CreateWindow({
   Name = "Energy Tycoon: Ultra Hub v2",
   LoadingTitle = "システム更新中...",
   LoadingSubtitle = "Battery Increaser Added",
   ConfigurationSaving = { Enabled = true, FolderName = "EnergyTycoon", FileName = "ConfigV2" },
   KeySystem = false
})

-- グローバル状態
local _G_Status = {
    AutoCollect = false,
    AutoTutorial = false,
    AutoBuyBattery = false,
    SelectedBattery = "Scrap Battery", -- デフォルト
    AutoRebirth = false,
}

-- ===== 🔨 メイン機能タブ =====
local MainTab = Window:CreateTab("🔨 メイン機能", 4483362458)

MainTab:CreateSection("自動チュートリアル")
MainTab:CreateToggle({
   Name = "自動チュートリアル完了 (一括)",
   CurrentValue = false,
   Flag = "AutoTutorial",
   Callback = function(Value)
      _G_Status.AutoTutorial = Value
      if Value then
         spawn(function()
            while _G_Status.AutoTutorial do
                pcall(function()
                    -- 提供コードにあったチュートリアル進行リモート
                    Functions.updateTutorialStep:InvokeServer(6)
                end)
                wait(2)
            end
         end)
      end
   end,
})

MainTab:CreateSection("エネルギー回収")
MainTab:CreateToggle({
   Name = "バッテリー自動回収 (UUID Touch)",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      _G_Status.AutoCollect = Value
      if Value then
         spawn(function()
            while _G_Status.AutoCollect do
               pcall(function()
                  -- Workspace内の自分のプロットにあるバッテリーを探す
                  for _, item in pairs(workspace:GetDescendants()) do
                     if item:IsA("Model") and item:GetAttribute("Owner") == LocalPlayer.Name then
                        local filled = item:GetAttribute("Filled")
                        -- 満タンじゃなくても少しでも入っていれば回収（効率重視）
                        if filled and filled > 0 then
                            if item.PrimaryPart then
                                -- プレイヤーとバッテリーを接触させる判定を送信
                                firetouchinterest(LocalPlayer.Character.PrimaryPart, item.PrimaryPart, 0)
                                task.wait()
                                firetouchinterest(LocalPlayer.Character.PrimaryPart, item.PrimaryPart, 1)
                            end
                        end
                     end
                  end
               end)
               wait(0.1)
            end
         end)
      end
   end,
})

-- ▼▼▼ 追加機能: バッテリー増設 ▼▼▼
MainTab:CreateSection("バッテリー増設 (New!)")

MainTab:CreateDropdown({
   Name = "購入するバッテリーを選択",
   Options = BatteryNames,
   CurrentOption = {"Scrap Battery"},
   MultipleOptions = false,
   Flag = "BatterySelect",
   Callback = function(Option)
      _G_Status.SelectedBattery = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "自動購入・配置 (Auto Buy & Place)",
   CurrentValue = false,
   Flag = "AutoBuyBattery",
   Callback = function(Value)
      _G_Status.AutoBuyBattery = Value
      if Value then
         spawn(function()
            while _G_Status.AutoBuyBattery do
               pcall(function()
                  -- 購入/配置のリモートを推測して実行
                  -- 注: 提供コードには配置の具体的なリモート名がなかったため、一般的な名称で試行します
                  -- 1. Functionsフォルダ内の配置リクエストを試す
                  if Functions:FindFirstChild("PlaceItem") then
                      Functions.PlaceItem:InvokeServer(_G_Status.SelectedBattery, Vector3.new(0,0,0), 0)
                  elseif Functions:FindFirstChild("BuyItem") then
                      Functions.BuyItem:InvokeServer(_G_Status.SelectedBattery)
                  elseif Functions:FindFirstChild("RequestPlace") then
                      Functions.RequestPlace:InvokeServer(_G_Status.SelectedBattery)
                  end
                  
                  -- 2. Eventsフォルダ内の配置イベントを試す
                  if Events:FindFirstChild("PlaceItem") then
                      Events.PlaceItem:FireServer(_G_Status.SelectedBattery)
                  end
               end)
               wait(0.5) -- 購入間隔
            end
         end)
      end
   end,
})
-- ▲▲▲ 追加機能終了 ▲▲▲

-- ===== 💰 経済・転生タブ =====
local EcoTab = Window:CreateTab("💰 経済/転生", 4483362458)

local CashLabel = EcoTab:CreateLabel("ステータス: 待機中...")

EcoTab:CreateToggle({
   Name = "自動転生 (Rebirth)",
   CurrentValue = false,
   Callback = function(Value)
      _G_Status.AutoRebirth = Value
      if Value then
         spawn(function()
            while _G_Status.AutoRebirth do
               pcall(function()
                   if Functions:FindFirstChild("RebirthRequest") then
                       Functions.RebirthRequest:InvokeServer()
                   elseif Functions:FindFirstChild("RequestRebirth") then
                       Functions.RequestRebirth:InvokeServer()
                   end
               end)
               wait(5)
            end
         end)
      end
   end,
})

-- ===== 📊 リーダーボード情報 =====
local StatsTab = Window:CreateTab("📊 ランキング", 4483362458)

StatsTab:CreateButton({
   Name = "リーダーボード情報取得",
   Callback = function()
      pcall(function()
          local data = Functions.getLeaderboardPlayers:InvokeServer()
          if data then
             Rayfield:Notify({Title = "成功", Content = "データを更新しました", Duration = 2})
          end
      end)
   end,
})

-- ===== ⚙️ 設定 =====
local MiscTab = Window:CreateTab("⚙️ 設定", 4483362458)

MiscTab:CreateButton({
   Name = "UIを閉じる",
   Callback = function()
      Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
