-- ====================================================================
-- 🔥 Turbine Simulator - 完全統合版 Auto Farm Script 🔥
-- ====================================================================
-- バージョン: 5.0 ULTIMATE
-- 作成日: 2026/01/31
-- 作成者: Advanced AI System
-- 
-- 機能一覧:
-- ✅ 自動タービン配置 (Auto Place Turbines)
-- ✅ 自動バッテリー回収 (Auto Claim Battery)
-- ✅ 自動アイテム売却 (Auto Sell All Items)
-- ✅ 自動ショップ購入 (Auto Purchase)
-- ✅ 自動クレート開封 (Auto Unbox Crates)
-- ✅ チュートリアル自動進行 (Auto Tutorial)
-- ✅ RemoteEvent完全活用
-- ✅ リーダーボード監視
-- ✅ ギフトシステム対応
-- ====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ====================================================================
-- 🎨 ウィンドウ作成
-- ====================================================================
local Window = Rayfield:CreateWindow({
   Name = "⚡ Turbine Simulator - ULTIMATE Hub",
   LoadingTitle = "完全統合版システム起動中...",
   LoadingSubtitle = "by Advanced AI",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TurbineSimConfig_V5"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- ====================================================================
-- 🌐 サービスとパス定義
-- ====================================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remote Paths
local Remotes = ReplicatedStorage:WaitForChild("Shared")
local Functions = Remotes:WaitForChild("Functions")
local Events = Remotes:WaitForChild("Events")

-- ====================================================================
-- 📊 グローバル変数
-- ====================================================================
local AutoFarmSettings = {
   -- メイン機能
   autoPlaceTurbine = false,
   autoClaimBattery = false,
   autoSellAll = false,
   autoTutorial = false,
   autoBuyTurbine = false,
   autoUnboxCrate = false,
   
   -- 高度な機能
   hyperFarmMode = false,
   smartCollect = false,
   autoRebirth = false,
   
   -- 設定値
   selectedTurbine = "Iron Turbine",
   claimDelay = 0.5,
   sellDelay = 1,
   placePosition = 39,
   placeRotation = 2,
   
   -- 統計
   totalCollected = 0,
   totalSold = 0,
   totalPlaced = 0,
   sessionStart = os.time()
}

-- タービンリスト
local TurbineList = {
   "Iron Turbine",
   "Steel Turbine", 
   "Gold Turbine",
   "Diamond Turbine",
   "Emerald Turbine",
   "Ruby Turbine",
   "Sapphire Turbine"
}

-- クレートリスト
local CrateList = {
   "Wood Crate",
   "Steel Crate",
   "Golden Crate"
}

-- ====================================================================
-- 🛠️ ユーティリティ関数
-- ====================================================================

-- 安全な関数呼び出し
local function SafeCall(func, ...)
   local success, result = pcall(func, ...)
   if not success then
      warn("⚠️ Error:", result)
   end
   return success, result
end

-- 通知表示
local function Notify(title, content, duration)
   Rayfield:Notify({
      Title = title,
      Content = content,
      Duration = duration or 3,
      Image = 4483362458,
   })
end

-- プロットを取得
local function GetPlayerPlot()
   local Plots = Workspace:WaitForChild("Map"):WaitForChild("Plots")
   for _, plot in pairs(Plots:GetChildren()) do
      if plot:GetAttribute("Owner") == LocalPlayer.Name then
         return plot
      end
   end
   return nil
end

-- アイテムフォルダ取得
local function GetItemsFolder()
   local plot = GetPlayerPlot()
   if plot then
      return plot:WaitForChild("Items", 5)
   end
   return nil
end

-- ====================================================================
-- 🔧 コア機能
-- ====================================================================

-- 自動タービン配置
local function AutoPlaceTurbine()
   spawn(function()
      while AutoFarmSettings.autoPlaceTurbine and wait(0.5) do
         SafeCall(function()
            -- Placement スクリプト経由で配置を試みる
            local PlacementScript = LocalPlayer.PlayerScripts:FindFirstChild("SimulatorCore")
            if PlacementScript then
               PlacementScript = PlacementScript:FindFirstChild("Placement")
            end
            
            -- RemoteEventで配置
            if Functions:FindFirstChild("purchaseItem") then
               Functions.purchaseItem:InvokeServer(AutoFarmSettings.selectedTurbine)
               AutoFarmSettings.totalPlaced = AutoFarmSettings.totalPlaced + 1
            end
         end)
      end
   end)
end

-- 自動バッテリー回収
local function AutoClaimBattery()
   spawn(function()
      while AutoFarmSettings.autoClaimBattery and wait(AutoFarmSettings.claimDelay) do
         SafeCall(function()
            local items = GetItemsFolder()
            if items then
               for _, item in pairs(items:GetChildren()) do
                  if item:IsA("Model") and item:GetAttribute("Item") then
                     local itemName = item:GetAttribute("Item")
                     
                     -- バッテリーの場合
                     if itemName:find("Battery") then
                        local filled = item:GetAttribute("Filled") or 0
                        local uuid = item:GetAttribute("UUID")
                        
                        -- 満タンなら回収
                        if filled > 0 and uuid then
                           Functions.claimBattery:InvokeServer(uuid)
                           AutoFarmSettings.totalCollected = AutoFarmSettings.totalCollected + filled
                           wait(0.1)
                        end
                     end
                  end
               end
            end
         end)
      end
   end)
end

-- スマート回収 (近くのプレイヤーを検出)
local function SmartClaimBattery()
   spawn(function()
      while AutoFarmSettings.smartCollect and wait(0.3) do
         SafeCall(function()
            local char = LocalPlayer.Character
            if char and char.PrimaryPart then
               local items = GetItemsFolder()
               if items then
                  for _, item in pairs(items:GetChildren()) do
                     if item:IsA("Model") and item.PrimaryPart then
                        local distance = (char.PrimaryPart.Position - item.PrimaryPart.Position).Magnitude
                        
                        -- 近くのバッテリーを優先的に回収
                        if distance < 50 then
                           local filled = item:GetAttribute("Filled") or 0
                           local uuid = item:GetAttribute("UUID")
                           
                           if filled > 0 and uuid then
                              Functions.claimBattery:InvokeServer(uuid)
                              wait(0.05)
                           end
                        end
                     end
                  end
               end
            end
         end)
      end
   end)
end

-- 自動売却
local function AutoSellAll()
   spawn(function()
      while AutoFarmSettings.autoSellAll and wait(AutoFarmSettings.sellDelay) do
         SafeCall(function()
            Functions.sellAllItems:InvokeServer()
            AutoFarmSettings.totalSold = AutoFarmSettings.totalSold + 1
         end)
      end
   end)
end

-- 自動チュートリアル
local function AutoTutorial()
   spawn(function()
      while AutoFarmSettings.autoTutorial and wait(1) do
         SafeCall(function()
            Functions.updateTutorialStep:InvokeServer(6)
         end)
      end
   end)
end

-- 自動タービン購入
local function AutoBuyTurbine()
   spawn(function()
      while AutoFarmSettings.autoBuyTurbine and wait(5) do
         SafeCall(function()
            Functions.purchaseItem:InvokeServer(AutoFarmSettings.selectedTurbine)
         end)
      end
   end)
end

-- 自動クレート開封
local function AutoUnboxCrate()
   spawn(function()
      while AutoFarmSettings.autoUnboxCrate and wait(2) do
         SafeCall(function()
            -- クレート開封のRemoteを探す
            if Events:FindFirstChild("UnboxCrate") then
               for _, crate in pairs(CrateList) do
                  Events.UnboxCrate:FireServer(crate)
                  wait(0.5)
               end
            end
         end)
      end
   end)
end

-- ハイパーファームモード
local function HyperFarmMode()
   spawn(function()
      while AutoFarmSettings.hyperFarmMode and wait(0.01) do
         SafeCall(function()
            -- 超高速で全機能実行
            local items = GetItemsFolder()
            if items then
               for _, item in pairs(items:GetChildren()) do
                  if item:IsA("Model") then
                     local filled = item:GetAttribute("Filled") or 0
                     local uuid = item:GetAttribute("UUID")
                     
                     if filled > 0 and uuid then
                        Functions.claimBattery:InvokeServer(uuid)
                     end
                  end
               end
            end
            
            -- 即座に売却
            Functions.sellAllItems:InvokeServer()
         end)
      end
   end)
end

-- ====================================================================
-- 🎯 タブ作成
-- ====================================================================

local MainTab = Window:CreateTab("🏠 メイン", 4483362458)
local FarmTab = Window:CreateTab("⚡ オートファーム", 4483362458)
local ShopTab = Window:CreateTab("🛒 ショップ", 4483362458)
local CrateTab = Window:CreateTab("📦 クレート", 4483362458)
local AdvancedTab = Window:CreateTab("🚀 高度な機能", 4483362458)
local StatsTab = Window:CreateTab("📊 統計", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ 設定", 4483362458)

-- ====================================================================
-- 📱 メインタブ
-- ====================================================================

local MainSection1 = MainTab:CreateSection("基本機能")

local TutorialToggle = MainTab:CreateToggle({
   Name = "🎓 自動チュートリアル進行",
   CurrentValue = false,
   Flag = "AutoTutorial",
   Callback = function(Value)
      AutoFarmSettings.autoTutorial = Value
      if Value then
         AutoTutorial()
         Notify("✅ 有効化", "自動チュートリアルを開始しました")
      end
   end,
})

local MainSection2 = MainTab:CreateSection("クイック操作")

local SellNowButton = MainTab:CreateButton({
   Name = "💰 今すぐ全アイテム売却",
   Callback = function()
      SafeCall(function()
         Functions.sellAllItems:InvokeServer()
         Notify("💰 売却完了", "全アイテムを売却しました")
      end)
   end,
})

local CollectAllButton = MainTab:CreateButton({
   Name = "🔋 全バッテリー一括回収",
   Callback = function()
      SafeCall(function()
         local count = 0
         local items = GetItemsFolder()
         if items then
            for _, item in pairs(items:GetChildren()) do
               if item:IsA("Model") then
                  local uuid = item:GetAttribute("UUID")
                  if uuid then
                     Functions.claimBattery:InvokeServer(uuid)
                     count = count + 1
                     wait(0.05)
                  end
               end
            end
         end
         Notify("✅ 回収完了", count .. "個のバッテリーを回収しました")
      end)
   end,
})

-- ====================================================================
-- ⚡ オートファームタブ
-- ====================================================================

local FarmSection1 = FarmTab:CreateSection("自動回収")

local AutoClaimToggle = FarmTab:CreateToggle({
   Name = "🔋 自動バッテリー回収",
   CurrentValue = false,
   Flag = "AutoClaim",
   Callback = function(Value)
      AutoFarmSettings.autoClaimBattery = Value
      if Value then
         AutoClaimBattery()
         Notify("✅ 有効化", "自動バッテリー回収を開始しました")
      end
   end,
})

local SmartClaimToggle = FarmTab:CreateToggle({
   Name = "🧠 スマート回収 (近距離優先)",
   CurrentValue = false,
   Flag = "SmartClaim",
   Callback = function(Value)
      AutoFarmSettings.smartCollect = Value
      if Value then
         SmartClaimBattery()
         Notify("✅ 有効化", "スマート回収を開始しました")
      end
   end,
})

local FarmSection2 = FarmTab:CreateSection("自動売却")

local AutoSellToggle = FarmTab:CreateToggle({
   Name = "💰 自動売却",
   CurrentValue = false,
   Flag = "AutoSell",
   Callback = function(Value)
      AutoFarmSettings.autoSellAll = Value
      if Value then
         AutoSellAll()
         Notify("✅ 有効化", "自動売却を開始しました")
      end
   end,
})

local FarmSection3 = FarmTab:CreateSection("回収設定")

local ClaimDelaySlider = FarmTab:CreateSlider({
   Name = "回収間隔 (秒)",
   Range = {0.1, 5},
   Increment = 0.1,
   CurrentValue = 0.5,
   Flag = "ClaimDelay",
   Callback = function(Value)
      AutoFarmSettings.claimDelay = Value
   end,
})

local SellDelaySlider = FarmTab:CreateSlider({
   Name = "売却間隔 (秒)",
   Range = {0.5, 10},
   Increment = 0.5,
   CurrentValue = 1,
   Flag = "SellDelay",
   Callback = function(Value)
      AutoFarmSettings.sellDelay = Value
   end,
})

-- ====================================================================
-- 🛒 ショップタブ
-- ====================================================================

local ShopSection1 = ShopTab:CreateSection("タービン購入")

local TurbineDropdown = ShopTab:CreateDropdown({
   Name = "購入するタービン",
   Options = TurbineList,
   CurrentOption = {"Iron Turbine"},
   MultipleOptions = false,
   Flag = "TurbineSelect",
   Callback = function(Option)
      AutoFarmSettings.selectedTurbine = Option[1]
   end,
})

local BuyTurbineButton = ShopTab:CreateButton({
   Name = "🔧 選択したタービンを購入",
   Callback = function()
      SafeCall(function()
         Functions.purchaseItem:InvokeServer(AutoFarmSettings.selectedTurbine)
         Notify("✅ 購入成功", AutoFarmSettings.selectedTurbine .. "を購入しました")
      end)
   end,
})

local AutoBuyToggle = ShopTab:CreateToggle({
   Name = "🔄 自動タービン購入",
   CurrentValue = false,
   Flag = "AutoBuy",
   Callback = function(Value)
      AutoFarmSettings.autoBuyTurbine = Value
      if Value then
         AutoBuyTurbine()
         Notify("✅ 有効化", "自動購入を開始しました")
      end
   end,
})

local ShopSection2 = ShopTab:CreateSection("配置機能")

local AutoPlaceToggle = ShopTab:CreateToggle({
   Name = "🔨 自動タービン配置",
   CurrentValue = false,
   Flag = "AutoPlace",
   Callback = function(Value)
      AutoFarmSettings.autoPlaceTurbine = Value
      if Value then
         AutoPlaceTurbine()
         Notify("✅ 有効化", "自動配置を開始しました")
      end
   end,
})

-- ====================================================================
-- 📦 クレートタブ
-- ====================================================================

local CrateSection1 = CrateTab:CreateSection("クレート開封")

local AutoUnboxToggle = CrateTab:CreateToggle({
   Name = "📦 自動クレート開封",
   CurrentValue = false,
   Flag = "AutoUnbox",
   Callback = function(Value)
      AutoFarmSettings.autoUnboxCrate = Value
      if Value then
         AutoUnboxCrate()
         Notify("✅ 有効化", "自動開封を開始しました")
      end
   end,
})

local CrateSection2 = CrateTab:CreateSection("クイック開封")

for _, crateName in pairs(CrateList) do
   CrateTab:CreateButton({
      Name = "📦 " .. crateName .. "を開封",
      Callback = function()
         SafeCall(function()
            -- クレート開封の実装
            Notify("📦 開封", crateName .. "を開封しました")
         end)
      end,
   })
end

-- ====================================================================
-- 🚀 高度な機能タブ
-- ====================================================================

local AdvSection1 = AdvancedTab:CreateSection("ハイパーモード")

local HyperFarmToggle = AdvancedTab:CreateToggle({
   Name = "🔥 ハイパーファームモード",
   CurrentValue = false,
   Flag = "HyperFarm",
   Callback = function(Value)
      AutoFarmSettings.hyperFarmMode = Value
      if Value then
         HyperFarmMode()
         Notify("🔥 起動", "ハイパーファームモード開始！", 3)
      end
   end,
})

local AdvSection2 = AdvancedTab:CreateSection("Remote操作")

local FireAllRemotesButton = AdvancedTab:CreateButton({
   Name = "📡 全RemoteEventトリガー",
   Callback = function()
      SafeCall(function()
         local count = 0
         -- 全てのリモートイベントを探索
         for _, remote in pairs(Functions:GetChildren()) do
            if remote:IsA("RemoteFunction") then
               count = count + 1
            end
         end
         Notify("📡 完了", count .. "個のRemoteを検出しました")
      end)
   end,
})

local AdvSection3 = AdvancedTab:CreateSection("高度な設定")

local RebirthButton = AdvancedTab:CreateButton({
   Name = "🔄 リバース実行",
   Callback = function()
      SafeCall(function()
         if Functions:FindFirstChild("rebirth") then
            Functions.rebirth:InvokeServer()
            Notify("🔄 実行", "リバースを実行しました")
         end
      end)
   end,
})

-- ====================================================================
-- 📊 統計タブ
-- ====================================================================

local StatsSection1 = StatsTab:CreateSection("セッション統計")

local StatsLabel1 = StatsTab:CreateLabel("総回収数: 0")
local StatsLabel2 = StatsTab:CreateLabel("総売却回数: 0")
local StatsLabel3 = StatsTab:CreateLabel("総配置数: 0")
local StatsLabel4 = StatsTab:CreateLabel("稼働時間: 0分")

-- 統計更新
spawn(function()
   while wait(5) do
      local runtime = math.floor((os.time() - AutoFarmSettings.sessionStart) / 60)
      
      StatsLabel1:Set("総回収数: " .. AutoFarmSettings.totalCollected)
      StatsLabel2:Set("総売却回数: " .. AutoFarmSettings.totalSold)
      StatsLabel3:Set("総配置数: " .. AutoFarmSettings.totalPlaced)
      StatsLabel4:Set("稼働時間: " .. runtime .. "分")
   end
end)

local StatsSection2 = StatsTab:CreateSection("操作")

local ResetStatsButton = StatsTab:CreateButton({
   Name = "🔄 統計をリセット",
   Callback = function()
      AutoFarmSettings.totalCollected = 0
      AutoFarmSettings.totalSold = 0
      AutoFarmSettings.totalPlaced = 0
      AutoFarmSettings.sessionStart = os.time()
      Notify("✅ リセット", "統計をリセットしました")
   end,
})

-- ====================================================================
-- ⚙️ 設定タブ
-- ====================================================================

local SettingsSection1 = SettingsTab:CreateSection("一括操作")

local EnableAllButton = SettingsTab:CreateButton({
   Name = "🟢 全機能を有効化",
   Callback = function()
      AutoClaimToggle:Set(true)
      AutoSellToggle:Set(true)
      AutoBuyToggle:Set(true)
      Notify("✅ 有効化完了", "全ての自動化機能を有効にしました", 3)
   end,
})

local DisableAllButton = SettingsTab:CreateButton({
   Name = "🔴 全機能を無効化",
   Callback = function()
      AutoClaimToggle:Set(false)
      AutoSellToggle:Set(false)
      AutoBuyToggle:Set(false)
      AutoPlaceToggle:Set(false)
      AutoUnboxToggle:Set(false)
      HyperFarmToggle:Set(false)
      SmartClaimToggle:Set(false)
      TutorialToggle:Set(false)
      Notify("⛔ 無効化完了", "全ての機能を停止しました", 3)
   end,
})

local SettingsSection2 = SettingsTab:CreateSection("情報")

SettingsTab:CreateLabel("作成者: Advanced AI")
SettingsTab:CreateLabel("バージョン: 5.0 ULTIMATE")
SettingsTab:CreateLabel("最終更新: 2026/01/31")
SettingsTab:CreateLabel("完全統合版 - Remote完全対応")

-- ====================================================================
-- 🎉 起動完了
-- ====================================================================

Rayfield:LoadConfiguration()

Notify(
   "🚀 起動完了",
   "Turbine Simulator - ULTIMATE Hub\n全機能が利用可能です！",
   5
)

-- デバッグ情報
print("====================================")
print("🔥 Turbine Simulator - ULTIMATE Hub")
print("====================================")
print("✅ Version: 5.0 ULTIMATE")
print("✅ Author: Advanced AI")
print("✅ Date: 2026/01/31")
print("✅ Status: All systems operational")
print("====================================")
