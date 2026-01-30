-- =====================================================================
-- Game Auto Farm Hub ULTRA MEGA EDITION - 倍率更新版
-- 完全統合版 - Multiplierシステム追加
-- Created by Advanced AI
-- Version: 7.0 MULTIPLIER EDITION
-- =====================================================================

-- Rayfield UI統合スクリプト (倍率機能追加版)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- サービス & 基本設定
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Functions = Shared:WaitForChild("Functions")

local Window = Rayfield:CreateWindow({
   Name = "🎮 Game Auto Farm Hub ULTRA MEGA",
   LoadingTitle = "倍率システムを初期化中...",
   LoadingSubtitle = "Multiplier機能 + 全システム統合",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "GameConfigUltimate"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- =====================================================================
-- グローバル状態管理
-- =====================================================================
local _G_Status = {
    -- 基本機能
    AutoCollect = false,
    AutoTutorial = false,
    AutoPlace = false,
    AutoSellAll = false,
    
    -- 倍率システム
    CollectMultiplier = 1,
    UseMultiplierMethod = false,
    OriginalMethod = true,
    
    -- ゲーム状態
    SelectedGame = "BasePlaced (鉱山採掘)",
    
    -- 高度な機能
    AutoMining = false,
    AutoHyperFarm = false,
    AutoBattery = false,
    AutoUnbox = false
}

-- ゲーム選択リスト
local gamesList = {
    "BasePlaced (鉱山採掘)",
    "Turbines/Batteries (エネルギー)",
    "シミュレーター系全般"
}

-- =====================================================================
-- ゲーム選択タブ
-- =====================================================================
local GameSelectionTab = Window:CreateTab("🎯 ゲーム選択", 4483362458)
GameSelectionTab:CreateSection("ゲーム選択")

local GameDropdown = GameSelectionTab:CreateDropdown({
   Name = "対象ゲーム選択",
   Options = gamesList,
   CurrentOption = {"BasePlaced (鉱山採掘)"},
   MultipleOptions = false,
   Flag = "GameSelect",
   Callback = function(Option)
       _G_Status.SelectedGame = Option[1]
       updateGameSpecificFunctions()
       Rayfield:Notify({
           Title = "ゲーム変更",
           Content = _G_Status.SelectedGame .. " を選択しました",
           Duration = 3,
           Image = 4483362458,
       })
   end,
})

GameSelectionTab:CreateLabel("選択したゲームに応じて機能が最適化されます")

-- =====================================================================
-- 🔨 メイン機能タブ (BasePlaced系)
-- =====================================================================
local MainTab = Window:CreateTab("🔨 メイン機能", 4483362458)

-- 自動配置セクション
MainTab:CreateSection("自動配置")
local PlaceToggle = MainTab:CreateToggle({
   Name = "自動アイテム配置",
   CurrentValue = false,
   Flag = "AutoPlace",
   Callback = function(Value)
      _G_Status.AutoPlace = Value
      if Value and _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
         spawn(function()
            while _G_Status.AutoPlace and wait(0.1) do
               pcall(function()
                  local pos = _G.CustomPosition or 39
                  local rot = _G.CustomRotation or 2
                  game:GetService("ReplicatedStorage").Remotes.PlaceItem:FireServer("Diggers", 1, pos, rot)
               end)
            end
         end)
      end
   end,
})

-- 自動回収セクション (旧方式)
MainTab:CreateSection("自動回収 (旧方式)")
local CollectToggle = MainTab:CreateToggle({
   Name = "Digger自動回収 (RemoteEvent)",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      _G_Status.AutoCollect = Value
      if Value and _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
         spawn(function()
            while _G_Status.AutoCollect and wait(0.1) do
               pcall(function()
                  for _, digger in pairs(workspace:GetDescendants()) do
                     if digger:IsA("Model") and digger:FindFirstChild("RemoteEvent") then
                        if digger:HasTag("DiggersPlaced") then
                           digger.RemoteEvent:FireServer()
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

-- チュートリアル自動化
MainTab:CreateSection("チュートリアル自動化")
local TutorialToggle = MainTab:CreateToggle({
   Name = "自動チュートリアル進行",
   CurrentValue = false,
   Flag = "AutoTutorial",
   Callback = function(Value)
      _G_Status.AutoTutorial = Value
      if Value then
         spawn(function()
            while _G_Status.AutoTutorial and wait(0.5) do
               pcall(function()
                  if _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
                     game:GetService("ReplicatedStorage").Remotes.NextFTUXStage:FireServer()
                  else
                     -- Turbines系のチュートリアル進行
                     Functions.updateTutorialStep:InvokeServer(6)
                  end
               end)
            end
         end)
      end
   end,
})

-- =====================================================================
-- ⚡ 倍率システムタブ (新機能)
-- =====================================================================
local MultiplierTab = Window:CreateTab("⚡ 倍率システム", 4483362458)

-- 信号偽装設定
MultiplierTab:CreateSection("信号偽装設定")
local MultiplierSlider = MultiplierTab:CreateSlider({
   Name = "回収信号の増幅倍率 (Signal Multiplier)",
   Range = {1, 10},
   Increment = 1,
   Suffix = "倍",
   CurrentValue = 1,
   Flag = "CollectMultiplier",
   Callback = function(Value)
      _G_Status.CollectMultiplier = Value
   end,
})

-- 実行方法選択
MultiplierTab:CreateSection("実行方法選択")
MultiplierTab:CreateToggle({
   Name = "倍率方式を使用 (firetouchinterest)",
   CurrentValue = false,
   Flag = "UseMultiplierMethod",
   Callback = function(Value)
      _G_Status.UseMultiplierMethod = Value
      _G_Status.OriginalMethod = not Value
   end,
})

MultiplierTab:CreateToggle({
   Name = "元の方式を使用 (RemoteEvent)",
   CurrentValue = true,
   Flag = "UseOriginalMethod",
   Callback = function(Value)
      _G_Status.OriginalMethod = Value
      _G_Status.UseMultiplierMethod = not Value
   end,
})

-- 実行
MultiplierTab:CreateSection("実行")
local MultiplierCollectToggle = MultiplierTab:CreateToggle({
   Name = "多重信号自動回収 (Multi-Process)",
   CurrentValue = false,
   Flag = "AutoMultiCollect",
   Callback = function(Value)
      if Value and _G_Status.SelectedGame == "Turbines/Batteries (エネルギー)" then
         if _G_Status.UseMultiplierMethod then
            -- 倍率方式 (firetouchinterest)
            spawn(function()
               while Value do
                  pcall(function()
                     local character = LocalPlayer.Character
                     if not character or not character.PrimaryPart then 
                        wait(0.5)
                        return 
                     end

                     -- Workspace内の自分のプロットにあるバッテリーを走査
                     for _, item in pairs(workspace:GetDescendants()) do
                        if item:IsA("Model") and item:GetAttribute("Owner") == LocalPlayer.Name then
                           -- バッテリー判定 (Filled属性があるもの)
                           local filled = item:GetAttribute("Filled")
                           
                           -- 少しでも溜まっていれば実行
                           if filled and filled > 0 and item.PrimaryPart then
                              
                              -- 設定された倍率分だけ信号を連打・偽装する
                              for i = 1, _G_Status.CollectMultiplier do
                                 -- 0 (Touch開始)
                                 firetouchinterest(character.PrimaryPart, item.PrimaryPart, 0)
                                 -- わずかな遅延を入れることで信号かぶりを防ぎつつ連打
                                 task.wait() 
                                 -- 1 (Touch終了)
                                 firetouchinterest(character.PrimaryPart, item.PrimaryPart, 1)
                              end
                           end
                        end
                     end
                  end)
                  -- ループ速度自体も高速化
                  task.wait(0.05)
               end
            end)
         else
            -- 元の方式 (RemoteEvent)
            spawn(function()
               while Value and wait(0.5) do
                  pcall(function()
                     for _, item in pairs(workspace.Map.Plots:GetDescendants()) do
                        if item:IsA("Model") and item:GetAttribute("Item") then
                           local itemName = item:GetAttribute("Item")
                           if string.find(itemName:lower(), "battery") then
                              local uuid = item:GetAttribute("UUID")
                              if uuid then
                                 Functions.claimBattery:InvokeServer(uuid)
                              end
                           end
                        end
                     end
                  end)
               end
            end)
         end
      elseif Value and _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
         -- BasePlaced用の倍率収集
         spawn(function()
            while Value and wait(0.05) do
               pcall(function()
                  for _, digger in pairs(workspace:GetDescendants()) do
                     if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
                        local remoteEvent = digger:FindFirstChild("RemoteEvent")
                        if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                           for i = 1, _G_Status.CollectMultiplier do
                              remoteEvent:FireServer()
                           end
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

-- =====================================================================
-- 💰 売却・経済タブ
-- =====================================================================
local SellTab = Window:CreateTab("💰 売却・経済システム", 4483362458)

-- 自動売却
SellTab:CreateSection("自動売却")
local SellAllToggle = SellTab:CreateToggle({
   Name = "全アイテム自動売却",
   CurrentValue = false,
   Flag = "AutoSellAll",
   Callback = function(Value)
      _G_Status.AutoSellAll = Value
      if Value then
         spawn(function()
            while _G_Status.AutoSellAll and wait(1) do
               pcall(function()
                  if _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
                     game:GetService("ReplicatedStorage").Remotes.SellAll:FireServer()
                  else
                     Functions.sellAllItems:InvokeServer()
                  end
               end)
            end
         end)
      end
   end,
})

SellTab:CreateButton({
   Name = "今すぐ全アイテム売却",
   Callback = function()
      pcall(function()
         if _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
            game:GetService("ReplicatedStorage").Remotes.SellAll:FireServer()
         else
            Functions.sellAllItems:InvokeServer()
         end
         Rayfield:Notify({
            Title = "売却完了",
            Content = "全アイテムを売却しました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

-- =====================================================================
-- 🛒 ショップ・購入タブ
-- =====================================================================
local ShopTab = Window:CreateTab("🛒 ショップ・購入システム", 4483362458)

-- アイテムリスト
local diggerList = {"DirtDabbler", "RockRipper", "StoneScavenger", "OreObliterator", "GemGrabber"}
local turbineList = {"Iron Turbine", "Scrap Battery", "Windmill"}

ShopTab:CreateSection("アイテム購入")
local ItemDropdown = ShopTab:CreateDropdown({
   Name = "購入するアイテム",
   Options = diggerList,
   CurrentOption = {"DirtDabbler"},
   MultipleOptions = false,
   Flag = "ItemSelect",
   Callback = function(Option)
      _G_Status.SelectedItem = Option[1]
   end,
})

ShopTab:CreateButton({
   Name = "選択したアイテムを購入",
   Callback = function()
      pcall(function()
         if _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
            game:GetService("ReplicatedStorage").Remotes.BuyDigger:FireServer(_G_Status.SelectedItem)
         else
            Functions.purchaseItem:InvokeServer(_G_Status.SelectedItem)
         end
         Rayfield:Notify({
            Title = "購入成功",
            Content = _G_Status.SelectedItem .. " を購入しました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

-- クラート自動開封
ShopTab:CreateSection("クラート自動開封")
local UnboxToggle = ShopTab:CreateToggle({
   Name = "クラート自動開封 (Turbines系)",
   CurrentValue = false,
   Flag = "AutoUnbox",
   Callback = function(Value)
      _G_Status.AutoUnbox = Value
      if Value and _G_Status.SelectedGame == "Turbines/Batteries (エネルギー)" then
         spawn(function()
            while _G_Status.AutoUnbox and wait(5) do
               pcall(function()
                  local crateTypes = {"Wood", "Steel", "Golden"}
                  for _, crate in pairs(crateTypes) do
                     local crateName = crate .. " Crate"
                     Functions.unboxCrate:InvokeServer(crateName)
                  end
               end)
            end
         end)
      end
   end,
})

-- =====================================================================
-- 📡 リモート・自動化タブ
-- =====================================================================
local RemoteTab = Window:CreateTab("📡 リモート・自動化", 4483362458)

RemoteTab:CreateSection("RemoteEvent自動化")
local AutoMiningToggle = RemoteTab:CreateToggle({
   Name = "自動マイニング (RemoteEvent)",
   CurrentValue = false,
   Flag = "AutoMining",
   Callback = function(Value)
      _G_Status.AutoMining = Value
      if Value and _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
         spawn(function()
            while _G_Status.AutoMining and wait(0.05) do
               pcall(function()
                  for _, digger in pairs(workspace:GetDescendants()) do
                     if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
                        local remoteEvent = digger:FindFirstChild("RemoteEvent")
                        if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                           remoteEvent:FireServer()
                        end
                     end
                  end
               end)
            end
         end)
      end
   end,
})

RemoteTab:CreateSection("グループ・通知")
RemoteTab:CreateButton({
   Name = "グループ参加確認",
   Callback = function()
      pcall(function()
         Functions.verifyJoinGroup:InvokeServer()
         Rayfield:Notify({
            Title = "グループ確認",
            Content = "グループ参加確認を実行しました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

RemoteTab:CreateButton({
   Name = "通知設定を更新",
   Callback = function()
      pcall(function()
         Functions.updateNotifications:InvokeServer()
         Rayfield:Notify({
            Title = "通知更新",
            Content = "通知設定を更新しました",
            Duration = 2,
            Image = 4483362458,
         })
      end)
   end,
})

-- =====================================================================
-- ⚡ 高度な機能タブ
-- =====================================================================
local AdvancedTab = Window:CreateTab("⚡ 高度な機能", 4483362458)

AdvancedTab:CreateSection("ハイパーファーム")
local HyperFarmToggle = AdvancedTab:CreateToggle({
   Name = "🔥 ハイパーファーム (超高速)",
   CurrentValue = false,
   Flag = "HyperFarm",
   Callback = function(Value)
      _G_Status.AutoHyperFarm = Value
      if Value then
         Rayfield:Notify({
            Title = "ハイパーファーム起動",
            Content = "超高速ファーミングを開始しました",
            Duration = 2,
            Image = 4483362458,
         })
         spawn(function()
            while _G_Status.AutoHyperFarm and wait(0.01) do
               pcall(function()
                  if _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
                     for _, digger in pairs(workspace:GetDescendants()) do
                        if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
                           local remoteEvent = digger:FindFirstChild("RemoteEvent")
                           if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                              remoteEvent:FireServer()
                           end
                        end
                     end
                  else
                     -- Turbines系の高速収集
                     for _, plot in pairs(workspace.Map.Plots:GetChildren()) do
                        local items = plot:FindFirstChild("Items")
                        if items then
                           for _, item in pairs(items:GetChildren()) do
                              if item:GetAttribute("Item") then
                                 local remote = item:FindFirstChild("RemoteEvent")
                                 if remote then
                                    remote:FireServer()
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
   end,
})

AdvancedTab:CreateSection("リーダーボード機能")
AdvancedTab:CreateButton({
   Name = "リーダーボード情報取得",
   Callback = function()
      pcall(function()
         local leaderboardData = Functions.getLeaderboardPlayers:InvokeServer()
         if leaderboardData then
            Rayfield:Notify({
               Title = "リーダーボード",
               Content = "リーダーボードデータを取得しました",
               Duration = 3,
               Image = 4483362458,
            })
            
            local topPlayers = {}
            for i = 1, math.min(3, #leaderboardData) do
               table.insert(topPlayers, leaderboardData[i].Name .. ": $" .. leaderboardData[i].Cash)
            end
            
            Rayfield:Notify({
               Title = "🏆 トッププレイヤー",
               Content = table.concat(topPlayers, "\n"),
               Duration = 5,
               Image = 4483362458,
            })
         end
      end)
   end,
})

-- =====================================================================
-- ⚙️ 設定・ユーティリティタブ
-- =====================================================================
local SettingsTab = Window:CreateTab("⚙️ 設定・ユーティリティ", 4483362458)

SettingsTab:CreateSection("詳細設定")
SettingsTab:CreateInput({
   Name = "配置位置ID (BasePlaced用)",
   PlaceholderText = "39",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      _G.CustomPosition = tonumber(Text) or 39
      Rayfield:Notify({
         Title = "設定更新",
         Content = "配置位置: " .. _G.CustomPosition,
         Duration = 2,
         Image = 4483362458,
      })
   end,
})

SettingsTab:CreateInput({
   Name = "回転値 (1-4) (BasePlaced用)",
   PlaceholderText = "2",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      local rot = tonumber(Text) or 2
      if rot >= 1 and rot <= 4 then
         _G.CustomRotation = rot
         Rayfield:Notify({
            Title = "設定更新",
            Content = "回転値: " .. _G.CustomRotation,
            Duration = 2,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "エラー",
            Content = "回転値は1-4の範囲で指定してください",
            Duration = 3,
            Image = 4483362458,
         })
      end
   end,
})

SettingsTab:CreateSection("一括操作")
SettingsTab:CreateButton({
   Name = "🟢 すべての機能を有効化",
   Callback = function()
      PlaceToggle:Set(true)
      TutorialToggle:Set(true)
      CollectToggle:Set(true)
      SellAllToggle:Set(true)
      AutoMiningToggle:Set(true)
      MultiplierCollectToggle:Set(true)
      UnboxToggle:Set(true)
      HyperFarmToggle:Set(true)
      Rayfield:Notify({
         Title = "✅ 有効化完了",
         Content = "すべての自動化機能が有効になりました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

SettingsTab:CreateButton({
   Name = "🔴 すべての機能を無効化",
   Callback = function()
      PlaceToggle:Set(false)
      TutorialToggle:Set(false)
      CollectToggle:Set(false)
      SellAllToggle:Set(false)
      AutoMiningToggle:Set(false)
      MultiplierCollectToggle:Set(false)
      UnboxToggle:Set(false)
      HyperFarmToggle:Set(false)
      Rayfield:Notify({
         Title = "⛔ 無効化完了",
         Content = "すべての自動化機能が無効になりました",
         Duration = 3,
         Image = 4483362458,
      })
   end,
})

SettingsTab:CreateSection("情報")
SettingsTab:CreateLabel("作成者: Advanced AI")
SettingsTab:CreateLabel("バージョン: 7.0 MULTIPLIER EDITION")
SettingsTab:CreateLabel("最終更新: 2026/01/31")
SettingsTab:CreateLabel("対応ゲーム: BasePlaced + Turbines/Batteries")
SettingsTab:CreateLabel("倍率システム: 最大10倍まで対応")

-- =====================================================================
-- 🎁 ギフト・アイテム管理タブ
-- =====================================================================
local GiftTab = Window:CreateTab("🎁 ギフト・アイテム管理", 4483362458)

GiftTab:CreateSection("ギフト機能")
GiftTab:CreateButton({
   Name = "アクティブギフトを設定",
   Callback = function()
      pcall(function()
         local giftModule = require(LocalPlayer.PlayerScripts:WaitForChild("GiftingModuleClient"))
         if giftModule and giftModule.SetActiveGift then
            giftModule.SetActiveGift(1, true)
            Rayfield:Notify({
               Title = "ギフト設定",
               Content = "アクティブギフトを設定しました",
               Duration = 2,
               Image = 4483362458,
            })
         end
      end)
   end,
})

-- =====================================================================
-- 📊 監視・統計タブ
-- =====================================================================
local MonitorTab = Window:CreateTab("📊 監視・統計", 4483362458)

MonitorTab:CreateSection("リアルタイム監視")
local MonitorToggle = MonitorTab:CreateToggle({
   Name = "リアルタイム統計監視",
   CurrentValue = false,
   Flag = "MonitorStats",
   Callback = function(Value)
      if Value then
         spawn(function()
            while Value and wait(2) do
               pcall(function()
                  local stats = {}
                  
                  if _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
                     local diggerCount = 0
                     local totalItems = 0
                     for _, digger in pairs(workspace:GetDescendants()) do
                        if digger:IsA("Model") and digger:HasTag("DiggersPlaced") then
                           diggerCount = diggerCount + 1
                           local amount = digger:GetAttribute("Amount") or 0
                           totalItems = totalItems + amount
                        end
                     end
                     stats["Digger数"] = diggerCount
                     stats["総アイテム"] = totalItems
                     
                  else -- Turbines系
                     local turbineCount = 0
                     local batteryCount = 0
                     for _, plot in pairs(workspace.Map.Plots:GetChildren()) do
                        local items = plot:FindFirstChild("Items")
                        if items then
                           for _, item in pairs(items:GetChildren()) do
                              local itemType = item:GetAttribute("Item") or ""
                              if string.find(itemType:lower(), "turbine") then
                                 turbineCount = turbineCount + 1
                              elseif string.find(itemType:lower(), "battery") then
                                 batteryCount = batteryCount + 1
                              end
                           end
                        end
                     end
                     stats["Turbine数"] = turbineCount
                     stats["Battery数"] = batteryCount
                  end
                  
                  local statText = ""
                  for key, value in pairs(stats) do
                     statText = statText .. key .. ": " .. value .. "\n"
                  end
                  
                  if statText ~= "" then
                     Rayfield:Notify({
                        Title = "📊 ファーム統計",
                        Content = statText,
                        Duration = 1.5,
                        Image = 4483362458,
                     })
                  end
               end)
            end
         end)
      end
   end,
})

-- =====================================================================
-- 初期化設定
-- =====================================================================
_G.CustomPosition = 39
_G.CustomRotation = 2
_G_Status.CollectMultiplier = 1

-- 設定読み込み
Rayfield:LoadConfiguration()

-- 起動通知
Rayfield:Notify({
   Title = "🚀 MULTIPLIER EDITION 起動",
   Content = "倍率システム + 全機能統合完了！\n最大10倍の収集倍率が利用可能",
   Duration = 6,
   Image = 4483362458,
})

-- =====================================================================
-- ゲーム固有の機能を動的に更新
-- =====================================================================
local function updateGameSpecificFunctions()
   -- アイテムリストを更新
   if _G_Status.SelectedGame == "BasePlaced (鉱山採掘)" then
      ItemDropdown:SetOptions(diggerList)
   else
      ItemDropdown:SetOptions(turbineList)
   end
   
   -- ゲームに応じて機能をリセット
   local basePlacedOnly = _G_Status.SelectedGame == "BasePlaced (鉱山採掘)"
   local turbinesOnly = _G_Status.SelectedGame == "Turbines/Batteries (エネルギー)"
   
   -- トグルの状態をリセット
   if not basePlacedOnly then
      PlaceToggle:Set(false)
      CollectToggle:Set(false)
      _G_Status.AutoPlace = false
      _G_Status.AutoCollect = false
   end
   
   if not turbinesOnly then
      UnboxToggle:Set(false)
      _G_Status.AutoUnbox = false
   end
   
   -- 倍率システムの注意喚起
   if _G_Status.SelectedGame == "Turbines/Batteries (エネルギー)" then
      Rayfield:Notify({
         Title = "倍率モード利用可能",
         Content = "⚡ 倍率システムが利用可能です\nfiretouchinterest方式で最大10倍まで設定できます",
         Duration = 4,
         Image = 4483362458,
      })
   end
end

-- ゲーム選択変更時に機能を更新
GameDropdown:SetCallback(function(Option)
   _G_Status.SelectedGame = Option[1]
   updateGameSpecificFunctions()
end)

-- 初期更新
updateGameSpecificFunctions()

-- =====================================================================
-- エラーハンドリング強化
-- =====================================================================
local function safeCall(callback, ...)
   local success, result = pcall(callback, ...)
   if not success then
       warn("スクリプトエラー:", result)
       Rayfield:Notify({
           Title = "⚠️ エラー発生",
           Content = "機能実行中にエラーが発生しました",
           Duration = 3,
           Image = 4483362458,
       })
   end
   return result
end

-- パフォーマンス最適化
local lastUpdate = tick()
local function optimizePerformance()
   local currentTime = tick()
   if currentTime - lastUpdate > 60 then
       collectgarbage()
       lastUpdate = currentTime
   end
end

spawn(function()
   while wait(30) do
       optimizePerformance()
   end
end)

print("🎮 Game Auto Farm Hub ULTRA MEGA - MULTIPLIER EDITION 起動完了")
print("⚡ 倍率システム: 最大10倍まで対応")
print("🎮 対応ゲーム: BasePlaced + Turbines/Batteries")
