-- [[ Rayfield UI統合スクリプト - V5 Stability Fix ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- サービス
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- フォルダ・コンフィグ確認
local Shared = ReplicatedStorage:WaitForChild("Shared", 10)
if not Shared then return warn("Critical Error: Shared folder not found.") end
local Configs = Shared:WaitForChild("Configs", 10)

-- コンフィグ読み込み（エラーハンドリング付き）
local BatteryConfig = {}
local WindmillConfig = {}

pcall(function()
    BatteryConfig = require(Configs:WaitForChild("Batteries")).Config
end)
pcall(function()
    WindmillConfig = require(Configs:WaitForChild("Windmills")).Config
end)

local Window = Rayfield:CreateWindow({
   Name = "Energy Tycoon: Fix V5",
   LoadingTitle = "Stabilizing Connection...",
   LoadingSubtitle = "Auto Collect Repair",
   ConfigurationSaving = { Enabled = true, FolderName = "EnergyTycoon", FileName = "FixV5" },
   KeySystem = false
})

-- グローバル変数
local _G_Status = {
    Active = false,
    Method = "Teleport", -- "Teleport" (物理) or "Signal" (信号)
    DebugMode = true,
}

-- ログ出力関数
local function DebugLog(msg)
    if _G_Status.DebugMode then
        print("[AutoFarm Debug]: " .. msg)
    end
end

-- 物理移動関数（Tweenを使用せず直接CFrame設定 + 待機）
local function TeleportCollect(targetPart)
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    local originalPos = char.PrimaryPart.CFrame
    
    -- ターゲットへ移動
    char:SetPrimaryPartCFrame(targetPart.CFrame)
    DebugLog("Teleported to: " .. targetPart.Parent.Name)
    
    -- サーバー認識待ち（重要）
    task.wait(0.15) 
    
    -- 信号も念のため送信
    if firetouchinterest then
        firetouchinterest(char.PrimaryPart, targetPart, 0)
        firetouchinterest(char.PrimaryPart, targetPart, 1)
    end
    
    -- 元の位置に戻る（オプション：視点が激しく動くのが嫌ならコメントアウト）
    -- char:SetPrimaryPartCFrame(originalPos)
end

-- 信号のみ送信関数
local function SignalCollect(targetPart)
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return end
    
    if firetouchinterest then
        firetouchinterest(char.PrimaryPart, targetPart, 0)
        firetouchinterest(char.PrimaryPart, targetPart, 1)
        DebugLog("Signal sent to: " .. targetPart.Parent.Name)
    else
        DebugLog("Error: firetouchinterest not supported on this executor.")
    end
end

-- ===== 🔨 メイン機能 =====
local MainTab = Window:CreateTab("🔨 修復版機能", 4483362458)

MainTab:CreateSection("状態確認")

MainTab:CreateLabel("現在、増殖機能は無効化しています。")
MainTab:CreateLabel("まずは基本回収が動くか確認してください。")

MainTab:CreateSection("回収設定")

MainTab:CreateDropdown({
   Name = "回収方法 (Method)",
   Options = {"Teleport", "Signal"},
   CurrentOption = {"Teleport"},
   MultipleOptions = false,
   Flag = "Method",
   Callback = function(Option)
      _G_Status.Method = Option[1]
   end,
})

MainTab:CreateToggle({
   Name = "自動回収開始 (Auto Collect)",
   CurrentValue = false,
   Flag = "Active",
   Callback = function(Value)
      _G_Status.Active = Value
      
      if Value then
         spawn(function()
            DebugLog("Started Auto Collect Loop")
            while _G_Status.Active do
               pcall(function()
                  local foundCount = 0
                  
                  -- Workspace走査
                  for _, item in pairs(workspace:GetDescendants()) do
                     if not _G_Status.Active then break end
                     
                     -- モデルかつオーナーが自分
                     if item:IsA("Model") and item:GetAttribute("Owner") == LocalPlayer.Name then
                        
                        local itemName = item:GetAttribute("Item")
                        local isTarget = false
                        
                        -- アイテム判定
                        if BatteryConfig[itemName] then
                             local filled = item:GetAttribute("Filled")
                             if filled and filled > 0 then isTarget = true end
                        elseif WindmillConfig[itemName] then
                             isTarget = true
                        end
                        
                        -- 実行
                        if isTarget and item.PrimaryPart then
                            foundCount = foundCount + 1
                            
                            if _G_Status.Method == "Teleport" then
                                TeleportCollect(item.PrimaryPart)
                            else
                                SignalCollect(item.PrimaryPart)
                            end
                            
                            -- 短い待機（早すぎるとサーバーに弾かれるため）
                            task.wait(0.1)
                        end
                     end
                  end
                  
                  if foundCount == 0 then
                      -- DebugLog("No targets found. Check owner attribute or item names.")
                  end
               end)
               task.wait(0.5) -- ループ全体の休憩
            end
            DebugLog("Stopped Auto Collect Loop")
         end)
      end
   end,
})

MainTab:CreateSection("デバッグ")

MainTab:CreateButton({
   Name = "F9コンソールでログを確認",
   Callback = function()
       Rayfield:Notify({Title="確認", Content="F9キーを押してログを見てください", Duration=3})
   end,
})

-- ===== ⚙️ 設定 =====
local MiscTab = Window:CreateTab("⚙️ 設定", 4483362458)
MiscTab:CreateButton({ Name = "UIを閉じる", Callback = function() Rayfield:Destroy() end })

Rayfield:LoadConfiguration()
