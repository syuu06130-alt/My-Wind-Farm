-- [[ Rayfield UI統合スクリプト - Multiplier Update ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- サービス & 基本設定
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Functions = Shared:WaitForChild("Functions")

local Window = Rayfield:CreateWindow({
   Name = "Energy Tycoon: Collection Multiplier",
   LoadingTitle = "Signal Forgery Init...",
   LoadingSubtitle = "Multiplier: Active",
   ConfigurationSaving = { Enabled = true, FolderName = "EnergyTycoon", FileName = "MultiConfig" },
   KeySystem = false
})

-- グローバル状態
local _G_Status = {
    AutoCollect = false,
    CollectMultiplier = 1, -- デフォルト倍率
    AutoTutorial = false,
}

-- ===== 🔨 メイン機能タブ =====
local MainTab = Window:CreateTab("⚡ 回収強化", 4483362458)

MainTab:CreateSection("信号偽装設定")

-- 倍率設定スライダー (2x - 10x)
local MultiplierSlider = MainTab:CreateSlider({
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

MainTab:CreateSection("実行")

-- 強化版自動回収トグル
local CollectToggle = MainTab:CreateToggle({
   Name = "多重信号自動回収 (Multi-Process)",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      _G_Status.AutoCollect = Value
      if Value then
         spawn(function()
            while _G_Status.AutoCollect do
               pcall(function()
                  local character = LocalPlayer.Character
                  if not character or not character.PrimaryPart then return end

                  -- Workspace内の自分のプロットにあるバッテリーを走査
                  for _, item in pairs(workspace:GetDescendants()) do
                     if item:IsA("Model") and item:GetAttribute("Owner") == LocalPlayer.Name then
                        -- バッテリー判定 (Filled属性があるもの)
                        local filled = item:GetAttribute("Filled")
                        
                        -- 少しでも溜まっていれば実行
                        if filled and filled > 0 and item.PrimaryPart then
                           
                           -- 【ここが変更点】設定された倍率分だけ信号を連打・偽装する
                           -- サーバーのDebounce(待機時間)の隙間を縫って複数のパケットを送信するイメージ
                           for i = 1, _G_Status.CollectMultiplier do
                              -- 0 (Touch開始)
                              firetouchinterest(character.PrimaryPart, item.PrimaryPart, 0)
                              -- わずかな遅延を入れることで信号かぶりを防ぎつつ連打（不要なら削除可）
                              -- task.wait() 
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
      end
   end,
})

-- ===== 🛠 その他タブ =====
local MiscTab = Window:CreateTab("🛠 その他", 4483362458)

MiscTab:CreateToggle({
   Name = "自動チュートリアル完了",
   CurrentValue = false,
   Flag = "AutoTutorial",
   Callback = function(Value)
      _G_Status.AutoTutorial = Value
      if Value then
         spawn(function()
            while _G_Status.AutoTutorial do
               pcall(function()
                  Functions.updateTutorialStep:InvokeServer(6)
               end)
               wait(2)
            end
         end)
      end
   end,
})

MiscTab:CreateButton({
   Name = "UIを閉じる",
   Callback = function()
      Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()

Rayfield:Notify({
   Title = "倍率モード適用完了",
   Content = "回収信号の多重送信が可能になりました。",
   Duration = 3,
   Image = 4483362458,
})
