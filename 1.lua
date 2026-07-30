
-- ============================================================================
-- ULTIMATE MERGED BYPASS v3.0 - COMPLETE SECURITY DISABLEMENT
-- ============================================================================
local function nop() return true end
local function retFalse() return false end
local function retZero() return 0 end
local function retEmpty() return {} end
local function retNil() return nil end
local function retTrue() return true end
local function retEmptyString() return "" end

local function InitializeSLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then slua_serialize.check = retTrue; slua_serialize.verify = retTrue end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
    end)
end

local function InitializeMD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = retTrue; FileHashChecker.VerifyAll = retTrue
            FileHashChecker.GetHash = function() return "BYPASS" end
        end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then TssSdk.GetFileMD5 = function() return "BYPASS" end; TssSdk.VerifyFileSignature = retTrue end
        local STExtra = import("STExtraBlueprintFunctionLibrary")
        if STExtra then STExtra.CheckMD5 = retTrue; STExtra.GetMD5 = function() return "BYPASS" end; STExtra.VerifyFile = retTrue end
    end)
end

local function InitializeSkinBypass()
    pcall(function()
        local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if ptlog then ptlog.ReportEvent = nop; ptlog.ReportDownloadResult = nop; ptlog.ReportODPTDError = nop; ptlog.ReportSkinError = nop end
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then AvatarUtils.CheckIsWeaponInBlackList = retFalse; AvatarUtils.IsValidAvatar = retTrue; AvatarUtils.CheckAvatarIntegrity = retTrue; AvatarUtils.ReportInvalidAvatar = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("FileCheckSubsystem")
        if sub then sub.StartCheck = nop; sub.ReportAbnormalFile = nop; sub.StopCheck = nop end
        local eqEx = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
        if eqEx then eqEx.Report = nop; eqEx.SendException = nop end
    end)
end

local function InitializeLogBlocker()
    pcall(function()
        local SMTD = import("ScreenshotMTDer")
        if SMTD then SMTD.MTDePicture = function() return "" end; SMTD.ReMTDePicture = function() return "" end; SMTD.HasCaptured = retTrue; SMTD.TakeScreenshot = nop end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop; TLog.Debug = nop; TLog.Report = nop; TLog.Send = nop; TLog.Flush = nop end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then CrashSight.ReportException = nop; CrashSight.SetCustomData = nop; CrashSight.Log = nop; CrashSight.SendCrash = nop; CrashSight.ReportUserException = nop end
        local GRUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GRUtils then GRUtils.BugglyPostExceptionFull = retFalse; GRUtils.CheckCanBugglyPostException = retFalse; GRUtils.ReplayReportData = nop; GRUtils.ReportGameException = nop; GRUtils.PostException = nop end
        local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if CTR then CTR.SendReport = nop; CTR.SendException = nop; CTR.UploadLog = nop end
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]; if s then s.logEvent = nop; s.trackEvent = nop; s.setEnabled = retFalse; s.sendEvent = nop; s.report = nop end
        end
    end)
end

local function InitializeScannerBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local subs = {"AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem", "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"}
            for _, name in ipairs(subs) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect")) then pcall(function() sub[k] = nop end) end
                    end
                    if sub.ReportPingDelayTimer then sub:RemoveGameTimer(sub.ReportPingDelayTimer); sub.ReportPingDelayTimer = nil end; sub.DelayCount = 0
                end
            end
        end
        local AvaEx = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvaEx then AvaEx.CheckAvatarException = nop; AvaEx.CheckAvatarExceptionOnce = nop; AvaEx.ReportAvatarException = nop; AvaEx.CheckSlotMeshVisible = retFalse; AvaEx.CheckPawnVisible = retFalse; AvaEx.CheckCanBugglyPostException = retFalse end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local origData = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data) if type(data) == "string" and (data:find("report", 1, true) or data:find("exception", 1, true) or data:find("cheat", 1, true) or data:find("violation", 1, true) or data:find("hack", 1, true) or data:find("verify", 1, true)) then return end; if origData then origData(data) end end
            TssSdk.SendReportInfo = nop; TssSdk.ScanMemory = retTrue; TssSdk.IsEmulator = retFalse; TssSdk.GetTssSdkReportInfo = retEmptyString; TssSdk.CheckEnvironment = retTrue; TssSdk.VerifyProcess = retTrue
        end
    end)
end

local function InitializeReplayTelemetryBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            for _, name in ipairs({"GameReportSubsystem", "ReplaySubsystem"}) do
                local sub = SubMgr:Get(name)
                if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Trace") or k:find("Replay") or k:find("Record") or k:find("Save")) then pcall(function() sub[k] = nop end) end end end
            end
        end
        local logRep = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logRep then logRep.ReportReplay = nop; logRep.SendReportReq = nop; logRep.UploadReplay = nop end
    end)
end

local function InitializeReportFlowBlocker()
    pcall(function()
        local flows = {"ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "ReportCircleFlow", "ReportSecMrpcsFlow"}
        for _, f in ipairs(flows) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        for _, f in ipairs({"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}) do if _G[f] then _G[f] = retFalse end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = retFalse end end
        for _, f in ipairs({"IsEnableReportMrpcsInCircleFlow", "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow", "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"}) do if _G[f] then _G[f] = retFalse end end
    end)
end

local function InitializePlayerSecurityBypass()
    pcall(function()
        for _, c in ipairs({"PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector", "ClientSecurityCollector", "PlayerAntiCheatCollector"}) do
            if _G[c] then for k, v in pairs(_G[c]) do if type(v) == "function" and (k:find("Report") or k:find("Collect") or k:find("Send") or k:find("Upload") or k:find("Record")) then _G[c][k] = nop end end end
        end
        local SecSub = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecSub then SecSub.ReportData = nop; SecSub.CheckCheat = retFalse; SecSub.ValidatePlayer = retTrue; SecSub.CollectData = nop; SecSub.SendToServer = nop end
    end)
end

local function InitializeClientFlowBypass()
    pcall(function()
        for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}) do
            local sub = package.loaded[name] or _G[name]
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Flow") or k:find("Record") or k:find("Process")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

local function InitializeSwiftHawkBypass()
    pcall(function()
        for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
        if sub then sub.ReportData = nop; sub.SendReport = nop; sub.CollectTelemetry = nop end
    end)
end

local function InitializeCoronaLabBypass()
    pcall(function()
        if _G.CoronaLab then _G.CoronaLab.ReportData = nop; _G.CoronaLab.SendData = nop; _G.CoronaLab.CollectData = nop; _G.CoronaLab.Telemetry = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("CoronaLabSubsystem")
        if sub then sub.ReportData = nop; sub.SendToServer = nop; sub.CollectTelemetry = nop; sub.StopCollection = nop end
    end)
end

local function InitializeModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then _G.bReportedModifierException = false end
        local sub = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if sub then sub.ReportException = nop; sub.CheckModifier = retTrue; sub.ValidateModifier = retTrue; sub.ReportModifierError = nop end
    end)
end

local function InitializeSimulateCharacterLocationBypass()
    pcall(function()
        local sub = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if sub then sub.ReportLocation = nop; sub.SendLocationData = nop; sub.VerifyLocation = retTrue end
    end)
end

local function InitializeShootVerificationBypass()
    pcall(function()
        local sub = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if sub then sub.OnShootVerifyFailed = nop; sub.SendVerifyData = nop; sub.ReportBulletHit = nop; sub.UploadHitInfo = nop; sub.VerifyShot = retTrue end
        if _G.BulletHitInfoUploadData then _G.BulletHitInfoUploadData.Report = nop; _G.BulletHitInfoUploadData.Send = nop; _G.BulletHitInfoUploadData.Upload = nop end
    end)
end

local function InitializeNetworkPacketBlock()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local orig = NetUtil.SendPacket
            local blocked = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1, ["ReportSecVehicleMoveFlow"]=1,
                ["report_parachute_data"]=1, ["on_tss_sdk_anti_data"]=1, ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_net_saturate"]=1, ["report_speed_hack"]=1, ["report_wall_hack"]=1, ["report_aim_bot"]=1, ["report_esp_usage"]=1,
                ["report_modded_files"]=1, ["detect_cheat"]=1, ["ban_player"]=1, ["client_anti_cheat_report"]=1,
                ["ClientSecMrpcsFlow"]=1, ["MrpcsData"]=1, ["CheckReportSecAttackFlow"]=1, ["CheckReportSecAttackFlowWithAttackFlow"]=1, ["RPC_ClientCoronaLab"]=1,
                ["CoronaLabReport"]=1, ["CoronaLabData"]=1, ["PlayerSecurityInfo"]=1, ["ReportSecurityInfo"]=1, ["SendSecurityData"]=1, ["ClientCircleFlow"]=1,
                ["IsEnableReportMrpcsInCircleFlow"]=1, ["IsEnableReportMrpcsInPartCircleFlow"]=1, ["bReportedModifierException"]=1,
                ["ReportModifierException"]=1, ["RPC_Server_ReportSimulateCharacterLocation"]=1, ["ReportSimulateCharacterLocation"]=1, ["RPC_Client_ShootVertifyRes"]=1,
                ["BulletHitInfoUploadData"]=1, ["ShootVerifyFailed"]=1, ["report_unrealnet_exception"]=1, ["tss_sdk_report"]=1, ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["ClientSwiftHawkWithParams"]=1, ["SwiftHawkReport"]=1, ["SwiftHawkData"]=1,
                ["AntiCheatReport"]=1, ["CheatDetection"]=1, ["ViolationReport"]=1, ["SecurityViolation"]=1, ["IntegrityCheck"]=1, ["SignatureVerify"]=1
            }
            NetUtil.SendPacket = function(packetName, ...) if blocked[packetName] then return nil end; return orig(packetName, ...) end
            NetUtil.IsBypassed = true
        end
        if _G.SendRPC then
            local origRPC = _G.SendRPC
            local blockedRPC = {"RPC_Server_ClientSecMrpcsFlow", "RPC_Server_SwiftHawk", "RPC_Server_ClientSwiftHawkWithParams", "RPC_Server_ReportSimulateCharacterLocation", "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab"}
            _G.SendRPC = function(rpcName, ...) for _, b in ipairs(blockedRPC) do if rpcName == b then return nil end end; return origRPC(rpcName, ...) end
        end
    end)
end

local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            for _, m in ipairs({"ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck", "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord", "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev", "RPC_Client_ShootVertifyRes", "RPC_Server_ReportSimulateCharacterLocation", "DisableHiggsBoson", "CheckMHActive", "ReportViolation", "ProcessSecurityEvent", "ValidatePlayer", "CheckIntegrity"}) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmpty; Higgs.GetCurWeaponSkinID = retZero; Higgs.IsMHActive = retFalse; Higgs.bMHActive = false; Higgs.bCallPreReplication = false
            if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
        end
        _G.BlackList = {}
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false; if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false; pc.HiggsBosonComponent:ControlMHActive(0) end
        end
    end)
end

local function InitializeAntiCheatHooks()
    pcall(function()
        local HBC = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HBC and HBC.StaticShowSecurityAlertInDev then HBC.StaticShowSecurityAlertInDev = nop end
    end)
    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = nop; _G.AvatarCheckCallback.OnReportItemID = nop
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
            if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then PlayerController.HiggsBosonComponent:ControlMHActive(0); PlayerController.HiggsBosonComponent.bMHActive = false end
        end
    end
end

local function InitializeAntiReport()
    pcall(function()
        for _, path in ipairs({"GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem", "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"}) do
            local sub = package.loaded[path]; if not sub then local s, r = pcall(require, path); if s and r then sub = r end end
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Record") or k:find("Send") or k:find("Upload") or k:find("Notify")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        local reports = {"ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"}
        for _, f in ipairs(reports) do GC[f] = nop end
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse; GC.CheckReportSecAttackFlow = retFalse
        local origState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
            local s = State and string.lower(tostring(State)) or ""
            local blocked = {["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1, ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1, ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1, ["integrityfailure"]=1, ["securityviolation"]=1}
            if blocked[s] then return end
            if origState then pcall(origState, UID, State, bPure, bSafe, Param) end
        end
        GC.OnPlayerNetConnectionClosed = nop; GC.OnPlayerActorChannelError = nop; GC.OnPlayerRPCValidateFailed = nop; GC.OnPlayerSpectateException = nop; GC.OnShutdownAfterError = nop; GC.IsBypassed = true
    end)
end

local function InitializeKillAllSubsystems()
    pcall(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local toKill = {"CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem", "PakVerifySubsystem"}
        for _, name in ipairs(toKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect") or k:find("Collect") or k:find("Flow") or k:find("Heartbeat")) then pcall(function() sub[k] = nop end) end end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
    end)
end

local function InitializeFinalProtection()
    pcall(function()
        for _, flag in ipairs({"ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"}) do if _G[flag] then _G[flag] = false end end
        local origReq = require
        local blocked = {"HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"}
        _G.require = function(m) for _, b in ipairs(blocked) do if m:find(b) then return {} end end; return origReq(m) end
    end)
end

_G.StartBypass_VIP_v3 = function()
    pcall(function()
        print("[ULTIMATE BYPASS] Starting initialization...")
        InitializeSLUABypass()
        InitializeMD5Bypass()
        InitializeSkinBypass()
        InitializeLogBlocker()
        InitializeScannerBlocker()
        InitializeReplayTelemetryBlocker()
        InitializeReportFlowBlocker()
        InitializePlayerSecurityBypass()
        InitializeClientFlowBypass()
        InitializeSwiftHawkBypass()
        InitializeCoronaLabBypass()
        InitializeModifierExceptionBypass()
        InitializeSimulateCharacterLocationBypass()
        InitializeShootVerificationBypass()
        InitializeNetworkPacketBlock()
        InitializeHiggsBosonBypass()
        InitializeAntiCheatHooks()
        InitializeAntiReport()
        InitializeGameplayBypass()
        InitializeKillAllSubsystems()
        InitializeFinalProtection()
        print("[ULTIMATE BYPASS] Complete - All Security Systems Disabled")
    end)
end

local function Notify(msg) local s = "[R6gaming VIP New] " .. tostring(msg)
    pcall(function() if _G.R6gamingNotify then _G.R6gamingNotify(s) end end)
    pcall(function() local sh = import("ScriptHelperClient") if sh and
            sh.AddOnScreenDebugMessage then sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=1,
                G=1, B=0, A=1}, {X=1.2, Y=1.2}) end end) print(s) end

local _slua = rawget(_G, "slua")

local function Valid(obj) if not obj then return false end if _slua and
        _slua.isValid then local ok, v = pcall(_slua.isValid, obj) if not ok or not v
            then return false end end return true end


-- ==========================================
-- STATIC VARIABLES & GLOBAL CACHE OPTIMIZED (LAG-FREE)
-- ==========================================
local C_GREEN = {R=0, G=255, B=0, A=255}
local C_RED = {R=255, G=0, B=0, A=255}
local C_CYAN = {R=0, G=255, B=255, A=255}
local C_YELLOW = {R=255, G=255, B=0, A=255}
local C_WHITE = {R=255, G=255, B=255, A=255}
local C_BLUE_TEXT = {R=0, G=200, B=255, A=255}

local GLOBAL_BONE_LIST = {
    "head", "neck_01", "pelvis",
    "upperarm_r", "lowerarm_r", "hand_r",
    "upperarm_l", "lowerarm_l", "hand_l",
    "thigh_l", "calf_l", "foot_l",
    "thigh_r", "calf_r", "foot_r"
}

-- ===== 7 WARNA UNTUK PILIHAN =====
local COLOR_PALETTE_7 = {
    [1] = {R=255, G=0, B=0, A=255}, -- Red
    [2] = {R=255, G=255, B=255, A=255}, -- White
    [3] = {R=255, G=255, B=0, A=255}, -- Yellow
    [4] = {R=0, G=255, B=0, A=255}, -- Green
    [5] = {R=0, G=255, B=255, A=255}, -- Cyan
    [6] = {R=0, G=0, B=255, A=255}, -- Blue
    [7] = {R=255, G=0, B=255, A=255}, -- Purple
}

local function GetColorBy7(idx)
    if not idx or idx < 1 or idx > 7 then idx = 4 end
    return COLOR_PALETTE_7[idx] or {R=0, G=255, B=0, A=255}
end

-- ==========================================
-- R6gaming CORE + FULL FEATURES VIP CONFIGURATION
-- ==========================================
_G.R6gamingConfig = _G.R6gamingConfig or {
    AutoHead = false,
    EspVip = false,
    EspDistance = false,
    EspVipPro = false,
    EspRadar = false,
    Esp5 = false,
    Esp6 = false,
    Esp7 = false,
    Esp8 = false,
    EspAntenna = false,
    EspName = false,
    EspOutline = false,
    OutlineThickness = 10,
    UnlockFPS = false,
    IpadView = false,
    CustomAimbot = false,
    CustomAimbotClose = false,
    LessShake = false,
    Crosshair = false,
    Accuracy = false,
    NoShake = false,
    AntiOverheadScopeAll = false,
    

    -- ... config lain ...
    EspLoai7 = false,
    Esp7_SoLuong = true,  -- Mặc định BẬT (true)
    Esp7_VuKhi = true,    -- Mặc định BẬT (true)
    Esp7_TuThe = true,    -- Mặc định BẬT (true)
    -- ... config lain ...


    -- New Configuration for Aimbot V2 (Aim Touch)
    AimTouchEnable = false,
    AimTouchHipIgKnock = false,
    AimTouchHipIgBot = false,
    AimTouchSGIgKnock = false,
    AimTouchSGIgBot = false,
    AimTouchHipVisCheck = false,
    AimTouchSGVisCheck = false,
    AimTouchHipfire = false,
    AimTouchSG = false,
    AimTouchSGAutoFire = false,
    AimTouchScopeAll = false,
    AimTouchScopeIgKnock = false,
    AimTouchScopeIgBot = false,
    AimTouchScopeVisCheck = false,
    AimTouchScopeSniper = false,
    AimTouchSniperIgKnock = false,
    AimTouchSniperIgBot = false,
    AimTouchSniperVisCheck = false,

    -- Skin Mod (LUCI VERSION + Kill Counter)
    ModSkin = false,
    Skin1Enabled = false, -- SUIT / HELM / BAG
    Skin2Enabled = false, -- WEAPON
    Skin3Enabled = false, -- VEHICLE
    DeadboxEnabled = false,
    KillCounterEnabled = false, -- Kill Counter di Skin

    -- ESP Throwable
    ThrowableEnabled = false,
    ThrowableGrenade = false,
    ThrowableSmoke = false,
    ThrowableMolotov = false,
    ThrowableColor_Grenade = 4, -- default Green
    ThrowableColor_Smoke = 4,
    ThrowableColor_Molotov = 4,
    ThrowableScanMode = 0, -- 0=Always, 5=5s, 10=10s



    -- ESP Loot
    EspLoot = false,
    LootShowM416 = false,
    LootShowAUG = false,
    LootShowAKM = false,
    LootShowM24 = false,
    LootShowUMP = false,
    LootShowDBS = false,
    LootShowS12K = false,
    LootShowVest3 = false,
    LootShowHelmet3 = false,
    LootShowBag3 = false,
    LootColor_M416 = 4,
    LootColor_AUG = 4,
    LootColor_AKM = 4,
    LootColor_M24 = 4,
    LootColor_UMP = 4,
    LootColor_DBS = 4,
    LootColor_S12K = 4,
    LootColor_Vest3 = 4,
    LootColor_Helmet3 = 4,
    LootColor_Bag3 = 4,
    LootScanMode = 0, -- 0=Always, 5=5s, 10=10s

    -- ESP STATIC (ESP Count)
    EspStatic = false,
    EspEnemyCount = true,
    EspWeaponStatus = true,



    -- BlackSky menggunakan r.CylinderMaxDrawHeight
    BlackSky = false,
}

-- STATE
_G.R6gamingState = _G.R6gamingState or {
    LoopToken = 0,
    AimbotLoopToken = 0,
    NativeESPReady = false,
    GraphicsUnlocked = false,
    MenuStep = 0,
    LastCmdTime = 0,
    TrackedMarks = {},
    EnemyMarks = {},
    LastAimbotCheckTime = 0,
    CustomTextData = nil,
    LastAimbotConfigString = "",
    MagicUpdateVersion = 1,
    LastMagicConfigHash = "",
    PrevGraphicsState = {},
    SkinWasApplied = false,
    DeadboxDelay = 2.0,
    LastLootScanTime = 0,
    LastThrowableScanTime = 0,
}

local limitTime = os.time({ year = 2027, month = 10, day = 1, hour = 23, min = 59, sec = 0 })
local currentTime = os.time(os.date("!*t"))
local isExpired = false

pcall(function()
    local fileName = ".sys_time_cache"
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
        "../../ShadowTrackerExtra/Saved/SaveGames/" .. fileName,
    }

    local tm = package.loaded["client.logic.common.TimeManager"]
    if not tm then
        local s, r = pcall(require, "client.logic.common.TimeManager")
        if s and r then tm = r end
    end
    if tm and type(tm.GetServerTime) == "function" then
        local serverTime = tm.GetServerTime()
        if serverTime and serverTime > 1700000000 then
            currentTime = serverTime
        end
    end

    local lastSeenTime = 0
    for _, path in ipairs(paths) do
        local file = io.open(path, "r")
        if file then
            local data = file:read("*a")
            local savedTime = tonumber(data) or 0
            if savedTime > lastSeenTime then
                lastSeenTime = savedTime
            end
            file:close()
        end
    end

    if currentTime < lastSeenTime then
        currentTime = lastSeenTime
      else
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(tostring(currentTime))
                file:close()
            end
        end
    end
end)

isExpired = (currentTime > limitTime)

-- ==========================================
-- MAP MARK CLEANUP MANAGEMENT FUNCTION (ANTI-LAG/FAKE DISPLAY WHEN ENEMY DIES)
-- ==========================================
local function SafeAddMark(id, pos, z, str, size, actor)
    local mark = nil
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.ClientAddMapMark then
            mark = InGameMarkTools.ClientAddMapMark(id, pos, z, str, size, actor)
            if mark then _G.R6gamingState.TrackedMarks[mark] = true end
        end
    end)
    return mark
end

local function SafeRemoveMark(mark)
    if not mark then return end
    pcall(function()
        local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")
        if InGameMarkTools and InGameMarkTools.HideMapMark then
            InGameMarkTools.HideMapMark(mark)
        end
        if InGameMarkTools and InGameMarkTools.RemoveMapMark then
            InGameMarkTools.RemoveMapMark(mark)
        end
    end)
    _G.R6gamingState.TrackedMarks[mark] = nil
end

-- ==========================================
-- CREATE A UNIQUE AND PERMANENT ID FOR EACH ENEMY (FIXED LAG ISSUES WHEN SLUA CREATES NEW WRAPPERS)
-- ==========================================
local function GetSafeEnemyKey(enemy)
    if Valid(enemy) then
        if enemy.PlayerKey then return tostring(enemy.PlayerKey) end
        if type(enemy.GetUniqueID) == "function" then return tostring(enemy:GetUniqueID()) end
    end
    return tostring(enemy)
end

-- ==========================================
-- AI (BOT) / REAL PLAYER - OPTIMIZED TEST
-- ==========================================
local function CheckIsAI(pawn, markData)
    if markData.AK_IS_BOT ~= nil then return markData.AK_IS_BOT, true end

    local isAI = false
    local hasChecked = false
    pcall(function()
        if pawn.bIsAI == true or pawn.IsAI == true then isAI = true; hasChecked = true end
        if type(pawn.IsBot) == "function" and pawn:IsBot() then isAI = true; hasChecked = true end

        local pState = pawn.PlayerState or (type(pawn.GetPlayerState) == "function" and pawn:GetPlayerState())
        if Valid(pState) then
            hasChecked = true
            if pState.bIsABot == true or pState.bIsBot == true then isAI = true end
            if type(pState.IsBot) == "function" and pState:IsBot() then isAI = true end
        end

        if not isAI then
            local name = pawn.PlayerName or (type(pawn.GetPlayerName) == "function" and pawn:GetPlayerName()) or ""
            if name ~= "" and (name:find("Cobra") or name:find("Target") or name:find("bot_") or name:find("b_")) then
                isAI = true
                hasChecked = true
            end
        end
    end)
    if hasChecked then markData.AK_IS_BOT = isAI end
    return isAI, hasChecked
end

-- ==========================================
-- INITIALIZES AUTO HEAD HOOKS FOR DAMAGE
-- ==========================================
function _G.InitializeAutoHeadHooks()
    pcall(function()
        local EAvatarDamagePosition = import("EAvatarDamagePosition")
        if not EAvatarDamagePosition then return end

        local modulesToHook = {
            "GameLua.Mod.BaseMod.Common.Weapon.ShootWeaponEntity",
            "GameLua.Logic.Weapon.ShootWeaponEntity"
        }

        for _, path in ipairs(modulesToHook) do
            local hitLogic = package.loaded[path]
            if hitLogic then
                local original_GetHitBodyType = hitLogic.GetHitBodyType
                hitLogic.GetHitBodyType = function(self, ImpactResult, InImpactVec)
                    if _G.R6gamingConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyType then return original_GetHitBodyType(self, ImpactResult, InImpactVec) end
                end

                local original_GetHitBodyTypeByHitPos = hitLogic.GetHitBodyTypeByHitPos
                hitLogic.GetHitBodyTypeByHitPos = function(self, InImpactVec)
                    if _G.R6gamingConfig.AutoHead then return EAvatarDamagePosition.BigHead end
                    if original_GetHitBodyTypeByHitPos then return original_GetHitBodyTypeByHitPos(self, InImpactVec) end
                end
            end
        end
    end)
end


-- ==========================================
-- COLOR CONFIGURATION FOR ESP HEALTH, ESP NAME, AND WALLHACK (7 warna)
-- ==========================================
if _G.ColorConfig == nil then
    _G.ColorConfig = {
        VisibleColor = 4, -- default Green
        InvisibleColor = 1, -- default Red
        Brightness = 25,
        Glow = 3.0,
    }
end

local COLOR_MAP_7 = {
    [1] = {R=255, G=0, B=0},
    [2] = {R=255, G=255, B=255},
    [3] = {R=255, G=255, B=0},
    [4] = {R=0, G=255, B=0},
    [5] = {R=0, G=255, B=255},
    [6] = {R=0, G=0, B=255},
    [7] = {R=255, G=0, B=255}
}

local function GetAppliedColor(colorIdx, brightness)
    local base = COLOR_MAP_7[colorIdx] or COLOR_MAP_7[4]
    local b = brightness or _G.ColorConfig.Brightness or 25
    return {
        R = math.min(255, (base.R or 0) * b / 25),
        G = math.min(255, (base.G or 0) * b / 25),
        B = math.min(255, (base.B or 0) * b / 25),
        A = 255
    }
end

---------------------------------------------------------------------------


-- ==========================================
-- AUTOMATIC VIP MENU STORAGE AND LOADING SYSTEM (FIXED - BACA DARI PAKS)
-- ==========================================
local function GetConfigPaths(fileName)
    local paths = {
        "//storage/emulated/0/Android/data/com.tencent.ig/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "//storage/emulated/0/Android/data/com.pubg.krmobile/files/UE4Game/ShadowTrackerExtra/ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "ShadowTrackerExtra/Saved/Paks/" .. fileName,
        "../../ShadowTrackerExtra/Saved/Paks/" .. fileName,
        fileName
    }
    return paths
end

local ConfigFileName = "R6gaming_settings.txt"
_G.LastConfigSaveStr = ""

-- ===== FUNGSI SERIALISASI REKURSIF UNTUK MENANGANI TABEL BERSARANG =====
local function serializeValue(val)
    if val == nil then
        return "nil"
      elseif type(val) == "string" then
        return string.format("%q", val)
      elseif type(val) == "number" or type(val) == "boolean" then
        return tostring(val)
      elseif type(val) == "table" then
        local items = {}
        for k, v in pairs(val) do
            local keyStr
            if type(k) == "string" then
                keyStr = string.format("[%q]", k)
              elseif type(k) == "number" then
                keyStr = "[" .. tostring(k) .. "]"
              else
                keyStr = "[" .. tostring(k) .. "]"
            end
            table.insert(items, keyStr .. " = " .. serializeValue(v))
        end
        return "{" .. table.concat(items, ", ") .. "}"
      else
        return "nil"
    end
end

-- ===== SAVE DENGAN SERIALISASI REKURSIF =====
_G.SaveModSettings = function()
    pcall(function()
        local data = "return {\nR6gamingConfig = {\n"
        for k, v in pairs(_G.R6gamingConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. serializeValue(v) .. ",\n"
        end
        data = data .. "},\nCustomTextData = {\n"
        if _G.R6gamingState and _G.R6gamingState.CustomTextData then
            for k, v in pairs(_G.R6gamingState.CustomTextData) do
                data = data .. "  [\"" .. tostring(k) .. "\"] = " .. serializeValue(v) .. ",\n"
            end
        end
        data = data .. "},\nColorConfig = {\n"
        for k, v in pairs(_G.ColorConfig or {}) do
            data = data .. "  [\"" .. tostring(k) .. "\"] = " .. serializeValue(v) .. ",\n"
        end
        data = data .. "}\n}"

        if data == _G.LastConfigSaveStr then return end
        _G.LastConfigSaveStr = data

        local paths = GetConfigPaths(ConfigFileName)
        for _, path in ipairs(paths) do
            local file = io.open(path, "w")
            if file then
                file:write(data)
                file:close()
                break
            end
        end
    end)
end

-- ===== LOAD TETAP MENGGUNAKAN load (SUDAH BISA MEMBACA FORMAT REKURSIF) =====
_G.LoadModSettings = function()
    pcall(function()
        local paths = GetConfigPaths(ConfigFileName)
        local content = nil
        for _, path in ipairs(paths) do
            local file = io.open(path, "r")
            if file then
                content = file:read("*a")
                file:close()
                break
            end
        end

        if content then
            local func = load(content)
            if func then
                local savedData = func()
                if savedData and type(savedData) == "table" then
                    if savedData.R6gamingConfig then
                        for k, v in pairs(savedData.R6gamingConfig) do
                            _G.R6gamingConfig[k] = v
                        end
                    end
                    if savedData.CustomTextData then
                        _G.R6gamingState.CustomTextData = _G.R6gamingState.CustomTextData or {}
                        for k, v in pairs(savedData.CustomTextData) do
                            _G.R6gamingState.CustomTextData[k] = v
                        end
                    end
                    if savedData.ColorConfig then
                        for k, v in pairs(savedData.ColorConfig) do
                            _G.ColorConfig[k] = v
                        end
                    end
                end
            end
        end
        _G.SaveModSettings()
    end)
end

-- ===== AUTO SAVE LOOP =====
local function AutoSaveLoop()
    pcall(function() if _G.SaveModSettings then _G.SaveModSettings() end end)
    pcall(function()
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(3.0, AutoSaveLoop)
        end
    end)
end

if not _G.ModConfigLoaded then
    _G.LoadModSettings()
    AutoSaveLoop()
    _G.ModConfigLoaded = true
end

_G.ReadLiveConfig = function()
    if _G.SaveModSettings then _G.SaveModSettings() end
end

-- ==========================================
-- SKIN MOD SYSTEM (FULL LUCI VERSION + KILL COUNTER)
-- ==========================================
_G.VIP_Attachments = {
    [1101004236]={1010042307,1010042306,1010042308,1010042304,1010042300,1010042305,1010042299,1010042298,1010042297,1010042296,1010042295,1010042294,0,1010042314,1010042309,1010042316,1010042317,1010042318,1010042310,1010042315,1010042319,0},
    [1101001116]={1010011106,1010011107,1010011108,0,1010011109,1010011112,1010011105,1010011104,1010011103,0,1010011102,0,0,0,0,0,0,0,0,0,0,0},
    [1101001128]={1010011232,1010011233,1010011234,1010011228,1010011227,1010011229,1010011226,1010011225,1010011224,1010011223,1010011222,0,0,0,0,0,0,0,0,0,0,0},
    [1101001154]={1010011487,1010011488,1010011489,1010011493,1010011490,1010011494,1010011486,1010011485,1010011484,1010011483,1010011482,1010011497,0,0,0,0,0,0,0,0,1010011498,0},
    [1101001174]={1010011667,1010011668,1010011669,1010011673,1010011670,1010011674,1010011666,1010011665,1010011664,1010011663,1010011662,0,0,0,0,0,0,0,0,0,0,0},
    [1101001213]={1010012067,1010012068,1010012069,1010012072,1010012070,1010012073,1010012066,1010012065,1010012064,1010012063,1010012062,0,0,0,0,0,0,0,0,0,1010012074,0},
    [1101001231]={1010012267,1010012268,1010012269,1010012273,1010012272,1010012274,1010012266,1010012265,1010012264,1010012263,1010012262,1010012075,0,0,0,0,0,0,0,0,1010012275,0},
    [1101001242]={1010012357,1010012358,1010012359,1010012363,1010012362,1010012364,1010012356,1010012355,1010012354,1010012353,1010012352,1010012276,0,0,0,0,0,0,0,0,1010012365,0},
    [1101001249]={1010012437,1010012438,1010012439,1010012443,1010012442,1010012444,1010012436,1010012435,1010012434,1010012433,1010012432,1010012366,0,0,0,0,0,0,0,0,1010012445,0},
    [1101001256]={1010012588,1010012589,1010012590,1010012593,1010012592,1010012594,1010012587,1010012586,1010012585,1010012584,1010012583,1010012582,0,0,0,0,0,0,0,0,1010012595,0},
    [1101001265]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101001276]={1010012698,1010012699,1010012700,1010012703,1010012702,1010012704,1010012697,1010012696,1010012695,1010012694,1010012693,1010012692,0,0,0,0,0,0,0,0,1010012705,0},
    [1101002029]={1010020249,1010020250,1010020255,1010020247,1010020246,1010020248,1010020240,1010020239,1010020238,1010020237,1010020236,1010020235,0,0,0,0,0,0,0,1010020257,1010020256,1010020258},
    [1101002056]={1010020519,0,0,1010020517,1010020516,1010020518,1010020500,1010020509,1010020508,1010020507,1010020506,1010020505,0,0,0,0,0,0,0,0,0,0},
    [1101002081]={1010020768,1010020769,1010020770,1010020766,1010020760,1010020767,1010020759,1010020758,1010020757,1010020756,1010020755,1010020776,0,0,0,0,0,0,0,1010020775,1010020777,1010020778},
    [1101003070]={1010030654,1010030653,1010030655,1010030649,1010030648,1010030650,1010030647,1010030646,1010030645,1010030644,1010030643,1010030642,0,1010030658,1010030656,1010030660,1010030662,1010030659,1010030657,0,1010030663,0},
    [1101003080]={1010030754,1010030753,1010030755,1010030749,1010030748,1010030750,1010030747,1010030746,1010030745,1010030744,1010030743,1010030742,0,1010030758,1010030756,1010030760,1010030762,1010030759,1010030757,0,1010030763,0},
    [1101003099]={1010030943,1010030944,1010030945,1010030939,1010030938,1010030942,1010030937,1010030936,1010030935,1010030934,1010030933,1010030932,0,1010030947,1010030946,1010030948,1010030949,1010030953,1010030952,0,1010030955,0},
    [1101003119]={1010031139,1010031140,1010031142,1010031138,1010031137,1010031146,1010031136,1010031135,1010031134,1010031133,1010031132,0,0,1010031144,1010031143,0,0,0,1010031145,0,0,0},
    [1101003146]={1010031229,1010031230,1010031237,1010031228,1010031227,1010031242,1010031226,1010031225,1010031224,1010031223,1010031222,0,0,1010031239,1010031238,0,0,0,1010031240,0,0,0},
    [1101003167]={1010031609,1010031610,1010031613,1010031608,1010031607,1010031617,1010031606,1010031605,1010031604,1010031603,1010031602,1010031618,0,1010031615,1010031614,1010031620,1010031622,1010031619,1010031616,0,1010031623,0},
    [1101003181]={1010031765,1010031764,1010031766,1010031759,1010031758,1010031763,1010031757,1010031756,1010031755,1010031754,1010031753,1010031752,0,1010031769,1010031767,1010031773,1010031774,1010031772,1010031768,0,1010031775,0},
    [1101003195]={1010031912,1010031911,1010031913,1010031908,1010031907,1010031909,1010031906,1010031905,1010031904,1010031903,1010031902,1010031901,0,1010031916,1010031914,1010031918,1010031919,1010031917,1010031915,0,1010031921,0},
    [1101003208]={1010032034,1010032033,1010032045,1010032029,1010032028,1010032032,1010032027,1010032026,1010032025,1010032024,1010032023,1010032022,0,1010032038,1010032036,1010032042,1010032043,1010032039,1010032037,0,1010032044,0},
    [1101004046]={1010040474,1010040475,1010040476,1010040472,1010040471,1010040473,1010040470,1010040469,1010040468,1010040467,1010040466,1010040481,0,1010040479,1010040477,1010040482,1010040483,1010040484,1010040478,1010040480,1010040485,0},
    [1101004062]={1010040578,1010040577,1010040579,1010040575,1010040570,1010040576,1010040569,1010040568,1010040567,1010040566,1010040565,1010040564,0,1010040585,1010040580,1010040587,1010040588,1010040589,1010040584,1010040586,1010040590,1010040594},
    [1101004098]={1010040924,1010040926,1010040925,0,1010040937,1010040938,1010040935,1010040934,1010040929,1010040928,1010040927,0,0,1010040939,1010040945,0,0,0,1010040944,1010040936,0,0},
    [1101004138]={1010041136,1010041137,1010041138,1010041134,1010041129,1010041135,1010041128,1010041127,1010041126,1010041125,1010041124,0,0,1010041145,1010041139,0,0,0,1010041144,1010041146,0,0},
    [1101004163]={1010041570,1010041574,1010041575,1010041568,1010041567,1010041569,1010041566,1010041565,1010041564,1010041560,1010041554,0,0,1010041578,1010041576,0,0,0,1010041577,1010041579,0,0},
    [1101004201]={1010041956,1010041957,1010041958,1010041950,1010041949,1010041955,1010041948,1010041947,1010041946,1010041945,1010041944,1010041967,0,1010041965,1010041959,0,0,0,1010041960,1010041966,0,0},
    [1101004209]={1010042038,1010042037,1010042039,1010042035,1010042034,1010042036,1010042029,1010042028,1010042027,1010042026,1010042025,1010042024,0,1010042046,1010042044,1010042048,1010042049,1010042054,1010042045,1010042047,1010042055,0},
    [1101004218]={1010042128,1010042127,1010042129,1010042125,1010042124,1010042126,1010042119,1010042118,1010042117,1010042116,1010042115,1010042114,0,1010042136,1010042134,1010042138,1010042139,1010042144,1010042135,1010042137,1010042145,0},
    [1101004226]={1010042238,1010042237,1010042239,1010042235,1010042234,1010042236,1010042233,1010042232,1010042231,1010042219,1010042218,1010042217,0,1010042243,1010042241,1010042245,1010042246,1010042247,1010042242,1010042244,1010042248,0},
    [1101004246]={1010042406,1010042407,1010042408,1010042404,1010042400,1010042405,1010042399,1010042398,1010042397,1010042396,1010042395,1010042394,0,1010042414,1010042409,1010042416,1010042417,1010042418,1010042410,1010042415,1010042419,1010042420},
    [1101005038]={0,0,1010050327,1010050329,1010050328,1010050330,1010050326,1010050325,1010050324,1010050323,1010050322,1010050334,0,0,0,0,0,0,0,0,0,0},
    [1101005052]={0,0,1010050467,1010050469,1010050468,1010050470,1010050466,1010050465,1010050464,1010050463,1010050462,1010050473,0,0,0,0,0,0,0,0,0,0},
    [1101005098]={0,0,1010050928,1010050930,1010050929,1010050932,1010050927,1010050926,1010050925,1010050924,1010050923,1010050922,0,0,0,0,0,0,0,0,0,0},
    [1101006062]={1010060573,1010060572,1010060574,1010060564,1010060563,1010060571,1010060562,1010060561,1010060554,1010060553,1010060552,1010060551,0,1010060583,1010060581,1010060591,1010060592,1010060584,1010060582,0,1010060593,0},
    [1101006075]={1010060702,1010060701,1010060703,1010060698,1010060697,1010060699,1010060696,1010060695,1010060694,1010060693,1010060692,1010060691,0,1010060706,1010060704,1010060708,1010060709,1010060707,1010060705,0,1010060711,0},
    [1101006085]={1010060796,1010060795,1010060797,1010060793,1010060789,1010060794,1010060788,1010060787,1010060786,1010060785,1010060784,1010060783,0,1010060800,1010060798,1010060804,1010060805,1010060803,1010060799,0,1010060806,0},
    [1101007046]={1010070410,1010070413,1010070414,1010070408,1010070407,1010070409,1010070406,1010070405,1010070404,1010070403,1010070402,1010070418,0,1010070417,1010070415,1010070420,1010070422,1010070419,1010070416,0,1010070423,0},
    [1101007062]={1010070579,1010070578,1010070581,1010070576,1010070575,1010070577,1010070574,1010070573,1010070572,1010070571,1010070569,1010070568,0,1010070584,1010070582,1010070585,1010070586,1010070587,1010070583,0,1010070588,0},
    [1101007071]={1010070663,1010070662,1010070664,1010070659,1010070658,1010070660,1010070657,1010070656,1010070655,1010070654,1010070653,1010070652,0,1010070667,1010070665,1010070668,1010070669,1010070670,1010070666,0,1010070672,0},
    [1101008051]={1010080463,1010080464,1010080465,1010080459,1010080458,1010080462,1010080457,1010080456,1010080455,1010080454,1010080453,1010080452,0,1010080467,1010080466,1010080468,1010080469,1010080473,1010080472,0,1010080475,0},
    [1101008061]={1010080563,1010080564,1010080565,1010080559,1010080558,1010080562,1010080557,1010080556,1010080555,1010080554,1010080553,0,0,1010080567,1010080566,0,0,0,1010080572,0,0,0},
    [1101008070]={1010080609,1010080612,1010080613,1010080608,1010080607,1010080617,1010080606,1010080605,1010080604,1010080603,1010080602,0,0,1010080615,1010080614,0,0,0,1010080616,0,0,0},
    [1101008081]={1010080740,1010080743,1010080745,1010080738,1010080737,1010080739,1010080736,1010080735,1010080734,1010080733,1010080732,1010080748,0,1010080747,1010080746,1010080750,1010080752,1010080749,1010080744,0,1010080753,0},
    [1101008104]={1010080980,1010080982,1010080984,1010080978,1010080977,1010080979,1010080976,1010080975,1010080974,1010080973,1010080972,1010080992,0,1010080986,1010080985,1010080989,1010080987,1010080993,1010080983,0,1010080988,0},
    [1101008116]={1010081110,1010081112,1010081114,1010081108,1010081107,1010081109,1010081106,1010081105,1010081104,1010081103,1010081102,0,0,1010081116,1010081115,0,0,0,1010081113,0,0,0},
    [1101008126]={1010081210,1010081225,1010081226,1010081208,1010081207,1010081209,1010081206,1010081205,1010081204,1010081203,1010081202,1010081218,0,1010081217,1010081216,1010081219,1010081220,1010081222,1010081214,1010081228,1010081227,1010081229},
    [1101008136]={1010081314,1010081315,1010081316,1010081312,1010081308,1010081313,1010081307,1010081306,1010081305,1010081304,1010081303,1010081302,0,1010081318,1010081317,1010081322,1010081323,1010081325,1010081324,0,1010081326,0},
    [1101008146]={1010081401,1010081402,1010081403,1010081398,1010081397,1010081399,1010081396,1010081395,1010081394,1010081393,1010081392,1010081391,0,1010081405,1010081404,1010081406,1010081407,1010081409,1010081408,0,1010081411,0},
    [1101008154]={1010081531,1010081532,1010081533,1010081528,1010081527,1010081529,1010081526,1010081525,1010081524,1010081523,1010081522,1010081521,0,1010081541,1010081534,1010081542,1010081543,1010081545,1010081544,0,1010081546,0},
    [1101008163]={1010081582,1010081583,1010081584,1010081579,1010081578,1010081580,1010081577,1010081576,1010081575,1010081574,1010081573,1010081572,0,1010081586,1010081585,1010081587,1010081588,1010081590,1010081589,0,1010081592,0},
    [1101012033]={1010120284,1010120285,1010120286,1010120280,1010120279,1010120283,1010120278,1010120277,1010120276,1010120275,1010120274,1010120273,0,0,0,0,0,0,0,0,1010120287,0},
    [1101100012]={1011000066,1011000067,1011000068,0,0,0,1011000058,1011000057,1011000056,1011000055,1011000054,1011000053,0,0,0,0,0,0,0,0,1011000073,0},
    [1101102007]={1011010025,1011010024,1011010026,1011010020,1011010019,1011010023,1011010018,1011010017,1011010016,1011010015,1011010014,1011010013,0,0,0,0,0,0,0,0,1011010027,0},
    [1101102017]={1011020027,1011020028,1011020029,1011020025,1011020024,1011020026,1011020019,1011020018,1011020017,1011020016,1011020015,1011020014,0,1011020036,1011020034,1011020038,1011020039,1011020044,1011020035,1011020037,1011020045,1011020047},
    [1101102025]={1011020127,1011020128,1011020129,1011020125,1011020124,1011020126,1011020119,1011020118,1011020117,1011020116,1011020115,1011020114,0,1011020136,1011020134,1011020138,1011020139,1011020144,1011020135,1011020137,1011020145,0},
    [1101102041]={1011020214,1011020215,1011020216,1011020212,1011020211,1011020213,1011020209,1011020208,1011020207,1011020206,1011020205,1011020204,0,1011020219,1011020217,1011020222,1011020223,1011020224,1011020218,1011020221,1011020225,1011020229},
    [1101102049]={1011020356,1011020357,1011020358,1011020354,1011020350,1011020355,1011020349,1011020348,1011020347,1011020346,1011020345,1011020344,0,1011020364,1011020359,1011020366,1011020367,1011020368,1011020360,1011020365,1011020369,1011020370},
    [1101101007]={1011020436,1011020437,1011020438,1011020434,1011020430,1011020435,1011020429,1011020428,1011020427,1011020426,1011020425,1011020424,0,1011020444,1011020439,1011020446,1011020447,1011020448,1011020440,1011020445,1011020449,1011020450},
    [1102001120]={1020011137,1020011138,1020011139,1020011135,1020011134,1020011136,1020011133,1020011132,0,0,0,0,0,0,0,0,0,0,0,1020011142,0,0},
    [1102001130]={1020011247,1020011248,1020011249,1020011245,1020011244,1020011246,1020011243,1020011242,0,0,0,0,0,0,0,0,0,0,0,1020011250,0,0},
    [1102002043]={1020020372,1020020374,1020020373,1020020383,1020020380,1020020384,1020020379,1020020378,1020020377,1020020376,1020020375,1020020388,0,1020020385,1020020387,0,0,0,1020020386,0,0,0},
    [1102002061]={1020020552,1020020554,1020020553,1020020563,1020020562,1020020564,1020020559,1020020558,1020020557,1020020556,1020020555,1020020578,0,1020020565,1020020567,1020020573,1020020574,1020020572,1020020566,0,1020020569,0},
    [1102002136]={1020021314,1020021313,1020021315,1020021309,1020021308,1020021312,1020021307,1020021306,1020021305,1020021304,1020021303,1020021302,0,1020021318,1020021316,1020021323,1020021324,1020021322,1020021317,0,1020021325,0},
    [1102002424]={1020024193,1020024192,1020024194,1020024189,1020024188,1020024190,1020024187,1020024186,1020024185,1020024184,1020024183,1020024182,0,1020024197,1020024195,1020024199,1020024200,1020024198,1020024196,0,1020024202,0},
    [1102003080]={1020030755,1020030756,1020030758,0,1020030749,1020030754,1020030748,1020030747,1020030746,1020030745,1020030744,1020030764,0,1020030760,0,1020030759,1020030757,0,0,1020030765,0,0},
    [1102003100]={1020030956,1020030957,1020030958,1020030954,1020030950,1020030955,1020030949,1020030948,1020030947,1020030946,1020030945,1020030944,0,1020030964,0,1020030960,1020030959,1020030965,0,1020030967,1020030966,1020030968},
    [1102005064]={1020050588,1020050589,1020050590,0,0,0,1020050587,1020050586,1020050585,1020050584,1020050583,1020050582,0,0,0,0,0,0,0,0,1020050592,0},
    [1103001101]={1030010954,1030010955,1030010956,0,0,0,0,0,0,0,1030010953,1030010952,1030010951,0,0,0,0,0,0,1030010957,0,1030010958},
    [1103001146]={1030011344,1030011345,1030011346,0,0,0,0,0,0,0,1030011343,1030011342,1030011341,0,0,0,0,0,0,1030011347,0,1030011348},
    [1103001154]={1030011484,1030011485,1030011486,0,0,0,0,0,0,0,1030011483,1030011482,1030011481,0,0,0,0,0,0,1030011487,0,1030011488},
    [1103001179]={1030011738,1030011739,1030011741,0,0,0,1030011737,1030011736,1030011735,1030011734,1030011733,1030011732,1030011731,0,0,0,0,0,0,1030011742,1030011743,1030011744},
    [1103001191]={1030011858,1030011859,1030011861,0,0,0,1030011857,1030011856,1030011855,1030011854,1030011853,1030011852,1030011851,0,0,0,0,0,0,1030011862,1030011863,1030011864},
    [1103001202]={1030011948,1030011949,1030011950,0,0,0,1030011947,1030011946,1030011945,1030011944,1030011943,1030011942,1030011941,0,0,0,0,0,0,1030011951,1030011952,1030011953},
    [1103002030]={1030020245,1030020246,1030020247,1030020252,1030020249,1030020253,1030020258,1030020257,1030020256,1030020255,1030020244,1030020243,1030020242,0,0,0,0,0,0,1030020248,0,0},
    [1103002059]={1030020544,1030020545,1030020546,1030020542,1030020539,1030020543,1030020538,1030020537,1030020536,1030020535,1030020534,1030020533,1030020532,0,0,0,0,0,0,1030020547,1030020548,0},
    [1103002087]={1030020824,1030020825,1030020826,0,0,0,1030020818,1030020817,1030020816,1030020815,1030020814,1030020813,1030020812,0,0,0,0,0,0,1030020827,1030020828,0},
    [1103002106]={1030021009,1030021010,1030021012,1030021015,1030021014,1030021016,1030021008,1030021007,1030021006,1030021005,1030021004,1030021003,1030021002,0,0,0,0,0,0,1030021013,1030021017,0},
    [1103002113]={1030021079,1030021080,1030021082,1030021085,1030021084,1030021086,1030021078,1030021077,1030021076,1030021075,1030021074,1030021073,1030021072,0,0,0,0,0,0,1030021083,1030021087,0},
    [1103003022]={1030030165,1030030166,1030030167,1030030172,1030030169,1030030173,0,0,0,0,1030030164,1030030163,1030030162,0,0,0,0,0,0,0,0,0},
    [1103003030]={1030030256,1030030257,1030030258,1030030254,1030030253,1030030255,1030030248,1030030247,1030030246,1030030245,1030030244,1030030243,1030030242,0,0,0,0,0,0,1030030259,1030030249,0},
    [1103003042]={1030030374,1030030375,1030030376,1030030372,1030030369,1030030373,0,0,0,0,1030030364,1030030363,1030030362,0,0,0,0,0,0,1030030377,0,0},
    [1103003051]={1030030458,1030030459,1030030460,1030030456,1030030455,1030030457,0,0,0,0,1030030454,1030030453,1030030452,0,0,0,0,0,0,1030030463,0,0},
    [1103003062]={1030030568,1030030569,1030030570,1030030566,1030030565,1030030567,0,0,0,0,1030030564,1030030563,1030030562,0,0,0,0,0,0,1030030572,0,0},
    [1103003079]={1030030744,1030030745,1030030746,1030030742,1030030740,1030030743,1030030738,1030030737,1030030736,1030030735,1030030734,1030030733,1030030732,0,0,0,0,0,0,1030030747,1030030739,0},
    [1103003087]={1030030825,1030030826,1030030827,1030030823,1030030824,1030030824,1030030818,1030030817,1030030816,1030030815,1030030814,1030030813,1030030812,0,0,0,0,0,0,1030030828,1030030819,0},
    [1103004037]={1030040315,1030040316,1030040317,1030040325,1030040324,1030040323,0,0,0,0,1030040314,1030040313,1030040312,1030040327,1030040326,0,0,0,1030040328,1030040329,0,0},
    [1103006030]={1030060245,1030060246,1030060247,0,1030060253,1030060252,0,0,0,0,1030060244,1030060243,1030060242,0,0,0,0,0,0,0,0,0},
    [1103007028]={1030070233,1030070234,1030070235,1030070226,1030070225,1030070227,1030070218,1030070217,1030070216,1030070215,1030070214,1030070213,1030070212,0,0,0,0,0,0,1030070236,1030070219,0},
    [1103012010]={0,0,0,0,0,0,1030120038,1030120037,1030120036,1030120035,1030120034,1030120033,1030120032,0,0,0,0,0,0,0,0,0},
    [1103012019]={0,0,0,0,0,0,1030120138,1030120137,1030120136,1030120135,1030120134,1030120133,1030120132,0,0,0,0,0,0,0,0,0},
    [1103012031]={0,0,0,0,0,0,1030120258,1030120257,1030120256,1030120255,1030120254,1030120253,1030120252,0,0,0,0,0,0,0,0,0},
    [1103012039]={0,0,0,0,0,0,1030120339,1030120338,1030120337,1030120336,1030120335,1030120334,1030120333,0,0,0,0,0,0,0,0,0},
    [1103102007]={1031020026,1031020027,1031020028,1031020024,1031020023,1031020025,1031020019,1031020018,1031020017,1031020016,1031020015,1031020014,1031020013,0,0,0,0,0,0,1031020029,0,0},
    [1105001034]={0,0,0,0,1050010287,1050010289,1050010286,1050010285,1050010284,1050010283,1050010282,0,0,0,0,0,0,0,0,1050010292,0,0},
    [1105001048]={0,0,0,1050010429,1050010428,1050010434,1050010427,1050010426,1050010425,1050010424,1050010423,0,0,0,0,0,0,0,0,1050010435,0,1050010436},
    [1105001069]={0,0,0,1050010639,1050010638,1050010640,1050010637,1050010636,1050010635,1050010634,1050010633,1050010645,0,0,0,0,0,0,0,1050010643,1050010646,1050010644},
    [1105002091]={0,0,0,0,0,0,1050020847,1050020846,1050020845,1050020844,1050020843,1050020842,0,0,0,0,0,0,0,0,0,1050020848},
    [1105010019]={0,0,0,0,0,0,1050100144,1050100143,1050100142,1050100141,1050100139,1050100138,0,0,0,0,0,0,0,0,0,0}
}

_G.BaseAttachToIndex = {
    [201010]=1, [201005]=1, [201004]=1, [201009]=2, [201003]=2, [201002]=2,
    [201011]=3, [201007]=3, [201006]=3, [204012]=4, [204005]=4, [204008]=4,
    [204011]=5, [204004]=5, [204007]=5, [204013]=6, [204006]=6, [204009]=6,
    [203001]=7, [203002]=8, [203003]=9, [203014]=10, [203004]=11, [203015]=12, [203005]=13,
    [202002]=14, [202001]=15, [202004]=16, [202005]=17, [202007]=18, [202006]=19,
    [205002]=20, [205003]=20, [205001]=20, [203018]=21, [204014]=22
}

_G.VipAttachToIndex = {}
for skinId, attachList in pairs(_G.VIP_Attachments) do
    for index, attachId in ipairs(attachList) do
        if attachId > 0 then
            _G.VipAttachToIndex[attachId] = index
        end
    end
end

_G.WeaponSkinMap = _G.WeaponSkinMap or {}
_G.VehicleSkinMap = _G.VehicleSkinMap or {}
_G.OutfitMap = _G.OutfitMap or {}
_G.skinIdCache = _G.skinIdCache or {}
_G.skinIdCache2 = _G.skinIdCache2 or {}

_G.OutfitSkins = {
    Suit = {403003,1408021,1407963,1407965,1407967,1407969,1407970,1407971,1407961,1407906,1407453,1406388,1406387,1406386,1407142,1407550,1406638,1406872,1406971,1407103,1407512,1407391,1407285,1407330,1407329,1407286,1407285,1407277,1407276,1407275,1407225,1407224,1407259,1407161,1407160,1407107,1407106,1407079,1407048,1406977,1406976,1406898,1400569,1404000,1404049,1400119,1400117,1406060,1406891,1400687,1405160,1405145,1405436,1405435,1405434,1405064,1405207,1406398,1407812,1405132,1407856,1405121,1406889,1407278,1407279,1407381,1407380,1407916,1406469,1405870,1407140,1407141,1406385,1406140,1400782,1407392,1407318,1407317,1407404,1407402,1407401,1407387,1404434,1404437,1404440,1404448,1400324,1400708,1404043,1404048,1405953,1400101,1404153,1407440,1407441,1407522,1405069,1405355,1408045,1408038,1407990},
    Bag = {
        {501001, 501002, 501003}, {1501001174, 1501002174, 1501003174}, {1501001220, 1501002220, 1501003220},
        {1501001051, 1501002051, 1501003051}, {1501001443, 1501002443, 1501003443}, {1501001265, 1501002265, 1501003265},
        {1501001321, 1501002321, 1501003321}, {1501001277, 1501002277, 1501003277}, {1501001550, 1501002550, 1501003550},
        {1501001592, 1501002592, 1501003592}, {1501001608, 1501002608, 1501003608}, {1501001024, 1501002024, 1501003024},
        {1501001019, 1501002019, 1501003019}, {1501001179, 1501002179, 1501003179}, {1501001194, 1501002194, 1501003194},
        {1501001346, 1501002346, 1501003346}, {1501001057, 1501002057, 1501003057}, {1501001229, 1501002229, 1501003229},
        {1501001022, 1501002022, 1501003022}, {1501001022, 1501002022, 1501003022}
    },
    Helmet = {
        {502001, 502002, 502003}, {1502001014, 1502002014, 1502003014}, {1502001349, 1502002349, 1502003349},
        {1502001012, 1502002012, 1502003012}, {1502001009, 1502002009, 1502003009}, {1502001397, 1502002397, 1502003397},
        {1502001390, 1502002390, 1502003390}, {1502001381, 1502002381, 1502003381}, {1502001358, 1502002358, 1502003358},
        {1502001350, 1502002350, 1502003350}, {1502001342, 1502002342, 1502003342}, {1502001058, 1502002058, 1502003058},
        {1502001031, 1502002031, 1502003031}, {1502001054, 1502002054, 1502003054}
    },
    Pet = {50000,50001,50002,50003,50004,50005,50006,50021,50022,50038,50039,50040}
}

_G.skinIdMappings = {
    [101004] = {101004, 1101004246,1101004226,1101004236,1101004062,1101004078,1101004086,1101004201,1101004218,1101004046},
    [101001] = {101001,1101001276,1101001265,1101001213,1101001172,1101001127,1101001230,1101001241},
    [101003] = {101003,1101003227,1103003208,1101003195,1101003187,1101003098,1101003166,1101003218},
    [101008] = {101008,1101008146,1101008154,1101008079,1101008126,1101008104,1101008146,1101008061,1101008116},
    [101006] = {101006,1101006098,1101006106,1101006085,1101006061,1101006074,1101006043,1101006032,1101006084},
    [101012] = {101012,1101012033},
    [101007] = {101007,1101007062,1101007071},
    [102002] = {102002,1102002136,1102002043,1102002061,1102002424,1102002438},
    [101101] = {101101, 1101101007},
    [101102] = {101102, 1101102041},
    [102001] = {102001, 1102001120},
    [102003] = {102003, 1102003100},
    [101005] = {101005, 1101005098},
    [103001] = {103001, 1103001202,1103001191},
    [103002] = {103002, 1103002106},
    [103003] = {103003, 1103003042,1103003062,1103003099},
    [103012] = {103012, 1103012039,1103012010},
    [104003] = {104003, 1104003037},
    [104004] = {104004, 1104004035, 1104004041}
}


_G.VehicleSkins = {
    [1961001] = { 1961007, 1961149, 1961069, 1961013, 1961014, 1961015, 1961016, 1961017, 1961018, 1961020, 1961021, 1961024, 1961025, 1961029, 1961030, 1961031, 1961032, 1961033, 1961034, 1961035, 1961036, 1961037, 1961038, 1961039, 1961040, 1961041, 1961042, 1961043, 1961044, 1961045, 1961046, 1961047, 1961048, 1961049, 1961050, 1961051, 1961052, 1961053, 1961054, 1961055, 1961056, 1961057, 1961058, 1961059, 1961060, 1961061, 1961062, 1961063, 1961064, 1961065, 1961066, 1961067, 1961068,1961136, 1961137, 1961138, 1961139, 1961140, 1961141, 1961142, 1961143, 1961144, 1961145, 1961147, 1961148, 1961010, 1961150, 1961151, 1961152, 1961153 },
    [1903001] = { 1961071, 1961070, 1961072, 1961073, 1908117, 1908118, 1908119, 1903230, 1903231, 1903231, 1903232, 1903017, 1903018, 1903019, 1903020, 1903021, 1903022, 1903023, 1903024, 1903029, 1903030, 1903031, 1903032, 1903033, 1903034, 1903035, 1903036, 1903037, 1903039, 1903040, 1903041, 1903042, 1903043, 1903044, 1903045, 1903046, 1903051, 1903052, 1903053, 1903054, 1903055, 1903056, 1903057, 1903058, 1903059, 1903060, 1903061, 1903062, 1903063, 1903066, 1903067, 1903068, 1903069, 1903070, 1903071, 1903072, 1903073, 1903074, 1903075, 1903076, 1903079, 1903080, 1903081, 1903082, 1903084, 1903085, 1903086, 1903087, 1903088, 1903089, 1903090, 1903189, 1903190, 1903191, 1903192, 1903193, 1903194, 1903195, 1903196, 1903197, 1903198, 1903199, 1903200, 1903201, 1903202, 1903203, 1903204, 1903205, 1903206, 1903207, 1903208, 1903209, 1903210, 1903211, 1903212, 1903213, 1903214, 1903215, 1903216, 1903217, 1903218, 1903219, 1903220, 1903221, 1903222, 1903223, 1903225, 1903226, 1903227, 1903228 },
    [1915001] = { 1915002, 1915003, 1915007, 1915005, 1915006, 1915008, 1915009, 1915010, 1915011, 1915012, 1915013, 1915014, 1915015, 1915016, 1915017, 1915018, 1915019, 1915020, 1915021, 1915022, 1915023, 1915024, 1915025, 1915026, 1915027, 1915099 },
    [1908001] = { 1908002, 1908003, 1908094, 1908006, 1908007, 1908008, 1908009, 1908010, 1908011, 1908012, 1908013, 1908015, 1908016, 1908017, 1908018, 1908019, 1908021, 1908023, 1908030, 1908031, 1908032, 1908033, 1908034, 1908035, 1908036, 1908037, 1908039, 1908040, 1908041, 1908043, 1908047, 1908049, 1908050, 1908051, 1908052, 1908053, 1908054, 1908055, 1908056, 1908057, 1908059, 1908060, 1908061, 1908062, 1908063, 1908064, 1908066, 1908067, 1908068, 1908069, 1908070, 1908075, 1908076, 1908077, 1908078, 1908080, 1908081, 1908082, 1908083, 1908084, 1908085, 1908086, 1908087, 1908088, 1908089, 1908091, 1908095, 1908096, 1908097, 1908098, 1908099, 1908100, 1908101, 1908102, 1908104, 1908105, 1908106, 1908107, 1908108, 1908109, 1908110, 1908111, 1908112, 1908188, 1908189 },
    [1907001] = { 1907007, 1907008, 1907010, 1907011, 1907012, 1907013, 1907014, 1907016, 1907018, 1907019, 1907021, 1907022, 1907023, 1907025, 1907026, 1907027, 1907028, 1907029, 1907030, 1907032, 1907033, 1907034, 1907035, 1907036, 1907037, 1907038, 1907040, 1907041, 1907043, 1907044, 1907045, 1907046, 1907047, 1907048, 1907049, 1907050, 1907051, 1907052, 1907053, 1907054, 1907055, 1907056, 1907058, 1907059, 1907060, 1907061, 1907062, 1907063, 1907064, 1907065, 1907066, 1907067, 1907068, 1907069, 1907070, 1907071, 1907072, 1907073, 1907074 }
}
_G.CustSlotType = { ClothesEquipemtSlot=5, BackpackEquipemtSlot=8, HelmetEquipemtSlot=9, ParachuteEquipemtSlot=11, GlideEquipemtSlot=15 }

local function DownloadGameItem(id)
    local puffer_manager = require('client.slua.logic.download.puffer.puffer_manager')
    local puffer_const = require('client.slua.logic.download.puffer_const')
    if puffer_manager and puffer_const and puffer_manager.GetState(puffer_const.ENUM_DownloadType.ODPTD, {id}) ~= puffer_const.ENUM_DownloadState.Done then
        puffer_manager.Download(puffer_const.ENUM_DownloadType.ODPTD, {id})
    end
end
_G.download_item = DownloadGameItem

_G.get_skin_id = function(weaponID)
    if not weaponID then return nil end
    local targetSkinId = _G.WeaponSkinMap and _G.WeaponSkinMap[weaponID]
    if targetSkinId and targetSkinId > 0 then
        if not _G.skinIdCache2[targetSkinId] then
            if _G.download_item then pcall(_G.download_item, targetSkinId) end
            _G.skinIdCache2[targetSkinId] = true
        end
        return targetSkinId
    end
    return weaponID
end

_G.equip_character_avatar = function(Character)
    if not Character or not slua.isValid(Character) or not Character.AvatarComponent2 then return end
    local BackpackUtils = import("BackpackUtils")
    local SlotSyncData = Character.AvatarComponent2.NetAvatarData and Character.AvatarComponent2.NetAvatarData.SlotSyncData
    if not SlotSyncData or not slua.isValid(SlotSyncData) or not BackpackUtils then return end

    local function EquipAvatar(ApplyDataIdx, mappedSkin, ApplyEquipSlot, isLevelDependent, levelFunc)
        if not mappedSkin or mappedSkin == 0 then return end
        local slotData = SlotSyncData:Get(ApplyDataIdx)
        if slotData and slotData.SlotID == ApplyEquipSlot then
            local applyItemId = mappedSkin
            if isLevelDependent and type(mappedSkin) == "table" then
                local level = levelFunc(slotData.AdditionalItemID) or 1
                if level < 1 then level = 1 end
                if level > 3 then level = 3 end
                applyItemId = mappedSkin[level] or mappedSkin[1]
            end
            if not applyItemId or applyItemId == 0 or slotData.ItemId == applyItemId then return end
            if not _G.skinIdCache[applyItemId] then
                if _G.download_item then pcall(_G.download_item, applyItemId) end
                _G.skinIdCache[applyItemId] = true
            end
            slotData.ItemId = applyItemId
            SlotSyncData:Set(ApplyDataIdx, slotData)
            Character.AvatarComponent2:OnRep_BodySlotStateChanged()
        end
    end

    local hasGliderSlot = false
    for i = 0, SlotSyncData:Num() - 1 do
        local slotData = SlotSyncData:Get(i)
        if slotData and slotData.SlotID == _G.CustSlotType.GlideEquipemtSlot then
            hasGliderSlot = true
            break
        end
    end
    if not hasGliderSlot then SlotSyncData:Add({ SlotID = _G.CustSlotType.GlideEquipemtSlot, ItemId = 0 }) end

    for i = 0, SlotSyncData:Num() - 1 do
        EquipAvatar(i, _G.OutfitMap.Suit or 0, _G.CustSlotType.ClothesEquipemtSlot, false)
        EquipAvatar(i, _G.OutfitMap.Bag, _G.CustSlotType.BackpackEquipemtSlot, true, BackpackUtils.GetEquipmentBagLevel)
        EquipAvatar(i, _G.OutfitMap.Helmet, _G.CustSlotType.HelmetEquipemtSlot, true, BackpackUtils.GetEquipmentHelmetLevel)
        EquipAvatar(i, _G.OutfitMap.Parachute or 0, _G.CustSlotType.ParachuteEquipemtSlot, false)
    end
end

_G.ApplyWeaponSkins = function(PlayerCharacter)
    pcall(function()
        local WeaponManager = PlayerCharacter:GetWeaponManager()
        if not slua.isValid(WeaponManager) then return end

        for slot = 1, 3 do
            local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
            if slua.isValid(Weapon) and slua.isValid(Weapon.synData) then
                local WeaponID = Weapon:GetWeaponID()
                local SkinID = _G.get_skin_id(WeaponID) or WeaponID
                local isModified = false

                local SkinData = Weapon.synData:Get(7)
                if SkinData and SkinData.defineID and SkinData.defineID.TypeSpecificID ~= SkinID then
                    SkinData.defineID.TypeSpecificID = SkinID
                    Weapon.synData:Set(7, SkinData)
                    if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(SkinID) end) end
                    if not _G.skinIdCache[SkinID] then
                        _G.download_item(SkinID)
                        _G.skinIdCache[SkinID] = true
                    end
                    isModified = true
                end

                if SkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[SkinID] then
                    for AttachIdx = 0, 5 do
                        local attachData = Weapon.synData:Get(AttachIdx)
                        if attachData then
                            local defineIDRef = slua.IndexReference(attachData, "defineID")
                            if defineIDRef then
                                local attachmentId = defineIDRef.TypeSpecificID
                                if attachmentId and attachmentId > 0 then
                                    local mapIndex = _G.BaseAttachToIndex[attachmentId] or _G.VipAttachToIndex[attachmentId]
                                    if mapIndex and _G.VIP_Attachments[SkinID][mapIndex] and _G.VIP_Attachments[SkinID][mapIndex] > 0 then
                                        local targetAttachId = _G.VIP_Attachments[SkinID][mapIndex]
                                        if targetAttachId ~= attachmentId then
                                            attachData.defineID.TypeSpecificID = targetAttachId
                                            Weapon.synData:Set(AttachIdx, attachData)
                                            if not _G.skinIdCache2[targetAttachId] then
                                                if _G.download_item then pcall(_G.download_item, targetAttachId) end
                                                _G.skinIdCache2[targetAttachId] = true
                                            end
                                            isModified = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if isModified then
                    if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                    if Weapon.OnRep_synData then pcall(function() Weapon:OnRep_synData() end) end
                end
            end
        end
    end)
end

_G.ApplyVehicleSkins = function(PlayerCharacter)
    pcall(function()
        local Vehicle = PlayerCharacter:GetCurrentVehicle()
        if not slua.isValid(Vehicle) then
            _G.LastVehicleEntity = nil
            return
        end

        if _G.LastVehicleEntity == Vehicle and _G.CurrentEquipVehicleID ~= nil then
            return
        end

        local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
        if not slua.isValid(VehicleAvatar) then return end

        local defId = tostring(VehicleAvatar:GetDefaultAvatarID() or Vehicle.VehicleID or "")
        local currentId = tostring(Vehicle:GetAvatarId() or "")
        local applySkinId = 0

        for baseMapId, targetSkin in pairs(_G.VehicleSkinMap) do
            if defId:find(tostring(baseMapId)) or currentId:find(tostring(baseMapId)) then
                applySkinId = targetSkin
                break
            end
        end

        if applySkinId and applySkinId > 0 then
            _G.skinIdCache = _G.skinIdCache or {}
            if not _G.skinIdCache[applySkinId] then
                if _G.download_item then pcall(_G.download_item, applySkinId) end
                _G.skinIdCache[applySkinId] = true
            end

            VehicleAvatar.curSwitchEffectId = 7303001
            if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(applySkinId, true) end

            _G.CurrentEquipVehicleID = applySkinId
            _G.LastVehicleEntity = Vehicle
        end
    end)
end

_G.HandlePetLogic = function()
    pcall(function()
        local petSkin = _G.OutfitMap.Pet
        if not petSkin or petSkin == 0 or petSkin == 50000 or petSkin == _G.LastAppliedPet then return end

        _G.skinIdCache = _G.skinIdCache or {}
        if not _G.skinIdCache[petSkin] then
            if _G.download_item then pcall(_G.download_item, petSkin) end
            _G.skinIdCache[petSkin] = true
        end

        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager then
            local logic_pet = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_pet)
            if logic_pet then
                if logic_pet.SetCurPetID then logic_pet:SetCurPetID(petSkin) end
                if logic_pet.EquipPet then logic_pet:EquipPet(petSkin) end
            end
        end
        _G.LastAppliedPet = petSkin
    end)
end

_G.ForceRefreshSkinMaps = function()
    pcall(function()
        if not _G.R6gamingState or not _G.R6gamingState.CustomTextData then return end
        local cData = _G.R6gamingState.CustomTextData

        if _G.OutfitSkins then
            if cData.SkinSuit and _G.OutfitSkins.Suit[cData.SkinSuit] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[cData.SkinSuit] end
            if cData.SkinBag and _G.OutfitSkins.Bag[cData.SkinBag] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[cData.SkinBag] end
            if cData.SkinHelmet and _G.OutfitSkins.Helmet[cData.SkinHelmet] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[cData.SkinHelmet] end
        end

        if _G.skinIdMappings then
            if cData.SkinM416 and _G.skinIdMappings[101004] and _G.skinIdMappings[101004][cData.SkinM416] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][cData.SkinM416] end
            if cData.SkinAKM and _G.skinIdMappings[101001] and _G.skinIdMappings[101001][cData.SkinAKM] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][cData.SkinAKM] end
            if cData.SkinSCAR and _G.skinIdMappings[101003] and _G.skinIdMappings[101003][cData.SkinSCAR] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][cData.SkinSCAR] end
            if cData.SkinM762 and _G.skinIdMappings[101008] and _G.skinIdMappings[101008][cData.SkinM762] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][cData.SkinM762] end
            if cData.SkinAUG and _G.skinIdMappings[101006] and _G.skinIdMappings[101006][cData.SkinAUG] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][cData.SkinAUG] end
            if cData.SkinHoney and _G.skinIdMappings[101012] and _G.skinIdMappings[101012][cData.SkinHoney] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][cData.SkinHoney] end
            if cData.SkinQBZ and _G.skinIdMappings[101007] and _G.skinIdMappings[101007][cData.SkinQBZ] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][cData.SkinQBZ] end
            if cData.SkinASM and _G.skinIdMappings[101101] and _G.skinIdMappings[101101][cData.SkinASM] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][cData.SkinASM] end
            if cData.SkinACE32 and _G.skinIdMappings[101102] and _G.skinIdMappings[101102][cData.SkinACE32] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][cData.SkinACE32] end
            if cData.SkinUMP and _G.skinIdMappings[102002] and _G.skinIdMappings[102002][cData.SkinUMP] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][cData.SkinUMP] end
            if cData.SkinUZI and _G.skinIdMappings[102001] and _G.skinIdMappings[102001][cData.SkinUZI] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][cData.SkinUZI] end
            if cData.SkinVector and _G.skinIdMappings[102003] and _G.skinIdMappings[102003][cData.SkinVector] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][cData.SkinVector] end
            if cData.SkinGroza and _G.skinIdMappings[101005] and _G.skinIdMappings[101005][cData.SkinGroza] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][cData.SkinGroza] end
            if cData.SkinKar98K and _G.skinIdMappings[103001] and _G.skinIdMappings[103001][cData.SkinKar98K] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][cData.SkinKar98K] end
            if cData.SkinM24 and _G.skinIdMappings[103002] and _G.skinIdMappings[103002][cData.SkinM24] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][cData.SkinM24] end
            if cData.SkinAWM and _G.skinIdMappings[103003] and _G.skinIdMappings[103003][cData.SkinAWM] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][cData.SkinAWM] end
            if cData.SkinAMR and _G.skinIdMappings[103012] and _G.skinIdMappings[103012][cData.SkinAMR] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][cData.SkinAMR] end
            if cData.SkinS12K and _G.skinIdMappings[104003] and _G.skinIdMappings[104003][cData.SkinS12K] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][cData.SkinS12K] end
            if cData.SkinDBS and _G.skinIdMappings[104004] and _G.skinIdMappings[104004][cData.SkinDBS] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][cData.SkinDBS] end
        end

        if _G.VehicleSkins then
            if cData.SkinDacia and _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][cData.SkinDacia] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][cData.SkinDacia] end
            if cData.SkinUAZ and _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][cData.SkinUAZ] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][cData.SkinUAZ] end
            if cData.SkinCoupe and _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][cData.SkinCoupe] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][cData.SkinCoupe] end
            if cData.SkinBuggy and _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][cData.SkinBuggy] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][cData.SkinBuggy] end
            if cData.SkinMirado and _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][cData.SkinMirado] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][cData.SkinMirado] end
        end
    end)
end

_G.InitializeSkinModSystem = function()
    pcall(function()
        local LobbyAvatar = package.loaded["client.logic.avatar.LobbyAvatar"] or require("client.logic.avatar.LobbyAvatar")
        if LobbyAvatar and not _G.LobbyBypassHacked then
            local originalPutonEquipment = LobbyAvatar.PutonEquipment
            LobbyAvatar.PutonEquipment = function(self, itemID, tAvatarCustom, tExtraData)
                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[itemID]
                if attachIndex then
                    local holdingWeaponSkinID = self.GetCurHoldingWeaponSkinID and self:GetCurHoldingWeaponSkinID()
                    if holdingWeaponSkinID and holdingWeaponSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[holdingWeaponSkinID] then
                        local vipAttachID = _G.VIP_Attachments[holdingWeaponSkinID][attachIndex]
                        if vipAttachID and vipAttachID > 0 then
                            if self.HandleDownload then self:HandleDownload(vipAttachID, nil, nil, false) end
                            itemID = vipAttachID
                        end
                    end
                end
                if originalPutonEquipment then return originalPutonEquipment(self, itemID, tAvatarCustom, tExtraData) end
            end

            local originalCharEquipWeaponByResId = LobbyAvatar.CharEquipWeaponByResId
            LobbyAvatar.CharEquipWeaponByResId = function(self, resID, isUse, isAsync, SocketName)
                local retValue = originalCharEquipWeaponByResId and originalCharEquipWeaponByResId(self, resID, isUse, isAsync, SocketName) or nil
                if isUse and self.GetEquipments then
                    local equipments = self:GetEquipments()
                    for _, equip in ipairs(equipments) do
                        if _G.BaseAttachToIndex and _G.BaseAttachToIndex[equip.itemID] then
                            self:PutonEquipment(equip.itemID, equip.CustomInfo, {bIsUse = false})
                        end
                    end
                end
                return retValue
            end
            _G.LobbyBypassHacked = true
        end
    end)

    pcall(function()
        local Common_Items_UIBP = package.loaded["client.slua.component.item.ItemChildren.Common_Items_UIBP"] or require("client.slua.component.item.ItemChildren.Common_Items_UIBP")
        if Common_Items_UIBP and not _G.IconBaloHacked then
            local originalInitView = Common_Items_UIBP.InitView
            Common_Items_UIBP.InitView = function(self, nItemId, nCount, nValidTime, tExtraData)
                tExtraData = tExtraData or {}
                local displayResId = nil

                if _G.get_skin_id then
                    local skinID = _G.get_skin_id(nItemId)
                    if skinID and skinID ~= nItemId then displayResId = skinID end
                end

                local attachIndex = _G.BaseAttachToIndex and _G.BaseAttachToIndex[nItemId]
                if not displayResId and attachIndex then
                    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
                    local LocalPlayer = GameplayData and GameplayData.GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) then
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local finalSkinID = _G.get_skin_id(weaponID) or weaponID
                            if finalSkinID >= 10000000 and _G.VIP_Attachments and _G.VIP_Attachments[finalSkinID] then
                                local vipAttachID = _G.VIP_Attachments[finalSkinID][attachIndex]
                                if vipAttachID and vipAttachID > 0 then displayResId = vipAttachID end
                            end
                        end
                    end
                end

                if displayResId then
                    tExtraData.displayResId = displayResId
                    if not _G.skinIdCache2[displayResId] then
                        if _G.download_item then pcall(_G.download_item, displayResId) end
                        _G.skinIdCache2[displayResId] = true
                    end
                end
                if originalInitView then return originalInitView(self, nItemId, nCount, nValidTime, tExtraData) end
            end
            _G.IconBaloHacked = true
        end
    end)
end

-- ==========================================
-- KILL COUNTER (dari LUCI)
-- ==========================================
_G.TDFTDeKillCounts = _G.TDFTDeKillCounts or {}
local CACHED_LinearColor = import("LinearColor")
local CACHED_GoldColor = CACHED_LinearColor and CACHED_LinearColor(1.0, 0.8, 0.0, 1.0) or nil
local CACHED_UI_Manager = nil

_G.ForceEnableKillCounterUI = function()
    pcall(function()
        local KillCounterUISubsystem = package.loaded["GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem"] or require("GameLua.Mod.BaseMod.Client.KillCounter.KillCounterUISubsystem")
        if KillCounterUISubsystem and KillCounterUISubsystem.__inner_impl and not _G.KCUISystemHacked2 then
            local kcImpl = KillCounterUISubsystem.__inner_impl
            kcImpl.CheckSupportKCUI = function() return true end
            kcImpl.CheckNeedMainKillCounterUI = function(self, PlayerWeapon, PlayerID)
                if slua.isValid(PlayerWeapon) then
                    local WeaponID = PlayerWeapon:GetWeaponID()
                    self:UpdateMainKillCounterUI(true, WeaponID, _G.get_skin_id(WeaponID) or WeaponID)
                  else self:UpdateMainKillCounterUI(false) end
            end
            local originalUpdateMainKillCounterUI = kcImpl.UpdateMainKillCounterUI
            kcImpl.UpdateMainKillCounterUI = function(self, bShow, WeaponID, AvatarID)
                if bShow then AvatarID = _G.get_skin_id(WeaponID) or AvatarID end
                if originalUpdateMainKillCounterUI then originalUpdateMainKillCounterUI(self, bShow, WeaponID, AvatarID) end
            end
            _G.KCUISystemHacked2 = true
        end

        local ModuleManager = require("client.module_framework.ModuleManager")
        if ModuleManager and not _G.KCLogicHacked2 then
            local LogicKillCounter = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicKillCounter)
            if LogicKillCounter then
                LogicKillCounter.CheckSupportKC = function() return true end
                LogicKillCounter.CheckSupportKillCounterAvatar = function() return true end
                LogicKillCounter.CheckHasWeaponKillCounter = function() return true end
                LogicKillCounter.GetBaseKillCounterIdByWeaponId = function() return 2100004 end
                LogicKillCounter.GetEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetMyEquipedKillCounterId = function() return 2100004 end
                LogicKillCounter.GetOneWeaponKillCountInBattle = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                LogicKillCounter.GetWeaponKillCountByUid = function(self, uid, weaponId) return _G.TDFTDeKillCounts[weaponId] or 0 end
                _G.KCLogicHacked2 = true
            end
        end

        local killInfoPath = "GameLua.Mod.BaseMod.Client.KillInfoTips.KillInfo"
        local KillInfo = package.loaded[killInfoPath] or require(killInfoPath)

        if KillInfo and KillInfo.__inner_impl and not _G.KillInfoCounterHacked then
            local originalFileItem = KillInfo.__inner_impl.FileItem
            KillInfo.__inner_impl.FileItem = function(self, DamageRecordData)
                pcall(function()
                    local LocalPlayer = require("GameLua.GameCore.Data.GameplayData").GetPlayerCharacter()
                    if slua.isValid(LocalPlayer) and DamageRecordData.Causer == LocalPlayer:GetPlayerNameSafety() then
                        local currentWeapon = LocalPlayer:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) then
                            local weaponID = currentWeapon:GetWeaponID()
                            local skinID = _G.get_skin_id(weaponID)
                            if skinID then DamageRecordData.CauserWeaponAvatarID = skinID end
                            if _G.OutfitMap.Suit and _G.OutfitMap.Suit ~= 0 then DamageRecordData.CauserClothAvatarID = _G.OutfitMap.Suit end

                            if CACHED_GoldColor then
                                DamageRecordData.IsUseColor, DamageRecordData.UseColor = true, CACHED_GoldColor
                            end

                            if DamageRecordData.ResultHealthStatus == 2 then
                                _G.TDFTDeKillCounts[weaponID] = (_G.TDFTDeKillCounts[weaponID] or 0) + 1
                            end
                        end
                    end
                end)
                if originalFileItem then return originalFileItem(self, DamageRecordData) end
            end
            _G.KillInfoCounterHacked = true
        end

        local SwitchWeaponSlotMode2 = package.loaded["GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2"] or require("GameLua.Mod.BaseMod.Client.MainControlUI.SwitchWeaponSlotMode2")
        if SwitchWeaponSlotMode2 and SwitchWeaponSlotMode2.__inner_impl and not _G.SlotBaseHacked then
            SwitchWeaponSlotMode2.__inner_impl.CheckShowKCIcon = function(self)
                if slua.isValid(self.KillCounterImg) then
                    self.KillCounterImg:SetVisibility(import("ESlateVisibility").SelfHitTestInvisible)
                end
            end
            _G.SlotBaseHacked = true
        end
    end)
end

-- ==========================================
-- DEADBOX SKIN
-- ==========================================
-- ==========================================
-- DEADBOX SKIN (FIXED - AKTIF TERUS)
-- ==========================================
local cached_GameplayStatics = nil
local cached_PlayerTombBox = nil
local cached_ActorClass = nil

_G.DeadBox_TemperRequest = function(PlayerController)
    if not _G.R6gamingConfig.DeadboxEnabled then return end
    if _G.NeedCheckDeadBoxTimer <= 0 then return end

    local curTime = os.clock()
    local delay = _G.R6gamingState.DeadboxDelay or 2.0
    if _G.LastCheckDeadBoxTime and (curTime - _G.LastCheckDeadBoxTime) < delay then return end
    _G.LastCheckDeadBoxTime = curTime

    _G.NeedCheckDeadBoxTimer = _G.NeedCheckDeadBoxTimer - 1

    local PlayerCharacter = PlayerController:GetPlayerCharacterSafety()
    if not slua.isValid(PlayerCharacter) then return end

    if not cached_GameplayStatics then
        cached_GameplayStatics = import("GameplayStatics")
        cached_ActorClass = import("Actor")
        cached_PlayerTombBox = import("PlayerTombBox")
    end

    if not _G.CachedActorArray then
        _G.CachedActorArray = slua.Array(UEnums.EPropertyClass.Object, cached_ActorClass)
    end

    local UI_Util = require("client.common.ui_util")
    local GameInstance = UI_Util and UI_Util.GetGameInstance()
    if not GameInstance or not cached_GameplayStatics then return end

    local deadBoxes = cached_GameplayStatics.GetAllActorsOfClass(GameInstance, cached_PlayerTombBox, _G.CachedActorArray)

    for _, deadBoxActor in pairs(deadBoxes) do
        if slua.isValid(deadBoxActor) and not deadBoxActor.bIsTDSkinApplied then
            local damageCauser = deadBoxActor.DamageCauser
            if damageCauser and damageCauser.PlayerKey == PlayerController.PlayerKey then
                local DeadBoxAvatarComponent = deadBoxActor.DeadBoxAvatarComponent_BP
                if slua.isValid(DeadBoxAvatarComponent) then
                    local currentBoxSkinId = 0
                    if PlayerCharacter.CurrentVehicle and _G.CurrentEquipVehicleID and _G.CurrentEquipVehicleID ~= 0 then
                        currentBoxSkinId = tonumber(tostring(_G.CurrentEquipVehicleID) .. "1") or 0
                      else
                        local currentWeapon = PlayerCharacter:GetCurrentWeapon()
                        if slua.isValid(currentWeapon) and currentWeapon.synData then
                            local weaponSkinData = currentWeapon.synData:Get(7)
                            if weaponSkinData and weaponSkinData.defineID then
                                currentBoxSkinId = weaponSkinData.defineID.TypeSpecificID
                            end
                        end
                    end

                    if currentBoxSkinId ~= 0 then
                        pcall(function()
                            DeadBoxAvatarComponent:ResetItemAvatar()
                            DeadBoxAvatarComponent:PreChangeItemAvatar(currentBoxSkinId)
                            DeadBoxAvatarComponent:SyncChangeItemAvatar(currentBoxSkinId)
                        end)
                    end
                    deadBoxActor.bIsTDSkinApplied = true
                end
            end
        end
    end
end

-- ============================================================
-- AKTIFKAN DEADBOX TIMER
-- ============================================================
_G.NeedCheckDeadBoxTimer = 999 -- ← SET NILAI BESAR AGAR AKTIF
_G.LastCheckDeadBoxTime = 0
_G.DeadboxLoopActive = false

-- ============================================================
-- DEADBOX LOOP (DIJALANKAN OTOMATIS)
-- ============================================================
local function StartDeadboxLoop()
    if _G.DeadboxLoopActive then return end
    if not _G.R6gamingConfig.DeadboxEnabled then return end

    _G.DeadboxLoopActive = true
    _G.NeedCheckDeadBoxTimer = 999

    local function DeadboxLoop()
        if not _G.R6gamingConfig.DeadboxEnabled then
            _G.DeadboxLoopActive = false
            return
        end

        -- Set timer terus
        _G.NeedCheckDeadBoxTimer = 999

        -- Panggil DeadBox_TemperRequest
        pcall(function()
            local GameplayData = require("GameLua.GameCore.Data.GameplayData")
            local pc = GameplayData.GetPlayerController()
            if slua.isValid(pc) then
                _G.DeadBox_TemperRequest(pc)
            end
        end)

        -- Lanjut loop setiap 3 detik
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(3.0, DeadboxLoop)
        end
    end

    DeadboxLoop()
end

-- ============================================================
-- START DEADBOX LOOP SAAT MOD AKTIF
-- ============================================================
pcall(function()
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(1.0, function()
            if _G.R6gamingConfig and _G.R6gamingConfig.DeadboxEnabled then
                StartDeadboxLoop()
            end
        end)
    end
end)

_G.NeedCheckDeadBoxTimer = 0
_G.LastCheckDeadBoxTime = 0

-- ==========================================
-- WATERMARK PERMANEN "@R6gaming" WARNA KUNING
-- ==========================================
pcall(function()
    local IPS = require("GameLua.Mod.Library.Client.UI.IngamePhoneStateUI")
    if IPS and IPS.__inner_impl then
        local o = IPS.__inner_impl.UpdateArtQualityUI
        IPS.__inner_impl.UpdateArtQualityUI = function(self, _, _)
            if self.UIRoot and self.UIRoot.TextBlock_quality then
                self.UIRoot.TextBlock_quality:SetText("R6 GAMING V12")
                self.UIRoot.TextBlock_quality:SetColorAndOpacity(FSlateColor(FLinearColor(1, 1, 0, 1))) -- Kuning
            end
        end
    end
end)

-- ==========================================
-- VIP NATIVE MENU SYSTEM (RUNS DIRECTLY FROM GAME SETTINGS)
-- ==========================================

function _G.InitModMenuTab()
    if _G.ModMenuInitialized then return end
    _G.ModMenuInitialized = true

    _G.R6gamingState.CustomTextData = _G.R6gamingState.CustomTextData or {
        OuterSpeed = 10, InnerSpeed = 10, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120,
        AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250,
        AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30,
        AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchScopePred = 0,
        AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400, AimTouchSniperPred = 0,
        -- Skin (LUCI)
        SkinSuit = 1, SkinBag = 1, SkinHelmet = 1,
        SkinM416 = 1, SkinAKM = 1, SkinSCAR = 1, SkinM762 = 1, SkinAUG = 1,
        SkinHoney = 1, SkinQBZ = 1, SkinASM = 1, SkinACE32 = 1,
        SkinUMP = 1, SkinUZI = 1, SkinVector = 1,
        SkinGroza = 1,
        SkinKar98K = 1, SkinM24 = 1, SkinAWM = 1, SkinAMR = 1,
        SkinS12K = 1, SkinDBS = 1,
        SkinDacia = 1, SkinUAZ = 1, SkinCoupe = 1, SkinBuggy = 1, SkinMirado = 1,
        DeadboxDelay = 2.0,
    }

    -- Cara yang lebih baik untuk memuat LocUtil
    local LocUtil = nil
    local ok, result = pcall(require, "client.common.LocUtil")
    if ok and result then
        LocUtil = result
      else
        LocUtil = rawget(_G, "LocUtil")
    end

    if LocUtil and not LocUtil._IsModMenuHooked then
        local old_get = LocUtil.GetLocalizeResStr
        if old_get then
            LocUtil.GetLocalizeResStr = function(id)
                if type(id) == "string" and not tonumber(id) then return id end
                return old_get(id)
            end
            LocUtil._IsModMenuHooked = true
        end
    end

    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")

    if not SettingPageDefine.ModMenu then
        local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")

        -- Fungsi pembuat warna dengan 7 pilihan (Switcher)
        local function MakeColorSwitcher(key, text, configKey, expandHandle, defaultVal)
            return {
                Key = key,
                UI = AliasMap.Switcher,
                Text = "      " .. text, -- Tetap Text, tidak berubah
                ExpandHandle = expandHandle,
                SwitcherText = {"Red","White","Yellow","Green","Cyan","Blue","Purple"},
                SwitcherValue = {1,2,3,4,5,6,7},
                GetFunc = function() return _G.R6gamingConfig[configKey] or (defaultVal or 4) end,
                SetFunc = function(c, v)
                    local val = math.floor(v + 0.5)
                    if val < 1 then val = 1 end
                    if val > 7 then val = 7 end
                    _G.R6gamingConfig[configKey] = val
                    return true
                end
            }
        end

       local StackESPVisual = {
    -- ============================================================
    -- ESP AUTO (SIMPLE MODE)
    -- ============================================================
    { 
        Key = "ModMenu_ESP1", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP AUTO (SIMPLE MODE)", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.EspVip end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspVip = v return true end 
    },

    -- ============================================================
    -- ESP RANGE
    -- ============================================================
    { 
        Key = "ModMenu_ESP2", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP RANGE", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.EspDistance end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspDistance = v return true end 
    },

    -- ============================================================
    -- ESP MARK - 360 Radar
    -- ============================================================
    { 
        Key = "ModMenu_ESP4", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP MARK - 360 Radar", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.EspRadar end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspRadar = v return true end 
    },

    -- ============================================================
    -- ESP BOX FRAME
    -- ============================================================
    { 
        Key = "ModMenu_ESP5", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP BOX FRAME", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.Esp5 end,
        SetFunc = function(c,v) _G.R6gamingConfig.Esp5 = v return true end 
    },

    -- ============================================================
    -- ESP SKELETON
    -- ============================================================
    { 
        Key = "ModMenu_ESP6", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP SKELETON", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.Esp6 end,
        SetFunc = function(c,v) _G.R6gamingConfig.Esp6 = v return true end 
    },

    -- ============================================================
    -- ESP HEALTH V2
    -- ============================================================
    { 
        Key = "ModMenu_ESP8", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP HEALTH V2", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.Esp8 end,
        SetFunc = function(c,v) _G.R6gamingConfig.Esp8 = v return true end 
    },

    -- ============================================================
    -- ESP NAME (VISCEK)
    -- ============================================================
    { 
        Key = "ModMenu_ESPName", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP NAME (VISCEK)", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.EspName end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspName = v return true end 
    },

    -- ============================================================
    -- ESP OUTLINE (Garis Tepi Musuh)
    -- ============================================================
    { 
        Key = "ModMenu_ESPOutline_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP OUTLINE (Garis Tepi Musuh)", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.EspOutline end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspOutline = v return true end 
    },
    { 
        Key = "ModMenu_ESPOutline_Thickness", 
        UI = AliasMap.Slider, 
        Text = "   Outline Thickness (Ketebalan)",
        ExpandHandle = "ModMenu_ESPOutline_Ex", 
        MinValue = 1, 
        MaxValue = 20, 
        min = 1, 
        max = 20,
        GetFunc = function() return _G.R6gamingConfig.OutlineThickness end,
        SetFunc = function(c,v) _G.R6gamingConfig.OutlineThickness = v return true end 
    },

    -- ============================================================
    -- ESP STATIC (Info Musuh)
    -- ============================================================
    { 
        Key = "ModMenu_EspStatic_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP STATIC (Info Musuh)", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.EspStatic end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspStatic = v return true end 
    },
    { 
        Key = "ModMenu_EspEnemyCount", 
        UI = AliasMap.Switcher, 
        Text = "   ESP ENEMY COUNT",
        ExpandHandle = "ModMenu_EspStatic_Ex",
        GetFunc = function() return _G.R6gamingConfig.EspEnemyCount end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspEnemyCount = v return true end 
    },
    { 
        Key = "ModMenu_EspWeaponStatus", 
        UI = AliasMap.Switcher, 
        Text = "   ESP WEAPON & STATUS ENEMY",
        ExpandHandle = "ModMenu_EspStatic_Ex",
        GetFunc = function() return _G.R6gamingConfig.EspWeaponStatus end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspWeaponStatus = v return true end 
    },

    -- ============================================================
    -- 🟢 ESP TIPE 7 (INFO DETAIL) - ESP7_SOLUONG ADA DI SINI!
    -- ============================================================
    { 
        Key = "ModMenu_ESP7_Ex", 
        UI = AliasMap.TitleSwitcher, 
        Text = "▶ ESP TIPE COUNT (INFO DETAIL)", 
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.EspLoai7 end,
        SetFunc = function(c,v) _G.R6gamingConfig.EspLoai7 = v return true end 
    },
    { 
        Key = "ModMenu_ESP7_SoLuong", 
        UI = AliasMap.Switcher, 
        Text = "   Tampilkan Jumlah Musuh di Sekitar",
        ExpandHandle = "ModMenu_ESP7_Ex",
        GetFunc = function() return _G.R6gamingConfig.Esp7_SoLuong end,
        SetFunc = function(c,v) _G.R6gamingConfig.Esp7_SoLuong = v return true end 
    },
}

        -- ==================== AIMBOT ORIGINAL (tanpa H/V Recoil) ====================
        -- ==================== AIMBOT ORIGINAL (tanpa H/V Recoil) ====================
        local StackAimbotOriginal = {
            -- ============================================================
            -- CUSTOM AIMBOT (DENGAN GARIS KUNING - TitleSwitcher)
            -- ============================================================
            { Key = "ModMenu_Aimbot_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Custom Long-Range Aimbot (Aimbot Jarak Jauh)", ExpandIndex = 0,
                GetFunc = function() return _G.R6gamingConfig.CustomAimbot end,
                SetFunc = function(c,v) _G.R6gamingConfig.CustomAimbot = v return true end },
            { Key = "ModMenu_Aimbot_Speed", UI = AliasMap.Slider, Text = "   Aimbot Speed (Kecepatan)",
                ExpandHandle = "ModMenu_Aimbot_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100,
                GetFunc = function() return _G.R6gamingState.CustomTextData.OuterSpeed end,
                SetFunc = function(c,v) _G.R6gamingState.CustomTextData.OuterSpeed = v return true end },

            { Key = "ModMenu_AimbotClose_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Custom Close-Range Aimbot (Aimbot Jarak Dekat)", ExpandIndex = 0,
                GetFunc = function() return _G.R6gamingConfig.CustomAimbotClose end,
                SetFunc = function(c,v) _G.R6gamingConfig.CustomAimbotClose = v return true end },
            { Key = "ModMenu_AimbotClose_Speed", UI = AliasMap.Slider, Text = "   Aimbot Speed (Kecepatan)",
                ExpandHandle = "ModMenu_AimbotClose_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100,
                GetFunc = function() return _G.R6gamingState.CustomTextData.InnerSpeed end,
                SetFunc = function(c,v) _G.R6gamingState.CustomTextData.InnerSpeed = v return true end },

            -- ============================================================
            -- FITUR LAIN (Switcher Biasa - TANPA GARIS)
            -- ============================================================
            { Key = "ModMenu_LessShake", UI = AliasMap.Switcher, Text = "Anti OverHead", GetFunc = function() return _G.R6gamingConfig.LessShake end, SetFunc = function(c,v) _G.R6gamingConfig.LessShake = v return true end },
            { Key = "ModMenu_Accuracy", UI = AliasMap.Switcher, Text = "Straight Bullet (Peluru Lurus)", GetFunc = function() return _G.R6gamingConfig.Accuracy end, SetFunc = function(c,v) _G.R6gamingConfig.Accuracy = v return true end },
            { Key = "ModMenu_Crosshair", UI = AliasMap.Switcher, Text = "Small Crosshair (Crosshair Kecil - Drop weapon and pick up if turning off)", GetFunc = function() return _G.R6gamingConfig.Crosshair end, SetFunc = function(c,v) _G.R6gamingConfig.Crosshair = v return true end },
            { Key = "ModMenu_AutoHead", UI = AliasMap.Switcher, Text = "Aimbot Head (If turning off, will take effect next match)", GetFunc = function() return _G.R6gamingConfig.AutoHead end, SetFunc = function(c,v) _G.R6gamingConfig.AutoHead = v return true end },
            { Key = "ModMenu_NoShake", UI = AliasMap.Switcher, Text = "No Shake (Zero Recoil & Shake)", GetFunc = function() return _G.R6gamingConfig.NoShake end, SetFunc = function(c,v) _G.R6gamingConfig.NoShake = v return true end },
        }



        -- ==================== AIMBOT FORCE ====================
        -- ==================== AIMBOT FORCE ====================
        -- ==================== AIMBOT FORCE ====================
        local StackAimbotForce = {
            { Key = "ModMenu_AT_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ Enable Royal & Custom Aimbot (Aktifkan Aimbot Royal & Custom)", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.AimTouchEnable end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchEnable = v return true end },

            -- HIPFIRE
            { Key = "ModMenu_AT_Hip_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Hipfire Aimbot (Aimbot Tembak Pinggul)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.AimTouchHipfire end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchHipfire = v return true end },
            { Key = "ModMenu_AT_Hip_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies (Abaikan Musuh Knock)", ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchHipIgKnock end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchHipIgKnock = v return true end },
            { Key = "ModMenu_AT_Hip_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots (Abaikan Bot)", ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchHipIgBot end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchHipIgBot = v return true end },
            { Key = "ModMenu_AT_Hip_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_Hip_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchHipVisCheck end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchHipVisCheck = v return true end },
            { Key = "ModMenu_AT_Hip_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas)", ExpandHandle = "ModMenu_AT_Hip_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchHipPrio or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchHipPrio = v return true end },
            { Key = "ModMenu_AT_Hip_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang)", ExpandHandle = "ModMenu_AT_Hip_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchHipBone or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchHipBone = v return true end },
            { Key = "ModMenu_AT_Hip_Cond", UI = AliasMap.Slider, Text = "      Condition (Kondisi - 1:Aim when firing 2:Always aim)", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchHipCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.R6gamingState.CustomTextData.AimTouchHipCond = val return true end },
            { Key = "ModMenu_AT_Hip_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Kehalusan / Kecepatan - 1-100)", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchHipSpeed or 50 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchHipSpeed = v return true end },
            { Key = "ModMenu_AT_Hip_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchHipFOV or 30 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchHipFOV = v return true end },
            { Key = "ModMenu_AT_Hip_Dist", UI = AliasMap.Slider, Text = "      Distance (Jarak - 1-500m)", ExpandHandle = "ModMenu_AT_Hip_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.R6gamingState.CustomTextData.AimTouchHipDist or 250) / 5) end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchHipDist = v * 5 return true end },

            -- SHOTGUN
            { Key = "ModMenu_AT_SG_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Shotgun Aimbot (Hanya untuk Shotgun)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.AimTouchSG end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSG = v return true end },
            { Key = "ModMenu_AT_SG_AutoFire", UI = AliasMap.Switcher, Text = "      Auto Fire (Tembak Otomatis - may cause damage bug if not firing manually)", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchSGAutoFire end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSGAutoFire = v return true end },
            { Key = "ModMenu_AT_SG_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies (Abaikan Musuh Knock)", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchSGIgKnock end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSGIgKnock = v return true end },
            { Key = "ModMenu_AT_SG_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots (Abaikan Bot)", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchSGIgBot end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSGIgBot = v return true end },
            { Key = "ModMenu_AT_SG_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_SG_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchSGVisCheck end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSGVisCheck = v return true end },
            { Key = "ModMenu_AT_SG_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas)", ExpandHandle = "ModMenu_AT_SG_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSGPrio or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSGPrio = v return true end },
            { Key = "ModMenu_AT_SG_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang)", ExpandHandle = "ModMenu_AT_SG_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSGBone or 2 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSGBone = v return true end },
            { Key = "ModMenu_AT_SG_Cond", UI = AliasMap.Slider, Text = "      Condition (Kondisi - 1:Aim when firing 2:Always aim)", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSGCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.R6gamingState.CustomTextData.AimTouchSGCond = val return true end },
            { Key = "ModMenu_AT_SG_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Kehalusan / Kecepatan - 1-100)", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSGSpeed or 80 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSGSpeed = v return true end },
            { Key = "ModMenu_AT_SG_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSGFOV or 40 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSGFOV = v return true end },
            { Key = "ModMenu_AT_SG_Dist", UI = AliasMap.Slider, Text = "      Distance (Jarak - 1-100m)", ExpandHandle = "ModMenu_AT_SG_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSGDist or 30 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSGDist = v return true end },

            -- SCOPE ALL
            { Key = "ModMenu_AT_ScopeAll_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Scoped Aimbot (All Weapons - If misaligned, toggle scope off/on)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.AimTouchScopeAll end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchScopeAll = v return true end },
            { Key = "ModMenu_AT_ScopeAll_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies (Abaikan Musuh Knock)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchScopeIgKnock end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchScopeIgKnock = v return true end },
            { Key = "ModMenu_AT_ScopeAll_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots (Abaikan Bot)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchScopeIgBot end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchScopeIgBot = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchScopeVisCheck end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchScopeVisCheck = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchScopePrio or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchScopePrio = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchScopeBone or 2 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchScopeBone = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Cond", UI = AliasMap.Slider, Text = "      Condition (Kondisi - 1:Aim when firing 2:Always aim)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchScopeCond or 1 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.R6gamingState.CustomTextData.AimTouchScopeCond = val return true end },
            { Key = "ModMenu_AT_ScopeAll_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Kehalusan / Kecepatan - 1-100)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchScopeSpeed or 40 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchScopeSpeed = v return true end },
            { Key = "ModMenu_AT_ScopeAll_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchScopeFOV or 20 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchScopeFOV = v return true end },
            { Key = "ModMenu_AT_ScopeAll_Dist", UI = AliasMap.Slider, Text = "      Distance (Jarak - 1-500m)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.R6gamingState.CustomTextData.AimTouchScopeDist or 300) / 5) end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchScopeDist = v * 5 return true end },
            { Key = "ModMenu_AT_ScopeAll_Pred", UI = AliasMap.Slider, Text = "      Movement Prediction (Prediksi Gerakan)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchScopePred or 0 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchScopePred = v return true end },
            { Key = "ModMenu_AT_ScopeAll_AntiOverhead", UI = AliasMap.Switcher, Text = "      Anti Overhead (No Recoil/Shake)", ExpandHandle = "ModMenu_AT_ScopeAll_Ex", GetFunc = function() return _G.R6gamingConfig.AntiOverheadScopeAll end, SetFunc = function(c,v) _G.R6gamingConfig.AntiOverheadScopeAll = v return true end },

            -- SNIPER
            { Key = "ModMenu_AT_Sniper_Ex", UI = AliasMap.TitleSwitcher, Text = "   ▶ Scoped Aimbot (Sniper Rifles Only)", ExpandHandle = "ModMenu_AT_Ex", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.AimTouchScopeSniper end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchScopeSniper = v return true end },
            { Key = "ModMenu_AT_Sniper_IgKnock", UI = AliasMap.Switcher, Text = "      Ignore Knocked Enemies (Abaikan Musuh Knock)", ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchSniperIgKnock end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSniperIgKnock = v return true end },
            { Key = "ModMenu_AT_Sniper_IgBot", UI = AliasMap.Switcher, Text = "      Ignore Bots (Abaikan Bot)", ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchSniperIgBot end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSniperIgBot = v return true end },
            { Key = "ModMenu_AT_Sniper_Vis", UI = AliasMap.Switcher, Text = "      Visibility Check (Periksa Dinding)", ExpandHandle = "ModMenu_AT_Sniper_Ex", GetFunc = function() return _G.R6gamingConfig.AimTouchSniperVisCheck end, SetFunc = function(c,v) _G.R6gamingConfig.AimTouchSniperVisCheck = v return true end },
            { Key = "ModMenu_AT_Sniper_Prio", UI = AliasMap.Switcher, Text = "      Priority (Prioritas)", ExpandHandle = "ModMenu_AT_Sniper_Ex", SwitcherText = {"Center","Distance","HP","HP%"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSniperPrio or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSniperPrio = v return true end },
            { Key = "ModMenu_AT_Sniper_Bone", UI = AliasMap.Switcher, Text = "      Bone Target (Target Tulang)", ExpandHandle = "ModMenu_AT_Sniper_Ex", SwitcherText = {"Head","Chest","Stomach","Pelvis"}, SwitcherValue = {1,2,3,4}, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSniperBone or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSniperBone = v return true end },
            { Key = "ModMenu_AT_Sniper_Cond", UI = AliasMap.Slider, Text = "      Condition (Kondisi - 1:Aim when firing 2:Always aim)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 2, min = 1, max = 2, Min = 1, Max = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSniperCond or 2 end, SetFunc = function(c,v) local val = math.floor(v+0.5); if val < 1 then val = 1 end; if val > 2 then val = 2 end; _G.R6gamingState.CustomTextData.AimTouchSniperCond = val return true end },
            { Key = "ModMenu_AT_Sniper_Spd", UI = AliasMap.Slider, Text = "      Smoothing / Speed (Kehalusan / Kecepatan - 1-100)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSniperSpeed or 30 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSniperSpeed = v return true end },
            { Key = "ModMenu_AT_Sniper_FOV", UI = AliasMap.Slider, Text = "      FOV Range (Rentang FOV - 1-100)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSniperFOV or 20 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSniperFOV = v return true end },
            { Key = "ModMenu_AT_Sniper_Dist", UI = AliasMap.Slider, Text = "      Distance (Jarak - 1-500m)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100, GetFunc = function() return math.floor((_G.R6gamingState.CustomTextData.AimTouchSniperDist or 400) / 5) end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSniperDist = v * 5 return true end },
            { Key = "ModMenu_AT_Sniper_Pred", UI = AliasMap.Slider, Text = "      Movement Prediction (Prediksi Gerakan - 0-100)", ExpandHandle = "ModMenu_AT_Sniper_Ex", MinValue = 0, MaxValue = 100, min = 0, max = 100, GetFunc = function() return _G.R6gamingState.CustomTextData.AimTouchSniperPred or 0 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.AimTouchSniperPred = v return true end }
        }

        -- ==================== COMBAT GRAPHIC (tanpa White Body) ====================
        -- ==================== COMBAT GRAPHIC (tanpa White Body) ====================
        -- ==================== COMBAT GRAPHIC (tanpa White Body) ====================
        local StackCombatGraphic = {
            -- ============================================================
            -- SEMUA VISUAL DIJADIKAN TitleSwitcher (GARIS KUNING)
            -- ============================================================

            -- IPAD VIEW
            { Key = "ModMenu_Ipad_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ iPad View (Tampilan iPad)", ExpandIndex = 0,
                GetFunc = function() return _G.R6gamingConfig.IpadView end,
                SetFunc = function(c,v) _G.R6gamingConfig.IpadView = v return true end },
            { Key = "ModMenu_Ipad_FOV", UI = AliasMap.Slider, Text = "   FOV Angle (Sudut Pandang)",
                ExpandHandle = "ModMenu_Ipad_Ex", MinValue = 1, MaxValue = 100, min = 1, max = 100,
                GetFunc = function() return (_G.R6gamingState.CustomTextData.IpadViewFOV or 120) - 90 end,
                SetFunc = function(c,v) _G.R6gamingState.CustomTextData.IpadViewFOV = 90 + v return true end },

            -- UNLOCK 165 FPS
            { Key = "ModMenu_165FPS", UI = AliasMap.TitleSwitcher, Text = "▶ Unlock 165 FPS", ExpandIndex = 0,
                GetFunc = function() return _G.R6gamingConfig.UnlockFPS end,
                SetFunc = function(c,v) _G.R6gamingConfig.UnlockFPS = v; if v then _G.R6gamingState.GraphicsUnlocked = false end return true end },


        }

        -- ==================== SKIN MOD (LUCI + Kill Counter) ====================
        local StackSkinMod = {
            -- SKIN 1: SUIT / HELM / BAG
            { Key = "ModMenu_Skin1_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SKIN 1 (SUIT / HELM / BAG)", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.Skin1Enabled end, SetFunc = function(c,v) _G.R6gamingConfig.Skin1Enabled = v return true end },
            { Key = "ModMenu_Skin_Suit", UI = AliasMap.Slider, Text = "   SUIT (Baju) [1-90]", ExpandHandle = "ModMenu_Skin1_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinSuit or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinSuit = v; if _G.OutfitSkins and _G.OutfitSkins.Suit[v] then _G.OutfitMap.Suit = _G.OutfitSkins.Suit[v] end return true end },
            { Key = "ModMenu_Skin_Bag", UI = AliasMap.Slider, Text = "   BAG (Ransel) [1-19]", ExpandHandle = "ModMenu_Skin1_Ex", MinValue = 1, MaxValue = 19, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinBag or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinBag = v; if _G.OutfitSkins and _G.OutfitSkins.Bag[v] then _G.OutfitMap.Bag = _G.OutfitSkins.Bag[v] end return true end },
            { Key = "ModMenu_Skin_Helmet", UI = AliasMap.Slider, Text = "   HELMET (Helm) [1-14]", ExpandHandle = "ModMenu_Skin1_Ex", MinValue = 1, MaxValue = 14, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinHelmet or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinHelmet = v; if _G.OutfitSkins and _G.OutfitSkins.Helmet[v] then _G.OutfitMap.Helmet = _G.OutfitSkins.Helmet[v] end return true end },

            -- SKIN 2: WEAPON
            { Key = "ModMenu_Skin2_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SKIN 2 (WEAPON)", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.Skin2Enabled end, SetFunc = function(c,v) _G.R6gamingConfig.Skin2Enabled = v return true end },
            { Key = "ModMenu_Skin_M416", UI = AliasMap.Slider, Text = "   M416 [1-10]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 10, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinM416 or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinM416 = v; if _G.skinIdMappings[101004] and _G.skinIdMappings[101004][v] then _G.WeaponSkinMap[101004] = _G.skinIdMappings[101004][v] end return true end },
            { Key = "ModMenu_Skin_AKM", UI = AliasMap.Slider, Text = "   AKM [1-8]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinAKM or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinAKM = v; if _G.skinIdMappings[101001] and _G.skinIdMappings[101001][v] then _G.WeaponSkinMap[101001] = _G.skinIdMappings[101001][v] end return true end },
            { Key = "ModMenu_Skin_SCAR", UI = AliasMap.Slider, Text = "   SCAR-L [1-8]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 8, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinSCAR or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinSCAR = v; if _G.skinIdMappings[101003] and _G.skinIdMappings[101003][v] then _G.WeaponSkinMap[101003] = _G.skinIdMappings[101003][v] end return true end },
            { Key = "ModMenu_Skin_M762", UI = AliasMap.Slider, Text = "   Beryl M762 [1-9]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 9, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinM762 or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinM762 = v; if _G.skinIdMappings[101008] and _G.skinIdMappings[101008][v] then _G.WeaponSkinMap[101008] = _G.skinIdMappings[101008][v] end return true end },
            { Key = "ModMenu_Skin_AUG", UI = AliasMap.Slider, Text = "   AUG [1-7]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 7, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinAUG or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinAUG = v; if _G.skinIdMappings[101006] and _G.skinIdMappings[101006][v] then _G.WeaponSkinMap[101006] = _G.skinIdMappings[101006][v] end return true end },
            { Key = "ModMenu_Skin_Honey", UI = AliasMap.Slider, Text = "   Honey Badger [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinHoney or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinHoney = v; if _G.skinIdMappings[101012] and _G.skinIdMappings[101012][v] then _G.WeaponSkinMap[101012] = _G.skinIdMappings[101012][v] end return true end },
            { Key = "ModMenu_Skin_QBZ", UI = AliasMap.Slider, Text = "   QBZ [1-3]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinQBZ or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinQBZ = v; if _G.skinIdMappings[101007] and _G.skinIdMappings[101007][v] then _G.WeaponSkinMap[101007] = _G.skinIdMappings[101007][v] end return true end },
            { Key = "ModMenu_Skin_ASM", UI = AliasMap.Slider, Text = "   ASM Abakan [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinASM or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinASM = v; if _G.skinIdMappings[101101] and _G.skinIdMappings[101101][v] then _G.WeaponSkinMap[101101] = _G.skinIdMappings[101101][v] end return true end },
            { Key = "ModMenu_Skin_ACE32", UI = AliasMap.Slider, Text = "   ACE32 [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinACE32 or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinACE32 = v; if _G.skinIdMappings[101102] and _G.skinIdMappings[101102][v] then _G.WeaponSkinMap[101102] = _G.skinIdMappings[101102][v] end return true end },
            { Key = "ModMenu_Skin_UMP", UI = AliasMap.Slider, Text = "   UMP45 [1-6]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 6, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinUMP or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinUMP = v; if _G.skinIdMappings[102002] and _G.skinIdMappings[102002][v] then _G.WeaponSkinMap[102002] = _G.skinIdMappings[102002][v] end return true end },
            { Key = "ModMenu_Skin_UZI", UI = AliasMap.Slider, Text = "   UZI [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinUZI or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinUZI = v; if _G.skinIdMappings[102001] and _G.skinIdMappings[102001][v] then _G.WeaponSkinMap[102001] = _G.skinIdMappings[102001][v] end return true end },
            { Key = "ModMenu_Skin_Vector", UI = AliasMap.Slider, Text = "   Vector [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinVector or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinVector = v; if _G.skinIdMappings[102003] and _G.skinIdMappings[102003][v] then _G.WeaponSkinMap[102003] = _G.skinIdMappings[102003][v] end return true end },
            { Key = "ModMenu_Skin_Groza", UI = AliasMap.Slider, Text = "   Groza [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinGroza or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinGroza = v; if _G.skinIdMappings[101005] and _G.skinIdMappings[101005][v] then _G.WeaponSkinMap[101005] = _G.skinIdMappings[101005][v] end return true end },
            { Key = "ModMenu_Skin_Kar98K", UI = AliasMap.Slider, Text = "   Kar98K [1-3]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinKar98K or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinKar98K = v; if _G.skinIdMappings[103001] and _G.skinIdMappings[103001][v] then _G.WeaponSkinMap[103001] = _G.skinIdMappings[103001][v] end return true end },
            { Key = "ModMenu_Skin_M24", UI = AliasMap.Slider, Text = "   M24 [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinM24 or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinM24 = v; if _G.skinIdMappings[103002] and _G.skinIdMappings[103002][v] then _G.WeaponSkinMap[103002] = _G.skinIdMappings[103002][v] end return true end },
            { Key = "ModMenu_Skin_AWM", UI = AliasMap.Slider, Text = "   AWM [1-4]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 4, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinAWM or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinAWM = v; if _G.skinIdMappings[103003] and _G.skinIdMappings[103003][v] then _G.WeaponSkinMap[103003] = _G.skinIdMappings[103003][v] end return true end },
            { Key = "ModMenu_Skin_AMR", UI = AliasMap.Slider, Text = "   AMR [1-3]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinAMR or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinAMR = v; if _G.skinIdMappings[103012] and _G.skinIdMappings[103012][v] then _G.WeaponSkinMap[103012] = _G.skinIdMappings[103012][v] end return true end },
            { Key = "ModMenu_Skin_S12K", UI = AliasMap.Slider, Text = "   S12K [1-2]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 2, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinS12K or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinS12K = v; if _G.skinIdMappings[104003] and _G.skinIdMappings[104003][v] then _G.WeaponSkinMap[104003] = _G.skinIdMappings[104003][v] end return true end },
            { Key = "ModMenu_Skin_DBS", UI = AliasMap.Slider, Text = "   DBS [1-3]", ExpandHandle = "ModMenu_Skin2_Ex", MinValue = 1, MaxValue = 3, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinDBS or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinDBS = v; if _G.skinIdMappings[104004] and _G.skinIdMappings[104004][v] then _G.WeaponSkinMap[104004] = _G.skinIdMappings[104004][v] end return true end },

            -- SKIN 3: VEHICLE
            { Key = "ModMenu_Skin3_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ SKIN 3 (VEHICLE)", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.Skin3Enabled end, SetFunc = function(c,v) _G.R6gamingConfig.Skin3Enabled = v return true end },
            { Key = "ModMenu_Skin_Dacia", UI = AliasMap.Slider, Text = "   Dacia [1-90]", ExpandHandle = "ModMenu_Skin3_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinDacia or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinDacia = v; if _G.VehicleSkins[1903001] and _G.VehicleSkins[1903001][v] then _G.VehicleSkinMap[1903001] = _G.VehicleSkins[1903001][v] end return true end },
            { Key = "ModMenu_Skin_UAZ", UI = AliasMap.Slider, Text = "   UAZ [1-90]", ExpandHandle = "ModMenu_Skin3_Ex", MinValue = 1, MaxValue = 90, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinUAZ or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinUAZ = v; if _G.VehicleSkins[1908001] and _G.VehicleSkins[1908001][v] then _G.VehicleSkinMap[1908001] = _G.VehicleSkins[1908001][v] end return true end },
            { Key = "ModMenu_Skin_Coupe", UI = AliasMap.Slider, Text = "   Coupe RB [1-70]", ExpandHandle = "ModMenu_Skin3_Ex", MinValue = 1, MaxValue = 70, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinCoupe or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinCoupe = v; if _G.VehicleSkins[1961001] and _G.VehicleSkins[1961001][v] then _G.VehicleSkinMap[1961001] = _G.VehicleSkins[1961001][v] end return true end },
            { Key = "ModMenu_Skin_Buggy", UI = AliasMap.Slider, Text = "   Buggy [1-50]", ExpandHandle = "ModMenu_Skin3_Ex", MinValue = 1, MaxValue = 50, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinBuggy or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinBuggy = v; if _G.VehicleSkins[1907001] and _G.VehicleSkins[1907001][v] then _G.VehicleSkinMap[1907001] = _G.VehicleSkins[1907001][v] end return true end },
            { Key = "ModMenu_Skin_Mirado", UI = AliasMap.Slider, Text = "   Mirado [1-27]", ExpandHandle = "ModMenu_Skin3_Ex", MinValue = 1, MaxValue = 27, GetFunc = function() return _G.R6gamingState.CustomTextData.SkinMirado or 1 end, SetFunc = function(c,v) _G.R6gamingState.CustomTextData.SkinMirado = v; if _G.VehicleSkins[1915001] and _G.VehicleSkins[1915001][v] then _G.VehicleSkinMap[1915001] = _G.VehicleSkins[1915001][v] end return true end },

            -- GLIDER (soon)
            { Key = "ModMenu_Skin_Glider", UI = AliasMap.Title, Text = "   GLIDER (SOON NEXT UPDATE)", ExpandHandle = "ModMenu_Skin3_Ex" },

            -- DEADBOX
            { Key = "ModMenu_Deadbox_Ex", UI = AliasMap.TitleSwitcher, Text = "▶ DEADBOX SKIN", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.DeadboxEnabled end, SetFunc = function(c,v) _G.R6gamingConfig.DeadboxEnabled = v return true end },
            { Key = "ModMenu_Deadbox_Delay", UI = AliasMap.Slider, Text = "   Deadbox Delay (Detik - 0.1-5.0)", ExpandHandle = "ModMenu_Deadbox_Ex", MinValue = 1, MaxValue = 50, min = 1, max = 50, GetFunc = function() return math.floor((_G.R6gamingState.DeadboxDelay or 2.0) * 10) end, SetFunc = function(c,v) _G.R6gamingState.DeadboxDelay = v / 10.0; return true end },

            -- KILL COUNTER
{ Key = "ModMenu_KillCounter_Ex", UI = AliasMap.TitleSwitcher, Text = "KILL COUNTER", ExpandIndex = 0, GetFunc = function() return _G.R6gamingConfig.KillCounterEnabled end, SetFunc = function(c,v) _G.R6gamingConfig.KillCounterEnabled = v; if v then _G.ForceEnableKillCounterUI() end return true end },

}

local StackWallhack = {
    -- ==========================================
    -- 🔶 GRUP 1: WALLHACK V1 
    -- ==========================================
    { 
        Key = "ModMenu_WallXuyenTuong_Ex", 
        UI = AliasMap.TitleSwitcher,
        Text = "▶ WALLHACK V1 (Tembus Dinding)",
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.WallXuyenTuong end, 
        SetFunc = function(c, v) 
            _G.R6gamingConfig.WallXuyenTuong = v 
            if v then print("✅ Wallhack V1 ON") else print("❌ Wallhack V1 OFF") end
            return true 
        end 
    },

    -- ==========================================
    -- 🔶 GRUP 2: CHAMS V2
    -- ==========================================
    { 
        Key = "ModMenu_ColorBodyV2_Ex", 
        UI = AliasMap.TitleSwitcher,
        Text = "▶ CHAMS V2 (Warna Dasar)",
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.ColorBodyV2 end, 
        SetFunc = function(c, v) 
            _G.R6gamingConfig.ColorBodyV2 = v 
            if v then print("✅ Chams V2 ON") else print("❌ Chams V2 OFF") end
            return true 
        end 
    },

    -- ==========================================
    -- 🔶 GRUP 3: WALL WARNA BARU
    -- ==========================================
    { 
        Key = "ModMenu_ColorBodyNew_Ex", 
        UI = AliasMap.TitleSwitcher,
        Text = "▶ WALL WARNA BARU (Merah/Hijau)",
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.ColorBodyNew end, 
        SetFunc = function(c, v) 
            _G.R6gamingConfig.ColorBodyNew = v 
            if v then print("✅ Wall Warna Baru ON") else print("❌ Wall Warna Baru OFF") end
            return true 
        end 
    },

    -- ==========================================
    -- 🔶 GRUP 4: WALL V2 + WARNA V3 (Kustom)
    -- ==========================================
    { 
        Key = "ModMenu_ColorBodyV3_Ex", 
        UI = AliasMap.TitleSwitcher,
        Text = "▶ WALL V2 + WARNA V3 (Kustom)",
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.ColorBodyV3 end, 
        SetFunc = function(c, v) 
            _G.R6gamingConfig.ColorBodyV3 = v 
            if v then print("✅ Wall V2 + Warna V3 ON") else print("❌ Wall V2 + Warna V3 OFF") end
            return true 
        end 
    },

    -- SUB MENU: Warna Tembus
    { 
        Key = "ModMenu_V3_Hidden", 
        UI = AliasMap.Slider, 
        Text = "   Warna Tembus (1-6)",
        ExpandHandle = "ModMenu_ColorBodyV3_Ex",
        MinValue = 1, MaxValue = 6, min = 1, max = 6,
        GetFunc = function() return _G.R6gamingState.CustomTextData.ColorV3Hidden or 1 end, 
        SetFunc = function(c, v) 
            local val = math.floor(v + 0.5)
            if val < 1 then val = 1 end
            if val > 6 then val = 6 end
            _G.R6gamingState.CustomTextData.ColorV3Hidden = val 
            local colors = {"Merah", "Hijau", "Biru", "Kuning", "Ungu", "Putih"}
            print("🎨 Warna Tembus: " .. (colors[val] or "Merah"))
            return true 
        end 
    },

    -- SUB MENU: Warna Terlihat
    { 
        Key = "ModMenu_V3_Vis", 
        UI = AliasMap.Slider, 
        Text = "   Warna Terlihat (1-6)",
        ExpandHandle = "ModMenu_ColorBodyV3_Ex",
        MinValue = 1, MaxValue = 6, min = 1, max = 6,
        GetFunc = function() return _G.R6gamingState.CustomTextData.ColorV3Visible or 2 end, 
        SetFunc = function(c, v) 
            local val = math.floor(v + 0.5)
            if val < 1 then val = 1 end
            if val > 6 then val = 6 end
            _G.R6gamingState.CustomTextData.ColorV3Visible = val 
            local colors = {"Merah", "Hijau", "Biru", "Kuning", "Ungu", "Putih"}
            print("🎨 Warna Terlihat: " .. (colors[val] or "Hijau"))
            return true 
        end 
    },

    -- SUB MENU: Ketebalan Garis
    { 
        Key = "ModMenu_V3_Thick", 
        UI = AliasMap.Slider, 
        Text = "   Ketebalan Garis (1-20)",
        ExpandHandle = "ModMenu_ColorBodyV3_Ex",
        MinValue = 1, MaxValue = 20, min = 1, max = 20,
        GetFunc = function() return _G.R6gamingState.CustomTextData.ColorV3Thickness or 4 end, 
        SetFunc = function(c, v) 
            local val = math.floor(v + 0.5)
            if val < 1 then val = 1 end
            if val > 20 then val = 20 end
            _G.R6gamingState.CustomTextData.ColorV3Thickness = val 
            print("📏 Ketebalan Garis: " .. val)
            return true 
        end 
    },

    -- ==========================================
    -- 🔶 GRUP 5: WALLHACK KENDARAAN
    -- ==========================================
    { 
        Key = "ModMenu_WallVehicle_Ex", 
        UI = AliasMap.TitleSwitcher,
        Text = "▶ WALLHACK KENDARAAN",
        ExpandIndex = 0,
        GetFunc = function() return _G.R6gamingConfig.WallVehicle end, 
        SetFunc = function(c, v) 
            _G.R6gamingConfig.WallVehicle = v 
            if v then print("✅ Wallhack Kendaraan ON") else print("❌ Wallhack Kendaraan OFF") end
            return true 
        end 
    },
}



local EntertainmentStack = {
    -- ============================================================
    -- WALL CLIMB (PANJAT DINDING)
    -- ============================================================
    { Key = "ModMenu_WallClimb_Ex", UI = AliasMap.TitleSwitcher, Text = "WALL CLIMB (Panjat Dinding)", ExpandIndex = 0,
      GetFunc = function() return _G.R6Config.WallClimb == 1 end,
      SetFunc = function(c, v) 
          _G.R6Config.WallClimb = v and 1 or 0
          print("[R6] Wall Climb = " .. tostring(v))
          if not v then
              pcall(function()
                  local me = GameplayData.GetPlayerCharacter()
                  if slua.isValid(me) then
                      local charMove = me.CharacterMovement or me.CharMoveComp
                      if slua.isValid(charMove) then
                          charMove.WalkableFloorAngle = 44.0
                          charMove.MaxStepHeight = 45.0
                          _G.R6ResetWallClimb()
                      end
                  end
              end)
          end
          return true 
      end },

    -- ============================================================
    -- ⚡ QUICK SWITCH (CEPAT GANTI SENJATA)
    -- ============================================================
    { Key = "ModMenu_QuickSwitch_Ex", UI = AliasMap.TitleSwitcher, Text = "QUICK SWITCH (Ganti Senjata Cepat)", ExpandIndex = 0,
      GetFunc = function() return _G.R6Config.QuickSwitch == 1 end,
      SetFunc = function(c, v) 
          _G.R6Config.QuickSwitch = v and 1 or 0
          print("[R6] Quick Switch = " .. tostring(v))
          return true 
      end },

    -- ============================================================
    -- 🎨 BODY COLOR (WARNA TUBUH MUSUH)
    -- ============================================================
    { Key = "ModMenu_BodyColor_Ex", UI = AliasMap.TitleSwitcher, Text = "BODY COLOR (Warna Tubuh Musuh)", ExpandIndex = 0,
      GetFunc = function() return _G.R6Config.BodyColor == 1 end,
      SetFunc = function(c, v) 
          _G.R6Config.BodyColor = v and 1 or 0
          print("[R6] Body Color = " .. tostring(v))
          return true 
      end },

    { Key = "ModMenu_BodyColor_Title", UI = AliasMap.Title, Text = "   ── Pilih Warna ──", ExpandHandle = "ModMenu_BodyColor_Ex" },

    { Key = "ModMenu_BodyColor_Red", UI = AliasMap.Switcher, Text = "   Merah", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Merah" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Merah"; print("[R6] Body Color = Merah") end; return true end },

    { Key = "ModMenu_BodyColor_Green", UI = AliasMap.Switcher, Text = "   Hijau", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Hijau" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Hijau"; print("[R6] Body Color = Hijau") end; return true end },

    { Key = "ModMenu_BodyColor_Blue", UI = AliasMap.Switcher, Text = "   Biru", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Biru" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Biru"; print("[R6] Body Color = Biru") end; return true end },

    { Key = "ModMenu_BodyColor_Yellow", UI = AliasMap.Switcher, Text = "   Kuning", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Kuning" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Kuning"; print("[R6] Body Color = Kuning") end; return true end },

    { Key = "ModMenu_BodyColor_Orange", UI = AliasMap.Switcher, Text = "   Orange", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Orange" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Orange"; print("[R6] Body Color = Orange") end; return true end },

    { Key = "ModMenu_BodyColor_Pink", UI = AliasMap.Switcher, Text = "   Pink", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Pink" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Pink"; print("[R6] Body Color = Pink") end; return true end },

    { Key = "ModMenu_BodyColor_Purple", UI = AliasMap.Switcher, Text = "   Ungu", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Ungu" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Ungu"; print("[R6] Body Color = Ungu") end; return true end },

    { Key = "ModMenu_BodyColor_Cyan", UI = AliasMap.Switcher, Text = "   Cyan", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Cyan" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Cyan"; print("[R6] Body Color = Cyan") end; return true end },

    { Key = "ModMenu_BodyColor_Magenta", UI = AliasMap.Switcher, Text = "   Magenta", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Magenta" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Magenta"; print("[R6] Body Color = Magenta") end; return true end },

    { Key = "ModMenu_BodyColor_White", UI = AliasMap.Switcher, Text = "   Putih", ExpandHandle = "ModMenu_BodyColor_Ex",
      GetFunc = function() return _G.R6Config.BodyColorName == "Putih" end,
      SetFunc = function(c, v) if v then _G.R6Config.BodyColorName = "Putih"; print("[R6] Body Color = Putih") end; return true end },


-- ============================================================
-- 🚗 VEHICLE FLY (MOBIL TERBANG) - SAMA SEPERTI MENU LAIN
-- ============================================================
{ Key = "ModMenu_VehicleFly_Ex", UI = AliasMap.TitleSwitcher, Text = "TANK TERBANG (Mobil Terbang)", ExpandIndex = 0,
  GetFunc = function() 
      return _G.R6Config.VehicleFly == 1  -- ✅ return boolean
  end,
  SetFunc = function(c, v) 
      _G.R6Config.VehicleFly = v and 1 or 0  -- ✅ v adalah boolean
      print("[R6] Vehicle Fly = " .. tostring(_G.R6Config.VehicleFly))
      
      if not v then
          pcall(function()
              local uLocalPlayer = GameplayData.GetPlayerCharacter()
              if slua.isValid(uLocalPlayer) then
                  local currentVehicle = uLocalPlayer.CurrentVehicle
                  if slua.isValid(currentVehicle) then
                      local rootComp = currentVehicle.RootComponent or currentVehicle:K2_GetRootComponent()
                      if slua.isValid(rootComp) then
                          rootComp:SetEnableGravity(true)
                          rootComp:SetLinearDamping(0.1)
                          rootComp:SetAngularDamping(0.1)
                          rootComp:SetAllPhysicsLinearVelocity(FVector(0, 0, 0), false)
                      end
                  end
              end
              if _G._vehicleFly then
                  _G._vehicleFly.initialHeight = nil
                  _G._vehicleFly.targetHeight = nil
                  _G._vehicleFly.isReady = false
                  _G._vehicleFly.lastVehicle = nil
                  _G._vehicleFly.forceApply = false
              end
          end)
          print("[R6] 🚗 Vehicle Fly OFF")
      else
          if _G._vehicleFly then
              _G._vehicleFly.initialHeight = nil
              _G._vehicleFly.targetHeight = nil
              _G._vehicleFly.isReady = false
              _G._vehicleFly.forceApply = true
          end
          print("[R6] 🚗 Vehicle Fly ON")
      end
      return true 
  end 
},

-- Slider Kecepatan Naik
{ Key = "ModMenu_VehicleFly_Speed", UI = AliasMap.Slider, Text = "   Kecepatan Naik", ExpandHandle = "ModMenu_VehicleFly_Ex",
  MinValue = 0, MaxValue = 100, min = 0, max = 100,
  GetFunc = function() 
      local raw = _G.R6Config.VehicleFlySpeed or 800
      local percent = math.floor(((raw - 100) / 1900) * 100)
      if percent < 0 then percent = 0 end
      if percent > 100 then percent = 100 end
      return percent
  end,
  SetFunc = function(c, v) 
      local val = math.floor(100 + (v / 100) * 1900 + 0.5)
      if val < 100 then val = 100 end
      if val > 2000 then val = 2000 end
      _G.R6Config.VehicleFlySpeed = val
      return true 
  end 
},

-- Slider Ketinggian Maksimal
{ Key = "ModMenu_VehicleFly_Height", UI = AliasMap.Slider, Text = "   Ketinggian Maks", ExpandHandle = "ModMenu_VehicleFly_Ex",
  MinValue = 0, MaxValue = 100, min = 0, max = 100,
  GetFunc = function() 
      local raw = _G.R6Config.VehicleFlyMaxHeight or 20000
      local percent = math.floor(((raw - 1000) / 19000) * 100)
      if percent < 0 then percent = 0 end
      if percent > 100 then percent = 100 end
      return percent
  end,
  SetFunc = function(c, v) 
      local val = math.floor(1000 + (v / 100) * 19000 + 0.5)
      if val < 1000 then val = 1000 end
      if val > 20000 then val = 20000 end
      _G.R6Config.VehicleFlyMaxHeight = val
      if _G._vehicleFly then
          _G._vehicleFly.targetHeight = nil
          _G._vehicleFly.initialHeight = nil
          _G._vehicleFly.forceApply = true
      end
      return true 
  end 
},

-- Info
{ Key = "ModMenu_VehicleFly_Info", UI = AliasMap.Title, Text = "   Speed: " .. tostring(_G.R6Config.VehicleFlySpeed or 800) .. " | Height: " .. tostring(_G.R6Config.VehicleFlyMaxHeight or 20000), ExpandHandle = "ModMenu_VehicleFly_Ex" },

-- ============================================================
-- 🚗 FAST CAR (Mobil Super Cepat) - SAMA SEPERTI MENU LAIN
-- ============================================================
{ Key = "ModMenu_FastCar_Ex", UI = AliasMap.TitleSwitcher, Text = "FAST CAR (Mobil Super Cepat)", ExpandIndex = 0,
  GetFunc = function() 
      return _G.R6Config.FastCar == 1  -- ✅ return boolean
  end,
  SetFunc = function(c, v) 
      _G.R6Config.FastCar = v and 1 or 0  -- ✅ v adalah boolean
      print("[R6] Fast Car = " .. tostring(_G.R6Config.FastCar))
      return true 
  end 
},

-- Slider Kecepatan Maksimal
{ Key = "ModMenu_FastCar_Speed", UI = AliasMap.Slider, Text = "   Kecepatan Maks", ExpandHandle = "ModMenu_FastCar_Ex",
  MinValue = 0, MaxValue = 100, min = 0, max = 100,
  GetFunc = function() 
      local raw = _G.R6Config.FastCarSpeed or 10000
      local percent = math.floor(((raw - 100) / 19900) * 100)
      if percent < 0 then percent = 0 end
      if percent > 100 then percent = 100 end
      return percent
  end,
  SetFunc = function(c, v) 
      local val = math.floor(100 + (v / 100) * 19900 + 0.5)
      if val < 100 then val = 100 end
      if val > 20000 then val = 20000 end
      _G.R6Config.FastCarSpeed = val
      return true 
  end 
},

-- Info
{ Key = "ModMenu_FastCar_Info", UI = AliasMap.Title, Text = "   Speed: " .. tostring(_G.R6Config.FastCarSpeed or 10000), ExpandHandle = "ModMenu_FastCar_Ex" },
}


        -- ==================== DEFINE MENU PAGE ====================
        -- Tambahkan di dalam SettingPageDefine.ModMenu.Category
        SettingPageDefine.ModMenu = {
            Key = "ModMenu",
            Text = "R6 GAMING MENU",
            UIKey = "Setting_Page_Privacy",
            Category = {
                { Key = "Cat_ESP_Visual", Text = "ESP FEATURE", Stack = StackESPVisual },
                { Key = "Cat_Aimbot_Original", Text = "AIMBOT ORIGINAL", Stack = StackAimbotOriginal },
                { Key = "Cat_Aimbot_Force", Text = "AIMBOT FORCE", Stack = StackAimbotForce },
                { Key = "Cat_Combat_Graphic", Text = "OPTIMEZE VISUAL", Stack = StackCombatGraphic },
                { Key = "Cat_SkinMod", Text = "SKIN HACK MOD", Stack = StackSkinMod },
                { Key = "Cat_Wallhack", Text = "WALLHACK V2", Stack = StackWallhack }, -- TAMBAHKAN INI
                { Key = "Cat_Entertainment", Text = "FITUR HIBURAN", Stack = EntertainmentStack },
            }
        }

        table.insert(SettingCatalog, SettingPageDefine.ModMenu)
    end

    local UIManager = _G.UIManager
    if UIManager and not UIManager._IsModMenuHooked then
        local old_ShowUI = UIManager.ShowUI
        UIManager.ShowUI = function(config, ...)
            local args = {...}
            local n = select('#', ...)

            if config and config.keyName and (
                string.find(string.lower(config.keyName), "setting_main") or
                string.find(string.lower(config.keyName), "setting")
                ) then
                local catalog = args[1]
                if type(catalog) == "table" then
                    local hasModMenu = false
                    for _, page in ipairs(catalog) do
                        if type(page) == "table" and page.Key == "ModMenu" then
                            hasModMenu = true
                            break
                        end
                    end
                    if not hasModMenu then
                        table.insert(catalog, SettingPageDefine.ModMenu)
                    end
                end
            end
            local table_unpack = table.unpack or unpack
            return old_ShowUI(config, table_unpack(args, 1, n))
        end
        UIManager._IsModMenuHooked = true
    end
end

local function ShowR6gamingVIPMenu()
    if _G.R6gamingMenuAlreadyShown then return end
    if _G.R6gamingState.MenuStep ~= 0 then return end

    pcall(function()
        local Msg = require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end

        local function Step_ScamAlert()
            Msg.Show(1, "WARNING", "TELEGRAM : @RA6A09", function() local Web = require("client.slua.logic.url.logic_webview_sdk"); if Web and Web.OpenURL then Web:OpenURL("https://t.me/R6gamingreal") end end, function() end, "JOIN", "CLOSE")
            _G.R6gamingState.MenuStep = 99
            _G.R6gamingMenuAlreadyShown = true
        end

        local function Step_Welcome()
            Msg.Show(1, "WELCOME", "PAKS ESP LUA VIP BY TELEGRAM @RA6A09 FULLY SAFE & PLAY SMART AVOID REPORT",
            function()
                _G.InitModMenuTab()
                Notify("VIP MOD MENU BY @RA6A09 to toggle features!")
                Step_ScamAlert()
            end,
            function() end, "OKEY", "CLOSE")
        end

        _G.R6gamingState.MenuStep = 1
        Step_Welcome()
        Bypass2()
    end)
end

-- ==========================================
-- LOGIC 165 FPS IPAD VIEW
-- ==========================================
local function InitializeGraphicsUnlock()
    if isExpired then return end
    if _G.R6gamingState.GraphicsUnlocked or currentTime > limitTime then return end

    pcall(function()
        local SettingCfg = require("client.logic.setting.setting_config")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
        if SettingCfg then
            if SettingCfg.TpViewValue then SettingCfg.TpViewValue.max = 160 end
            if SettingCfg.FpViewValue then SettingCfg.FpViewValue.max = 160 end
        end
        if GraphicSettingDB then
            if GraphicSettingDB.TpViewValue then GraphicSettingDB.TpViewValue.max = 160 end
        end
    end)

    pcall(function()
        local logic_setting_graphics = require("client.slua.logic.setting.logic_setting_graphics")
        local GSC_FPS = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPS")
        local GSC_FPSFT = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_FPSFT")
        local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")

        local KismetMathLibrary = import("KismetMathLibrary") or _G.KismetMathLibrary
        local FLinearColor = import("LinearColor") or _G.FLinearColor

        if logic_setting_graphics then
            local old_SetFPS = logic_setting_graphics.SetFPS
            function logic_setting_graphics.SetFPS(gameInstance, FPSLevel)
                if old_SetFPS then old_SetFPS(gameInstance, FPSLevel) end
                if FPSLevel == 8 then
                    gameInstance:ExecuteCMD("t.MaxFPS", "165")
                    gameInstance:ExecuteCMD("r.FrameRateLimit", "165")
                end
            end
        end

        if GSC_FPS and GSC_FPS.__inner_impl then
            local fps_impl = GSC_FPS.__inner_impl
            function fps_impl:GetMaxFPSLevel() return 8, 8 end
            function fps_impl:InitRealSupportFPS()
                local RealSupportFPS = {}
                for i = 1, 8 do RealSupportFPS[i] = {true, true} end
                if GraphicSettingDB then GraphicSettingDB:UpdateUIData(GraphicSettingDB.RealSupportFPS, RealSupportFPS, false) end
                return RealSupportFPS
            end
            function fps_impl:UpdateSelectedFPSState(selectedLevel)
                if not slua.isValid(self.UIRoot) then return end
                for level = 2, 8 do
                    local name = "NodeFps" .. (({[2]=20,[3]=25,[4]=30,[5]=40,[6]=60,[7]=90,[8]=120})[level] or 120)
                    local widget = self.UIRoot[name]
                    if slua.isValid(widget) then
                        widget:SetIsEnabled(true)
                        pcall(function() widget:SetRenderOpacity(1.0) end)
                        local switcher = self.UIRoot["WidgetSwitcher_" .. level]
                        if slua.isValid(switcher) then
                            switcher:SetActiveWidgetIndex(level == selectedLevel and 0 or 1)
                        end
                    end
                end
            end
        end

        if GSC_FPSFT and GSC_FPSFT.__inner_impl then
            local ft_impl = GSC_FPSFT.__inner_impl
            local NMinFPS, NStep = 90, 5
            local function clamp(value, min, max)
                if value < min then return min end
                if max < value then return max end
                return value
            end
            local function lerp(a, b, t) return a + (b - a) * t end
            local function _getColorByPercent(start, finish, percent)
                if not FLinearColor then return nil end
                return FLinearColor(lerp(start.R, finish.R, percent), lerp(start.G, finish.G, percent), lerp(start.B, finish.B, percent), lerp(start.A, finish.A, percent))
            end

            ft_impl.ShowOrHide = function(self)
                self:SelfHitTestInvisible()
                if self.InitFPSFTSwitch then self:InitFPSFTSwitch() end
            end

            ft_impl.InitFPSFTSwitch = function(self)
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                if self.UIRoot.Setting_Switch then self.UIRoot.Setting_Switch:SetSwitcherEnable2(FPSFineTuneSwitch, true) end
                if self.UIRoot.CanvasPanel_8 then self:SetWidgetVisible(self.UIRoot.CanvasPanel_8, FPSFineTuneSwitch) end
                if self.UIRoot.WidgetSwitcher_0 then self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(2) end
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
            end

            ft_impl.InitFPSFTValue165 = function(self)
                local itemRoot = self.UIRoot
                local FPSFineTuneSwitch = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch)
                local FPSFineTuneNum = 165
                if FPSFineTuneSwitch then
                    FPSFineTuneNum = GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneNum) or 165
                    itemRoot.Slider_screen3:SetLocked(false)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 1.0, 1.0, 1.0))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 1.0, 1.0, 1.0))
                    end
                  else
                    itemRoot.Slider_screen3:SetLocked(true)
                    if FLinearColor then
                        itemRoot.ProgressBar_screen3:SetFillColorAndOpacity(FLinearColor(1.0, 0.625, 0.6, 1))
                        itemRoot.Slider_screen3:SetSliderHandleColor(FLinearColor(1.0, 0.625, 0.6, 1.0))
                    end
                end
                local FPSFineTunePer = (FPSFineTuneNum - NMinFPS) / (165 - NMinFPS)

                itemRoot.Veihclescreen3:SetText(tostring(FPSFineTuneNum))
                itemRoot.Slider_screen3:SetValue(FPSFineTunePer)
                itemRoot.ProgressBar_screen3:SetPercent(FPSFineTunePer)

                if FLinearColor then
                    local startColor = FLinearColor(1.0, 1.0, 1.0, 1.0)
                    local midColor = FLinearColor(1.0, 0.54, 0.11, 1.0)
                    local endColor = FLinearColor(1.0, 0.23, 0.15, 1.0)
                    local sliderColor = FPSFineTunePer < 0.4 and startColor or _getColorByPercent(midColor, endColor, (FPSFineTunePer - 0.4) / 0.6)
                    itemRoot.Slider_screen3:SetSliderHandleColor(sliderColor)
                end
            end

            ft_impl.OnFPSFTValueChange3 = function(self, FPSFineTuneNum)
                GraphicSettingDB:UpdateUIData(GraphicSettingDB.FPSFineTuneNum, FPSFineTuneNum)
                if self.InitFPSFTValue165 then self:InitFPSFTValue165() end
                if self:GetParentUI() then self:GetParentUI():SetDirty(true) end
                local gameInstance = GraphicSettingDB.GetGameInstance and GraphicSettingDB.GetGameInstance()
                if gameInstance then
                    gameInstance:ExecuteCMD("t.MaxFPS", tostring(FPSFineTuneNum))
                    gameInstance:ExecuteCMD("r.FrameRateLimit", tostring(FPSFineTuneNum))
                end
            end

            ft_impl.OnFPSFTSliderValueChange3 = function(self, value)
                if GraphicSettingDB:GetUIData(GraphicSettingDB.FPSFineTuneSwitch) and KismetMathLibrary then
                    local FPSFineTuneNum = KismetMathLibrary.FCeil(value * (165 - NMinFPS) / NStep) * NStep + NMinFPS
                    self:OnFPSFTValueChange3(clamp(FPSFineTuneNum, NMinFPS, 165))
                end
            end

            ft_impl.OnFPSFTAdd = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTAdd2 = ft_impl.OnFPSFTAdd3
            ft_impl.OnFPSFTMinus2 = ft_impl.OnFPSFTMinus3
            ft_impl.OnFPSFTSliderValueChange = ft_impl.OnFPSFTSliderValueChange3
            ft_impl.OnFPSFTSliderValueChange2 = ft_impl.OnFPSFTSliderValueChange3
        end
    end)
    _G.R6gamingState.GraphicsUnlocked = true
    Notify("Graphics & FPS 165Hz Unlocked (Upgraded Version)")
end

-- ==========================================
-- INITIALIZE THE ESP SYSTEM (BASED)
-- ==========================================
local function InitializeNativeESP()
    if _G.R6gamingState.NativeESPReady then return end
    pcall(function()
        local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
        local currentMarkCfg = GamePlayTools.GetCurrentConfig("ScreenMarkConfig")
        local function ApplyCfg(cfg)
            if not cfg then return end
            if cfg[1006] then
                cfg[1006].bBindBlocked = true;
                cfg[1006].bBindOutScreen = true;
                cfg[1006].MaxWidgetNum = 99
                cfg[1006].MaxShowDistance = 6000000;
                cfg[1006].bScaleByDistance = false
                cfg[1006].BindSocketName = "root";
                cfg[1006].bUseLuaWorldSocketName = true
                cfg[1006].WorldPositionOffset = FVector(0, 0, -30)
            end
            cfg[8888] = {
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99,
                MaxShowDistance = 6000000,
                bBindOutScreen = true,
                bBindBlocked = true,
                bIsBindingActor = true,
                BindSocketName = "head",
                bUseLuaWorldSocketName = true,
                WorldPositionOffset = FVector(0, 0, 30),
                bNeedPreLoad = true,
                Priority = 2
            }
            cfg[9999] = {
                UIPathName = "/Game/Mod/EvoBase/BluePrints/UIBP/QuickSign/QuickSign_TipHitEnemy_UIBP_New.QuickSign_TipHitEnemy_UIBP_New_C",
                MaxWidgetNum = 99,
                MaxShowDistance = 6000000,
                bBindOutScreen = true,
                bBindBlocked = true,
                bIsBindingActor = true,
                BindSocketName = "head",
                bUseLuaWorldSocketName = true,
                WorldPositionOffset = FVector(0, 0, 50),
                bNeedPreLoad = true,
                Priority = 2
            }
        end
        ApplyCfg(currentMarkCfg)
        for k, cfg in pairs(package.loaded) do
            if type(k) == "string" and string.find(k, "ScreenMarkConfig") and type(cfg) == "table" then
                ApplyCfg(cfg)
            end
        end
    end)
    _G.R6gamingState.NativeESPReady = true
    Notify("Native ESP System Initialized")
end

-- ==========================================
-- LOCAL FUNCTIONS CHO LOGIC NEW ESP - OPTIMIZED
-- ==========================================
local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime) < 3.0 then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if Valid(cachedMesh) then table.insert(validMeshes, cachedMesh) end
        end
        markData.CachedMeshes = validMeshes
        return validMeshes
    end

    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    if markData then
        markData.CachedMeshes = meshes
        markData.CachedMeshTime = curTime
    end
    return meshes
end



-- ==========================================
-- WEAPON MOD (EXPERT FITUR) - dipanggil di MainLoop
-- ==========================================
_G.ApplyWeaponMod = function(weapon)
    if not _G.R6gamingConfig.EnableWeaponMod then return end
    if not Valid(weapon) then return end

    pcall(function()
        local wid = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
        local cfg = _G.R6gamingConfig.WeaponMod[wid]
        if not cfg then return end

        local shootComp = weapon.ShootWeaponEntityComp or weapon.ShootWeaponEntity or weapon
        if not Valid(shootComp) then return end

        if cfg.FireSpeed then
            if shootComp.ShootInterval then shootComp.ShootInterval = 0.07 end
        end
        if cfg.InstanHit then
            if shootComp.BulletFireSpeed then shootComp.BulletFireSpeed = 150000 end
        end
        if cfg.FastSwitch then
            if shootComp.SwitchFromIdleToBackpackTime then shootComp.SwitchFromIdleToBackpackTime = 0 end
            if shootComp.SwitchFromBackpackToIdleTime then shootComp.SwitchFromBackpackToIdleTime = 0 end
        end
        if cfg.FastScope then
            if shootComp.WeaponAimInTime then shootComp.WeaponAimInTime = 7 end
        end
    end)
end


-- ============================================================
-- AIMBOT FORCE - SINKRON DENGAN MOD MENU
-- ============================================================

if _G.R6RegisterMod then 
    _G.R6RegisterMod("AIMBOT FORCE", "Loaded") 
end

local GameplayData = require("GameLua.GameCore.Data.GameplayData")

-- ============================================================
-- ⭐ AMBIL KONFIGURASI DARI MOD MENU (JANGAN OVERRIDE!)
-- ============================================================
_G.R6gamingConfig = _G.R6gamingConfig or {}
_G.R6gamingState = _G.R6gamingState or {}

-- ⭐ PASTIKAN CUSTOM TEXT DATA ADA (DARI MENU)
_G.R6gamingState.CustomTextData = _G.R6gamingState.CustomTextData or {
    AimTouchHipPrio = 1,
    AimTouchHipBone = 1,
    AimTouchHipCond = 1,
    AimTouchHipSpeed = 50,
    AimTouchHipFOV = 30,
    AimTouchHipDist = 250,
    AimTouchSGPrio = 1,
    AimTouchSGBone = 2,
    AimTouchSGCond = 1,
    AimTouchSGSpeed = 80,
    AimTouchSGFOV = 40,
    AimTouchSGDist = 30,
    AimTouchScopePrio = 1,
    AimTouchScopeBone = 2,
    AimTouchScopeCond = 1,
    AimTouchScopeSpeed = 40,
    AimTouchScopeFOV = 20,
    AimTouchScopeDist = 300,
    AimTouchScopePred = 0,
    AimTouchSniperPrio = 1,
    AimTouchSniperBone = 1,
    AimTouchSniperCond = 2,
    AimTouchSniperSpeed = 30,
    AimTouchSniperFOV = 20,
    AimTouchSniperDist = 400,
    AimTouchSniperPred = 0,
}

-- ⭐ JANGAN OVERRIDE! Biarkan nilai dari mod menu
-- Hanya set default jika belum ada
if _G.R6gamingConfig.AimTouchEnable == nil then
    _G.R6gamingConfig.AimTouchEnable = false
end

-- ============================================================
-- GET ENEMY TARGETS
-- ============================================================
local function GetEnemyTargetsFromActors(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return result end

    local allCharacters = {}
    if GameplayData.GetAllPlayerCharacters then
        allCharacters = GameplayData.GetAllPlayerCharacters()
    elseif GameplayData.GameCharacters then
        for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
    end

    local myTeam = player:GetTeamID()

    for _, actor in pairs(allCharacters) do
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

-- ============================================================
-- CHECK IS BOT
-- ============================================================
local function IsBot(pawn)
    if not slua.isValid(pawn) then return false end
    if pawn.bIsAI == true or pawn.IsAI == true then return true end
    local pState = pawn.PlayerState
    if slua.isValid(pState) and (pState.bIsABot or pState.bIsBot) then return true end
    return false
end

-- ============================================================
-- ⭐ MAIN AIMBOT FORCE
-- ============================================================
_G.AimTouch = function()
    pcall(function()
        -- ⭐ CEK DARI MOD MENU
        if not _G.R6gamingConfig.AimTouchEnable then return end
        
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end
        
        local pc = player:GetPlayerControllerSafety()
        if not slua.isValid(pc) then return end
        
        local isFiring = player.bIsWeaponFiring
        local isADS = player.bIsGunADS
        
        local weapon = player.WeaponManagerComponent and player.WeaponManagerComponent.CurrentWeaponReplicated
        if not weapon and type(player.GetCurrentShootWeapon) == "function" then
            weapon = player:GetCurrentShootWeapon()
        end
        
        local isShotgun = false
        local isSniper = false
        local currentAmmo = 1
        
        if slua.isValid(weapon) then
            local wID = type(weapon.GetWeaponID) == "function" and weapon:GetWeaponID() or 0
            local wName = type(weapon.GetWeaponName) == "function" and weapon:GetWeaponName() or ""
            
            if (wID >= 1030000 and wID < 1040000) or wName:find("S686") or wName:find("S1897") or wName:find("S12") or wName:find("DBS") or wName:find("M1014") then 
                isShotgun = true 
            end
            
            if wName:find("Kar98") or wName:find("M24") or wName:find("AWM") or wName:find("Mosin") or wName:find("Win94") or wName:find("AMR") or wName:find("SKS") or wName:find("SLR") or wName:find("Mini") or wName:find("Mk14") or wName:find("QBU") or wName:find("Mk12") or wName:find("VSS") then
                isSniper = true
            end
            
            if type(weapon.GetCurrentAmmo) == "function" then
                currentAmmo = weapon:GetCurrentAmmo()
            elseif weapon.ShootWeaponComponent and type(weapon.ShootWeaponComponent.GetCurrentAmmo) == "function" then
                currentAmmo = weapon.ShootWeaponComponent:GetCurrentAmmo()
            elseif weapon.CurrentAmmo ~= nil then
                currentAmmo = weapon.CurrentAmmo
            end
        end

        if _G.R6gamingState.IsAutoFiring then
            pcall(function()
                player.bIsWeaponFiring = false
                if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(false) end
                if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(false) end
                local wepMgr = player.WeaponManagerComponent
                if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = false end
            end)
            _G.R6gamingState.IsAutoFiring = false
        end

        if isShotgun and currentAmmo <= 0 then
            return
        end

        -- ⭐ AMBIL SETTING DARI MOD MENU
        local cond = 2
        local prioMode = 1
        local boneIdx = 1
        local speedVal = 50
        local fovVal = 30
        local maxDistMeters = 50
        local useVisCheck = false
        local igKnock = false
        local igBot = false
        local predVal = 0 

        if isShotgun and _G.R6gamingConfig.AimTouchSG then
            cond = _G.R6gamingState.CustomTextData.AimTouchSGCond or 1
            if _G.R6gamingConfig.AimTouchSGAutoFire then cond = 2 end
            if cond == 1 and not isFiring then return end
            prioMode = _G.R6gamingState.CustomTextData.AimTouchSGPrio or 1
            boneIdx = _G.R6gamingState.CustomTextData.AimTouchSGBone or 2
            speedVal = _G.R6gamingState.CustomTextData.AimTouchSGSpeed or 80
            fovVal = _G.R6gamingState.CustomTextData.AimTouchSGFOV or 40
            maxDistMeters = _G.R6gamingState.CustomTextData.AimTouchSGDist or 30
            useVisCheck = _G.R6gamingConfig.AimTouchSGVisCheck
            igKnock = _G.R6gamingConfig.AimTouchSGIgKnock
            igBot = _G.R6gamingConfig.AimTouchSGIgBot
            
        elseif isADS then
            if isSniper and _G.R6gamingConfig.AimTouchScopeSniper then
                cond = _G.R6gamingState.CustomTextData.AimTouchSniperCond or 2
                if cond == 1 and not isFiring then return end
                prioMode = _G.R6gamingState.CustomTextData.AimTouchSniperPrio or 1
                boneIdx = _G.R6gamingState.CustomTextData.AimTouchSniperBone or 1
                speedVal = _G.R6gamingState.CustomTextData.AimTouchSniperSpeed or 30
                fovVal = _G.R6gamingState.CustomTextData.AimTouchSniperFOV or 20
                maxDistMeters = _G.R6gamingState.CustomTextData.AimTouchSniperDist or 400
                useVisCheck = _G.R6gamingConfig.AimTouchSniperVisCheck
                igKnock = _G.R6gamingConfig.AimTouchSniperIgKnock
                igBot = _G.R6gamingConfig.AimTouchSniperIgBot
                predVal = _G.R6gamingState.CustomTextData.AimTouchSniperPred or 0
            elseif _G.R6gamingConfig.AimTouchScopeAll then
                cond = _G.R6gamingState.CustomTextData.AimTouchScopeCond or 1
                if cond == 1 and not isFiring then return end
                prioMode = _G.R6gamingState.CustomTextData.AimTouchScopePrio or 1
                boneIdx = _G.R6gamingState.CustomTextData.AimTouchScopeBone or 2
                speedVal = _G.R6gamingState.CustomTextData.AimTouchScopeSpeed or 40
                fovVal = _G.R6gamingState.CustomTextData.AimTouchScopeFOV or 20
                maxDistMeters = _G.R6gamingState.CustomTextData.AimTouchScopeDist or 300
                useVisCheck = _G.R6gamingConfig.AimTouchScopeVisCheck
                igKnock = _G.R6gamingConfig.AimTouchScopeIgKnock
                igBot = _G.R6gamingConfig.AimTouchScopeIgBot
                predVal = _G.R6gamingState.CustomTextData.AimTouchScopePred or 0
            else
                return
            end
        else
            if not _G.R6gamingConfig.AimTouchHipfire then return end
            cond = _G.R6gamingState.CustomTextData.AimTouchHipCond or 1
            if cond == 1 and not isFiring then return end 
            prioMode = _G.R6gamingState.CustomTextData.AimTouchHipPrio or 1
            boneIdx = _G.R6gamingState.CustomTextData.AimTouchHipBone or 1
            speedVal = _G.R6gamingState.CustomTextData.AimTouchHipSpeed or 50
            fovVal = _G.R6gamingState.CustomTextData.AimTouchHipFOV or 30
            maxDistMeters = _G.R6gamingState.CustomTextData.AimTouchHipDist or 250
            useVisCheck = _G.R6gamingConfig.AimTouchHipVisCheck
            igKnock = _G.R6gamingConfig.AimTouchHipIgKnock
            igBot = _G.R6gamingConfig.AimTouchHipIgBot
        end

        local currentMaxDist = maxDistMeters * 100 

        local enemies = GetEnemyTargetsFromActors(currentMaxDist)
        if not enemies or #enemies == 0 then return end
        
        local FVector2D = import("Vector2D")
        local UGameplayStatics = import("GameplayStatics")
        local KismetMathLibrary = import("KismetMathLibrary")
        
        local camManager = UGameplayStatics.GetPlayerCameraManager(pc, 0)
        if not slua.isValid(camManager) then return end
        
        local camLoc = camManager:GetCameraLocation()
        if not camLoc then return end
        
        local ui_util = require("client.common.ui_util")
        if not ui_util then return end
        
        local viewportSize = ui_util.GetViewportSize()
        if not viewportSize then return end
        
        local centerX = viewportSize.X * 0.5
        local centerY = viewportSize.Y * 0.5
        
        local FOV_RADIUS = (fovVal / 100.0) * (viewportSize.X / 2.0)
        
        local bestTarget = nil
        local bestScore = 99999999 
        
        local selBoneName = "head"
        if boneIdx == 1 then selBoneName = "head"
        elseif boneIdx == 2 then selBoneName = "spine_03"
        elseif boneIdx == 3 then selBoneName = "spine_01"
        elseif boneIdx == 4 then selBoneName = "pelvis" end

        for i, target in ipairs(enemies) do
            if not slua.isValid(target) then goto continue end
            
            pcall(function()
                if slua.isValid(target.Mesh) then
                    target.Mesh.MeshComponentUpdateFlag = 0
                end
            end)
            
            if igKnock and target.HealthStatus == 1 then goto continue end
            
            if igBot then
                if IsBot(target) then goto continue end
            end
            
            if useVisCheck then
                local curTime = os.clock()
                local tId = type(target.GetUniqueID) == "function" and target:GetUniqueID() or tostring(target)
                _G.AimTouchVisCache = _G.AimTouchVisCache or {}
                if not _G.AimTouchVisCache[tId] or (curTime - _G.AimTouchVisCache[tId].time) > 0.2 then
                    local isHidden = true
                    pcall(function() if pc:LineOfSightTo(target) then isHidden = false end end)
                    _G.AimTouchVisCache[tId] = { hidden = isHidden, time = curTime }
                end
                if _G.AimTouchVisCache[tId].hidden then goto continue end
            end
            
            local tPos = target:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.GetSocketLocation) == "function" then
                    tPos = target:GetSocketLocation(selBoneName)
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then
                if type(target.K2_GetActorLocation) == "function" then
                    tPos = target:K2_GetActorLocation()
                    if tPos then
                        if boneIdx == 1 then tPos.Z = tPos.Z + 70
                        elseif boneIdx == 2 then tPos.Z = tPos.Z + 40
                        elseif boneIdx == 3 then tPos.Z = tPos.Z + 20 end
                    end
                end
            end
            if not tPos or (tPos.X == 0 and tPos.Y == 0 and tPos.Z == 0) then goto continue end
            
            local screen = FVector2D()
            local success = pc:ProjectWorldLocationToScreen(tPos, screen, false)
            if not success or screen.X <= 0 or screen.Y <= 0 then goto continue end
            
            local dx = screen.X - centerX
            local dy = screen.Y - centerY
            local distScreen = math.sqrt(dx*dx + dy*dy)
            
            if distScreen > FOV_RADIUS then goto continue end
            
            local currentScore = distScreen
            if prioMode == 2 then currentScore = player:GetDistanceTo(target)
            elseif prioMode == 3 then currentScore = target.Health or 100
            elseif prioMode == 4 then 
                local hp = target.Health or 100
                local maxhp = target.HealthMax or 100
                if maxhp <= 0 then maxhp = 100 end
                currentScore = hp / maxhp
            end
            
            if currentScore < bestScore then
                bestScore = currentScore
                bestTarget = target
            end
            
            ::continue::
        end
        
        if not slua.isValid(bestTarget) then return end
        
        local finalBonePos = bestTarget:GetBonePos(selBoneName, {X=0, Y=0, Z=0})
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.GetSocketLocation) == "function" then
                finalBonePos = bestTarget:GetSocketLocation(selBoneName)
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then
            if type(bestTarget.K2_GetActorLocation) == "function" then
                finalBonePos = bestTarget:K2_GetActorLocation()
                if finalBonePos then
                    if boneIdx == 1 then finalBonePos.Z = finalBonePos.Z + 70
                    elseif boneIdx == 2 then finalBonePos.Z = finalBonePos.Z + 40
                    elseif boneIdx == 3 then finalBonePos.Z = finalBonePos.Z + 20 end
                end
            end
        end
        if not finalBonePos or (finalBonePos.X == 0 and finalBonePos.Y == 0 and finalBonePos.Z == 0) then return end
        
        if predVal > 0 then
            pcall(function()
                local tVelocity = nil
                if type(bestTarget.GetVelocity) == "function" then
                    tVelocity = bestTarget:GetVelocity()
                end
                
                if tVelocity and (tVelocity.X ~= 0 or tVelocity.Y ~= 0) then
                    local distToEnemy = player:GetDistanceTo(bestTarget) / 100.0
                    local ToF = (distToEnemy / 800.0) * (predVal / 50.0) 
                    finalBonePos.X = finalBonePos.X + (tVelocity.X * ToF)
                    finalBonePos.Y = finalBonePos.Y + (tVelocity.Y * ToF)
                end
            end)
        end

        local rot = KismetMathLibrary.FindLookAtRotation(camLoc, finalBonePos)
        if not rot then return end
        
        local currentRot = pc:GetControlRotation()
        if not currentRot then return end
        
        local deltaYaw = rot.Yaw - currentRot.Yaw
        local deltaPitch = rot.Pitch - currentRot.Pitch
        
        if isADS then
            local camRot = nil
            if type(camManager.GetCameraRotation) == "function" then
                camRot = camManager:GetCameraRotation()
            end
            if camRot then
                deltaYaw = deltaYaw - (camRot.Yaw - currentRot.Yaw)
                deltaPitch = deltaPitch - (camRot.Pitch - currentRot.Pitch)
            end
        end

        if deltaYaw > 180 then deltaYaw = deltaYaw - 360 end
        if deltaYaw < -180 then deltaYaw = deltaYaw + 360 end
        if deltaPitch > 180 then deltaPitch = deltaPitch - 360 end
        if deltaPitch < -180 then deltaPitch = deltaPitch + 360 end
        
        local smoothFactor = 0.0
        if speedVal >= 100 then
            smoothFactor = 1.0
        else
            smoothFactor = (speedVal / 100.0) * 0.3
            if smoothFactor < 0.01 then smoothFactor = 0.01 end
        end
        
        local finalPitch = currentRot.Pitch + (deltaPitch * smoothFactor)
        local finalYaw = currentRot.Yaw + (deltaYaw * smoothFactor)

        -- ⭐ ANTI OVERHEAD (No Recoil) - CEK DARI MOD MENU
        if isADS and _G.R6gamingConfig.AntiOverheadScopeAll then
            local weaponManager = player.WeaponManagerComponent
            if slua.isValid(weaponManager) then
                local currentWeapon = weaponManager.CurrentWeaponReplicated
                if slua.isValid(currentWeapon) then
                    local shootComp = currentWeapon.ShootWeaponComponent
                    if slua.isValid(shootComp) then
                        local entity = shootComp.ShootWeaponEntityComponent
                        if slua.isValid(entity) then
                            entity.RecoilKick = 0.0
                            entity.RecoilKickADS = 0.0
                            entity.AnimationKick = 0.0
                        end
                    end
                end
            end
        end

        local finalRot = { Pitch = finalPitch, Yaw = finalYaw, Roll = 0 }
        pc:SetControlRotation(finalRot, "AimTouch")
        
        -- ⭐ AUTO FIRE UNTUK SHOTGUN
        if isShotgun and _G.R6gamingConfig.AimTouchSGAutoFire then
            pcall(function()
                local distToTarget = player:GetDistanceTo(bestTarget) / 100
                if distToTarget <= maxDistMeters then
                    player.bIsWeaponFiring = true
                    if type(player.SetIsWeaponFiring) == "function" then player:SetIsWeaponFiring(true) end
                    if slua.isValid(pc) and type(pc.SetIsWeaponFiring) == "function" then pc:SetIsWeaponFiring(true) end
                    local wepMgr = player.WeaponManagerComponent
                    if slua.isValid(wepMgr) then wepMgr.bIsWeaponFiring = true end
                    
                    local currentWep = player:GetCurrentWeapon()
                    if slua.isValid(currentWep) and type(currentWep.StartFire) == "function" then 
                        currentWep:StartFire() 
                    end
                    _G.R6gamingState.IsAutoFiring = true
                end
            end)
        end

    end)
end

-- ============================================================
-- ⭐ REGISTRASI KE LOADER (PAKAI R6AddTick)
-- ============================================================
local function AimbotTick()
    if _G.R6gamingConfig.AimTouchEnable then
        _G.AimTouch()
    end
end

-- ⭐ CEK APAKAH LOADER PUNYA R6AddTick
if _G.R6AddTick then
    _G.R6AddTick(AimbotTick)
    print("[AIMBOT] ✅ Registered to R6AddTick")
else
    -- FALLBACK: PAKAI TIME_TICKER LANGSUNG
    local function AimbotLoop()
        AimbotTick()
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.016, AimbotLoop)
        end
    end
    
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, AimbotLoop)
    end
    print("[AIMBOT] ✅ Running with time_ticker fallback")
end

-- ============================================================
-- ⭐ INISIALISASI
-- ============================================================
local function InitAimbot()
    print("[AIMBOT] ════════════════════════════════════════")
    print("[AIMBOT] 📌 Aimbot Force Loaded!")
    print("[AIMBOT] ✅ AimTouchEnable: " .. tostring(_G.R6gamingConfig.AimTouchEnable))
    print("[AIMBOT] ✅ Hipfire: " .. tostring(_G.R6gamingConfig.AimTouchHipfire))
    print("[AIMBOT] ✅ Shotgun: " .. tostring(_G.R6gamingConfig.AimTouchSG))
    print("[AIMBOT] ✅ Scope All: " .. tostring(_G.R6gamingConfig.AimTouchScopeAll))
    print("[AIMBOT] ✅ Sniper: " .. tostring(_G.R6gamingConfig.AimTouchScopeSniper))
    print("[AIMBOT] ✅ R6AddTick: " .. tostring(_G.R6AddTick ~= nil))
    print("[AIMBOT] ════════════════════════════════════════")
end

pcall(function()
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.5, InitAimbot)
    end
end)


-- ==========================================
-- ESP7_SOLUONG - PAKAI R6AddTick (SEPERTI AIMBOT)
-- ==========================================

-- WIDGET UI
local BTN_BP = "/Game/UMG/UI_BP/Common/BaseComponent/CommonBaseComponent_TextButton_UIBP.CommonBaseComponent_TextButton_UIBP"
local EnemyCounterWidget = nil
local LastCounterTime = 0

function _G.CleanUpEnemyCounterWidget()
    if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
        EnemyCounterWidget:RemoveFromParent()
    end
    EnemyCounterWidget = nil
end

local function CreateEnemyCounterWidget()
    if EnemyCounterWidget then
        if slua.isValid(EnemyCounterWidget) then return EnemyCounterWidget else EnemyCounterWidget = nil end
    end

    pcall(function()
        local btn = slua.loadUI(BTN_BP)
        if not btn or not slua.isValid(btn) then return end
        require("game_frontend_hud").AddToContainer(UIContainers.Top, btn, 10500)
        
        if btn.RichText_Content then
            btn.RichText_Content:SetText("Musuh: 0  |  Terdekat: 0m")
            local fontInfo = btn.RichText_Content.Font
            if fontInfo then fontInfo.Size = 16 btn.RichText_Content:SetFont(fontInfo) end
        end
        
        local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
        local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(btn)
        if slot then
            slot:SetAnchors(FAnchors(0.5, 0, 0.5, 0))
            slot:SetAlignment(FVector2D(0.5, 0))
            slot:SetPosition(FVector2D(0, 30))
            slot:SetSize(FVector2D(240, 36))
        end
        btn:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        EnemyCounterWidget = btn
    end)
    return EnemyCounterWidget
end

-- FUNGSI HITUNG COUNTER
local function _M_DrawCounter()
    pcall(function()
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        local player = GameplayData.GetPlayerCharacter()
        
        if not slua.isValid(player) then 
            if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
                EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
            return 
        end

        local widgetCounter = CreateEnemyCounterWidget()
        if widgetCounter and slua.isValid(widgetCounter) then
            widgetCounter:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end

        local curTime = os.clock()
        if (curTime - LastCounterTime) > 0.5 then
            LastCounterTime = curTime
            
            local myTeam = player.TeamID or (type(player.GetTeamID) == "function" and player:GetTeamID()) or 0
            local count = 0
            local nearest = 9999

            local allCharacters = {}
            if GameplayData.GetAllPlayerCharacters then
                allCharacters = GameplayData.GetAllPlayerCharacters()
            elseif GameplayData.GameCharacters then
                for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
            end

            for _, tPawn in pairs(allCharacters) do
                if slua.isValid(tPawn) and tPawn ~= player then
                    local isAlive = false
                    if tPawn.HealthStatus ~= nil then
                        isAlive = (tPawn.HealthStatus ~= 2)
                    else
                        isAlive = (tPawn.Health or 0) > 0 or (type(tPawn.IsAlive) == "function" and tPawn:IsAlive())
                    end
                    
                    if isAlive then
                        local tTeam = tPawn.TeamID or (type(tPawn.GetTeamID) == "function" and tPawn:GetTeamID()) or 0
                        if tTeam ~= myTeam then
                            count = count + 1
                            local d = math.floor(player:GetDistanceTo(tPawn) / 100)
                            if d < nearest then nearest = d end
                        end
                    end
                end
            end

            if widgetCounter and widgetCounter.RichText_Content then
                widgetCounter.RichText_Content:SetText(string.format(
                    "Musuh Di Sekitar: %d  |  Terdekat: %dm", 
                    count, count > 0 and nearest or 0
                ))
            end
        end
    end)
end

-- ============================================================
-- ⭐ REGISTRASI KE R6AddTick (SEPERTI AIMBOT FORCE)
-- ============================================================
local function ESP7Tick()
    if _G.R6gamingConfig.EspLoai7 and _G.R6gamingConfig.Esp7_SoLuong then
        _M_DrawCounter()
    else
        if EnemyCounterWidget and slua.isValid(EnemyCounterWidget) then
            EnemyCounterWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
    end
end

-- ⭐ CEK APAKAH LOADER PUNYA R6AddTick
if _G.R6AddTick then
    _G.R6AddTick(ESP7Tick)
    print("[ESP7] ✅ Registered to R6AddTick")
else
    -- FALLBACK: PAKAI TIME_TICKER LANGSUNG
    local function ESP7Loop()
        ESP7Tick()
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.2, ESP7Loop)  -- 0.2 detik (5 FPS) cukup untuk counter
        end
    end
    
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.5, ESP7Loop)
    end
    print("[ESP7] ✅ Running with time_ticker fallback")
end

-- ============================================================
-- ⭐ INISIALISASI
-- ============================================================
local function InitESP7()
    print("[ESP7] ════════════════════════════════════════")
    print("[ESP7] 📌 ESP7_SoLuong Loaded!")
    print("[ESP7] ✅ EspLoai7: " .. tostring(_G.R6gamingConfig.EspLoai7))
    print("[ESP7] ✅ Esp7_SoLuong: " .. tostring(_G.R6gamingConfig.Esp7_SoLuong))
    print("[ESP7] ✅ R6AddTick: " .. tostring(_G.R6AddTick ~= nil))
    print("[ESP7] ════════════════════════════════════════")
end

pcall(function()
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.5, InitESP7)
    end
end)

-- ==========================================
-- MAIN LOOP: EXTREMELY POWERFUL OPTIMIZED
-- ==========================================
local function MainLoop()
    if isExpired then return end

    if _G.R6gamingState.CustomTextData == nil then
        _G.R6gamingState.CustomTextData = {OuterSpeed = 10, InnerSpeed = 10, MagicHead = 1.0, MagicBody = 1.0, MagicLegs = 1.0, IpadViewFOV = 120, AimTouchHipPrio = 1, AimTouchHipBone = 1, AimTouchHipCond = 1, AimTouchHipSpeed = 50, AimTouchHipFOV = 30, AimTouchHipDist = 250, AimTouchSGPrio = 1, AimTouchSGBone = 2, AimTouchSGCond = 1, AimTouchSGSpeed = 80, AimTouchSGFOV = 40, AimTouchSGDist = 30, AimTouchScopePrio = 1, AimTouchScopeBone = 2, AimTouchScopeCond = 1, AimTouchScopeSpeed = 40, AimTouchScopeFOV = 20, AimTouchScopeDist = 300, AimTouchSniperPrio = 1, AimTouchSniperBone = 1, AimTouchSniperCond = 2, AimTouchSniperSpeed = 30, AimTouchSniperFOV = 20, AimTouchSniperDist = 400}
    end

    local okData, GameplayData = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if not okData or not GameplayData then return end
    local pc = GameplayData.GetPlayerController()
    local localPlayer = nil
    if Valid(pc) then
        localPlayer = pc:GetPlayerCharacterSafety()
    end

    if not Valid(localPlayer) then
        if _G.R6gamingState.TrackedMarks then
            for markId, _ in pairs(_G.R6gamingState.TrackedMarks) do
                SafeRemoveMark(markId)
            end
        end
        _G.R6gamingState.TrackedMarks = {}

        for key, data in pairs(_G.R6gamingState.EnemyMarks) do
            if data and data.MIDs then
                for meshStr, midTable in pairs(data.MIDs) do
                    for k, _ in pairs(midTable) do midTable[k] = nil end
                end
                data.MIDs = nil
            end
        end

        _G.R6gamingState.EnemyMarks = {}
        _G.AK_OrigHitboxes = {}
        _G.AK_ModdedPhysAssets = {}
        _G.R6gamingState.PrevGraphicsState = {}
        return
    end


    -- ====== EKSEKUSI BYPASS (AMAN UNTUK SKIN) ======
    if not _G.R6gamingState.BypassExecuted then
        _G.StartBypass_VIP_v3()
        if _G.InitializeSkinModSystem then _G.InitializeSkinModSystem() end
        _G.R6gamingState.BypassExecuted = true
        Notify("Bypass & Skin Protection Active!")
    end

    local Cached_PPM = nil
    pcall(function() Cached_PPM = import("PostProcessManager").GetInstance() end)
    local Cached_SecurityCommonUtils = nil
    pcall(function() Cached_SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils") end)
    local Cached_MyHUD = pc and pc.MyHUD or nil

    if _G.R6gamingConfig.UnlockFPS then InitializeGraphicsUnlock() end
    InitializeNativeESP()
    ShowR6gamingVIPMenu()    
    if _G.R6gamingConfig.IpadView and _G.R6gamingState.CustomTextData then
        pcall(function()
            local targetTPP = _G.R6gamingState.CustomTextData.IpadViewFOV or 120
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= targetTPP then uTPPCam.FieldOfView = targetTPP end
            end
        end)
      else
        pcall(function()
            local uTPPCam = localPlayer.ThirdPersonCameraComponent
            if Valid(uTPPCam) and not localPlayer.bIsWeaponAiming then
                if uTPPCam.FieldOfView ~= 90 then uTPPCam.FieldOfView = 90 end
            end
        end)
    end

    -- ==========================================
    -- SKIN MOD LOOP + DEADBOX + KILL COUNTER
    -- ==========================================
    _G.R6gamingConfig.ModSkin = _G.R6gamingConfig.Skin1Enabled or _G.R6gamingConfig.Skin2Enabled or _G.R6gamingConfig.Skin3Enabled or _G.R6gamingConfig.DeadboxEnabled or _G.R6gamingConfig.KillCounterEnabled

    if _G.R6gamingConfig.ModSkin then
        if not _G.TDSkinLoopStarted then
            if _G.InitializeSkinModSystem then _G.InitializeSkinModSystem() end
            if _G.ForceRefreshSkinMaps then _G.ForceRefreshSkinMaps() end
            if _G.R6gamingConfig.KillCounterEnabled and not _G.KillInfoCounterHacked then _G.ForceEnableKillCounterUI() end
            _G.TDSkinLoopStarted = true
        end

        _G.R6gamingState.SkinWasApplied = true
        local curTime = os.clock()
        if not _G.LastSkinUpdateTime or (curTime - _G.LastSkinUpdateTime) > 1.5 then
            _G.LastSkinUpdateTime = curTime
            pcall(function()
                local isAlive = type(localPlayer.IsAlive) == "function" and localPlayer:IsAlive() or true
                if isAlive then
                    if _G.ReadLiveConfig then _G.ReadLiveConfig() end

                    if _G.R6gamingConfig.Skin1Enabled then
                        if _G.equip_character_avatar then _G.equip_character_avatar(localPlayer) end
                    end

                    if _G.R6gamingConfig.Skin2Enabled then
                        if _G.ApplyWeaponSkins then _G.ApplyWeaponSkins(localPlayer) end
                    end

                    if _G.R6gamingConfig.Skin3Enabled then
                        if _G.ApplyVehicleSkins then _G.ApplyVehicleSkins(localPlayer) end
                    end

                    if _G.HandlePetLogic then _G.HandlePetLogic() end

                    if _G.R6gamingConfig.DeadboxEnabled then
                        if _G.DeadBox_TemperRequest and _G.NeedCheckDeadBoxTimer > 0 then _G.DeadBox_TemperRequest(pc) end
                    end
                end
            end)
        end
      else
        if _G.R6gamingState.SkinWasApplied then
            _G.OutfitMap = {}
            _G.WeaponSkinMap = {}
            _G.VehicleSkinMap = {}
            pcall(function()
                local WeaponManager = localPlayer:GetWeaponManager()
                if Valid(WeaponManager) then
                    for slot = 1, 3 do
                        local Weapon = WeaponManager:GetInventoryWeaponByPropSlot(slot)
                        if Valid(Weapon) and Valid(Weapon.synData) then
                            local WeaponID = Weapon:GetWeaponID()
                            local SkinData = Weapon.synData:Get(7)
                            if SkinData and SkinData.defineID then
                                SkinData.defineID.TypeSpecificID = WeaponID
                                Weapon.synData:Set(7, SkinData)
                                if Weapon.SetWeaponAvatarID then pcall(function() Weapon:SetWeaponAvatarID(WeaponID) end) end
                                if Weapon.DelayHandleAvatarMeshChanged then pcall(function() Weapon:DelayHandleAvatarMeshChanged() end) end
                            end
                        end
                    end
                end
                local Vehicle = localPlayer:GetCurrentVehicle()
                if Valid(Vehicle) then
                    local VehicleAvatar = Vehicle.VehicleAvatar or Vehicle.VehicleAvatarComponent_BP or Vehicle:GetAvatarComponent()
                    if Valid(VehicleAvatar) and type(VehicleAvatar.GetDefaultAvatarID) == "function" then
                        local defId = VehicleAvatar:GetDefaultAvatarID()
                        if VehicleAvatar.ChangeItemAvatar then VehicleAvatar:ChangeItemAvatar(defId, true) end
                    end
                end
                if localPlayer.AvatarComponent2 and type(localPlayer.AvatarComponent2.OnRep_BodySlotStateChanged) == "function" then
                    localPlayer.AvatarComponent2:OnRep_BodySlotStateChanged()
                end
            end)
            _G.R6gamingState.SkinWasApplied = false
        end
        _G.TDSkinLoopStarted = false
    end

    -- ==========================================
    -- WEAPON MODS (NoShake, AntiOverheadScopeAll, MagicBullet, AutoHead, Aimbot, WeaponMod)
    -- ==========================================
    pcall(function()
        local weapon = nil
        pcall(function()
            local weaponManager = localPlayer.WeaponManagerComponent
            if Valid(weaponManager) and type(weaponManager.GetCurrentWeapon) == "function" then
                weapon = weaponManager:GetCurrentWeapon()
            end
        end)
        if not Valid(weapon) then
            if type(localPlayer.GetCurrentShootWeapon) == "function" then weapon = localPlayer:GetCurrentShootWeapon()
              elseif type(localPlayer.GetCurrentWeapon) == "function" then weapon = localPlayer:GetCurrentWeapon() end
        end

        if Valid(weapon) then
            -- Apply Weapon Mod (EXPERT FITUR)
            _G.ApplyWeaponMod(weapon)

            local entities = {}
            if Valid(weapon.ShootWeaponEntity_GEN_VARIABLE) then table.insert(entities, weapon.ShootWeaponEntity_GEN_VARIABLE) end
            if Valid(weapon.ShootWeaponEntity) then table.insert(entities, weapon.ShootWeaponEntity) end
            if Valid(weapon.ShootWeaponComponent) and Valid(weapon.ShootWeaponComponent.ShootWeaponEntityComponent) then
                table.insert(entities, weapon.ShootWeaponComponent.ShootWeaponEntityComponent)
            end

            for _, entity in ipairs(entities) do
                local anyWeaponModOn = _G.R6gamingConfig.LessShake or _G.R6gamingConfig.Accuracy or _G.R6gamingConfig.Crosshair or _G.R6gamingConfig.AutoHead or _G.R6gamingConfig.CustomAimbot or _G.R6gamingConfig.CustomAimbotClose or _G.R6gamingConfig.CustomMagicBullet or _G.R6gamingConfig.NoShake or _G.R6gamingConfig.AntiOverheadScopeAll or _G.R6gamingConfig.EnableWeaponMod

                if anyWeaponModOn then
                    if not entity.OriginalStatsCached then
                        entity.OriginalStatsCached = {
                            GameDeviationFactor = entity.GameDeviationFactor,
                            GameDeviationAccuracy = entity.GameDeviationAccuracy,
                            BulletFireSpeed = entity.BulletFireSpeed,
                            ShootInterval = entity.ShootInterval,
                            BaseDamage = entity.BaseDamage,
                            AccessoriesHRecoilFactor = entity.AccessoriesHRecoilFactor,
                            AccessoriesVRecoilFactor = entity.AccessoriesVRecoilFactor,
                            RecoilKick = entity.RecoilKick,
                            RecoilKickADS = entity.RecoilKickADS,
                            AnimationKick = entity.AnimationKick
                        }
                    end

                    if _G.R6gamingConfig.LessShake then entity.RecoilKickADS = 0.0; entity.RecoilKick = 0.0 end
                    if _G.R6gamingConfig.Accuracy then entity.GameDeviationAccuracy = 0.0 end
                    if _G.R6gamingConfig.Crosshair then entity.GameDeviationFactor = 0.0 end
                    if _G.R6gamingConfig.CustomMagicBullet then
                        entity.BaseDamage = entity.BaseDamage * (_G.R6gamingState.CustomTextData.MagicHead or 1.0)
                    end

                    if _G.R6gamingConfig.NoShake then
                        entity.AnimationKick = 0.0
                    end

                    if localPlayer.bIsGunADS and _G.R6gamingConfig.AntiOverheadScopeAll then
                        entity.RecoilKick = 0.0
                        entity.RecoilKickADS = 0.0
                    end

                    if entity.AutoAimingConfig then
                        if not entity.OriginalAutoAimCached then
                            entity.OriginalAutoAimCached = {
                                OuterSpeed = entity.AutoAimingConfig.OuterRange and entity.AutoAimingConfig.OuterRange.Speed,
                                InnerSpeed = entity.AutoAimingConfig.InnerRange and entity.AutoAimingConfig.InnerRange.Speed
                            }
                        end

                        if _G.R6gamingConfig.AutoHead then
                            pcall(function() entity.AutoAimingConfig.Bones = { "Head", "Head", "Head" } end)
                        end

                        if _G.R6gamingConfig.CustomAimbot then
                            local speed = _G.R6gamingState.CustomTextData.OuterSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.RangeRate = 4.5
                                entity.AutoAimingConfig.OuterRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.OuterRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.OuterRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.OuterRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.OuterRange.ProneRate = 1.0
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.RangeRate = 4.5
                                entity.AutoAimingConfig.InnerRange.SpeedRate = 1.3
                                entity.AutoAimingConfig.InnerRange.RangeRateSight = 1.8
                                entity.AutoAimingConfig.InnerRange.SpeedRateSight = 2.2
                                entity.AutoAimingConfig.InnerRange.CrouchRate = 1.1
                                entity.AutoAimingConfig.InnerRange.ProneRate = 1.0
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                          elseif _G.R6gamingConfig.CustomAimbotClose then
                            local speed = _G.R6gamingState.CustomTextData.InnerSpeed or 10
                            if entity.AutoAimingConfig.OuterRange then
                                entity.AutoAimingConfig.OuterRange.Speed = speed
                                entity.AutoAimingConfig.OuterRange.DyingRate = 0.0
                            end
                            if entity.AutoAimingConfig.InnerRange then
                                entity.AutoAimingConfig.InnerRange.Speed = speed
                                entity.AutoAimingConfig.InnerRange.DyingRate = 0.0
                            end
                        end
                    end

                    entity.R6gamingWeaponModsActive = true

                  elseif entity.R6gamingWeaponModsActive then
                    if entity.OriginalStatsCached then
                        local orig = entity.OriginalStatsCached
                        entity.GameDeviationFactor = orig.GameDeviationFactor
                        entity.GameDeviationAccuracy = orig.GameDeviationAccuracy
                        entity.BulletFireSpeed = orig.BulletFireSpeed
                        entity.ShootInterval = orig.ShootInterval
                        entity.BaseDamage = orig.BaseDamage
                        entity.AccessoriesHRecoilFactor = orig.AccessoriesHRecoilFactor
                        entity.AccessoriesVRecoilFactor = orig.AccessoriesVRecoilFactor
                        entity.RecoilKick = orig.RecoilKick
                        entity.RecoilKickADS = orig.RecoilKickADS
                        entity.AnimationKick = orig.AnimationKick
                    end
                    if entity.AutoAimingConfig and entity.OriginalAutoAimCached then
                        pcall(function() entity.AutoAimingConfig.Bones = { "Spine_01", "Pelvis", "Head" } end)
                        if entity.AutoAimingConfig.OuterRange and entity.OriginalAutoAimCached.OuterSpeed then
                            entity.AutoAimingConfig.OuterRange.Speed = entity.OriginalAutoAimCached.OuterSpeed
                        end
                        if entity.AutoAimingConfig.InnerRange and entity.OriginalAutoAimCached.InnerSpeed then
                            entity.AutoAimingConfig.InnerRange.Speed = entity.OriginalAutoAimCached.InnerSpeed
                        end
                    end
                    entity.R6gamingWeaponModsActive = false
                end
            end
        end
    end)

    -- ==========================================
    -- GRAPHICS COMMANDS (Black Sky, Remove Fog, Remove Grass, White Body, ColorBodyV2)
    -- ==========================================
    pcall(function()
        local lsg = require("client.slua.logic.setting.logic_setting_graphics")
        local gi = lsg.GetGameInstance()
        if gi then

            -- Black Sky
            if _G.R6gamingConfig.BlackSky and not _G.R6gamingState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.SkyLighting", "0")
                gi:ExecuteCMD("r.SkyAtmosphere", "0")
                gi:ExecuteCMD("r.SkylightIntensityMultiplier", "0")
                _G.R6gamingState.PrevGraphicsState.BlackSky = true
              elseif not _G.R6gamingConfig.BlackSky and _G.R6gamingState.PrevGraphicsState.BlackSky then
                gi:ExecuteCMD("r.SkyLighting", "1")
                gi:ExecuteCMD("r.SkyAtmosphere", "1")
                gi:ExecuteCMD("r.SkylightIntensityMultiplier", "1")
                _G.R6gamingState.PrevGraphicsState.BlackSky = false
            end
        end
    end)

    -- ==========================================
    -- MAGIC BULLET HITBOX SCALING
    -- ==========================================
    local mHead_Global, mBody_Global, mLegs_Global = 1.0, 1.0, 1.0
    local runInject_Global = false

    pcall(function()
        if _G.R6gamingConfig.CustomMagicBullet then
            runInject_Global = true
            mHead_Global = 1.0; mBody_Global = 1.0; mLegs_Global = 1.0
            if _G.R6gamingState.CustomTextData then
                local cData = _G.R6gamingState.CustomTextData
                if cData.MagicHead ~= nil then mHead_Global = tonumber(cData.MagicHead) or mHead_Global end
                if cData.MagicBody ~= nil then mBody_Global = tonumber(cData.MagicBody) or mBody_Global end
                if cData.MagicLegs ~= nil then mLegs_Global = tonumber(cData.MagicLegs) or mLegs_Global end
            end
          elseif _G.R6gamingConfig.MagicBullet then
            runInject_Global = true
            mHead_Global = 1.05; mBody_Global = 1.0; mLegs_Global = 1.0
        end

        if runInject_Global then
            local currentMagicHash = "M_"..tostring(mHead_Global).."_"..tostring(mBody_Global).."_"..tostring(mLegs_Global)
            if _G.R6gamingState.LastMagicConfigHash ~= currentMagicHash then
                _G.R6gamingState.MagicUpdateVersion = (_G.R6gamingState.MagicUpdateVersion or 0) + 1
                _G.R6gamingState.LastMagicConfigHash = currentMagicHash
            end
          else
            if _G.R6gamingState.LastMagicConfigHash ~= "OFF" then
                _G.R6gamingState.MagicUpdateVersion = (_G.R6gamingState.MagicUpdateVersion or 0) + 1
                _G.R6gamingState.LastMagicConfigHash = "OFF"
            end
        end
    end)

    -- ==========================================
    -- ESP & ENEMY LOOP
    -- ==========================================
    pcall(function()
        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then allCharacters = GameplayData.GetAllPlayerCharacters()
          elseif GameplayData.GameCharacters then for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end end

        local currentValidKeys = {}
        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer then
                currentValidKeys[GetSafeEnemyKey(enemy)] = true
            end
        end

        for key, data in pairs(_G.R6gamingState.EnemyMarks) do
            if not currentValidKeys[key] then
                SafeRemoveMark(data.radarMark)
                SafeRemoveMark(data.hpMark)
                SafeRemoveMark(data.distMark)

                if _G.AimTouchVisCache and _G.AimTouchVisCache[key] then
                    _G.AimTouchVisCache[key] = nil
                end

                if data.MIDs then
                    for meshStr, midTable in pairs(data.MIDs) do
                        for k, _ in pairs(midTable) do
                            midTable[k] = nil
                        end
                    end
                    data.MIDs = nil
                end

                data.enemy = nil
                data.CachedMeshes = nil
                _G.R6gamingState.EnemyMarks[key] = nil
            end
        end

        local realCount = 0
        local aiCount = 0

        local function GetFirstElemSafe(elemArray)
            if elemArray and type(elemArray.Num) == "function" and elemArray:Num() > 0 then
                if type(elemArray.Get) == "function" then return elemArray:Get(0) end
              elseif elemArray and type(elemArray) == "table" and #elemArray > 0 then
                return elemArray[1]
            end
            return nil
        end

        local BoneScaleMap = {
            ["head"] = mHead_Global, ["neck_01"] = mHead_Global,
            ["pelvis"] = mBody_Global, ["spine_01"] = mBody_Global, ["spine_02"] = mBody_Global, ["spine_03"] = mBody_Global,
            ["thigh_l"] = mLegs_Global, ["thigh_r"] = mLegs_Global,
            ["calf_l"] = mLegs_Global, ["calf_r"] = mLegs_Global,
            ["foot_l"] = mLegs_Global, ["foot_r"] = mLegs_Global
        }

        local mLoc = nil
        pcall(function() if type(localPlayer.K2_GetActorLocation) == "function" then mLoc = localPlayer:K2_GetActorLocation() end end)

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                local bIsReallyDead = false
                pcall(function()
                    if type(enemy.IsDead) == "function" then bIsReallyDead = enemy:IsDead()
                      elseif enemy.bIsDead ~= nil then bIsReallyDead = enemy.bIsDead
                      elseif enemy.bIsDeadFlag ~= nil then bIsReallyDead = enemy.bIsDeadFlag end
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsReallyDead = true end
                end)

                local eKey = GetSafeEnemyKey(enemy)
                _G.R6gamingState.EnemyMarks[eKey] = _G.R6gamingState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.R6gamingState.EnemyMarks[eKey]
                markData.enemy = enemy

                if not bIsReallyDead then
                    if markData.lastEnemyActor ~= enemy then
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                        if markData.radarMark then SafeRemoveMark(markData.radarMark); markData.radarMark = nil end

                        markData.lastEnemyActor = enemy
                        markData.LastUIComp = nil
                        markData.LastFrameUIState = nil
                    end

                    local eMesh = nil
                    pcall(function() eMesh = enemy.Mesh or (type(enemy.getAvatarComponent2) == "function" and enemy:getAvatarComponent2() or nil) end)
                    local aLoc = nil
                    pcall(function() if type(enemy.K2_GetActorLocation) == "function" then aLoc = enemy:K2_GetActorLocation() end end)

                    local isBotResult, isStateLoaded = CheckIsAI(enemy, markData)
                    local isBot = markData.AK_IS_BOT or false

                    local currentMeshCount = 0
                    if Valid(eMesh) then
                        local tempMeshes = GetAllSkeletalMeshes(enemy, markData)
                        currentMeshCount = #tempMeshes
                    end
                    local isMeshChanged = (markData.LastMeshCountWall ~= currentMeshCount)


                    -- ==========================================
                    -- MAGIC BULLET HITBOX SCALING (LANJUTAN)
                    -- ==========================================
                    pcall(function()
                        local EnemyMesh = eMesh
                        if slua.isValid(EnemyMesh) then
                            local uniqueID = type(enemy.GetUniqueID) == "function" and enemy:GetUniqueID() or tostring(enemy.PlayerKey or enemy)

                            if markData.MagicBulletHash == _G.R6gamingState.LastMagicConfigHash and markData.MagicTargetID == uniqueID then
                                return
                            end

                            local PhysicsAsset = EnemyMesh.PhysicsAssetOverride
                            if not slua.isValid(PhysicsAsset) and EnemyMesh.SkeletalMesh then PhysicsAsset = EnemyMesh.SkeletalMesh.PhysicsAsset end

                            if slua.isValid(PhysicsAsset) and PhysicsAsset.SkeletalBodySetups then
                                if not _G.AK_ModdedPhysAssets then _G.AK_ModdedPhysAssets = {} end
                                local PhysAssetName = "DefaultPhys"
                                pcall(function() PhysAssetName = PhysicsAsset:GetName() end)

                                if _G.AK_ModdedPhysAssets[PhysAssetName] ~= _G.R6gamingState.LastMagicConfigHash then

                                    if not _G.AK_OrigHitboxes then _G.AK_OrigHitboxes = {} end
                                    if not _G.AK_OrigHitboxes[PhysAssetName] then _G.AK_OrigHitboxes[PhysAssetName] = {} end
                                    local OrigHitboxData = _G.AK_OrigHitboxes[PhysAssetName]

                                    local SkeletalBodySetups = PhysicsAsset.SkeletalBodySetups
                                    local numSetups = type(SkeletalBodySetups.Num) == "function" and SkeletalBodySetups:Num() or #SkeletalBodySetups
                                    local limit = numSetups > 50 and 50 or numSetups

                                    for i = 1, limit do
                                        local BodySetup = type(SkeletalBodySetups.Get) == "function" and SkeletalBodySetups:Get(i-1) or SkeletalBodySetups[i]
                                        if slua.isValid(BodySetup) then
                                            local LowerBoneName = string.lower(tostring(BodySetup.BoneName))
                                            local MatchedBoneKey = nil
                                            for k, _ in pairs(BoneScaleMap) do
                                                if string.find(LowerBoneName, k, 1, true) then MatchedBoneKey = k break end
                                            end

                                            if MatchedBoneKey then
                                                local TargetScale = 1.0
                                                if runInject_Global then TargetScale = BoneScaleMap[MatchedBoneKey] end

                                                local AggGeom = BodySetup.AggGeom

                                                local BoxElems = AggGeom and AggGeom.BoxElems or BodySetup.BoxElems
                                                local SphereElems = AggGeom and AggGeom.SphereElems or BodySetup.SphereElems
                                                local SphylElems = AggGeom and AggGeom.SphylElems or BodySetup.SphylElems

                                                local BoxElem = GetFirstElemSafe(BoxElems)
                                                local SphereElem = GetFirstElemSafe(SphereElems)
                                                local SphylElem = GetFirstElemSafe(SphylElems)

                                                if not OrigHitboxData[MatchedBoneKey] then
                                                    OrigHitboxData[MatchedBoneKey] = { Box = nil, Sphere = nil, Sphyl = nil }
                                                    if BoxElem then OrigHitboxData[MatchedBoneKey].Box = { X = BoxElem.X, Y = BoxElem.Y, Z = BoxElem.Z } end
                                                    if SphereElem then OrigHitboxData[MatchedBoneKey].Sphere = { Radius = SphereElem.Radius } end
                                                    if SphylElem then OrigHitboxData[MatchedBoneKey].Sphyl = { Radius = SphylElem.Radius, Length = SphylElem.Length } end
                                                end

                                                local OrigElemData = OrigHitboxData[MatchedBoneKey]

                                                if OrigElemData.Box and BoxElem then
                                                    BoxElem.X = OrigElemData.Box.X * TargetScale
                                                    BoxElem.Y = OrigElemData.Box.Y * TargetScale
                                                    BoxElem.Z = OrigElemData.Box.Z * TargetScale
                                                    if type(BoxElems.Set) == "function" then BoxElems:Set(0, BoxElem) else BoxElems[1] = BoxElem end
                                                    if AggGeom then AggGeom.BoxElems = BoxElems; BodySetup.AggGeom = AggGeom else BodySetup.BoxElems = BoxElems end
                                                end

                                                if OrigElemData.Sphere and SphereElem then
                                                    SphereElem.Radius = OrigElemData.Sphere.Radius * TargetScale
                                                    if type(SphereElems.Set) == "function" then SphereElems:Set(0, SphereElem) else SphereElems[1] = SphereElem end
                                                    if AggGeom then AggGeom.SphereElems = SphereElems; BodySetup.AggGeom = AggGeom else BodySetup.SphereElems = SphereElems end
                                                end

                                                if OrigElemData.Sphyl and SphylElem then
                                                    SphylElem.Radius = OrigElemData.Sphyl.Radius * TargetScale
                                                    SphylElem.Length = OrigElemData.Sphyl.Length * TargetScale
                                                    if type(SphylElems.Set) == "function" then SphylElems:Set(0, SphylElem) else SphylElems[1] = SphylElem end
                                                    if AggGeom then AggGeom.SphylElems = SphylElems; BodySetup.AggGeom = AggGeom else BodySetup.SphylElems = SphylElems end
                                                end
                                            end
                                        end
                                    end
                                    _G.AK_ModdedPhysAssets[PhysAssetName] = _G.R6gamingState.LastMagicConfigHash
                                end

                                if EnemyMesh.SetPhysicsAsset then EnemyMesh:SetPhysicsAsset(PhysicsAsset) end
                                EnemyMesh.PhysicsAssetOverride = PhysicsAsset

                                markData.MagicBulletHash = _G.R6gamingState.LastMagicConfigHash
                                markData.MagicTargetID = uniqueID
                            end
                        end
                    end)

                    -- ==========================================
                    -- ESP VISUAL
                    -- ==========================================
                    local distM = 0
                    pcall(function() distM = localPlayer:GetDistanceTo(enemy) / 100 end)

                    local currentHp, maxHp = 100, 100
                    local showFrameUI = _G.R6gamingConfig.Esp5 or _G.R6gamingConfig.EspVipPro or _G.R6gamingConfig.EspVip

                    if showFrameUI then
                        pcall(function()
                            if enemy.Health then currentHp = enemy.Health elseif type(enemy.GetHealth) == "function" then currentHp = enemy:GetHealth() end
                            if enemy.HealthMax then maxHp = enemy.HealthMax elseif type(enemy.GetHealthMax) == "function" then maxHp = enemy:GetHealthMax() end
                        end)
                        if maxHp <= 0 then maxHp = 100 end
                    end
                    local hpRatio = currentHp / maxHp

                    -- ===== ESP THROWABLE (hanya Grenade, Smoke, Molotov) dengan timer 5/10 detik =====
                    if _G.R6gamingConfig.ThrowableEnabled then
                        pcall(function()
                            local MyHUD = Cached_MyHUD
                            if Valid(MyHUD) then
                                if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                                if not _G.CachedActorClass_ForBomb then _G.CachedActorClass_ForBomb = import("Actor") end
                                if not _G.CachedProjArray then _G.CachedProjArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForBomb) end
                                local ui_util = require("client.common.ui_util")
                                local gameInstance = ui_util and ui_util.GetGameInstance()
                                if gameInstance and _G.CachedGameplayStatics then
                                    local curTime = os.clock()
                                    local scanInterval = 0.5
                                    local mode = _G.R6gamingConfig.ThrowableScanMode or 0
                                    if mode == 0 then scanInterval = 0.5
                                      elseif mode == 10 then scanInterval = 10.0
                                      elseif mode == 20 then scanInterval = 20.0
                                    end

                                    if not _G.LastThrowableScanTime or (curTime - _G.LastThrowableScanTime) >= scanInterval then
                                        _G.LastThrowableScanTime = curTime
                                        local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForBomb, _G.CachedProjArray)
                                        local activeThrowables = {}
                                        local itemThrowables = {}
                                        if allActors then
                                            for _, actor in pairs(allActors) do
                                                if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                                    local isPendingKill = false
                                                    pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                                    if not isPendingKill then
                                                        local nameLower = string.lower(tostring(actor))
                                                        local bType = 0
                                                        if string.find(nameLower, "smoke") then bType = 2
                                                          elseif string.find(nameLower, "burn") or string.find(nameLower, "molotov") then bType = 3
                                                          elseif string.find(nameLower, "grenade") then bType = 1 end
                                                        if bType > 0 then
                                                            if string.find(nameLower, "projectile") or string.find(nameLower, "thrown") then
                                                                table.insert(activeThrowables, {act = actor, type = bType})
                                                              else
                                                                local shouldAdd = true
                                                                if shouldAdd then table.insert(itemThrowables, {act = actor, type = bType}) end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        _G.CachedActiveThrowables = activeThrowables
                                        _G.CachedItemThrowables = itemThrowables
                                    end

                                    local function DrawThrowables(throwableList, isItem, maxDist)
                                        if not throwableList then return end
                                        for _, item in ipairs(throwableList) do
                                            local throwable = item.act
                                            local bType = item.type
                                            if slua.isValid(throwable) and not throwable.bHidden then
                                                local isPendingKill = false
                                                pcall(function() if type(throwable.IsPendingKill) == "function" then isPendingKill = throwable:IsPendingKill() end end)
                                                if not isPendingKill then
                                                    local skipDraw = false
                                                    if isItem and _G.CachedActiveThrowables then
                                                        pcall(function()
                                                            local loc1 = type(throwable.K2_GetActorLocation) == "function" and throwable:K2_GetActorLocation()
                                                            if loc1 then
                                                                for _, actItem in ipairs(_G.CachedActiveThrowables) do
                                                                    local activeT = actItem.act
                                                                    if slua.isValid(activeT) then
                                                                        local loc2 = type(activeT.K2_GetActorLocation) == "function" and activeT:K2_GetActorLocation()
                                                                        if loc2 then
                                                                            local dx = loc1.X - loc2.X
                                                                            local dy = loc1.Y - loc2.Y
                                                                            local dz = loc1.Z - loc2.Z
                                                                            if math.sqrt(dx*dx + dy*dy + dz*dz) < 150 then skipDraw = true; break end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end)
                                                    end
                                                    if not skipDraw then
                                                        local distM = 0
                                                        pcall(function() distM = localPlayer:GetDistanceTo(throwable) / 100 end)
                                                        if distM > 0 and distM <= maxDist then
                                                            local displayName = ""
                                                            local color = nil
                                                            local zOffset = isItem and 15 or 25
                                                            local colorIdx = 4
                                                            if bType == 1 then
                                                                if not _G.R6gamingConfig.ThrowableGrenade then goto continue end
                                                                displayName = isItem and "Grenade" or "GRENADE"
                                                                colorIdx = _G.R6gamingConfig.ThrowableColor_Grenade or 4
                                                                color = GetColorBy7(colorIdx)
                                                              elseif bType == 2 then
                                                                if not _G.R6gamingConfig.ThrowableSmoke then goto continue end
                                                                displayName = isItem and "Smoke" or "SMOKE"
                                                                colorIdx = _G.R6gamingConfig.ThrowableColor_Smoke or 4
                                                                color = GetColorBy7(colorIdx)
                                                              elseif bType == 3 then
                                                                if not _G.R6gamingConfig.ThrowableMolotov then goto continue end
                                                                displayName = isItem and "Molotov" or "MOLOTOV"
                                                                colorIdx = _G.R6gamingConfig.ThrowableColor_Molotov or 4
                                                                color = GetColorBy7(colorIdx)
                                                              else
                                                                goto continue
                                                            end
                                                            if color then
                                                                local text = string.format("%s [%dm]", displayName, math.floor(distM))
                                                                local curGameTime = 0
                                                                pcall(function() curGameTime = _G.CachedGameplayStatics.GetTimeSeconds(gameInstance) end)
                                                                local shouldTimerRun = not isItem
                                                                if isItem then
                                                                    pcall(function()
                                                                        if throwable.bIsPinPulled or throwable.bPinPulled or (type(throwable.IsPinPulled) == "function" and throwable:IsPinPulled()) then
                                                                            shouldTimerRun = true
                                                                        end
                                                                    end)
                                                                end
                                                                if shouldTimerRun and curGameTime > 0 then
                                                                    local timeLeft = -1
                                                                    pcall(function()
                                                                        if type(throwable.GetExplosionTime) == "function" then timeLeft = throwable:GetExplosionTime() - curGameTime
                                                                          elseif throwable.ExplosionTime then timeLeft = throwable.ExplosionTime - curGameTime
                                                                          elseif throwable.ExplodeTime then timeLeft = throwable.ExplodeTime - curGameTime end
                                                                    end)
                                                                    if timeLeft == -1 or timeLeft > 100 then
                                                                        _G.ActiveThrowableTimers = _G.ActiveThrowableTimers or {}
                                                                        local id = tostring(throwable)
                                                                        if not _G.ActiveThrowableTimers[id] then _G.ActiveThrowableTimers[id] = curGameTime end
                                                                        local elapsed = curGameTime - _G.ActiveThrowableTimers[id]
                                                                        local maxTime = 5.0
                                                                        if bType == 1 then maxTime = 7.0
                                                                          elseif bType == 2 then maxTime = 45.0
                                                                          elseif bType == 3 then maxTime = 12.0 end
                                                                        timeLeft = maxTime - elapsed
                                                                    end
                                                                    if timeLeft < 0 then timeLeft = 0 end
                                                                    if timeLeft > 0.1 then
                                                                        text = string.format("%s (%.1fs)", text, timeLeft)
                                                                        if bType == 1 and timeLeft <= 1.5 then
                                                                            color = {R=255, G=165, B=0, A=255}
                                                                        end
                                                                    end
                                                                end
                                                                pcall(function()
                                                                    if _G.ActiveThrowableTimers then
                                                                        for k, v in pairs(_G.ActiveThrowableTimers) do
                                                                            if (curGameTime - v) > 60.0 then _G.ActiveThrowableTimers[k] = nil end
                                                                        end
                                                                    end
                                                                end)
                                                                local dynamicScale = math.max(0.6, 1.1 - (distM / maxDist))
                                                                MyHUD:AddDebugText(text, throwable, 0.3, {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset}, color, true, false, true, nil, dynamicScale, true)
                                                            end
                                                        end
                                                    end
                                                end
                                            end
::continue::
                                        end
                                    end

                                    DrawThrowables(_G.CachedItemThrowables, true, 50)
                                    DrawThrowables(_G.CachedActiveThrowables, false, 150)
                                end
                            end
                        end)
                    end

                    -- ESP Skeleton (Esp6)
                    if _G.R6gamingConfig.Esp6 then
                        pcall(function()
                            local curTime = os.clock()
                            if markData.LastEsp6Time == nil or (curTime - markData.LastEsp6Time) >= 0.05 then
                                markData.LastEsp6Time = curTime
                                local MyHUD = Cached_MyHUD
                                if Valid(MyHUD) and Valid(eMesh) and aLoc then
                                    if distM <= 250 then
                                        if type(eMesh.GetSocketLocation) == "function" then
                                            for _, bName in ipairs(GLOBAL_BONE_LIST) do
                                                if distM > 50 and (bName ~= "head" and bName ~= "pelvis" and bName ~= "neck_01") then
                                                  else
                                                    local wLoc = eMesh:GetSocketLocation(bName)
                                                    if wLoc then
                                                        local offset = {X = wLoc.X - aLoc.X, Y = wLoc.Y - aLoc.Y, Z = wLoc.Z - aLoc.Z}
                                                        local mark = "▪"
                                                        local fixedSize = 0.25
                                                        local color = C_CYAN
                                                        if bName == "head" then
                                                            mark = "●"
                                                            fixedSize = 0.45
                                                            color = C_RED
                                                          elseif bName == "pelvis" or bName == "neck_01" then
                                                            mark = "▪"
                                                            fixedSize = 0.35
                                                            color = C_YELLOW
                                                        end
                                                        MyHUD:AddDebugText(mark, enemy, 0.06, offset, offset, color, true, false, true, nil, fixedSize, true)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end


                    -- Frame UI (Esp5 / VipPro / Vip)
                    if showFrameUI then
                        pcall(function()
                            local SecurityCommonUtils = Cached_SecurityCommonUtils
                            local show = true
                            if enemy.HealthStatus and SecurityCommonUtils and SecurityCommonUtils.IsHealthStatusAlive then
                                if not SecurityCommonUtils.IsHealthStatusAlive(enemy.HealthStatus) then show = false end
                            end
                            if show and mLoc then
                                if aLoc and SecurityCommonUtils and SecurityCommonUtils.IsVector then
                                    if SecurityCommonUtils.IsVector(aLoc) and SecurityCommonUtils.IsVector(mLoc) then
                                        if aLoc.Z >= 150000 or FVector.Dist2D(mLoc, aLoc) > 50000 then show = false end
                                    end
                                end
                            end
                            if show then
                                if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then enemy:Replay_CreateEnemyFrameUI(true, true) end
                                if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                                if enemy.Replay_UpdateEnemyFrameUI then enemy:Replay_UpdateEnemyFrameUI(hpRatio) end

                                local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if markData.LastFrameUIState ~= "VISIBLE" then
                                        if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(0) end
                                        if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(false) end
                                        markData.LastFrameUIState = "VISIBLE"
                                    end
                                end
                            end
                        end)
                      else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                            local uiComp = enemy.EnemyFrameUI or (type(enemy.GetEnemyFrameUI) == "function" and enemy:GetEnemyFrameUI())
                            if Valid(uiComp) then
                                if markData.LastFrameUIState ~= "HIDDEN" then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                    markData.LastFrameUIState = "HIDDEN"
                                end
                            end
                        end)
                    end

                    -- ESP HEALTH V1 (VipPro)
                    if _G.R6gamingConfig.EspVipPro then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local hp = enemy.Health or 100
                            local maxHp = enemy.HealthMax or 100
                            local isKnock = (hp <= 0 or enemy.HealthStatus == 1)
                            local hpPercent = isKnock and 0 or (hp / maxHp)
                            local pctValue = math.floor(hpPercent * 100 + 0.5)

                            local pName = ""
                            if _G.R6gamingConfig.EspName then
                                pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
                            end

                            local bIsVisible = false
                            if pc and type(pc.LineOfSightTo) == "function" then
                                bIsVisible = pc:LineOfSightTo(enemy)
                            end

                            local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
                            local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)

                            local textColor = {R=255, G=255, B=255, A=255}
                            if isKnock then
                                textColor = {R=0, G=0, B=255, A=255}
                              else
                                textColor = bIsVisible and visibleCol or invisibleCol
                            end

                            local prefix = bIsVisible and "▶" or "▶"
                            local label = ""
                            if isKnock then
                                label = (pName ~= "" and string.format("%s [♿]", pName) or "♿")
                              else
                                if pName ~= "" then
                                    label = string.format("%s %s %.0f%%", pName, prefix, pctValue)
                                  else
                                    label = string.format("%s %.0f%%", prefix, pctValue)
                                end
                            end

                            hud:AddDebugText(label, enemy, 0.2, {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                            textColor, true, false, true, nil, 1.0, true)
                        end)
                    end

                    -- ESP RANGE
                    if _G.R6gamingConfig.EspDistance then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local distMeters = math.floor(distM + 0.5)
                            local rangeColor = {R=255, G=255, B=255, A=255}

                            hud:AddDebugText(string.format("%.0fm", distMeters), enemy, 0.3,
                            {X=15, Y=15, Z=-15}, {X=15, Y=15, Z=-15},
                            rangeColor, true, false, true, nil, 0.9, true)
                        end)
                    end

                    -- ESP NAME (jika tidak aktif VipPro)
                    if _G.R6gamingConfig.EspName and not _G.R6gamingConfig.EspVipPro then
                        pcall(function()
                            local hud = Cached_MyHUD
                            if not (Valid(hud) and hud.AddDebugText) then return end
                            if distM > 400 then return end

                            local pName = enemy.PlayerName or enemy.PlayerNamePublic or "Enemy"
                            if pName == "" then return end

                            local isKnock = (enemy.Health or 100) <= 0 or enemy.HealthStatus == 1
                            local bIsVisible = true
                            pcall(function()
                                if pc and type(pc.LineOfSightTo) == "function" then
                                    bIsVisible = pc:LineOfSightTo(enemy)
                                end
                            end)

                            local visibleCol = GetAppliedColor(_G.ColorConfig.VisibleColor or 4, _G.ColorConfig.Brightness)
                            local invisibleCol = GetAppliedColor(_G.ColorConfig.InvisibleColor or 1, _G.ColorConfig.Brightness)

                            local nameColor = {R=255, G=255, B=255, A=255}
                            if isKnock then
                                nameColor = {R=0, G=0, B=255, A=255}
                              else
                                nameColor = bIsVisible and visibleCol or invisibleCol
                            end

                            hud:AddDebugText(pName, enemy, 0.2, {X=0, Y=0, Z=120}, {X=0, Y=0, Z=120},
                            nameColor, true, false, true, nil, 1.0, true)
                        end)
                    end

                    -- ESP Vip (mark)
                    if _G.R6gamingConfig.EspVip then
                        if markData.hpMark == nil then markData.hpMark = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                        if markData.distMark == nil then markData.distMark = SafeAddMark(9999, FVector(0,0,0), 0, "", 4, enemy) end
                      else
                        if markData.hpMark then SafeRemoveMark(markData.hpMark); markData.hpMark = nil end
                        if markData.distMark then SafeRemoveMark(markData.distMark); markData.distMark = nil end
                    end

                    -- ESP Health V2 (Esp8)
                    if _G.R6gamingConfig.Esp8 then
                        if markData.hpMark8 == nil then markData.hpMark8 = SafeAddMark(1006, FVector(0,0,0), 0, "", 4, enemy) end
                      else
                        if markData.hpMark8 then SafeRemoveMark(markData.hpMark8); markData.hpMark8 = nil end
                    end

                    -- ESP Radar
                    if _G.R6gamingConfig.EspRadar then
                        if not markData.radarMark or markData.radarMark == 0 then
                            markData.radarMark = SafeAddMark(8888, FVector(0,0,0), 0, "", 4, enemy)
                        end
                      else
                        if markData.radarMark and markData.radarMark ~= 0 then
                            SafeRemoveMark(markData.radarMark)
                            markData.radarMark = nil
                        end
                    end

                    -- ESP Outline
                    if _G.R6gamingConfig.EspOutline then
                        pcall(function()
                            local outlineHash = tostring(_G.R6gamingConfig.OutlineThickness)
                            if markData.OutlineState ~= outlineHash then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then
                                    PPM.OutlineThickness = _G.R6gamingConfig.OutlineThickness
                                    if PPM.OutlineColor then PPM.OutlineColor = {r = 1, g = 0, b = 0, a = 1} end
                                    PPM:EnableAvatarOutline(avatarComp, true)
                                    markData.OutlineState = outlineHash
                                end
                            end
                        end)
                      else
                        pcall(function()
                            if markData.OutlineState ~= "OFF" then
                                local PPM = Cached_PPM
                                local avatarComp = (type(enemy.getAvatarComponent2) == "function") and enemy:getAvatarComponent2() or nil
                                if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                                markData.OutlineState = "OFF"
                            end
                        end)
                    end

                  else
                    if not markData.IsCleanedUp then
                        SafeRemoveMark(markData.radarMark)
                        markData.radarMark = nil
                        SafeRemoveMark(markData.hpMark)
                        markData.hpMark = nil
                        SafeRemoveMark(markData.hpMark8)
                        markData.hpMark8 = nil
                        SafeRemoveMark(markData.distMark)
                        markData.distMark = nil

                        if markData.MIDs then
                            for meshStr, midTable in pairs(markData.MIDs) do
                                for k, _ in pairs(midTable) do midTable[k] = nil end
                            end
                            markData.MIDs = nil
                        end

                        pcall(function()
                            local eObj = markData.enemy
                            if Valid(eObj) then
                                if eObj.Replay_SetVisiableOfFrameUI then eObj:Replay_SetVisiableOfFrameUI(false) end
                                local uiComp = eObj.EnemyFrameUI or (type(eObj.GetEnemyFrameUI) == "function" and eObj:GetEnemyFrameUI())
                                if Valid(uiComp) then
                                    if type(uiComp.SetVisibility) == "function" then uiComp:SetVisibility(2) end
                                    if type(uiComp.SetHiddenInGame) == "function" then uiComp:SetHiddenInGame(true) end
                                end
                            end

                            local PPM = Cached_PPM
                            local avatarComp = Valid(eObj) and (type(eObj.getAvatarComponent2) == "function") and eObj:getAvatarComponent2() or nil
                            if Valid(avatarComp) and Valid(PPM) then PPM:EnableAvatarOutline(avatarComp, false) end
                        end)

                        markData.IsCleanedUp = true
                    end
                end
            end
        end

        -- ==========================================
        -- ESP STATIC (ESP Count) - 2 sub menu
        -- ==========================================
        if _G.R6gamingConfig.EspStatic then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if not Valid(MyHUD) then return end

                -- ESP ENEMY COUNT
                if _G.R6gamingConfig.EspEnemyCount then
                    local myTeamId = localPlayer.TeamID or localPlayer:GetTeamID() or 0
                    local myPos = localPlayer:K2_GetActorLocation()
                    local maxDist = 35000
                    local realCount = 0
                    local aiCount = 0

                    for _, tPawn in pairs(allCharacters) do
                        if slua.isValid(tPawn) and tPawn ~= localPlayer then
                            local targetTeamId = tPawn.TeamID or tPawn:GetTeamID() or 0
                            if targetTeamId ~= myTeamId then
                                local enemyPos = tPawn:K2_GetActorLocation()
                                if enemyPos then
                                    local dx = enemyPos.X - myPos.X
                                    local dy = enemyPos.Y - myPos.Y
                                    local dz = enemyPos.Z - myPos.Z
                                    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                                    if dist <= maxDist then
                                        local isAI = false
                                        if tPawn.bIsAI == true or tPawn.IsAI == true then isAI = true end
                                        if not isAI then
                                            local pState = tPawn.PlayerState or (type(tPawn.GetPlayerState) == "function" and tPawn:GetPlayerState())
                                            if slua.isValid(pState) and (pState.bIsABot == true or pState.bIsBot == true) then isAI = true end
                                        end
                                        if isAI then aiCount = aiCount + 1 else realCount = realCount + 1 end
                                    end
                                end
                            end
                        end
                    end

                    local text = string.format("ENEMY (P: %d | B: %d)", realCount, aiCount)
                    MyHUD:AddDebugText(text, localPlayer, 1.2, {X=0, Y=0, Z=150}, {X=0, Y=0, Z=150}, {R=255, G=255, B=255, A=255}, true, false, true, nil, 1.0, true)
                end

                -- ESP WEAPON & STATUS ENEMY
                if _G.R6gamingConfig.EspWeaponStatus then
                    -- Cari musuh terdekat di tengah layar
                    local ui_util = require("client.common.ui_util")
                    local viewportSize = ui_util and ui_util.GetViewportSize()
                    if viewportSize then
                        local centerX = viewportSize.X * 0.5
                        local centerY = viewportSize.Y * 0.5
                        local FOV_RADIUS = (10 / 100.0) * (viewportSize.X / 2.0)
                        local FVector2D = import("Vector2D")
                        local bestTarget = nil
                        local bestDist = 999999

                        for _, enemy in pairs(allCharacters) do
                            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                                local ePos = enemy:K2_GetActorLocation()
                                if ePos then
                                    local screen = FVector2D()
                                    if pc:ProjectWorldLocationToScreen(ePos, screen, false) and screen.X > 0 and screen.Y > 0 then
                                        local dx = screen.X - centerX
                                        local dy = screen.Y - centerY
                                        local distScreen = math.sqrt(dx*dx + dy*dy)
                                        if distScreen <= FOV_RADIUS then
                                            local dist3D = localPlayer:GetDistanceTo(enemy)
                                            if dist3D < bestDist then
                                                bestDist = dist3D
                                                bestTarget = enemy
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        if Valid(bestTarget) then
                            local distM = math.floor(bestDist / 100)
                            local hp = bestTarget.Health or 100
                            local maxHp = bestTarget.HealthMax or 100
                            local hpPercent = maxHp > 0 and math.floor((hp / maxHp) * 100) or 0
                            local isKnock = (hp <= 0 or bestTarget.HealthStatus == 1)

                            local weaponName = "Tangan Kosong"
                            local eWeapon = nil
                            if bestTarget.CurrentWeapon then eWeapon = bestTarget.CurrentWeapon
                              elseif type(bestTarget.GetCurrentWeapon) == "function" then eWeapon = bestTarget:GetCurrentWeapon()
                              elseif bestTarget.WeaponManagerComponent then eWeapon = bestTarget.WeaponManagerComponent.CurrentWeaponReplicated end
                            if Valid(eWeapon) and type(eWeapon.GetWeaponName) == "function" then weaponName = eWeapon:GetWeaponName() end

                            local statusText = isKnock and " [♿ KNOCK]" or ""
                            local text = string.format("%s | %dm | %d%% HP%s", weaponName, distM, hpPercent, statusText)
                            MyHUD:AddDebugText(text, bestTarget, 0.15, {X=0, Y=0, Z=-50}, {X=0, Y=0, Z=-50}, C_YELLOW, true, false, true, nil, 0.8, true)
                        end
                    end
                end
            end)
        end


       -- ===== ESP LOOT (dengan timer 5/10 detik) =====
        if _G.R6gamingConfig.EspLoot then
            pcall(function()
                local MyHUD = Cached_MyHUD
                if Valid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForLoot then _G.CachedActorClass_ForLoot = import("Actor") end
                    if not _G.CachedLootArray then _G.CachedLootArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForLoot) end
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()
                        local scanInterval = 0.5
                        local mode = _G.R6gamingConfig.LootScanMode or 0
                        if mode == 0 then scanInterval = 0.5
                          elseif mode == 10 then scanInterval = 10.0
                          elseif mode == 20 then scanInterval = 20.0
                        end

                        if not _G.LastLootScanTime or (curTime - _G.LastLootScanTime) >= scanInterval then
                            _G.LastLootScanTime = curTime
                            local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForLoot, _G.CachedLootArray)
                            local lootItems = {}
                            local lootKeywords = {
                                ["m416"] = {name = "M416", toggle = "LootShowM416", colorKey = "LootColor_M416", defaultColor = 4},
                                ["aug"] = {name = "AUG", toggle = "LootShowAUG", colorKey = "LootColor_AUG", defaultColor = 4},
                                ["akm"] = {name = "AKM", toggle = "LootShowAKM", colorKey = "LootColor_AKM", defaultColor = 4},
                                ["m24"] = {name = "M24", toggle = "LootShowM24", colorKey = "LootColor_M24", defaultColor = 4},
                                ["ump45"] = {name = "UMP45", toggle = "LootShowUMP", colorKey = "LootColor_UMP", defaultColor = 4},
                                ["ump"] = {name = "UMP45", toggle = "LootShowUMP", colorKey = "LootColor_UMP", defaultColor = 4},
                                ["dbs"] = {name = "DBS", toggle = "LootShowDBS", colorKey = "LootColor_DBS", defaultColor = 4},
                                ["s12k"] = {name = "S12K", toggle = "LootShowS12K", colorKey = "LootColor_S12K", defaultColor = 4},
                                ["s12"] = {name = "S12K", toggle = "LootShowS12K", colorKey = "LootColor_S12K", defaultColor = 4},
                            }
                            local level3Items = {
                                ["vest"] = {name = "Vest Lv3", toggle = "LootShowVest3", colorKey = "LootColor_Vest3", defaultColor = 4},
                                ["helmet"] = {name = "Helm Lv3", toggle = "LootShowHelmet3", colorKey = "LootColor_Helmet3", defaultColor = 4},
                                ["helm"] = {name = "Helm Lv3", toggle = "LootShowHelmet3", colorKey = "LootColor_Helmet3", defaultColor = 4},
                                ["bag"] = {name = "Bag Lv3", toggle = "LootShowBag3", colorKey = "LootColor_Bag3", defaultColor = 4},
                                ["backpack"] = {name = "Bag Lv3", toggle = "LootShowBag3", colorKey = "LootColor_Bag3", defaultColor = 4},
                            }

                            if allActors then
                                for _, actor in pairs(allActors) do
                                    if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                        local isPendingKill = false
                                        pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                        if not isPendingKill then
                                            local actorName = ""
                                            pcall(function()
                                                if type(actor.GetName) == "function" then actorName = actor:GetName()
                                                  elseif actor.Name then actorName = actor.Name
                                                  else actorName = tostring(actor) end
                                            end)
                                            local lowerName = string.lower(actorName)
                                            if lowerName == "" then lowerName = string.lower(tostring(actor)) end

                                            local displayInfo = nil
                                            local matched = false

                                            for keyword, info in pairs(lootKeywords) do
                                                if string.find(lowerName, keyword, 1, true) then
                                                    displayInfo = info
                                                    matched = true
                                                    break
                                                end
                                            end

                                            if not matched then
                                                for keyword, info in pairs(level3Items) do
                                                    if string.find(lowerName, keyword, 1, true) and string.find(lowerName, "3", 1, true) then
                                                        displayInfo = info
                                                        matched = true
                                                        break
                                                    end
                                                end
                                            end

                                            if matched and displayInfo then
                                                table.insert(lootItems, {act = actor, info = displayInfo})
                                            end
                                        end
                                    end
                                end
                            end
                            _G.CachedLootItems = lootItems
                        end

                        if _G.CachedLootItems then
                            for _, item in ipairs(_G.CachedLootItems) do
                                local loot = item.act
                                if slua.isValid(loot) and not loot.bHidden then
                                    local distM = 0
                                    pcall(function() distM = localPlayer:GetDistanceTo(loot) / 100 end)
                                    if distM > 0 and distM <= 100 then
                                        local displayName = item.info.name
                                        local toggle = item.info.toggle
                                        if toggle and not _G.R6gamingConfig[toggle] then goto continue end
                                        local colorIdx = 4
                                        if item.info.colorKey then
                                            colorIdx = _G.R6gamingConfig[item.info.colorKey] or item.info.defaultColor or 4
                                          else
                                            colorIdx = item.info.defaultColor or 4
                                        end
                                        local color = GetColorBy7(colorIdx)
                                        local dynamicScale = math.max(0.5, 1.0 - (distM / 100))
                                        MyHUD:AddDebugText(
                                        string.format("%s [%dm]", displayName, math.floor(distM)),
                                        loot,
                                        0.3,
                                        {X=0, Y=0, Z=30},
                                        {X=0, Y=0, Z=30},
                                        color,
                                        true, false, true, nil, dynamicScale, true
                                        )
                                    end
                                end
::continue::
                            end
                        end
                    end
                end
            end)
        end
    end)
end



_G.R6gamingState.LoopToken = (_G.R6gamingState.LoopToken or 0) + 1
local myToken = _G.R6gamingState.LoopToken

-- ============================================
-- 1.lua - BYPASS SYSTEM (Anti-Cheat, Anti-Report)
-- ============================================
if _G.R6RegisterMod then _G.R6RegisterMod("Bypass", "Loaded") end

local function nop() return true end
local function retFalse() return false end
local function retTrue() return true end
local function retEmptyString() return "" end
local function retZero() return 0 end

-- ============================================
-- NOTIFY FUNCTION
-- ============================================
local function Notify(msg)
    local s = "[R6 BYPASS] " .. tostring(msg)
    pcall(function()
        local sh = import("ScriptHelperClient")
        if sh and sh.AddOnScreenDebugMessage then
            sh.AddOnScreenDebugMessage(s, -1, 3.0, {R=0, G=1, B=0, A=1}, {X=1.2, Y=1.2})
        end
    end)
    print(s)
end

-- ============================================
-- SHOW BYPASS POPUP
-- ============================================
local function ShowBypassPopup()
    if _G.BypassPopupShown then return end
    _G.BypassPopupShown = true

    pcall(function()
        local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
        local Web = require("client.slua.logic.url.logic_webview_sdk")
        local function onClickTele()
            Web:OpenURL("https://t.me/r6gamingreal")
        end
        local msg = "BYPASS AKTIF!\n\nAnti-Cheat: OFF\nAnti-Report: OFF\nAnti-Scan: OFF\nHiggsBoson: DISABLED\nTSS SDK: BLOCKED\n\nTELEGRAM @RA6A09"
        CommonMsgBoxMgr.Show(2, "R6 GAMING BYPASS", msg, onClickTele, nil, "TELEGRAM")
    end)
end

-- ============================================
-- 1. BYPASS SLUA VERIFICATION
-- ============================================
local function InitializeSLUABypass()
    pcall(function()
        if slua and slua.getSignature then slua.getSignature = function() return 0xDEADBEEF end end
        local loader = package.loaded["slua.loader"] or rawget(_G, "slua_loader")
        if loader then
            loader.verifyBytecode = retTrue
            loader.checkIntegrity = retTrue
            if loader.disableSignatureCheck then loader.disableSignatureCheck = retTrue end
        end
        local slua_serialize = package.loaded["slua.serialize"]
        if slua_serialize then slua_serialize.check = retTrue; slua_serialize.verify = retTrue end
        if jit and jit.attach then jit.attach(function() end, "bc") end
        if _G.slua_verify then _G.slua_verify = retTrue end
        if _G.check_slua_integrity then _G.check_slua_integrity = retTrue end
    end)
end

-- ============================================
-- 2. BYPASS MD5 & FILE INTEGRITY
-- ============================================
local function InitializeMD5Bypass()
    pcall(function()
        local console = import("KismetSystemLibrary")
        if console then
            console.ExecuteConsoleCommand(nil, "pak.DisablePakSignatureCheck 1")
            console.ExecuteConsoleCommand(nil, "pakchunk.EnableSignatureCheck 0")
            console.ExecuteConsoleCommand(nil, "s.VerifyPak 0")
            console.ExecuteConsoleCommand(nil, "sig.Check 0")
            console.ExecuteConsoleCommand(nil, "security.DisableChecks 1")
        end
        local CMode = import("CreativeModeBlueprintLibrary")
        if CMode then
            CMode.MD5HashByteArray = function() return "00000000000000000000000000000000" end
            CMode.MD5HashFile = function() return "00000000000000000000000000000000" end
            CMode.GetContentDiffData = function() return true, "BYPASSED" end
            CMode.VerifyFileIntegrity = retTrue
        end
        if _G.MD5Hash then _G.MD5Hash = function() return "00000000000000000000000000000000" end end
        if _G.CRC32 then _G.CRC32 = function() return 0 end end
        if _G.SHA1 then _G.SHA1 = function() return "BYPASS" end end
        local FileHashChecker = package.loaded["common.file_hash_checker"]
        if FileHashChecker then
            FileHashChecker.CheckFileMD5 = retTrue; FileHashChecker.VerifyAll = retTrue
            FileHashChecker.GetHash = function() return "BYPASS" end
        end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then TssSdk.GetFileMD5 = function() return "BYPASS" end; TssSdk.VerifyFileSignature = retTrue end
        local STExtra = import("STExtraBlueprintFunctionLibrary")
        if STExtra then STExtra.CheckMD5 = retTrue; STExtra.GetMD5 = function() return "BYPASS" end; STExtra.VerifyFile = retTrue end
    end)
end

-- ============================================
-- 3. BYPASS SKIN VALIDATION
-- ============================================
local function InitializeSkinBypass()
    pcall(function()
        local ptlog = package.loaded["client.slua.logic.download.report.puffer_tlog"]
        if ptlog then ptlog.ReportEvent = nop; ptlog.ReportDownloadResult = nop; ptlog.ReportODPTDError = nop; ptlog.ReportSkinError = nop end
        local AvatarUtils = package.loaded["AvatarUtils"]
        if AvatarUtils then AvatarUtils.CheckIsWeaponInBlackList = retFalse; AvatarUtils.IsValidAvatar = retTrue; AvatarUtils.CheckAvatarIntegrity = retTrue; AvatarUtils.ReportInvalidAvatar = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("FileCheckSubsystem")
        if sub then sub.StartCheck = nop; sub.ReportAbnormalFile = nop; sub.StopCheck = nop end
        local eqEx = package.loaded["client.slua.logic.report.EquipmentExceptionReport"]
        if eqEx then eqEx.Report = nop; eqEx.SendException = nop end
    end)
end

-- ============================================
-- 4. BYPASS LOG & CRASH REPORT
-- ============================================
local function InitializeLogBlocker()
    pcall(function()
        local SMTD = import("ScreenshotMTDer")
        if SMTD then SMTD.MTDePicture = function() return "" end; SMTD.ReMTDePicture = function() return "" end; SMTD.HasCaptured = retTrue; SMTD.TakeScreenshot = nop end
        local TLog = package.loaded["TLog"] or _G.TLog
        if TLog then TLog.Info = nop; TLog.Warning = nop; TLog.Error = nop; TLog.Debug = nop; TLog.Report = nop; TLog.Send = nop; TLog.Flush = nop end
        local CrashSight = package.loaded["CrashSight"] or _G.CrashSight
        if CrashSight then CrashSight.ReportException = nop; CrashSight.SetCustomData = nop; CrashSight.Log = nop; CrashSight.SendCrash = nop; CrashSight.ReportUserException = nop end
        local GRUtils = package.loaded["GameLua.Mod.BaseMod.GamePlay.GameReport.GameReportUtils"]
        if GRUtils then GRUtils.BugglyPostExceptionFull = retFalse; GRUtils.CheckCanBugglyPostException = retFalse; GRUtils.ReplayReportData = nop; GRUtils.ReportGameException = nop; GRUtils.PostException = nop end
        local CTR = package.loaded["client.slua.logic.report.ClientToolsReport"]
        if CTR then CTR.SendReport = nop; CTR.SendException = nop; CTR.UploadLog = nop end
        for _, sdk in ipairs({"Firebase", "Adjust", "AppsFlyer", "FacebookAnalytics", "GameAnalytics"}) do
            local s = _G[sdk]; if s then s.logEvent = nop; s.trackEvent = nop; s.setEnabled = retFalse; s.sendEvent = nop; s.report = nop end
        end
    end)
end

-- ============================================
-- 5. BYPASS SCANNER (Memory, Speed, Wall)
-- ============================================
local function InitializeScannerBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            local subs = {"AFKReportorSubsystem", "ClientDataStatistcsSubsystem", "AvatarExceptionSubsystem", "ShootVerifySubSystemClient", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "FileCheckSubsystem", "BehaviorScoreSubsystem"}
            for _, name in ipairs(subs) do
                local sub = SubMgr:Get(name)
                if sub then
                    for k, v in pairs(sub) do
                        if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect")) then pcall(function() sub[k] = nop end) end
                    end
                    if sub.ReportPingDelayTimer then sub:RemoveGameTimer(sub.ReportPingDelayTimer); sub.ReportPingDelayTimer = nil end; sub.DelayCount = 0
                end
            end
        end
        local AvaEx = package.loaded["GameLua.Mod.Library.GamePlay.Avatar.Exception.AvatarExceptionPlayerInst"]
        if AvaEx then AvaEx.CheckAvatarException = nop; AvaEx.CheckAvatarExceptionOnce = nop; AvaEx.ReportAvatarException = nop; AvaEx.CheckSlotMeshVisible = retFalse; AvaEx.CheckPawnVisible = retFalse; AvaEx.CheckCanBugglyPostException = retFalse end
        local TssSdk = package.loaded["TssSdk"] or _G.TssSdk
        if TssSdk then
            local origData = TssSdk.OnRecvData
            TssSdk.OnRecvData = function(data) if type(data) == "string" and (data:find("report", 1, true) or data:find("exception", 1, true) or data:find("cheat", 1, true) or data:find("violation", 1, true) or data:find("hack", 1, true) or data:find("verify", 1, true)) then return end; if origData then origData(data) end end
            TssSdk.SendReportInfo = nop; TssSdk.ScanMemory = retTrue; TssSdk.IsEmulator = retFalse; TssSdk.GetTssSdkReportInfo = retEmptyString; TssSdk.CheckEnvironment = retTrue; TssSdk.VerifyProcess = retTrue
        end
    end)
end

-- ============================================
-- 6. BYPASS REPLAY & TELEMETRY
-- ============================================
local function InitializeReplayTelemetryBlocker()
    pcall(function()
        local SubMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if SubMgr then
            for _, name in ipairs({"GameReportSubsystem", "ReplaySubsystem"}) do
                local sub = SubMgr:Get(name)
                if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Trace") or k:find("Replay") or k:find("Record") or k:find("Save")) then pcall(function() sub[k] = nop end) end end end
            end
        end
        local logRep = package.loaded["client.slua.logic.replay.logic_report_replay"]
        if logRep then logRep.ReportReplay = nop; logRep.SendReportReq = nop; logRep.UploadReplay = nop end
    end)
end

-- ============================================
-- 7. BYPASS REPORT FLOW
-- ============================================
local function InitializeReportFlowBlocker()
    pcall(function()
        local flows = {"ReportAimFlow", "ReportHitFlow", "ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "ReportEquipmentFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "ReportCircleFlow", "ReportSecMrpcsFlow"}
        for _, f in ipairs(flows) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        for _, f in ipairs({"CheckReportSecAttackFlowWithAttackFlow", "CheckReportSecAttackFlow"}) do if _G[f] then _G[f] = retFalse end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = retFalse end end
        for _, f in ipairs({"IsEnableReportMrpcsInCircleFlow", "IsEnableReportMrpcsInPartCircleFlow", "IsEnableReportMrpcsFlow", "IsEnableReportAttackFlow", "IsEnableReportHitFlow", "IsEnableReportCircleFlow"}) do if _G[f] then _G[f] = retFalse end end
    end)
end

-- ============================================
-- 8. BYPASS PLAYER SECURITY
-- ============================================
local function InitializePlayerSecurityBypass()
    pcall(function()
        for _, c in ipairs({"PlayerSecurityInfoCollector", "PlayerSecurityInfo", "SecurityInfoCollector", "ClientSecurityCollector", "PlayerAntiCheatCollector"}) do
            if _G[c] then for k, v in pairs(_G[c]) do if type(v) == "function" and (k:find("Report") or k:find("Collect") or k:find("Send") or k:find("Upload") or k:find("Record")) then _G[c][k] = nop end end end
        end
        local SecSub = require("GameLua.Mod.BaseMod.Common.Security.PlayerSecurityInfoSubsystem")
        if SecSub then SecSub.ReportData = nop; SecSub.CheckCheat = retFalse; SecSub.ValidatePlayer = retTrue; SecSub.CollectData = nop; SecSub.SendToServer = nop end
    end)
end

-- ============================================
-- 9. BYPASS CLIENT FLOW
-- ============================================
local function InitializeClientFlowBypass()
    pcall(function()
        for _, name in ipairs({"ClientSecMrpcsFlow", "MrpcsFlow", "MrpcsData", "ClientCircleFlowSubsystem", "ClientKillFlowSubsystem", "ClientSecPlayerKillFlow"}) do
            local sub = package.loaded[name] or _G[name]
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Flow") or k:find("Record") or k:find("Process")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

-- ============================================
-- 10. BYPASS SWIFT HAWK
-- ============================================
local function InitializeSwiftHawkBypass()
    pcall(function()
        for _, f in ipairs({"SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams", "SendSwiftHawkData"}) do if _G[f] then _G[f] = nop end; if _G.GameplayCallbacks and _G.GameplayCallbacks[f] then _G.GameplayCallbacks[f] = nop end end
        local sub = package.loaded["GameLua.Mod.BaseMod.Client.Security.SwiftHawkSubsystem"]
        if sub then sub.ReportData = nop; sub.SendReport = nop; sub.CollectTelemetry = nop end
    end)
end

-- ============================================
-- 11. BYPASS CORONA LAB
-- ============================================
local function InitializeCoronaLabBypass()
    pcall(function()
        if _G.CoronaLab then _G.CoronaLab.ReportData = nop; _G.CoronaLab.SendData = nop; _G.CoronaLab.CollectData = nop; _G.CoronaLab.Telemetry = nop end
        local sub = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr"):Get("CoronaLabSubsystem")
        if sub then sub.ReportData = nop; sub.SendToServer = nop; sub.CollectTelemetry = nop; sub.StopCollection = nop end
    end)
end

-- ============================================
-- 12. BYPASS MODIFIER EXCEPTION
-- ============================================
local function InitializeModifierExceptionBypass()
    pcall(function()
        if _G.bReportedModifierException then _G.bReportedModifierException = false end
        local sub = require("GameLua.Mod.BaseMod.Common.Security.ModifierExceptionSubsystem")
        if sub then sub.ReportException = nop; sub.CheckModifier = retTrue; sub.ValidateModifier = retTrue; sub.ReportModifierError = nop end
    end)
end

-- ============================================
-- 13. BYPASS SIMULATE CHARACTER LOCATION
-- ============================================
local function InitializeSimulateCharacterLocationBypass()
    pcall(function()
        local sub = require("GameLua.Mod.BaseMod.Gameplay.Simulate.SimulateCharacterSubsystem")
        if sub then sub.ReportLocation = nop; sub.SendLocationData = nop; sub.VerifyLocation = retTrue end
    end)
end

-- ============================================
-- 14. BYPASS SHOOT VERIFICATION
-- ============================================
local function InitializeShootVerificationBypass()
    pcall(function()
        local sub = require("GameLua.Dev.Subsystem.ShootVerifySubSystemClient")
        if sub then sub.OnShootVerifyFailed = nop; sub.SendVerifyData = nop; sub.ReportBulletHit = nop; sub.UploadHitInfo = nop; sub.VerifyShot = retTrue end
        if _G.BulletHitInfoUploadData then _G.BulletHitInfoUploadData.Report = nop; _G.BulletHitInfoUploadData.Send = nop; _G.BulletHitInfoUploadData.Upload = nop end
    end)
end

-- ============================================
-- 15. BYPASS NETWORK PACKET
-- ============================================
local function InitializeNetworkPacketBlock()
    pcall(function()
        if NetUtil and NetUtil.SendPacket then
            local orig = NetUtil.SendPacket
            local blocked = {
                ["ReportAttackFlow"]=1, ["ReportSecAttackFlow"]=1, ["ReportFireArms"]=1, ["ReportVerifyInfoFlow"]=1, ["ReportMrpcsFlow"]=1,
                ["ReportPlayerBehavior"]=1, ["ReportTeammatHurt"]=1, ["ReportPlayerMoveRoute"]=1, ["ReportPlayerPosition"]=1, ["ReportSecVehicleMoveFlow"]=1,
                ["report_parachute_data"]=1, ["on_tss_sdk_anti_data"]=1, ["ReportAimFlow"]=1, ["ReportHitFlow"]=1, ["ReportCircleFlow"]=1, ["report_players_ping"]=1,
                ["report_player_ip"]=1, ["report_net_saturate"]=1, ["report_speed_hack"]=1, ["report_wall_hack"]=1, ["report_aim_bot"]=1, ["report_esp_usage"]=1,
                ["report_modded_files"]=1, ["detect_cheat"]=1, ["ban_player"]=1, ["client_anti_cheat_report"]=1,
                ["ClientSecMrpcsFlow"]=1, ["MrpcsData"]=1, ["CheckReportSecAttackFlow"]=1, ["CheckReportSecAttackFlowWithAttackFlow"]=1, ["RPC_ClientCoronaLab"]=1,
                ["CoronaLabReport"]=1, ["CoronaLabData"]=1, ["PlayerSecurityInfo"]=1, ["ReportSecurityInfo"]=1, ["SendSecurityData"]=1, ["ClientCircleFlow"]=1,
                ["IsEnableReportMrpcsInCircleFlow"]=1, ["IsEnableReportMrpcsInPartCircleFlow"]=1, ["bReportedModifierException"]=1,
                ["ReportModifierException"]=1, ["RPC_Server_ReportSimulateCharacterLocation"]=1, ["ReportSimulateCharacterLocation"]=1, ["RPC_Client_ShootVertifyRes"]=1,
                ["BulletHitInfoUploadData"]=1, ["ShootVerifyFailed"]=1, ["report_unrealnet_exception"]=1, ["tss_sdk_report"]=1, ["SwiftHawk"]=1, ["ClientSwiftHawk"]=1, ["ClientSwiftHawkWithParams"]=1, ["SwiftHawkReport"]=1, ["SwiftHawkData"]=1,
                ["AntiCheatReport"]=1, ["CheatDetection"]=1, ["ViolationReport"]=1, ["SecurityViolation"]=1, ["IntegrityCheck"]=1, ["SignatureVerify"]=1
            }
            NetUtil.SendPacket = function(packetName, ...) if blocked[packetName] then return nil end; return orig(packetName, ...) end
            NetUtil.IsBypassed = true
        end
        if _G.SendRPC then
            local origRPC = _G.SendRPC
            local blockedRPC = {"RPC_Server_ClientSecMrpcsFlow", "RPC_Server_SwiftHawk", "RPC_Server_ClientSwiftHawkWithParams", "RPC_Server_ReportSimulateCharacterLocation", "RPC_Client_ShootVertifyRes", "RPC_ClientCoronaLab"}
            _G.SendRPC = function(rpcName, ...) for _, b in ipairs(blockedRPC) do if rpcName == b then return nil end end; return origRPC(rpcName, ...) end
        end
    end)
end

-- ============================================
-- 16. BYPASS HIGGS BOSON
-- ============================================
local function InitializeHiggsBosonBypass()
    pcall(function()
        local Higgs = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if Higgs then
            for _, m in ipairs({"ControlMHActive", "Tick", "OnTick", "MHActiveLogic", "TriggerAvatarCheck", "StartAvatarCheck", "ReportItemID", "ReceiveAnyDamage", "OnWeaponHitRecord", "ShowSecurityAlert", "ServerReportAvatar", "ClientReportNetAvatar", "SendHisarData", "ValidateSecurityData", "StaticShowSecurityAlertInDev", "RPC_Client_ShootVertifyRes", "RPC_Server_ReportSimulateCharacterLocation", "DisableHiggsBoson", "CheckMHActive", "ReportViolation", "ProcessSecurityEvent", "ValidatePlayer", "CheckIntegrity"}) do
                if Higgs[m] then Higgs[m] = nop end
            end
            Higgs.GetNetAvatarItemIDs = retEmptyString; Higgs.GetCurWeaponSkinID = retZero; Higgs.IsMHActive = retFalse; Higgs.bMHActive = false; Higgs.bCallPreReplication = false
            if Higgs.BlackList then for k in pairs(Higgs.BlackList) do Higgs.BlackList[k] = nil end end
        end
        _G.BlackList = {}
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            if pc.HiggsBoson then pc.HiggsBoson.bMHActive = false; pc.HiggsBoson.bCallPreReplication = false; if pc.HiggsBoson.ControlMHActive then pc.HiggsBoson:ControlMHActive(0) end end
            if pc.HiggsBosonComponent then pc.HiggsBosonComponent.bMHActive = false; pc.HiggsBosonComponent.bCallPreReplication = false; pc.HiggsBosonComponent:ControlMHActive(0) end
        end
    end)
end

-- ============================================
-- 17. BYPASS ANTI CHEAT HOOKS
-- ============================================
local function InitializeAntiCheatHooks()
    pcall(function()
        local HBC = require("GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
        if HBC and HBC.StaticShowSecurityAlertInDev then HBC.StaticShowSecurityAlertInDev = nop end
    end)
    if _G.AvatarCheckCallback then
        _G.AvatarCheckCallback.StartAvatarCheck = nop; _G.AvatarCheckCallback.OnReportItemID = nop
        _G.AvatarCheckCallback.PostPlayerControllerLoginInit = function(PlayerController)
            if slua.isValid(PlayerController) and PlayerController.HiggsBosonComponent then PlayerController.HiggsBosonComponent:ControlMHActive(0); PlayerController.HiggsBosonComponent.bMHActive = false end
        end
    end
end

-- ============================================
-- 18. BYPASS ANTI REPORT
-- ============================================
local function InitializeAntiReport()
    pcall(function()
        for _, path in ipairs({"GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem", "Client.Security.ClientReportPlayerSubsystem", "GameLua.Mod.BaseMod.DS.Security.DSReportPlayerSubsystem"}) do
            local sub = package.loaded[path]; if not sub then local s, r = pcall(require, path); if s and r then sub = r end end
            if sub then for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Record") or k:find("Send") or k:find("Upload") or k:find("Notify")) then pcall(function() sub[k] = nop end) end end end
        end
    end)
end

-- ============================================
-- 19. BYPASS GAMEPLAY CALLBACKS
-- ============================================
local function InitializeGameplayBypass()
    pcall(function()
        if not _G.GameplayCallbacks then _G.GameplayCallbacks = {} end
        if _G.GameplayCallbacks.IsBypassed then return end
        local GC = _G.GameplayCallbacks
        local reports = {"ReportAttackFlow", "ReportSecAttackFlow", "ReportFireArms", "ReportVerifyInfoFlow", "ReportMrpcsFlow", "ReportPlayerBehavior", "ReportTeammatHurt", "ReportMisKillByTeammate", "ReportForbitPick", "ReportPlayerMoveRoute", "ReportPlayerPosition", "ReportVehicleMoveFlow", "ReportSecTgameMovingFlow", "ReportParachuteData", "SendTssSdkAntiDataToLobby", "ReportEquipmentFlow", "ReportAimFlow", "ReportPlayersPing", "ReportPlayerIP", "ReportPlayerFramePingRecord", "OnDSConnectionSaturated", "ReportDSNetSaturation", "ReportNetContinuousSaturate", "ReportDSNetRate", "SendClientStats", "SendServerAvgTickDelta", "ReportCircleFlow", "ClientSecMrpcsFlow", "SwiftHawk", "ClientSwiftHawk", "ClientSwiftHawkWithParams"}
        for _, f in ipairs(reports) do GC[f] = nop end
        GC.CheckReportSecAttackFlowWithAttackFlow = retFalse; GC.CheckReportSecAttackFlow = retFalse
        local origState = GC.OnDSPlayerStateChanged
        GC.OnDSPlayerStateChanged = function(UID, State, bPure, bSafe, Param)
            local s = State and string.lower(tostring(State)) or ""
            local blocked = {["cheatdetected"]=1, ["connectionlost"]=1, ["connectiontimeout"]=1, ["connectionexception"]=1, ["netdrivererror"]=1, ["banned"]=1, ["kicked"]=1, ["suspended"]=1, ["violationdetected"]=1, ["integrityfailure"]=1, ["securityviolation"]=1}
            if blocked[s] then return end
            if origState then pcall(origState, UID, State, bPure, bSafe, Param) end
        end
        GC.OnPlayerNetConnectionClosed = nop; GC.OnPlayerActorChannelError = nop; GC.OnPlayerRPCValidateFailed = nop; GC.OnPlayerSpectateException = nop; GC.OnShutdownAfterError = nop; GC.IsBypassed = true
    end)
end

-- ============================================
-- 20. BYPASS KILL ALL SUBSYSTEMS
-- ============================================
local function InitializeKillAllSubsystems()
    pcall(function()
        local subMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
        if not subMgr then return end
        local toKill = {"CoronaLabSubsystem", "PlayerSecurityInfoSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "SimulateCharacterSubsystem", "ShootVerifySubSystemClient", "HiggsBosonComponent", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem", "ClientHawkEyePatrolSubsystem", "DSHawkEyePatrolSubsystem", "ClientDataStatistcsSubsystem", "AFKReportorSubsystem", "BehaviorScoreSubsystem", "FileCheckSubsystem", "MemoryCheckSubsystem", "SpeedCheckSubsystem", "WallCheckSubsystem", "AvatarExceptionSubsystem", "GameReportSubsystem", "ClientSecMrpcsFlowSubsystem", "MrpcsFlowSubsystem", "CircleFlowSubsystem", "SwiftHawkSubsystem", "AntiCheatSubsystem", "IntegrityCheckSubsystem", "SignatureVerifySubsystem", "MD5CheckSubsystem", "PakVerifySubsystem"}
        for _, name in ipairs(toKill) do
            local sub = subMgr:Get(name)
            if sub then
                for k, v in pairs(sub) do if type(v) == "function" and (k:find("Report") or k:find("Send") or k:find("Upload") or k:find("Verify") or k:find("Check") or k:find("Validate") or k:find("Scan") or k:find("Detect") or k:find("Collect") or k:find("Flow") or k:find("Heartbeat")) then pcall(function() sub[k] = nop end) end end
                if sub.timer then pcall(function() sub:RemoveGameTimer(sub.timer) end) end
                if sub.heartbeatTimer then pcall(function() sub:RemoveGameTimer(sub.heartbeatTimer) end) end
                if sub.reportTimer then pcall(function() sub:RemoveGameTimer(sub.reportTimer) end) end
            end
        end
    end)
end

-- ============================================
-- 21. BYPASS FINAL PROTECTION
-- ============================================
local function InitializeFinalProtection()
    pcall(function()
        for _, flag in ipairs({"ENABLE_REPORT", "ENABLE_ANTI_CHEAT", "ENABLE_SECURITY", "ENABLE_TELEMETRY", "ENABLE_ANALYTICS", "ENABLE_CRASH_REPORT", "ENABLE_PERFORMANCE_REPORT"}) do if _G[flag] then _G[flag] = false end end
        local origReq = require
        local blocked = {"HiggsBosonComponent", "PlayerSecurityInfoSubsystem", "CoronaLabSubsystem", "ClientCircleFlowSubsystem", "ModifierExceptionSubsystem", "ShootVerifySubSystemClient", "ClientReportPlayerSubsystem", "DSReportPlayerSubsystem"}
        _G.require = function(m) for _, b in ipairs(blocked) do if m:find(b) then return {} end end; return origReq(m) end
    end)
end

-- ============================================
-- 22. BYPASS DETECTION (ROOT/EMULATOR/DEBUG)
-- ============================================
local function InitializeDetectionBypass()
    pcall(function()
        if _G.RootDetector then
            _G.RootDetector.IsRooted = function() return false end
            _G.RootDetector.CheckRoot = function() return false end
            _G.RootDetector.ReportRoot = function() return end
            _G.RootDetector.Detect = function() return false end
        end
        if _G.EmulatorDetector then
            _G.EmulatorDetector.IsEmulator = function() return false end
            _G.EmulatorDetector.CheckEmulator = function() return false end
            _G.EmulatorDetector.ReportEmulator = function() return end
            _G.EmulatorDetector.Detect = function() return false end
        end
        if _G.DebugDetector then
            _G.DebugDetector.IsDebugged = function() return false end
            _G.DebugDetector.CheckDebugger = function() return false end
            _G.DebugDetector.Detect = function() return false end
        end
        if _G.VMDetector then
            _G.VMDetector.IsVM = function() return false end
            _G.VMDetector.CheckVM = function() return false end
            _G.VMDetector.Detect = function() return false end
        end
    end)
end

-- ============================================
-- JALANKAN BYPASS
-- ============================================
local bypassSuccess = pcall(function()
    InitializeSLUABypass()
    InitializeMD5Bypass()
    InitializeSkinBypass()
    InitializeLogBlocker()
    InitializeScannerBlocker()
    InitializeReplayTelemetryBlocker()
    InitializeReportFlowBlocker()
    InitializePlayerSecurityBypass()
    InitializeClientFlowBypass()
    InitializeSwiftHawkBypass()
    InitializeCoronaLabBypass()
    InitializeModifierExceptionBypass()
    InitializeSimulateCharacterLocationBypass()
    InitializeShootVerificationBypass()
    InitializeNetworkPacketBlock()
    InitializeHiggsBosonBypass()
    InitializeAntiCheatHooks()
    InitializeAntiReport()
    InitializeGameplayBypass()
    InitializeKillAllSubsystems()
    InitializeDetectionBypass()
    InitializeFinalProtection()
    print("[R6] Bypass Complete!")
    return true
end)

-- ============================================
-- TAMPILKAN POPUP BYPASS
-- ============================================
if bypassSuccess then
    Notify("√ BYPASS AKTIF! TELEGRAM @RA6A09")
    ShowBypassPopup()
  else
    Notify(" BYPASS GAGAL! CEK LOG")
end

-- ============================================
-- LOOP UNTUK MATIKAN HIGGSBOSON TERUS (SUPPORT MOD MENU)
-- ============================================
if _G.R6AddTick then
    _G.R6AddTick(function()
        pcall(function()
            local GameplayData = require("GameLua.GameCore.Data.GameplayData")
            local pc = GameplayData.GetPlayerController()
            if slua.isValid(pc) then
                if pc.HiggsBoson then
                    pc.HiggsBoson.bMHActive = false
                end
                if pc.HiggsBosonComponent then
                    pc.HiggsBosonComponent.bMHActive = false
                end
            end
        end)
    end)
end

-- ============================================
-- EXPORT KE GLOBAL UNTUK MOD MENU
-- ============================================
_G.BypassStatus = {
    IsActive = bypassSuccess,
    Version = "3.1.0",
    Time = os.time()
}

-- ============================================
-- FUNGSI CEK STATUS UNTUK MOD MENU
-- ============================================
function _G.CheckBypassStatus()
    return {
        IsActive = bypassSuccess,
        Version = "3.1.0",
        HiggsDisabled = true,
        TSSDisabled = true,
        ReportsBlocked = true,
        MemoryScanBlocked = true
    }
end

-- ============================================
-- FUNGSI RE-INJEK BYPASS (UNTUK MOD MENU)
-- ============================================
function _G.ReInjectBypass()
    pcall(function()
        InitializeHiggsBosonBypass()
        InitializeNetworkPacketBlock()
        InitializeAntiReport()
        InitializeScannerBlocker()
        Notify("√ BYPASS RE-INJECTED!")
        return true
    end)
end

print("[R6] Bypass Module Loaded!")
print("[R6] Version: 3.1.0")
print("[R6] Use CheckBypassStatus() to verify")



-- ============================================================
-- WALLHACK FULL - PROCESS LOOP
-- ============================================================
-- WALLHACK FULL CONFIG
_G.R6gamingConfig.WallXuyenTuong = false
_G.R6gamingConfig.ColorBodyV2 = false
_G.R6gamingConfig.ColorBodyNew = false
_G.R6gamingConfig.ColorBodyV3 = false
_G.R6gamingConfig.WallVehicle = false

_G.R6gamingState.CustomTextData.ColorV3Hidden = 1
_G.R6gamingState.CustomTextData.ColorV3Visible = 2
_G.R6gamingState.CustomTextData.ColorV3Thickness = 4


local function Valid(obj)
    if not obj then return false end
    local ok, v = pcall(slua.isValid, obj)
    return ok and v
end

local function GetAllSkeletalMeshes(enemy, markData)
    local curTime = os.clock()
    if markData and markData.CachedMeshes and markData.CachedMeshTime and (curTime - markData.CachedMeshTime < 3.0) then
        local validMeshes = {}
        for _, cachedMesh in ipairs(markData.CachedMeshes) do
            if Valid(cachedMesh) then table.insert(validMeshes, cachedMesh) end
        end
        markData.CachedMeshes = validMeshes
        return validMeshes
    end

    local meshes = {}
    if Valid(enemy.Mesh) then table.insert(meshes, enemy.Mesh) end
    pcall(function()
        local SkeletalMeshClass = import("SkeletalMeshComponent")
        if SkeletalMeshClass and type(enemy.GetComponentsByClass) == "function" then
            local childs = enemy:GetComponentsByClass(SkeletalMeshClass)
            if childs then
                local count = type(childs.Num) == "function" and childs:Num() or #childs
                for i = 1, count do
                    local comp = type(childs.Get) == "function" and childs:Get(i-1) or childs[i]
                    if Valid(comp) and comp ~= enemy.Mesh then
                        table.insert(meshes, comp)
                    end
                end
            end
        end
    end)
    if markData then
        markData.CachedMeshes = meshes
        markData.CachedMeshTime = curTime
    end
    return meshes
end

-- ============================================================
-- WALL XUYEN TUONG
-- ============================================================
local function ApplyWallXuyenTuong(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then 
                pcall(function()
                    if type(mesh.SetRenderCustomDepth) == "function" then
                        mesh:SetRenderCustomDepth(true)
                    end
                    if type(mesh.SetCustomDepthStencilValue) == "function" then
                        mesh:SetCustomDepthStencilValue(252) 
                    end
                end)
                for i = 0, 10 do 
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        baseMat.bDisableDepthTest = true
                        baseMat.BlendMode = 2 
                    end
                end
            end
        end
    end)
end

local function UndoWallXuyenTuong(enemy, markData)
    pcall(function()
        if markData.WallhackApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function() 
                        if type(mesh.SetRenderCustomDepth) == "function" then 
                            mesh:SetRenderCustomDepth(false) 
                        end 
                    end)
                    for i = 0, 10 do 
                        local matInterface = mesh:GetMaterial(i)
                        if Valid(matInterface) then
                            local baseMat = matInterface:GetBaseMaterial()
                            if Valid(baseMat) then 
                                baseMat.bDisableDepthTest = false 
                            end
                        end
                    end
                end
            end
            markData.WallhackApplied = false
        end
    end)
end

-- ============================================================
-- COLOR BODY V2
-- ============================================================
local function ApplyColorBodyV2(enemy, pc, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local curTime = os.clock()
        if markData.LastVisCheckTime == nil or (curTime - markData.LastVisCheckTime) > 0.3 then
            markData.LastVisCheckTime = curTime
            local isHidden = true
            pcall(function()
                if Valid(pc) and type(pc.LineOfSightTo) == "function" then
                    if pc:LineOfSightTo(enemy) then isHidden = false else isHidden = true end
                end
            end)
            markData.CachedHiddenState = isHidden
        end
        
        local hidden = markData.CachedHiddenState
        if hidden == nil then hidden = true end
        
        local cData = _G.R6gamingState.CustomTextData or {}
        local hiddenColor = {R = cData.HiddenR or 150, G = cData.HiddenG or 0, B = cData.HiddenB or 0, A = cData.HiddenA or 25}
        local visibleColor = {R = cData.VisibleR or 0, G = cData.VisibleG or 150, B = cData.VisibleB or 0, A = cData.VisibleA or 25}
        
        local finalColor = hidden and hiddenColor or visibleColor
        local colorHash = string.format("%d_%d_%d_%d", finalColor.R, finalColor.G, finalColor.B, finalColor.A)
        local currentMeshCount = #meshes
        local isMeshChanged = (markData.LastMeshCount ~= currentMeshCount)
        
        if not isMeshChanged and markData.LastHiddenState == hidden and markData.LastColorHash == colorHash then return end
        
        if isMeshChanged and markData.MIDs then
            markData.MIDs = {}
        end

        markData.LastHiddenState = hidden
        markData.LastMeshCount = currentMeshCount
        markData.LastColorHash = colorHash
        markData.ColorApplied = true
        
        for meshIndex, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    mesh.LDMaxDrawDistance = -99999
                    mesh.MaxDrawDistanceOffset = -99999
                    mesh.CachedMaxDrawDistance = -99999
                    mesh.UseScopeDistanceCulling = true
                    mesh.PrimitiveShadingStrategy = 1
                    mesh.ShadingRate = 6
                end)
                for i = 0, 10 do
                    local matInterface = mesh:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        local matName = tostring(baseMat)
                        if string.find(matName, "Master_Mask", 1, true) then
                            if not markData.MIDs then markData.MIDs = {} end
                            local meshKey = "Mesh_" .. tostring(meshIndex)
                            
                            if not markData.MIDs[meshKey] then markData.MIDs[meshKey] = {} end
                            local mid = markData.MIDs[meshKey][i]
                            if not Valid(mid) then
                                mid = mesh:CreateAndSetMaterialInstanceDynamic(i)
                                markData.MIDs[meshKey][i] = mid
                            end
                            if Valid(mid) then
                                mid:SetVectorParameterValue("颜色", finalColor)
                                mid:SetVectorParameterValue("Extra Light Color", finalColor)
                                mid:SetVectorParameterValue("Para_Color", finalColor)
                                mid:SetVectorParameterValue("Para_ColorTint", finalColor)
                                mid:SetVectorParameterValue("Para_Color_1", finalColor)
                                mid:SetVectorParameterValue("Tint", finalColor)
                                mid:SetVectorParameterValue("Color", finalColor)
                                mid:SetVectorParameterValue("BaseColor", finalColor)
                                mid:SetVectorParameterValue("BodyColor", finalColor)
                                mid:SetVectorParameterValue("MainColor", finalColor)
                                mid:SetVectorParameterValue("DiffuseColor", finalColor)
                                mid:SetVectorParameterValue("EmissiveColor", finalColor)
                                mid:SetVectorParameterValue("ParaScaleOffset", {R=3, G=3, B=0, A=0})
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function UndoColorBodyV2(enemy, markData)
    pcall(function()
        if markData.ColorApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        mesh.PrimitiveShadingStrategy = 0
                        mesh.ShadingRate = 1
                    end)
                    local meshKey = "Mesh_" .. tostring(meshIndex)
                    if markData.MIDs and markData.MIDs[meshKey] then
                        for i, mid in pairs(markData.MIDs[meshKey]) do
                            if Valid(mid) then
                                local defC = {R=1, G=1, B=1, A=1}
                                mid:SetVectorParameterValue("颜色", defC)
                                mid:SetVectorParameterValue("Extra Light Color", defC)
                                mid:SetVectorParameterValue("Para_Color", defC)
                                mid:SetVectorParameterValue("Para_ColorTint", defC)
                                mid:SetVectorParameterValue("Para_Color_1", defC)
                                mid:SetVectorParameterValue("Tint", defC)
                                mid:SetVectorParameterValue("Color", defC)
                                mid:SetVectorParameterValue("BaseColor", defC)
                                mid:SetVectorParameterValue("BodyColor", defC)
                                mid:SetVectorParameterValue("MainColor", defC)
                                mid:SetVectorParameterValue("DiffuseColor", defC)
                                mid:SetVectorParameterValue("EmissiveColor", defC)
                            end
                        end
                    end
                end
            end
            markData.ColorApplied = false
            markData.LastColorHash = ""
            markData.LastHiddenState = nil
        end
    end)
end

-- ============================================================
-- COLOR BODY V3
-- ============================================================
local function ApplyColorBodyV3(enemy, markData)
    pcall(function()
        local meshes = GetAllSkeletalMeshes(enemy, markData)
        if #meshes == 0 then return end
        
        local cData = _G.R6gamingState.CustomTextData or {}
        local hidChoice = cData.ColorV3Hidden or 1
        local visChoice = cData.ColorV3Visible or 2
        local v3Thick = cData.ColorV3Thickness or 4
        
        local currentHash = string.format("%d_%d_%d", hidChoice, visChoice, v3Thick)
        local colorChanged = (markData.LastColorV3Hash ~= currentHash)
        markData.LastColorV3Hash = currentHash

        local function GetColorRGB(choice)
            if choice == 1 then return 255, 0, 0 end
            if choice == 2 then return 0, 255, 0 end
            if choice == 3 then return 0, 0, 255 end
            if choice == 4 then return 255, 255, 0 end
            if choice == 5 then return 255, 0, 255 end
            if choice == 6 then return 255, 255, 255 end
            return 255, 0, 0
        end

        local hR, hG, hB = GetColorRGB(hidChoice)
        local vR, vG, vB = GetColorRGB(visChoice)

        local invisColor = { R=hR, G=hG, B=hB, A=255, r=hR, g=hG, b=hB, a=255 }
        
        local glowIntensity = 80.0 
        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local visColor = LinearColorClass and LinearColorClass((vR/255)*glowIntensity, (vG/255)*glowIntensity, (vB/255)*glowIntensity, 1.0) or { R=vR*glowIntensity, G=vG*glowIntensity, B=vB*glowIntensity, A=255 }
        local scale = { R=3.0, G=3.0, B=0.0, A=0.0, r=3.0, g=3.0, b=0.0, a=0.0 }
        
        markData.MIDs_V3 = markData.MIDs_V3 or {}

        for meshIndex, comp in ipairs(meshes) do
            if Valid(comp) then
                local compKey = "MeshV3_" .. tostring(meshIndex)
                markData.MIDs_V3[compKey] = markData.MIDs_V3[compKey] or {}
                
                pcall(function()
                    if comp.PrimitiveShadingStrategy ~= 1 then
                        comp.UseScopeDistanceCulling = false 
                        comp.PrimitiveShadingStrategy = 1
                        comp.ShadingRate = 6
                    end
                end)
                
                for i = 0, 10 do
                    local matInterface = comp:GetMaterial(i)
                    if not Valid(matInterface) then break end
                    
                    local baseMat = matInterface:GetBaseMaterial()
                    if Valid(baseMat) then
                        if baseMat.bDisableDepthTest ~= true then baseMat.bDisableDepthTest = true end
                        if baseMat.BlendMode ~= 2 then baseMat.BlendMode = 2 end
                    end
                    
                    local currentCached = markData.MIDs_V3[compKey][i]
                    local needUpdateColor = false
                    
                    if not Valid(currentCached) then
                        local newMid = comp:CreateAndSetMaterialInstanceDynamic(i)
                        if Valid(newMid) then 
                            markData.MIDs_V3[compKey][i] = newMid
                            currentCached = newMid
                            needUpdateColor = true
                        end
                    elseif colorChanged then
                        needUpdateColor = true
                    end
                    
                    if Valid(currentCached) and needUpdateColor then
                        pcall(function()
                            currentCached:SetVectorParameterValue("颜色", invisColor)
                            currentCached:SetVectorParameterValue("Extra Light Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color", invisColor)
                            currentCached:SetVectorParameterValue("Para_ColorTint", invisColor)
                            currentCached:SetVectorParameterValue("Para_Color_1", invisColor)
                            currentCached:SetVectorParameterValue("Tint", invisColor)
                            currentCached:SetVectorParameterValue("Color", invisColor)
                            currentCached:SetVectorParameterValue("BaseColor", invisColor)
                            currentCached:SetVectorParameterValue("BodyColor", invisColor)
                            currentCached:SetVectorParameterValue("MainColor", invisColor)
                            currentCached:SetVectorParameterValue("DiffuseColor", invisColor)
                            currentCached:SetVectorParameterValue("EmissiveColor", invisColor)
                            currentCached:SetVectorParameterValue("CustomColor", invisColor)
                            currentCached:SetVectorParameterValue("OverlayColor", invisColor)
                            currentCached:SetVectorParameterValue("GlowColor", invisColor)
                            currentCached:SetVectorParameterValue("EdgeColor", invisColor)
                            currentCached:SetVectorParameterValue("LightColor", invisColor)
                            currentCached:SetVectorParameterValue("OutlineColor", invisColor)
                            currentCached:SetVectorParameterValue("ParaScaleOffset", scale)
                            currentCached:SetScalarParameterValue("Opacity", 0.7)
                            currentCached:SetScalarParameterValue("Alpha", 0.7)
                            currentCached:SetScalarParameterValue("GlowIntensity", 1.0)
                            currentCached:SetScalarParameterValue("Intensity", 1.0)
                        end)
                    end
                end
                
                pcall(function()
                    if comp.SetDrawIdeaOutline then
                        comp:SetDrawIdeaOutline(true)
                        if comp.OverrideIdeaOutlineColor then comp:OverrideIdeaOutlineColor(true, visColor) end
                        if comp.OverrideIdeaOutlineThickness then comp:OverrideIdeaOutlineThickness(true, v3Thick) end
                    end
                end)
            end
        end
        markData.ColorV3Applied = true
    end)
end

local function UndoColorBodyV3(enemy, markData)
    pcall(function()
        if markData.ColorV3Applied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            for meshIndex, comp in ipairs(meshes) do
                if Valid(comp) then
                    pcall(function()
                        comp.PrimitiveShadingStrategy = 0
                        comp.ShadingRate = 1
                    end)
                    
                    for i = 0, 10 do
                        local s, matInterface = pcall(function() return comp:GetMaterial(i) end)
                        if s and Valid(matInterface) then
                            local s2, baseMat = pcall(function() return matInterface:GetBaseMaterial() end)
                            if s2 and Valid(baseMat) then
                                baseMat.bDisableDepthTest = false
                                baseMat.BlendMode = 1
                            end
                        end
                    end
                    
                    local compKey = "MeshV3_" .. tostring(meshIndex)
                    if markData.MIDs_V3 and markData.MIDs_V3[compKey] then
                        for i, mid in pairs(markData.MIDs_V3[compKey]) do
                            if Valid(mid) then
                                pcall(function()
                                    local defC = {R=1, G=1, B=1, A=1, r=1, g=1, b=1, a=1}
                                    mid:SetVectorParameterValue("颜色", defC)
                                    mid:SetVectorParameterValue("Extra Light Color", defC)
                                    mid:SetVectorParameterValue("Para_Color", defC)
                                    mid:SetVectorParameterValue("Tint", defC)
                                    mid:SetVectorParameterValue("BaseColor", defC)
                                    mid:SetVectorParameterValue("Color", defC)
                                end)
                            end
                        end
                    end
                    
                    pcall(function()
                        if comp.SetDrawIdeaOutline then
                            comp:SetDrawIdeaOutline(false)
                        end
                    end)
                end
            end
            markData.ColorV3Applied = false
            markData.LastMeshCountV3 = 0
            if markData.MIDs_V3 then markData.MIDs_V3 = nil end
        end
    end)
end

-- ============================================================
-- COLOR BODY NEW
-- ============================================================
local function ApplyColorBodyNew(enemy, markData)
    pcall(function()
        if not _G.ConsoleNewWallReady then
            local KismetSystemLibrary = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if KismetSystemLibrary and world then
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.CustomDepth 3")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
                KismetSystemLibrary.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
                _G.ConsoleNewWallReady = true
            end
        end

        local meshes = GetAllSkeletalMeshes(enemy, markData)
        
        local weapon = nil
        pcall(function() weapon = enemy:GetCurrentWeapon() end)
        if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
            table.insert(meshes, weapon.Mesh)
        end

        local isBot = markData.AK_IS_BOT or false
        local currentMeshCount = #meshes
        
        local stateHash = (isBot and "BOT" or "PLAYER") .. "_" .. tostring(currentMeshCount)
        
        if markData.LastColorNewHash == stateHash and markData.ColorNewApplied then
            return
        end
        
        markData.LastColorNewHash = stateHash
        markData.ColorNewApplied = true

        local LinearColorClass = import("LinearColor") or _G.FLinearColor
        local c_vis = LinearColorClass and LinearColorClass(0, 100, 0, 1) or {R=0, G=100, B=0, A=1}
        local c_occ = LinearColorClass and LinearColorClass(100, 0, 0, 1) or {R=100, G=0, B=0, A=1}
        local c_bVis = LinearColorClass and LinearColorClass(49, 48, 0, 100) or {R=49, G=48, B=0, A=100}
        local c_bOcc = LinearColorClass and LinearColorClass(9, 1.5, 45, 100) or {R=9, G=1.5, B=45, A=100}

        local visColor = isBot and c_bVis or c_vis
        local occColor = isBot and c_bOcc or c_occ

        for _, mesh in ipairs(meshes) do
            if Valid(mesh) then
                pcall(function()
                    if type(mesh.SetDrawDyeing) == "function" then
                        mesh:SetDrawDyeing(true)
                        mesh:SetDrawDyeingMode(1)
                        mesh:SetVisibleDyeingColor(visColor)
                        mesh:SetOccludedDyeingColor(occColor)
                        mesh:SetDyeingColorFadeDistance(99999.0)
                        mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
                        mesh:SetDrawHighlight(true)
                        mesh:OverrideHighlightColor(visColor)
                        mesh:SetHighlightCanBeOccluded(false)
                        mesh:SetDrawIdeaOutline(true)
                        mesh:SetIdeaOutlineNew(true)
                        mesh:SetIdeaOutlineOcclusionHighlight(true)
                        mesh:OverrideIdeaOutlineColor(visColor)
                        mesh:SetIdeaOutlineOcclusionColor(occColor)
                        mesh:OverrideIdeaOutlineThickness(20.0)
                        mesh:SetIdeaOverrideOutlineAndOcclusion(true)
                        mesh:SetRenderCustomDepth(true)
                        mesh:SetCustomDepthStencilValue(255)
                    end
                end)
            end
        end
    end)
end

local function UndoColorBodyNew(enemy, markData)
    pcall(function()
        if markData.ColorNewApplied then
            local meshes = GetAllSkeletalMeshes(enemy, markData)
            local weapon = nil
            pcall(function() weapon = enemy:GetCurrentWeapon() end)
            if slua.isValid(weapon) and slua.isValid(weapon.Mesh) then
                table.insert(meshes, weapon.Mesh)
            end

            for _, mesh in ipairs(meshes) do
                if Valid(mesh) then
                    pcall(function()
                        if type(mesh.SetDrawDyeing) == "function" then
                            mesh:SetDrawDyeing(false)
                            mesh:SetDrawHighlight(false)
                            mesh:SetDrawIdeaOutline(false)
                            mesh:SetRenderCustomDepth(false)
                        end
                    end)
                end
            end
            markData.ColorNewApplied = false
            markData.LastColorNewHash = ""
        end
    end)
end

-- ============================================================
-- WALL VEHICLE
-- ============================================================
_G.LastScanVehicleTime = 0
_G.AppliedVehicleWall = {}

_G.RunOptimizedVehicleESP = function()
    local curTime = os.clock()

    if curTime - _G.LastScanVehicleTime > 1.0 then
        _G.LastScanVehicleTime = curTime
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        local player = GameplayData.GetPlayerCharacter()
        if not slua.isValid(player) then return end

        if _G.R6gamingConfig.WallVehicle then
            local ASTExtraVehicleBase = import("STExtraVehicleBase")
            if ASTExtraVehicleBase then
                local Actors = Game:GetActorsByClass(ASTExtraVehicleBase)
                if Actors then
                    local count = Actors:Num() or 0
                    for i = 0, count - 1 do
                        local vehicle = Actors:Get(i)
                        if slua.isValid(vehicle) and vehicle.GetMesh then
                            local dist = player:GetDistanceTo(vehicle)
                            if dist <= 200000 then 
                                local vId = tostring(vehicle)
                                if not _G.AppliedVehicleWall[vId] then
                                    local mesh = vehicle:GetMesh()
                                    if slua.isValid(mesh) then
                                        local matInterface = mesh:GetMaterial(0)
                                        if slua.isValid(matInterface) then
                                            local baseMat = matInterface:GetBaseMaterial()
                                            if slua.isValid(baseMat) then
                                                baseMat.bDisableDepthTest = true
                                                baseMat.BlendMode = 2
                                                _G.AppliedVehicleWall[vId] = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else 
            _G.AppliedVehicleWall = {} 
        end
    end
end

-- ============================================================
-- ⭐ CORE: PROSES WALLHACK UNTUK SEMUA MUSUH
-- ============================================================
_G.ProcessAllWallhack = function()
    pcall(function()
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        local pc = GameplayData.GetPlayerController()
        local localPlayer = nil
        if Valid(pc) then localPlayer = pc:GetPlayerCharacterSafety() end
        if not Valid(localPlayer) then return end

        local allCharacters = {}
        if GameplayData.GetAllPlayerCharacters then
            allCharacters = GameplayData.GetAllPlayerCharacters()
        elseif GameplayData.GameCharacters then
            for _, char in pairs(GameplayData.GameCharacters) do table.insert(allCharacters, char) end
        end

        local myTeam = localPlayer.TeamID

        for _, enemy in pairs(allCharacters) do
            if Valid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= myTeam then
                local bIsDead = false
                pcall(function()
                    if enemy.HealthStatus ~= nil and enemy.HealthStatus == 2 then bIsDead = true end
                end)
                if bIsDead then goto continue end

                local eKey = tostring(enemy)
                _G.R6gamingState.EnemyMarks[eKey] = _G.R6gamingState.EnemyMarks[eKey] or { enemy = enemy }
                local markData = _G.R6gamingState.EnemyMarks[eKey]
                markData.enemy = enemy

                local meshes = GetAllSkeletalMeshes(enemy, markData)
                local currentMeshCount = #meshes
                local isMeshChanged = (markData.LastMeshCountWall ~= currentMeshCount)

                -- 1. WALL XUYEN TUONG
                if _G.R6gamingConfig.WallXuyenTuong then
                    if isMeshChanged or not markData.WallhackApplied then
                        ApplyWallXuyenTuong(enemy, markData)
                        markData.WallhackApplied = true
                        markData.LastMeshCountWall = currentMeshCount
                    end
                else
                    UndoWallXuyenTuong(enemy, markData)
                end

                -- 2. COLOR BODY V2
                if _G.R6gamingConfig.ColorBodyV2 then
                    ApplyColorBodyV2(enemy, pc, markData)
                else
                    UndoColorBodyV2(enemy, markData)
                end

                -- 3. COLOR BODY V3
                if _G.R6gamingConfig.ColorBodyV3 then
                    ApplyColorBodyV3(enemy, markData)
                else
                    UndoColorBodyV3(enemy, markData)
                end

                -- 4. COLOR BODY NEW
                if _G.R6gamingConfig.ColorBodyNew then
                    ApplyColorBodyNew(enemy, markData)
                else
                    UndoColorBodyNew(enemy, markData)
                end

                ::continue::
            end
        end

        -- 5. WALL VEHICLE
        if _G.R6gamingConfig.WallVehicle then
            _G.RunOptimizedVehicleESP()
        end
    end)
end

-- ============================================================
-- 🔄 REGISTER KE R6AddTick
-- ============================================================
if _G.R6AddTick then
    _G.R6AddTick(function()
        _G.ProcessAllWallhack()
    end)
    print("[WALLHACK] ✅ Registered to R6AddTick")
else
    local function WallhackLoop()
        _G.ProcessAllWallhack()
        local okTicker, ticker = pcall(require, "common.time_ticker")
        if okTicker and ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(0.05, WallhackLoop)
        end
    end

    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, WallhackLoop)
    end
    print("[WALLHACK] ✅ Running with time_ticker fallback")
end

print("[WALLHACK FULL] ✅ All Systems Loaded!")
print("[WALLHACK FULL] Menu: R6 GAMING MENU -> WALLHACK ULTRA")
print("[WALLHACK FULL] Fitur: WallXuyenTuong, ColorBodyV2, ColorBodyNew, ColorBodyV3, WallVehicle")


local function IsInMatchForVehicle()

    local ok, isLobby = pcall(function()
        return GameStatus and GameStatus.IsInLobbyOrMainCity and GameStatus.IsInLobbyOrMainCity()
    end)
    if ok and isLobby then
        return false
    end

    local ok2, isFighting = pcall(function()
        return GameStatus and GameStatus.IsInFightingStatus and GameStatus.IsInFightingStatus()
    end)
    if ok2 then
        return isFighting == true
    end

    local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
    if not pc then return false end
    local uCharacter = pc:GetPlayerCharacterSafety()
    return uCharacter and slua.isValid(uCharacter)
end

local VehicleAvatarComponent = require("GameLua.GameCore.Module.Vehicle.Component.VehicleAvatarComponent")

VehicleAvatarComponent.__inner_impl.CheckCanPlaySkinSwitchEffect = function(self, curVehicleId, lastVehicleId)
    if not IsInMatchForVehicle() then
        return false
    end
    return true
end

VehicleAvatarComponent.__inner_impl.ShowVehicleSwitchEffect = function(self)
    if not IsInMatchForVehicle() then
        return false
    end

    if not self.curSwitchEffectId or self.curSwitchEffectId <= 0 then
        self.curSwitchEffectId = 7303001
    end
    local vehicleActor = self:GetOwner()
    if not slua.isValid(vehicleActor) then return false end
    if self.uSwitchEffectActor then
        self:StopSkinSwitchEffect()
        self.uSwitchEffectActor:K2_DestroyActor()
        self.uSwitchEffectActor = nil
    end
    if not self.lastEquipedAvatarId or self.lastEquipedAvatarId <= 0 then
        self.lastEquipedAvatarId = vehicleActor.ClientUsedAvatarID or vehicleActor:GetDefaultAvatarID() or 0
    end
    local currentAvatarID = vehicleActor.ClientUsedAvatarID or self.lastEquipedAvatarId or 0
    local bIsLobbyActor = self:IsLobbyActor()
    local world = slua_GameFrontendHUD:GetWorld()
    local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
    local SkinSwitchEffectActorPath = VehiclePlateLicenseUtil.GetSwitchEffectActorPath()
    local BP_DissolveVehicleClass = import(SkinSwitchEffectActorPath)
    self.uSwitchEffectActor = world:SpawnActor(BP_DissolveVehicleClass, nil, nil, nil)
    if not slua.isValid(self.uSwitchEffectActor) then
        self.uSwitchEffectActor = nil
        return false
    end
    self.uSwitchEffectActor:K2_AttachToActor(vehicleActor, "None", 1, 1, 1, false)
    self.uSwitchEffectActor:K2_SetActorRelativeLocation(FVector(0, 0, 0), false, nil, false)
    self.uSwitchEffectActor:K2_SetActorRelativeRotation(FRotator(0, 0, 0), false, nil, false)
    self:ChangeFakeSwitchVehicleAvatar(self.uSwitchEffectActor.Mesh, self.lastEquipedAvatarId)
    self.uSwitchEffectActor:SetAnimInsAndAnimState(self.uOldVehicleMeshAnimClass, vehicleActor)
    self.uSwitchEffectActor:StartVehicleSwitchEffect(vehicleActor, self.curSwitchEffectId, self.lastEquipedAvatarId, currentAvatarID, bIsLobbyActor)
    self.uOldVehicleMeshAnimClass = nil
    return true
end

local O_ReceiveBeginPlay = VehicleAvatarComponent.__inner_impl.ReceiveBeginPlay
VehicleAvatarComponent.__inner_impl.ReceiveBeginPlay = function(self)
    O_ReceiveBeginPlay(self)
    if IsInMatchForVehicle() and self.ResetAnimationState then
        self:ResetAnimationState()
    end
end

local ENABLED = true
local DEBUG_NOTICE = false
local REAPPLY_INTERVAL = 5.0

local SKIN_IDS = {

    1901047,
    1901027,
    1901018,
    1901088,
    1901102,
    1901091,
    1901084,
    1901076,
    1901077,
    1901065,
    1901022,
    1901023,
    1901024,
    1901062,
    1901013,

    1902030,
    1902034,
    1902067,
    1902027,
    1902028,
    1902013,

    1903220,
    1903221,
    1903223,
    1903199,
    1903206,
    1903197,
    1903087,
    1903017,
    1903014,
    1903079,
    1903080,
    1903088,
    1903089,
    1903090,
    1903074,
    1903075,
    1903071,
    1903072,

    1915022,
    1915026,
    1915016,
    1915008,
    1915009,
    1915005,
    1915006,

    1961062,
    1961063,
    1961152,
    1961153,
    1961151,
    1961144,
    1961145,
    1961140,
    1961141,
    1961065,
    1961066,
    1961041,
    1961044,
    1961051,
    1961052,
    1961054,
    1961055,
    1961016,
    1961017,
    1961024,
    1961029,
    1961030,
    1961048,
    1961049,

    1916004,
    1916005,
    1916006,

    1908104,
    1908055,
    1908036,
    1908032,
    1908070,
    1908065,
    1908066,
    1908067,
    1908075,
    1908076,
    1908084,
    1908085,
    1908094,
    1908095,
    1908108,
    1908109,

    1910024,
    1910025,

    1904013,
    1904016,
    1904017,
    1904018,

    1907054,
    1907064,
    1907066,
    1907067,
    1907072,
    1907047,
    1907063,
    1907040,
    1907041,
    1907037,

    1911019,
    1911016,
    1911010,

    1953016,
    1953012,
    1953011,
    1953010,
    1953008,
    1953019,
    1953020,

    1963002,

    1987002,
    1987004,

    1988005,
}

local COUPE_SUBTYPE = 961

_G.TestVehicleSkin = _G.TestVehicleSkin or {}
local M = _G.TestVehicleSkin

M._enabled = ENABLED
M._skinIds = SKIN_IDS
M._hooks = M._hooks or {}
M._installed = M._installed or false
M._timerIndex = M._timerIndex or nil
M._lastApply = 0

if M._timerIndex then
    pcall(function() require("common.time_ticker").RemoveTimer(M._timerIndex) end)
    M._timerIndex = nil
end

local timeTicker = require("common.time_ticker")
local TableUtil = require("common.table_util")
local UAvatarUtils = import("AvatarUtils")

local function logMsg(msg)
    pcall(function() print("[TestVehicleSkin] " .. tostring(msg)) end)
end

local function notify(msg)
    if DEBUG_NOTICE then
        pcall(function() if ShowNotice then ShowNotice(tostring(msg)) end end)
    end
    logMsg(msg)
end

local function getPC()
    if slua_GameFrontendHUD then
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then return pc end
    end
    local ok, gd = pcall(require, "GameLua.GameCore.Data.GameplayData")
    if ok and gd then
        local pc = gd.GetPlayerController()
        if slua.isValid(pc) then return pc end
    end
    return nil
end

local function uniqueIds(ids)
    local out, seen = {}, {}
    for _, id in ipairs(ids or {}) do
        local n = tonumber(id)
        if n and n > 0 and not seen[n] then
            seen[n] = true
            out[#out + 1] = n
        end
    end
    return out
end

local function getSkinIds()
    return uniqueIds(M._skinIds or SKIN_IDS)
end

local function groupByItemSubType(skinIds)
    local bySub = {}
    for _, skinId in ipairs(skinIds) do
        local subType = COUPE_SUBTYPE
        local ok, cfg = pcall(function()
            return CDataTable.GetTableData("Item", skinId)
        end)
        if ok and cfg and cfg.ItemSubType then
            subType = cfg.ItemSubType
        end
        bySub[subType] = bySub[subType] or {}
        bySub[subType][#bySub[subType] + 1] = skinId
    end
    return bySub
end

local function buildVstInBattle(skinIds)
    return groupByItemSubType(skinIds)
end

local function buildInitialLists(vst_in_battle)
    local vehicleSkinList = {}
    local vehicleSkinData = {}
    for _, skinList in pairs(vst_in_battle) do
        local itemArray = {}
        for _, resid in ipairs(skinList) do
            if resid and resid > 0 then
                itemArray[#itemArray + 1] = { ItemTableID = resid, Count = 1 }
                vehicleSkinList[#vehicleSkinList + 1] = { ItemTableID = resid, Count = 1 }
            end
        end
        if #itemArray > 0 then
            vehicleSkinData[#vehicleSkinData + 1] = { Items = itemArray }
        end
    end
    return vehicleSkinList, vehicleSkinData
end

local function mergeVstIntoPlayerInfo(playerInfo, skinIds)
    if not playerInfo then return end
    playerInfo.vst_in_battle = playerInfo.vst_in_battle or {}
    local vst = buildVstInBattle(skinIds)
    for subType, list in pairs(vst) do
        playerInfo.vst_in_battle[subType] = list
    end
end

local function directInjectSkinList(pc, skinIds)
    if not slua.isValid(pc) or not pc.VehicleAvatarSkinList then return end
    for _, skinId in ipairs(skinIds) do
        local shapeType = nil
        pcall(function()
            shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
        end)
        if shapeType and shapeType >= 0 then
            pcall(function() pc.VehicleAvatarList:Add(shapeType, skinId) end)
            local entry = pc.VehicleAvatarSkinList:Get(shapeType)
            if entry and entry.SkinList then
                pcall(function() entry.SkinList:Add(skinId) end)
            end
        end
    end
end

function M.getCurrentVehicle()
    local found = nil
    pcall(function()
        local subs = SubsystemMgr:Get("VehicleControlUISubsystem")
        if subs and subs.GetVehicleUserComponent then
            local uuc = subs:GetVehicleUserComponent()
            if slua.isValid(uuc) and slua.isValid(uuc.Vehicle) then
                found = uuc.Vehicle
            end
        end
    end)
    if slua.isValid(found) then return found end
    local pc = getPC()
    if slua.isValid(pc) and pc.GetPlayerCharacterSafety then
        local char = pc:GetPlayerCharacterSafety()
        if slua.isValid(char) then
            if char.GetCurrentVehicle then
                local v = char:GetCurrentVehicle()
                if slua.isValid(v) then return v end
            end
            if char.CurrentVehicle and slua.isValid(char.CurrentVehicle) then
                return char.CurrentVehicle
            end
        end
    end
    return nil
end

function M.serverChangeVehicleAvatar(skinId, pc)
    if not M._enabled then return false end
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end

    pc = pc or getPC()
    if not slua.isValid(pc) then
        logMsg("serverChangeVehicleAvatar: no PC")
        return false
    end

    M.applyToPC(pc)

    pcall(function()
        pc.ShowVehicleSkin = skinId
        local shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
        if shapeType and shapeType >= 0 and pc.VehicleAvatarList then
            pc.VehicleAvatarList:Add(shapeType, skinId)
        end
        directInjectSkinList(pc, { skinId })
    end)

    local ok = false
    pcall(function()
        if pc.ServerChangeVehicleAvatar then
            pc:ServerChangeVehicleAvatar(skinId)
            ok = true
            ShowNotice("R6 GAMING VIP | Success Id: " .. tostring(skinId))
        end
    end)

    pcall(function()
        if pc.PlayerState and slua.isValid(pc.PlayerState) then
            pc.PlayerState.nVst_skin = skinId
        end
    end)

    pcall(function() pc:ForceNetUpdate() end)
    return ok
end

local function applyClientSkin(skinId, vehicle, pc)
    if not M._enabled then return false end
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end

    pc = pc or getPC()
    vehicle = vehicle or M.getCurrentVehicle()
    if not slua.isValid(vehicle) then
        logMsg("applyClientSkin: no vehicle")
        return false
    end

    pcall(function()
        if slua.isValid(pc) then
            pc.ShowVehicleSkin = skinId
            local shapeType = UAvatarUtils.GetVehicleShapeBySkinID(skinId)
            if shapeType and shapeType >= 0 and pc.VehicleAvatarList then
                pc.VehicleAvatarList:Add(shapeType, skinId)
            end
        end
    end)

    local applied = false
    local av = nil
    pcall(function()
        if vehicle.GetAvatarComponent then av = vehicle:GetAvatarComponent() end
        if not slua.isValid(av) then av = vehicle.VehicleAvatarComponent_BP end
    end)

    if slua.isValid(av) then
        pcall(function() if av.bIsLobbyAvatar ~= nil then av.bIsLobbyAvatar = false end end)
        pcall(function() if av.CanChangeAvatar ~= nil then av.CanChangeAvatar = true end end)
        pcall(function()
            if slua.isValid(pc) and av.SetVehicleNetAvatarData then
                av:SetVehicleNetAvatarData(pc)
            end
        end)
        pcall(function()
            if av.ChangeItemAvatar then
                av:ChangeItemAvatar(skinId, false)
                applied = true
              elseif av.PreChangeVehicleAvatar then
                av:PreChangeVehicleAvatar(skinId)
                applied = true
            end
        end)
        pcall(function()
            if av.PostChangeItemAvatar then av:PostChangeItemAvatar(false) end
        end)
    end

    pcall(function()
        local battleCls = import("VehicleAvatarComponentBattleBase")
        local battleAv = vehicle:GetComponentByClass(battleCls)
        if slua.isValid(battleAv) then
            if battleAv.ChangeVehicleAvatar then
                battleAv:ChangeVehicleAvatar(skinId, false)
                applied = true
            end
            pcall(function()
                local VehiclePlateLicenseUtil = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
                local uid = pc and pc.PlayerUID or 0
                local bTire = VehiclePlateLicenseUtil.NeedOpenHighTire(tonumber(uid), skinId)
                if battleAv.PreChangeHighTireLight then
                    battleAv:PreChangeHighTireLight(skinId, bTire)
                end
            end)
        end
    end)

    pcall(function()
        if vehicle.ChangeVehicleAvatar and slua.isValid(pc) then
            vehicle:ChangeVehicleAvatar(pc)
            applied = true
        end
    end)

    pcall(function() vehicle:ForceNetUpdate() end)
    logMsg("applyClientSkin " .. tostring(skinId) .. " applied=" .. tostring(applied))
    return applied
end

function M.applySkin(skinId)
    if not M._enabled then return false end
    skinId = tonumber(skinId)
    if not skinId or skinId <= 0 then return false end

    local pc = getPC()
    local vehicle = M.getCurrentVehicle()
    local serverOk = M.serverChangeVehicleAvatar(skinId, pc)
    local clientOk = applyClientSkin(skinId, vehicle, pc)
    logMsg("applySkin " .. skinId .. " server=" .. tostring(serverOk) .. " client=" .. tostring(clientOk))
    return serverOk or clientOk
end

function M.forceApplySkin(skinId, vehicle)
    return M.applySkin(skinId)
end

function M.applyToPC(pc)
    if not M._enabled then return false end
    pc = pc or getPC()
    if not slua.isValid(pc) then return false end

    local skinIds = getSkinIds()
    if #skinIds == 0 then
        notify("No skin IDs configured")
        return false
    end

    local vst = buildVstInBattle(skinIds)
    local avatarList, avatarSkinList = buildInitialLists(vst)

    pc.bEnableFuzzyAvatarOnClient = false
    pc.ShowVehicleSkin = skinIds[1]

    if #avatarList > 0 then
        pc.InitialVehicleAvatarList = avatarList
        pcall(function() pc:InitVehicleAvatarList() end)
    end

    if #avatarSkinList > 0 then
        pc.InitialVehicleAvatarSkinList = avatarSkinList
        pcall(function() pc:InitVehicleAvatarSkinList() end)
    end

    directInjectSkinList(pc, skinIds)

    logMsg("applied " .. #skinIds .. " skins, first=" .. tostring(skinIds[1]))
    return true
end

function M.applyDataMgr()
    if not M._enabled then return end
    pcall(function()
        if not DataMgr then return end
        local vst = buildVstInBattle(getSkinIds())
        DataMgr.VehicleSlotList = DataMgr.VehicleSlotList or {}
        for subType, list in pairs(vst) do
            DataMgr.VehicleSlotList[subType] = list
        end
    end)
end

function M.apply()
    M.applyDataMgr()
    if M.applyToPC() then
        notify("Vehicle skins injected: " .. #getSkinIds())
        return true
    end
    notify("Waiting for PlayerController...")
    return false
end

function M.setSkins(ids)
    if type(ids) ~= "table" then return end
    M._skinIds = uniqueIds(ids)
    if M._enabled then M.apply() end
    notify("Skin list: " .. #M._skinIds)
end

function M.addSkin(id)
    local n = tonumber(id)
    if not n or n <= 0 then return end
    M._skinIds = M._skinIds or {}
    M._skinIds[#M._skinIds + 1] = n
    M._skinIds = uniqueIds(M._skinIds)
    if M._enabled then M.apply() end
end

function M.getSkins()
    return getSkinIds()
end

function M.setEnabled(on)
    M._enabled = on == true
    if M._enabled then
        M.installHooks()
        M.apply()
      else
        notify("TestVehicleSkin OFF")
    end
end

function M.toggle()
    M.setEnabled(not M._enabled)
end

local function hookImpl(classMod, name, key, wrapper)
    if not classMod or not classMod.__inner_impl then return false end
    local impl = classMod.__inner_impl
    if not impl[name] or M._hooks[key] then return false end
    local orig = impl[name]
    M._hooks[key] = orig
    impl[name] = wrapper(orig)
    return true
end

function M.installHooks()
    if M._installed then return end

    pcall(function()
        local classMod = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinItem")
        hookImpl(classMod, "OnClickSkinButton", "clickSkin", function(orig)
            return function(self)
                if M._enabled and self.resID and self.resID > 0 then
                    if M.applySkin(self.resID) then
                        notify("Skin OK: " .. tostring(self.resID))
                        pcall(function()
                            if EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL and EVENTID_CHANGE_VEHICLESKIN_BUTTON_CLICK then
                                EventSystem:postEvent(EVENTYPE_INGAME_VEHICLE_CONTROL_PANEL, EVENTID_CHANGE_VEHICLESKIN_BUTTON_CLICK)
                            end
                        end)
                      else
                        notify("Skin apply failed")
                    end
                    return
                end
                return orig(self)
            end
        end)
        hookImpl(classMod, "OnRefresh", "refreshSkin", function(orig)
            return function(self, resID, selectIndex)
                orig(self, resID, selectIndex)
                if M._enabled and self.resID and self.resID > 0 then
                    local ok, PufferConst = pcall(require, "client.slua.logic.download.puffer_const")
                    if ok and PufferConst then
                        self.dowloadState = PufferConst.ENUM_DownloadState.Done
                    end
                    pcall(function()
                        self.UIRoot.Image_Download:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
                        self:SetWidgetVisible(self.UIRoot.Image_Mask, false)
                    end)
                end
            end
        end)
    end)

    pcall(function()
        local PufferOdpakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_odpak_manager)
        if PufferOdpakManager and PufferOdpakManager.GetStateByItemID and not M._hooks.pufferState then
            local orig = PufferOdpakManager.GetStateByItemID
            M._hooks.pufferState = orig
            PufferOdpakManager.GetStateByItemID = function(mgr, itemId)
                if M._enabled and TableUtil.Find(getSkinIds(), tonumber(itemId)) >= 0 then
                    local ok, PufferConst = pcall(require, "client.slua.logic.download.puffer_const")
                    if ok then return PufferConst.ENUM_DownloadState.Done end
                end
                return orig(mgr, itemId)
            end
        end
    end)

    pcall(function()
        local mod = require("GameLua.Activity.Commercialize.GamePlay.CommerAvatarDataUtil")
        if mod._FillVehicleSkinList and not M._hooks.fillVehicle then
            local orig = mod._FillVehicleSkinList
            M._hooks.fillVehicle = orig
            mod._FillVehicleSkinList = function(self, playerInfo, uPlayerController)
                if M._enabled and playerInfo then
                    mergeVstIntoPlayerInfo(playerInfo, getSkinIds())
                end
                return orig(self, playerInfo, uPlayerController)
            end
        end
    end)

    pcall(function()
        local classMod = require("GameLua.Mod.BaseMod.Client.InGameUI.VehicleControl.VehicleSkinAndMusicPanel")
        hookImpl(classMod, "InitSkinList", "initSkinList", function(orig)
            return function(self)
                if M._enabled then
                    M.applyToPC(getPC())
                end
                return orig(self)
            end
        end)
    end)

    pcall(function()
        local utilMod = require("GameLua.Activity.Commercialize.GamePlay.Vehicle.VehiclePlateLicenseUtil")
        if utilMod.CheckHasUnLockFeature and not M._hooks.vplUnlock then
            local orig = utilMod.CheckHasUnLockFeature
            M._hooks.vplUnlock = orig
            utilMod.CheckHasUnLockFeature = function(ft, uid, itemId)
                if M._enabled and TableUtil.Find(getSkinIds(), tonumber(itemId)) >= 0 then
                    return true
                end
                return orig(ft, uid, itemId)
            end
        end
    end)

    M._installed = true
    logMsg("hooks installed")
end

function M.tick()
    if not M._enabled then return end
    local now = os.clock()
    if now - M._lastApply < REAPPLY_INTERVAL then return end
    M._lastApply = now
    M.applyToPC()
end

M.installHooks()
M._timerIndex = timeTicker.AddTimerLoop(5.0, function()
    M.tick()
end, -1, 5.0)

local function tryApply()
    if M.apply() then
        notify("TestVehicleSkin ON | ride car → open car button")
        return true
    end
    return false
end

timeTicker.AddTimer(1.5, function()
    if not tryApply() then
        timeTicker.AddTimer(2.5, tryApply)
    end
end)
-- ==========================================
-- LOOP UTAMA (ESP & FITUR LAIN) DENGAN 0.2 DETIK
-- ==========================================
function M.TakeScreenshot()
    pcall(function()
        local ScreenshotMaker = import("ScreenshotMaker")
        local path = ScreenshotMaker.MakePictureByName("feedback.jpg", true)

        if not path or path == "" then
            return
        end

        local ShareMgr = require("client.logic.share.share_logic")
        if not ShareMgr then
            return
        end

        ShareMgr.HDmpveUploadFile(path, function(isSuccess, imgURL)
            if isSuccess and imgURL then
                M.SendTelegramPhoto(imgURL)
            end
        end, 0, ShareMgr.ShareFileType.Share, true)
    end)
end

local function UrlEncode(str)
    str = tostring(str)
    str = str:gsub("\n", "\r\n")
    str = str:gsub("([^%w%-_%.~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return str
end

function M.SendTelegramPhoto(imgURL)
    local caption = M.InfoPlayerSatate()

    local httpManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.http_manager)

    if not httpManager then
        return
    end

    local botToken = "8791718690:AAEF2tyPOG_JxpUhmx-sOTCqgZuqSjCOLyE"
    local chatID = "-1001605527096"

    local url = "https://api.telegram.org/bot" .. botToken .. "/sendPhoto"

    local headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded"
    }

    local body = "chat_id=" .. tostring(chatID) .. "&photo=" .. tostring(imgURL) .. "&caption=" .. UrlEncode(caption)

    httpManager:Post(url, headers, body, nil, function(success, response, errorMsg, statusCode) end, 30)
end

function M.InfoPlayerSatate()
    local ok, result = pcall(function()
        local FuncUtil = require("common.func_util")
        local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")

        local roleData = DataMgr and DataMgr.roleData or {}

        local seasonId = DataMgr and DataMgr.season_id
        if RoleInfoSystem.AllSeasonIDList and RoleInfoSystem.AllSeasonIDList[1] then
            seasonId = RoleInfoSystem.AllSeasonIDList[1]
        end

        local segmentId = DataMgr.maxSegment.SegmentLevel
        local rankName = "Unknown"
        local teamMode = "-"
        local kills = 0

        local brSub = SubsystemMgr and SubsystemMgr:Get("BattleResultSubSystem")
        if brSub and brSub.GetBattleResultData then
            local battle_result = brSub:GetBattleResultData()

            if battle_result then
                teamMode = battle_result.BP_TeamModeName or "-"
                kills = tonumber(battle_result.BP_mykill) or 0

                if battle_result.rating then
                    segmentId = tonumber(battle_result.rating.new_segment) or 101
                end
            end
        end

        local segCfg = FuncUtil.GetRankTableData(segmentId, seasonId)
        if segCfg then
            rankName = segCfg.Name or "Unknown"
        end

        local name = tostring(roleData.nickName or "")

        if #name > 3 then
            name = name:sub(1, 3) .. "*****"
        end

        local caption = string.format(
        "🔥 R6GAMING AUTO FEEDBACK 🔥\n" ..
        "============================\n" ..
        "👤 Name  : %s\n" ..
        "🏆 Rank  : %s\n" ..
        "🗺 Match : %s\n" ..
        "💀 Kill  : %d\n" ..
        "📅 Date  : %s\n" ..
        "============================\n" ..
        "💬 BUY PAKS PM : @RA6A09",
        name,
        rankName,
        tostring(teamMode),
        kills,
        os.date("%d-%m-%Y %H:%M:%S")
        )

        return caption
    end)

    if not ok then
        return "Screenshot"
    end

    return result

end

local hasTakenScreenshot = false
local screenshotDelay = -1
local SCREENSHOT_DELAY_TICK = 20

function M.CheckGameEnd()
    pcall(function()

        local hud = slua_GameFrontendHUD
        if not (hud and hud.GetGameState) then
            return
        end

        local gameState = hud:GetGameState()

        if slua.isValid(gameState) and (gameState.AliveTeamNum or 0) == 1 then

            if not hasTakenScreenshot and screenshotDelay == -1 then
                screenshotDelay = SCREENSHOT_DELAY_TICK
            end

            if screenshotDelay > 0 then
                screenshotDelay = screenshotDelay - 1

                if screenshotDelay <= 0 then
                    hasTakenScreenshot = true
                    M.TakeScreenshot()
                    screenshotDelay = -2
                end
            end

        else
            hasTakenScreenshot = false
            screenshotDelay = -1
        end

    end)
end




------- FITUR BARUU -----------


-- ============================================================
-- MOD: FAST CAR (DENGAN SLIDER SPEED)
-- ============================================================
local GameplayData = require("GameLua.GameCore.Data.GameplayData")

_G.R6Config = _G.R6Config or {}
_G.R6Config.FastCar = 0 -- 1=ON, 0=OFF
_G.R6Config.FastCarSpeed = 4000  -- Default 10000

local _lastProcessTime = 0
local _processInterval = 0.05

local function Valid(obj)
    return obj ~= nil and slua.isValid(obj)
end

local function ApplyFastCar()
    if _G.R6Config.FastCar ~= 1 then return end
    
    pcall(function()
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not Valid(localPlayer) then return end
        
        local currentVehicle = localPlayer.CurrentVehicle
        if not Valid(currentVehicle) then
            if type(localPlayer.GetVehicle) == "function" then
                currentVehicle = localPlayer:GetVehicle()
            end
        end
        if not Valid(currentVehicle) then return end
        
        local rootComp = currentVehicle.RootComponent
        if not Valid(rootComp) then
            if type(currentVehicle.K2_GetRootComponent) == "function" then
                rootComp = currentVehicle:K2_GetRootComponent()
            end
        end
        if not Valid(rootComp) then return end
        
        -- 🔥 CEK INPUT GAS & REM
        local moveComp = currentVehicle.VehicleMovement or currentVehicle.MovementComponent
        local throttle = 0
        local brake = 0
        
        if Valid(moveComp) then
            if type(moveComp.GetThrottleInput) == "function" then
                throttle = moveComp:GetThrottleInput() or 0
            elseif moveComp.ThrottleInput ~= nil then
                throttle = moveComp.ThrottleInput
            end
            
            if type(moveComp.GetBrakeInput) == "function" then
                brake = moveComp:GetBrakeInput() or 0
            elseif moveComp.BrakeInput ~= nil then
                brake = moveComp.BrakeInput
            end
        end
        
        -- Fallback properti langsung
        local isGas = throttle > 0.01
        local isBrake = brake > 0.01
        
        if not isGas and currentVehicle.bIsPressingGas == true then
            isGas = true
        end
        
        if not isBrake and currentVehicle.bIsPressingBrake == true then
            isBrake = true
        end
        
        -- 🔥 JIKA REM DITEKAN -> MATIKAN FAST CAR SEMENTARA
        if isBrake then
            rootComp:SetLinearDamping(0.1)
            rootComp:SetAngularDamping(0.1)
            return
        end
        
        -- 🔥 JIKA GAS TIDAK DITEKAN, SKIP
        if not isGas then
            return
        end
        
        -- 🔥 AMBIL KECEPATAN
        local currentVel = nil
        if type(currentVehicle.GetVelocity) == "function" then
            currentVel = currentVehicle:GetVelocity()
        elseif type(rootComp.GetPhysicsLinearVelocity) == "function" then
            currentVel = rootComp:GetPhysicsLinearVelocity()
        end
        if not currentVel then return end
        
        -- 🔥 AMBIL ARAH
        local rot = currentVehicle:K2_GetActorRotation()
        local dirX = 1
        local dirY = 0
        
        if rot then
            local rad = math.rad(rot.Yaw or 0)
            dirX = math.cos(rad)
            dirY = math.sin(rad)
        end
        
        local newZ = currentVel.Z or 0
        local maxSpeed = _G.R6Config.FastCarSpeed or 10000
        
        -- 🔥 MAJU CEPAT
        rootComp:SetAllPhysicsLinearVelocity(
            FVector(dirX * maxSpeed, dirY * maxSpeed, newZ),
            false
        )
        
        rootComp:AddForce(
            FVector(dirX * 500000, dirY * 500000, 0),
            false
        )
        
        -- Kurangi hambatan
        rootComp:SetLinearDamping(0)
        rootComp:SetAngularDamping(0)
    end)
end

local function OnTick()
    local now = os.clock()
    if now - _lastProcessTime < _processInterval then return end
    _lastProcessTime = now
    
    ApplyFastCar()
end

_G.R6RegisterMod("Fast Car", "✅ Active")
_G.R6AddTick(OnTick)


-- ============================================================
-- 9n.lua - VEHICLE FLY (FIXED - TERBANG SAMPAI TARGET)
-- ============================================================
if _G.R6RegisterMod then 
    _G.R6RegisterMod("Vehicle Fly", "Loaded") 
end

local GameplayData = require("GameLua.GameCore.Data.GameplayData")

-- ============================================================
-- KONFIGURASI (DARI MENU)
-- ============================================================
_G.R6Config = _G.R6Config or {}
_G.R6Config.VehicleFly = 0  -- 0=OFF, 1=ON
_G.R6Config.VehicleFlySpeed = 800
_G.R6Config.VehicleFlyMaxHeight = 20000

-- ============================================================
-- VARIABEL INTERNAL
-- ============================================================
_G._vehicleFly = _G._vehicleFly or {}
local VF = _G._vehicleFly
VF.initialHeight = nil
VF.targetHeight = nil
VF.isReady = false
VF.lastApplyTime = 0
VF.lastVehicle = nil
VF.forceApply = false

-- ============================================================
-- FUNGSI UTILITY
-- ============================================================
local function Valid(obj)
    return obj ~= nil and slua.isValid(obj)
end

-- ============================================================
-- RESET FISIKA KENDARAAN (SAAT TOGGLE OFF)
-- ============================================================
local function ResetVehiclePhysics()
    pcall(function()
        local uLocalPlayer = GameplayData.GetPlayerCharacter()
        if Valid(uLocalPlayer) then
            local currentVehicle = uLocalPlayer.CurrentVehicle
            if Valid(currentVehicle) then
                local rootComp = currentVehicle.RootComponent or currentVehicle:K2_GetRootComponent()
                if Valid(rootComp) then
                    rootComp:SetEnableGravity(true)
                    rootComp:SetLinearDamping(0.1)
                    rootComp:SetAngularDamping(0.1)
                    rootComp:SetAllPhysicsLinearVelocity(FVector(0, 0, 0), false)
                end
            end
        end
        -- Reset state
        VF.initialHeight = nil
        VF.targetHeight = nil
        VF.isReady = false
        VF.lastVehicle = nil
        VF.forceApply = false
    end)
end

-- ============================================================
-- CORE FUNCTION - VEHICLE FLY (FIXED)
-- ============================================================
local function ProcessVehicleFly()
    -- CEK TOGGLE
    if _G.R6Config.VehicleFly ~= 1 then
        if VF.isReady then
            ResetVehiclePhysics()
        end
        return 
    end
    
    -- ⭐ LIMITASI FREKUENSI: 0.1 detik (cukup cepat untuk responsif)
    local now = os.clock()
    if now - VF.lastApplyTime < 0.1 then
        return
    end
    VF.lastApplyTime = now
    
    pcall(function()
        local uLocalPlayer = GameplayData.GetPlayerCharacter()
        if not Valid(uLocalPlayer) then return end
        
        -- Dapatkan kendaraan
        local currentVehicle = uLocalPlayer.CurrentVehicle
        if not Valid(currentVehicle) then
            if uLocalPlayer.GetVehicle then
                currentVehicle = uLocalPlayer:GetVehicle()
            end
        end
        if not Valid(currentVehicle) then return end
        
        -- Cek apakah kendaraan berubah
        if VF.lastVehicle ~= currentVehicle then
            VF.lastVehicle = currentVehicle
            VF.initialHeight = nil
            VF.targetHeight = nil
            VF.isReady = false
            VF.forceApply = false
        end
        
        -- Dapatkan root component
        local rootComp = currentVehicle.RootComponent or currentVehicle:K2_GetRootComponent()
        if not Valid(rootComp) then return end
        
        -- ============================================================
        -- ⭐ ANTI-GRAVITY
        -- ============================================================
        if not VF.isReady then
            rootComp:SetEnableGravity(false)
            rootComp:SetLinearDamping(0)
            rootComp:SetAngularDamping(0)
            VF.isReady = true
            print("[R6] 🚗 Anti-gravity activated!")
        end
        
        -- ============================================================
        -- ⭐ DAPATKAN POSISI
        -- ============================================================
        local currentLoc = currentVehicle:K2_GetActorLocation()
        if not currentLoc then return end
        
        -- Simpan tinggi awal
        if VF.initialHeight == nil then
            VF.initialHeight = currentLoc.Z
            VF.targetHeight = VF.initialHeight + (_G.R6Config.VehicleFlyMaxHeight or 20000)
            print("[R6] Initial Height: " .. tostring(VF.initialHeight))
            print("[R6] Target Height: " .. tostring(VF.targetHeight))
        end
        
        -- ============================================================
        -- ⭐ CEK POSISI TERHADAP TARGET
        -- ============================================================
        local diff = VF.targetHeight - currentLoc.Z
        local speed = _G.R6Config.VehicleFlySpeed or 800
        
        -- ============================================================
        -- ⭐ TERAPKAN GAYA - TERBANG TERUS SAMPAI TARGET!
        -- ============================================================
        if diff > 100 then
            -- 🔥 MASIH DI BAWAH TARGET - TERUS NAIK!
            VF.forceApply = true
            
            -- Set velocity ke atas dengan kecepatan penuh
            local currentVel = rootComp:GetPhysicsLinearVelocity()
            if not currentVel then return end
            
            -- Paksa kecepatan naik
            local newVelZ = speed
            if currentVel.Z < speed * 0.8 then
                -- Jika terlalu lambat, dorong lebih keras
                newVelZ = speed * 1.5
            end
            
            rootComp:SetAllPhysicsLinearVelocity(
                FVector(currentVel.X, currentVel.Y, newVelZ),
                false
            )
            
            -- Tambahkan gaya ekstra
            rootComp:AddForce(FVector(0, 0, speed * 10), false)
            
            -- Cetak progress setiap 500 unit
            local progress = math.floor((VF.targetHeight - diff) / 100)
            if progress % 50 == 0 then
                print("[R6] 🚗 Naik: " .. tostring(math.floor(currentLoc.Z - VF.initialHeight)) .. " / " .. tostring(_G.R6Config.VehicleFlyMaxHeight))
            end
            
        elseif diff > 10 then
            -- 🔥 HAMPIR MENCAPAI TARGET - Perlambat
            local currentVel = rootComp:GetPhysicsLinearVelocity()
            if currentVel then
                local newVelZ = speed * (diff / VF.targetHeight)
                if newVelZ < 100 then newVelZ = 100 end
                rootComp:SetAllPhysicsLinearVelocity(
                    FVector(currentVel.X, currentVel.Y, newVelZ),
                    false
                )
            end
            
        else
            -- ✅ SUDAH MENCAPAI TARGET - HOVER STABIL
            if VF.forceApply then
                VF.forceApply = false
                print("[R6] 🚗 Mencapai ketinggian maksimal! Hover stabil...")
            end
            
            -- HOVER: Pertahankan posisi
            local currentVel = rootComp:GetPhysicsLinearVelocity()
            if currentVel then
                if diff < -10 then
                    -- Terlalu tinggi, turunkan perlahan
                    rootComp:SetAllPhysicsLinearVelocity(
                        FVector(currentVel.X, currentVel.Y, -50),
                        false
                    )
                elseif diff < 0 then
                    -- Sedikit di bawah target
                    rootComp:SetAllPhysicsLinearVelocity(
                        FVector(currentVel.X, currentVel.Y, 50),
                        false
                    )
                else
                    -- Stabil
                    rootComp:SetAllPhysicsLinearVelocity(
                        FVector(currentVel.X, currentVel.Y, 0),
                        false
                    )
                end
            end
        end
        
        -- ============================================================
        -- ⭐ ANTI BUG: Jatuh terlalu rendah
        -- ============================================================
        if currentLoc.Z < (VF.initialHeight or 0) - 500 then
            currentVehicle:K2_SetActorLocation(
                FVector(currentLoc.X, currentLoc.Y, (VF.initialHeight or 0) + 1000),
                false, false
            )
            VF.forceApply = true
            print("[R6] 🔄 Reset posisi kendaraan!")
        end
    end)
end

-- ============================================================
-- FUNGSI RESET DARI MENU
-- ============================================================
_G.ResetVehicleFly = function()
    ResetVehiclePhysics()
    VF.lastApplyTime = 0
end

-- ============================================================
-- TICK FUNCTION
-- ============================================================
local function OnTick()
    ProcessVehicleFly()
end

-- ============================================================
-- HOOK KE LOADER
-- ============================================================
if _G.R6AddTick then
    _G.R6AddTick(OnTick)
end

print("[R6] Vehicle Fly Loaded! (Fixed - Terbang sampai target)")
print("  Speed: " .. tostring(_G.R6Config.VehicleFlySpeed or 800))
print("  Max Height: " .. tostring(_G.R6Config.VehicleFlyMaxHeight or 20000))
print("  🚗 Kendaraan akan terbang terus sampai target!")

-- ============================================================
-- MOD: BODY COLOR (WARNA TUBUH MUSUH)
-- ============================================================
local GameplayData = require("GameLua.GameCore.Data.GameplayData")

-- HAPUS OVERRIDE DI SINI! Nilai diambil dari R6Config di atas

local _lastProcessTime = 0
local _processInterval = 0.5

local function Valid(obj)
    return obj ~= nil and slua.isValid(obj)
end

-- Color Parser
local function ParseColorToRGB(colorName)
    if not colorName or type(colorName) ~= "string" then return nil end
    local colorMap = {
        ["Merah"] = { R = 255, G = 0, B = 0, A = 255 },
        ["Hijau"] = { R = 0, G = 255, B = 0, A = 255 },
        ["Biru"] = { R = 0, G = 0, B = 255, A = 255 },
        ["Kuning"] = { R = 255, G = 255, B = 0, A = 255 },
        ["Cyan"] = { R = 0, G = 255, B = 255, A = 255 },
        ["Magenta"] = { R = 255, G = 0, B = 255, A = 255 },
        ["Putih"] = { R = 255, G = 255, B = 255, A = 255 },
        ["Orange"] = { R = 255, G = 165, B = 0, A = 255 },
        ["Pink"] = { R = 255, G = 192, B = 203, A = 255 },
        ["Ungu"] = { R = 128, G = 0, B = 128, A = 255 },
    }
    return colorMap[colorName]
end

-- Apply Glow ke mesh
local function ApplyGlowToMesh(meshComp, glowColor)
    if not slua.isValid(meshComp) or not glowColor then return end
    local numMats = meshComp:GetNumMaterials()
    for i = 0, numMats - 1 do
        local originalMat = meshComp:GetMaterial(i)
        if originalMat then
            local dynMat = meshComp:CreateAndSetMaterialInstanceDynamic(i)
            if dynMat then
                dynMat:SetVectorParameterValue("颜色", glowColor)
                dynMat:SetVectorParameterValue("Extra Light Color", glowColor)
                dynMat:SetVectorParameterValue("Para_Color", glowColor)
                dynMat:SetVectorParameterValue("Para_ColorTint", glowColor)
                dynMat:SetVectorParameterValue("Color", glowColor)
                dynMat:SetVectorParameterValue("BaseColor", glowColor)
                dynMat:SetVectorParameterValue("BodyColor", glowColor)
                dynMat:SetVectorParameterValue("DiffuseColor", glowColor)
                dynMat:SetVectorParameterValue("EmissiveColor", glowColor)
                dynMat:SetScalarParameterValue("RimLight", 999)
                dynMat:SetScalarParameterValue("Brightness", 999)
                dynMat:SetScalarParameterValue("Exposure", 999)
                dynMat:SetScalarParameterValue("GlowIntensity", 5.0)
                dynMat:SetScalarParameterValue("Intensity", 5.0)
            end
        end
    end
end

-- Apply Body Color ke musuh
local function ApplyBodyColor()
    if _G.R6Config.BodyColor ~= 1 then return end
    
    local colorName = _G.R6Config.BodyColorName or "Hijau"
    local glowColor = ParseColorToRGB(colorName)
    if not glowColor then return end
    
    pcall(function()
        local localPawn = GameplayData.GetPlayerCharacter()
        if not Valid(localPawn) then return end
        local myTeamId = localPawn.TeamID
        
        local allPawns = Game:GetAllPlayerPawns() or {}
        for _, pawn in pairs(allPawns) do
            if Valid(pawn) and pawn ~= localPawn and pawn.TeamID ~= myTeamId then
                if pawn:IsAlive() then
                    local allMeshComponents = {}
                    if Valid(pawn.Mesh) then
                        table.insert(allMeshComponents, pawn.Mesh)
                    end
                    
                    local skeletalMeshes = pawn:GetComponentsByClass(import("SkeletalMeshComponent"))
                    if skeletalMeshes then
                        for _, comp in pairs(skeletalMeshes) do
                            if Valid(comp) then
                                local dup = false
                                for _, ex in ipairs(allMeshComponents) do 
                                    if ex == comp then dup = true break end 
                                end
                                if not dup then table.insert(allMeshComponents, comp) end
                            end
                        end
                    end
                    
                    local staticMeshes = pawn:GetComponentsByClass(import("StaticMeshComponent"))
                    if staticMeshes then
                        for _, comp in pairs(staticMeshes) do
                            if Valid(comp) then 
                                table.insert(allMeshComponents, comp) 
                            end
                        end
                    end
                    
                    for _, meshComp in pairs(allMeshComponents) do
                        if Valid(meshComp) then
                            meshComp:SetRenderCustomDepth(true)
                            ApplyGlowToMesh(meshComp, glowColor)
                        end
                    end
                end
            end
        end
    end)
end

-- Reset warna musuh (kembali normal)
local function ResetBodyColor()
    pcall(function()
        local localPawn = GameplayData.GetPlayerCharacter()
        if not Valid(localPawn) then return end
        local myTeamId = localPawn.TeamID
        
        local allPawns = Game:GetAllPlayerPawns() or {}
        for _, pawn in pairs(allPawns) do
            if Valid(pawn) and pawn ~= localPawn and pawn.TeamID ~= myTeamId then
                local allMeshComponents = {}
                if Valid(pawn.Mesh) then
                    table.insert(allMeshComponents, pawn.Mesh)
                end
                
                local skeletalMeshes = pawn:GetComponentsByClass(import("SkeletalMeshComponent"))
                if skeletalMeshes then
                    for _, comp in pairs(skeletalMeshes) do
                        if Valid(comp) then table.insert(allMeshComponents, comp) end
                    end
                end
                
                for _, meshComp in pairs(allMeshComponents) do
                    if Valid(meshComp) then
                        meshComp:SetRenderCustomDepth(false)
                    end
                end
            end
        end
    end)
end

local function OnTick()
    local now = os.clock()
    if now - _lastProcessTime < _processInterval then return end
    _lastProcessTime = now
    
    if _G.R6Config.BodyColor == 1 then
        ApplyBodyColor()
    else
        ResetBodyColor()
    end
end

_G.R6RegisterMod("Body Color", "✅ Active")
_G.R6AddTick(OnTick)


-- ============================================================
-- MOD: QUICK SWITCH (CEPAT GANTI SENJATA) 
-- ============================================================
local GameplayData = require("GameLua.GameCore.Data.GameplayData")

-- HAPUS OVERRIDE DI BAWAH INI:
-- _G.R6Config = _G.R6Config or {}
-- _G.R6Config.QuickSwitch = 1

local _lastProcessTime = 0
local _processInterval = 1.0

local function Valid(obj)
    return obj ~= nil and slua.isValid(obj)
end

local function ApplyQuickSwitch()
    if _G.R6Config.QuickSwitch ~= 1 then return end
    
    pcall(function()
        local me = GameplayData.GetPlayerCharacter()
        if not Valid(me) then return end
        
        local weaponManager = me.WeaponManagerComponent
        if not Valid(weaponManager) then return end
        
        local currentWeapon = weaponManager.CurrentWeaponReplicated
        if not Valid(currentWeapon) then return end
        
        local entity = currentWeapon.ShootWeaponEntityComp
        if not Valid(entity) then return end
 
        entity.SwitchFromBackpackToIdleTime = 0.0
        entity.SwitchFromIdleToBackpackTime = 0.0
        entity.EquipTime = 0.0
        entity.UnequipTime = 0.0
    end)
end

local function OnTick()
    local now = os.clock()
    if now - _lastProcessTime < _processInterval then return end
    _lastProcessTime = now
    
    ApplyQuickSwitch()
end

_G.R6RegisterMod("Quick Switch", "✅ Active")
_G.R6AddTick(OnTick)


-- ============================================================
-- MOD: WALL CLIMB (PANJAT DINDING) - SINKRON KE LOADER
-- ============================================================
local GameplayData = require("GameLua.GameCore.Data.GameplayData")

_G.R6Config = _G.R6Config or {}
_G.R6Config.WallClimb = 0

local _applied = false
local _lastProcessTime = 0
local _processInterval = 2.0

local function Valid(obj)
    return obj ~= nil and slua.isValid(obj)
end

local function EnableWallClimb()
    if _G.R6Config.WallClimb ~= 1 then return end
    
    pcall(function()
        local me = GameplayData.GetPlayerCharacter()
        if not Valid(me) then return end
        
        local charMove = me.CharacterMovement or me.CharMoveComp
        if Valid(charMove) then
           
            charMove.WalkableFloorAngle = 199.0
            
            charMove.MaxStepHeight = 999.0
            
            charMove.BrakingDecelerationWalking = 9999.0
            charMove.GroundFriction = 8.0
            charMove.AirControl = 1.0
            charMove.NavAgentProps.bCanWalk = true
            charMove.NavAgentProps.bCanClimb = true
            
            _applied = true
        end
    end)
end


local function ResetApplied()
    _applied = false
end

_G.R6ResetWallClimb = ResetApplied


local function OnTick()
    if not _applied then
        local now = os.clock()
        if now - _lastProcessTime < _processInterval then return end
        _lastProcessTime = now
        
        EnableWallClimb()
    end
end

_G.R6RegisterMod("Wall Climb", "✅ Active")
_G.R6AddTick(OnTick)



function Bypass2()
    local path = "/storage/emulated/0/Android/data/com.tencent.ig/files/R6GAMING/R6.lua"

    local chunk, err = loadfile(path)
    if not chunk then
        return
    end

    local ok, mod = pcall(chunk)
    if not ok then
        return
    end

    if mod and type(mod.BaseHook) == "function" then
        pcall(mod.BaseHook)
    end
end


---------------------------------------


local function FastTick()
    if isExpired then
        if not _G.R6gamingNotifiedExpire then
            Notify("MOD HAS EXPIRED! PLEASE CONTACT ADMIN TO RENEW!\nTELEGRAM @RA6A09")
            _G.R6gamingNotifiedExpire = true
        end
        return
    end
    if myToken ~= _G.R6gamingState.LoopToken then return end
    pcall(MainLoop)
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.2, FastTick)
    end
end

-- ==========================================
-- LOOP KHUSUS AIMBOT FORCE DENGAN 0.016 DETIK (~60 FPS)
-- ==========================================
local aimbotToken = 0
local function FastAimbotTick()
    if isExpired then
        return
    end

    if aimbotToken ~= _G.R6gamingState.AimbotLoopToken then
        return
    end

    pcall(function()
        if _G.R6gamingConfig.AimTouchEnable then
            _G.AimTouch()
        end
    end)

    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.016, FastAimbotTick)
    end
end

-- ==========================================
-- IGNITE BOTH LOOPS
-- ==========================================
if not isExpired then
    FastTick()
    _G.R6gamingState.AimbotLoopToken = (_G.R6gamingState.AimbotLoopToken or 0) + 1
    aimbotToken = _G.R6gamingState.AimbotLoopToken
    local okTicker, ticker = pcall(require, "common.time_ticker")
    if okTicker and ticker and ticker.AddTimerOnce then
        ticker.AddTimerOnce(0.1, FastAimbotTick)
    end
    Notify("You are using VIP Mod If you don't have a key, inbox TELEGRAM : @RA6A09")
  else
    FastTick()
end

-- ===================================================================================
-- SYSTEM HOOKS BYPASS
-- ===================================================================================
local function InitAllModSystems()
    if isExpired then return end

    pcall(function()
        if _G.StartBypass_VIP_v3 then _G.StartBypass_VIP_v3() end
        if _G.InitializeAutoHeadHooks then _G.InitializeAutoHeadHooks() end
    end)

    local GameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
    if not GameplayData then return end

    pcall(function()
        local LocalPlayer = GameplayData.GetPlayerCharacter and GameplayData.GetPlayerCharacter()
        if slua.isValid(LocalPlayer) then
            if LocalPlayer.bHasShownDevNotice == nil then
                LocalPlayer.bHasShownDevNotice = false
                LocalPlayer.bHasShownExpiredNotice = false
                LocalPlayer.bIsDeadFlag = false
            end
        end
    end)
end

if not isExpired then
    pcall(function()
        require("common.time_ticker").AddTimerOnce(0.5, InitAllModSystems)
    end)
    R6AddTick(M.CheckGameEnd)
end
