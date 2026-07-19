local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local DEFAULT_FFLAGS = [[{
  "FFlagEnableAccessibilitySettingsEffectsInExperienceChat": "True",
  "FFlagEnableToastLiteRender": "true",
  "FFlagRenderEnableGlobalInstancingD3D11": "true",
  "DFFlagTeleportPreloadingMetrics5": "true",
  "FFlagReduceTextureMemory": "True",
  "DFFlagRakNetDetectNetUnreachable": "True",
  "DFIntReplicationBatchSize": "32",
  "DFFlagQueueDataPingFromSendData": "True",
  "DFIntRenderThrottlePercentage": "100",
  "DFFlagFixUIRenderModifierUnibarBug": "true",
  "DFIntMemoryCleanupDelay": "1000",
  "DFIntTexturePoolSize": "512",
  "FFlagPushFrameTimeToHarmony": "true",
  "FFlagRenderFixULGlassRefraction": "true",
  "DFFlagPerformanceControlEnableMemoryProbing3": "true",
  "DFIntMobileTextureQuality": "2",
  "FFlagQuaternionPoseCorrection": "true",
  "DFFlagRakNetEnablePoll": "true",
  "FFlagLuauCodegen": "true",
  "DFFlagUnifyLegacyJointGeometry": "true",
  "FFlagScreenGuiDoNotRenderUnderViewportFrame": "true",
  "FFlagFixGraphicsQuality": "True",
  "DFFlagRenderMeshBulkUploadEnable": "true",
  "FFlagUserShowGuiHideToggles": "true",
  "DFFlagRenderEmitterOcclusionCulling": "true",
  "DFFlagFrameTimeJitterMedians2": "True",
  "DFFlagSimDCDEnableWithoutRollout2": "true",
  "FFlagEnableQuickGameLaunch": "true",
  "FFlagDebugDisableTelemetryEventIngest": "True",
  "FFlagVoiceBetaBadge": "False",
  "FFlagUserUpdateInputConnections": "true",
  "FFlagEnablePreferredTextSizeGuiService": "true",
  "FFlagEnableTerrainOptimizations": "True",
  "DFFlagEnableSoundPreloading": "true",
  "DFFlagDebugSkipMeshVoxelizer": "true",
  "FFlagHandleAltEnterFullscreenManually": "false",
  "DFFlagDisableDPIScale": "true",
  "DFFlagMatrixFromEulerPerf": "true",
  "FFlagCommitToGraphicsQualityFix": "True",
  "FIntRenderShadowIntensity": "0",
  "FStringWhitelistVerifiedUserId": "1909432994",
  "FFlagEnableInGameMenuV3": "True",
  "DFFlagEnableTexturePreloading": "true",
  "FFlagFixInputLag": "True",
  "DFFlagRenderDeferredExecutionEnabled": "True",
  "FFlagImproveShiftLockTransition": "true",
  "FFlagEnablePingOptimizations": "True",
  "DFFlagRenderFastClusterOcclusionCulling": "false",
  "FFlagMouseGetPartOptimization": "true",
  "DFFlagSimSkipVoxelCDECMerge": "true",
  "DFFlagAllowRegistrationOfAnimationClipInCoreScripts": "true",
  "DFFlagSkipSomeProperties": "true",
  "DFFlagDebugRenderForceTechnologyVoxel": "True",
  "FFlagUISUseLastFrameTimeInUpdateInputSignal": "true",
  "FFlagRenderDeferShaderLoading": "true",
  "DFFlagTeleportClientAssetPreloadingEnabledIXP2": "true",
  "DFFlagDebugPauseVoxelizer": "true",
  "DFIntTextureQualityOverride": "1",
  "DFFlagOnlyDecrementCompletenessIfReplicating": "true",
  "FFlagDisablePostFx": "true",
  "FFlagOptimizeMobileRendering": "True",
  "FFlagOptimizeAvatarLoading": "True",
  "DFIntTextureCompressionLevel": "1",
  "DFFlagOptimizePartsInPart": "true",
  "FFlagTaskSchedulerLimitTargetFpsTo2402": "false",
  "DFIntTaskSchedulerTargetFps": "29383",
  "DFFlagRakNetDecoupleRecvAndUpdateLoopShutdown": "true",
  "FIntFullscreenTitleBarTriggerDelayMillis": "3600000",
  "FFlagRenderFallbackToPBR": "False",
  "FFlagLoginPageOptimizedPngs": "True",
  "DFFlagRenderModelClusterOcclusionCulling": "false",
  "DFIntRaknetBandwidthPingSendEveryXSeconds": "1",
  "DFIntRakNetResendRttMultiple": "1",
  "FFlagEnableMenuControlsABTest": "False",
  "DFFlagOptimizeClusterCacheAlloc": "true",
  "DFFlagRenderFastFlag3": "True",
  "FFlagProcessEventQueueOnInput": "true",
  "FFlagRenderLegacyShadowsQualityRefactor": "true",
  "FFlagDisableChatWindowRerenderOnPlayerJoinAndLeave": "true",
  "DFFlagTeleportClientAssetPreloadingEnabledIXP": "true",
  "DFFlagClampIncomingReplicationLag": "true",
  "FIntRomarkStartWithGraphicQualityLevel": "1",
  "FFlagDebugDisableTelemetryV2Stat": "True",
  "FFlagEnableInGameMenuModernization": "false",
  "DFFlagGameNetFixReplicationSkipBug": "true",
  "FFlagRenderEnableGlobalInstancing7": "true",
  "FFlagRenderCBRefactor2": "true",
  "FFlagRenderFixGrassPrepass": "true",
  "FFlagEnableAggressivePacketResends": "True",
  "FFlagUserBetterInertialScrolling": "true",
  "DFFlagSkipReadDiskCacheRedirects": "true",
  "FFlagEnableInGameMenuControls": "True",
  "FFlagDebugDisableTelemetryV2Counter": "True",
  "FIntDebugForceMSAASamples": "1",
  "DFIntTextureCompositorActiveJobs": "0",
  "FFlagRenderDebugCheckThreading2": "true",
  "FFlagFastGPULightCulling3": "true",
  "FFlagBillboardGuiOnlyLayoutWhenRenderable": "true",
  "FLogNetwork": "7",
  "DFIntGcStepSize": "200",
  "DFIntMaxTextureSize": "2048",
  "FFlagSimEnableDCD16": "true",
  "FFlagGraphicsEnableD3D10Compute": "True",
  "FFlagOptimizeSoundPlayback": "True",
  "FFlagUseStableSort": "True",
  "DFFlagDisableFastLogTelemetry": "true",
  "DFFlagEnablePreloadAvatarAssets": "True",
  "DFFlagRenderOptimizeWallClock2": "True",
  "FFlagHttpAssetCacheInitOnly6": "True",
  "FStringInGameMenuModernizationStickyBarForcedUserIds": "1909432994",
  "FFlagAnimationClipMemCacheEnabled": "true",
  "FFlagEarlyUpdateBoundings": "true",
  "DFIntCullingFrustumPadding": "5",
  "FFlagNewLightAttenuation": "True",
  "FFlagRenderTestEnableDistanceCulling": "true",
  "FFlagRenderSkipReadingShaderData": "true",
  "FFlagOptimizeUIBlur": "True",
  "DFFlagSimSolverOptimizeLDLCache": "True",
  "FFlagFixIGMTabTransitions": "True",
  "FFlagLuaMenuPerfImprovements": "true",
  "FFlagEnableRbxPostAPI": "True",
  "DFFlagCorrectCachePolicySkipRedirectCache": "true",
  "DFFlagSkipSomePropertiesSkip": "true",
  "DFIntPerformanceControlTextureQualityBestUtility": "-1",
  "DFFlagDebugPerfMode": "true",
  "DFFlagSampleAndRefreshRakPing": "true",
  "FFlagDontCreatePingJob": "True",
  "FFlagEnableTerrainFoliageOptimizations": "True",
  "FFlagDebugDisableTelemetryEphemeralStat": "True",
  "FIntDebugTextureManagerSkipMips": "10",
  "FFlagRenderFixSurfaceLight": "true",
  "DFIntInputBufferSize": "3",
  "DFIntSoundChannels": "24",
  "DFIntRenderQueueSize": "64",
  "FFlagEnableV3MenuABTest3": "False",
  "FFlagDebugDisableParticleEmitterCulling": "False",
  "FFlagUserCameraInputDt": "true",
  "FFlagEnableAccessibilitySettingsAPIV2": "True",
  "FFlagEnableRateLimiting": "True",
  "FFlagGpuGeometryManager7": "True",
  "FFlagEnablePreferredTextSizeStyleFixesInAppShell3": "True",
  "FFlagTopBarUseNewBadge": "false",
  "FFlagUserCameraInputRefactor3": "true",
  "DFIntShaderCacheSize": "256",
  "DFIntCodecMaxIncomingPackets": "100",
  "FFlagEnableNewInput": "True",
  "DFIntGuiInsetMaxCorrection": "10",
  "FFlagEnableAccessibilitySettingsInExperienceMenu2": "True",
  "FFlagTweenOptimizations": "True",
  "DFFlagUpdateClientChannelA": "true",
  "DFFlagAllowPropertyDefaultSkip": "true",
  "DFIntPathfindingThreads": "2",
  "DFFlagEnableMeshPreloading2": "true",
  "FFlagEnableAccessibilitySettingsEffectsInCoreScripts2": "True",
  "FFlagRenderNoLowFrmBloom": "true",
  "FStringVoiceBetaBadgeLearnMoreLink": "null",
  "DFFlagJointIrregularityOptimization": "true",
  "FFlagRenderFixBrokenAvatarShadow": "true",
  "FFlagRenderDX11FixWaitForGpu": "true",
  "FFlagBatchAssetApi": "True",
  "FFlagBetaBadgeLearnMoreLinkFormview": "False",
  "FFlagFixMemoryLeaks": "True",
  "FFlagAssetImportRemoveAnimationSuffix": "true",
  "DFIntMaxParticleEmitters": "100",
  "FFlagAssetPreloadingIXP": "true",
  "FIntActivatedCountTimerMSMouse": "1",
  "FFlagOptimizeNetworkReplication": "True",
  "FFlagEnableInGameMenuSongbirdABTest": "false",
  "FFlagDebugDisableTelemetryV2Event": "True",
  "FFlagEnableFasterPathfinding": "True",
  "FFlagUseNewMemoryManager": "True",
  "FFlagEnableBetterCulling": "True",
  "FFlagDebugSkyGray": "true",
  "FFlagLuauSolverV2": "true",
  "DFFlagMergeFakeInputEvents3": "true",
  "FFlagEnableFasterRendering": "True",
  "FFlagFixTransparentSurfacesZOrder": "True",
  "FFlagRenderGpuTextureCompressor": "true",
  "FFlagLuaAppExitModalDoNotShow": "True",
  "FFlagLuaAppLegacyInputSettingRefactor": "true",
  "FFlagPreloadTextureItemsOption4": "true",
  "FFlagRenderDynamicResolutionScale12": "true",
  "FFlagMessageBusCallOptimization": "True",
  "FFlagDebugDisableTelemetryPoint": "True",
  "DFFlagSimOptimizeSetSize": "true",
  "DFFlagTeleportClientAssetPreloadingEnabled9": "true",
  "FFlagReduceShaderCompilation": "True",
  "FFlagSimOptimizeGeometryChangedAssemblies": "true",
  "FFlagGcInParallelWithRenderPrepare3": "true",
  "FFlagRenderUnifiedLighting16": "true",
  "FFlagRenderFixFog": "True",
  "DFIntAvatarCacheSize": "50",
  "DFFlagTeleportClientAssetPreloadingDoingExperiment2": "true",
  "FIntTerrainArraySliceSize": "0",
  "FFlagGameBasicSettingsFramerateCap5": "false",
  "DFIntDebugFRMQualityLevelOverride": "1",
  "DFFlagTextureQualityOverrideEnabled": "true",
  "FFlagControlBetaBadgeWithGuac": "false",
  "DFFlagSimDcdRecompUseClosedVoxel4": "true",
  "FIntActivatedCountTimerMSKeyboard": "1",
  "FFlagHighlightOutlinesOnMobile": "true",
  "FFlagDebugGraphicsPreferD3D11": "true",
  "FFlagDebugDisableTelemetryEphemeralCounter": "True",
  "FFlagFutureIsBrightPhase3": "False",
  "FFlagEnableGCStepSize": "True",
  "DFFlagRakNetDisconnectNotification": "True",
  "FFlagEnablePreferredTextSizeScale": "true",
  "DFIntMaxProcessPacketsStepsPerCyclic": "5000",
  "FFlagGraphicsFixMsaaInGuiScene": "true",
  "FFlagAdServiceEnabled": "false"
}]]

local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3,
    })
end

local function stripFlagPrefix(flagName)
    local prefixes = {
        "DFFlag",
        "FFlag",
        "DFInt",
        "FInt",
        "DFString",
        "FString",
    }

    for _, prefix in ipairs(prefixes) do
        if flagName:sub(1, #prefix) == prefix then
            return flagName:sub(#prefix + 1)
        end
    end

    return flagName
end

local function applyJson(jsonText)
    local decodedSuccessfully, decoded = pcall(function()
        return HttpService:JSONDecode(jsonText)
    end)

    if not decodedSuccessfully or type(decoded) ~= "table" then
        notify("Error", "Invalid JSON format!")
        return
    end

    local appliedCount = 0

    for flagName, value in pairs(decoded) do
        local strippedName = stripFlagPrefix(tostring(flagName))

        pcall(function()
            setfflag(strippedName, tostring(value))
        end)

        appliedCount = appliedCount + 1
    end

    notify("Success", "Applied " .. tostring(appliedCount) .. " FFlags!")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AVERAGE_FFLAG_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local toggleButton = Instance.new("TextButton", screenGui)
toggleButton.Size = UDim2.new(0, 45, 0, 45)
toggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(48, 25, 82)
toggleButton.Text = ""
toggleButton.Draggable = true
toggleButton.Active = true

Instance.new("UICorner", toggleButton)

local toggleStroke = Instance.new("UIStroke", toggleButton)
toggleStroke.Color = Color3.fromRGB(138, 90, 224)

local togglePattern = Instance.new("ImageLabel", toggleButton)
togglePattern.Image = "rbxassetid://6803353442"
togglePattern.BackgroundTransparency = 1
togglePattern.ImageTransparency = 0.95
togglePattern.ScaleType = Enum.ScaleType.Tile
togglePattern.TileSize = UDim2.new(0, 10, 0, 10)
togglePattern.Size = UDim2.new(1, 0, 1, 0)
togglePattern.BorderSizePixel = 0
togglePattern.ZIndex = toggleButton.ZIndex

local toggleIcon = Instance.new("ImageLabel", toggleButton)
toggleIcon.Name = "Icon"
toggleIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
toggleIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Image = "rbxthumb://type=Asset&id=118294068232420&w=150&h=150"
toggleIcon.ScaleType = Enum.ScaleType.Fit
toggleIcon.ZIndex = toggleButton.ZIndex + 1

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 360, 0, 280)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(48, 25, 82)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

Instance.new("UICorner", mainFrame)

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(138, 90, 224)

local mainPattern = Instance.new("ImageLabel", mainFrame)
mainPattern.Image = "rbxassetid://6803353442"
mainPattern.BackgroundTransparency = 1
mainPattern.ImageTransparency = 0.95
mainPattern.ScaleType = Enum.ScaleType.Tile
mainPattern.TileSize = UDim2.new(0, 10, 0, 10)
mainPattern.Size = UDim2.new(1, 0, 1, 0)
mainPattern.BorderSizePixel = 0
mainPattern.ZIndex = mainFrame.ZIndex

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Text = "AVERAGE FFLAG UI"
titleLabel.Font = Enum.Font.Cartoon
titleLabel.TextSize = 22
titleLabel.BackgroundTransparency = 0.9
titleLabel.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Size = UDim2.new(1, 0, 0, 40)

Instance.new("UICorner", titleLabel)

local rawUrlBox = Instance.new("TextBox", mainFrame)
rawUrlBox.PlaceholderText = "Paste Raw GitHub URL here..."
rawUrlBox.Text = ""
rawUrlBox.Size = UDim2.new(0, 320, 0, 35)
rawUrlBox.Position = UDim2.new(0.05, 0, 0.2, 0)
rawUrlBox.TextColor3 = Color3.new(1, 1, 1)
rawUrlBox.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
rawUrlBox.Font = Enum.Font.Cartoon
rawUrlBox.TextSize = 14
rawUrlBox.BackgroundTransparency = 0.8

Instance.new("UICorner", rawUrlBox)

local openEditorButton = Instance.new("TextButton", mainFrame)
openEditorButton.Text = "Open Editor"
openEditorButton.Size = UDim2.new(0, 155, 0, 35)
openEditorButton.Position = UDim2.new(0.05, 0, 0.38, 0)
openEditorButton.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
openEditorButton.BackgroundTransparency = 0.8
openEditorButton.TextColor3 = Color3.new(1, 1, 1)
openEditorButton.Font = Enum.Font.Cartoon
openEditorButton.TextSize = 18

Instance.new("UICorner", openEditorButton)

local defaultFlagsButton = Instance.new("TextButton", mainFrame)
defaultFlagsButton.Text = "Default Fflags"
defaultFlagsButton.Size = UDim2.new(0, 155, 0, 35)
defaultFlagsButton.Position = UDim2.new(0.51, 0, 0.38, 0)
defaultFlagsButton.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
defaultFlagsButton.BackgroundTransparency = 0.8
defaultFlagsButton.TextColor3 = Color3.new(1, 1, 1)
defaultFlagsButton.Font = Enum.Font.Cartoon
defaultFlagsButton.TextSize = 18

Instance.new("UICorner", defaultFlagsButton)

local applyUrlButton = Instance.new("TextButton", mainFrame)
applyUrlButton.Text = "Apply URL"
applyUrlButton.Size = UDim2.new(0, 320, 0, 40)
applyUrlButton.Position = UDim2.new(0.05, 0, 0.58, 0)
applyUrlButton.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
applyUrlButton.BackgroundTransparency = 0.8
applyUrlButton.TextColor3 = Color3.new(1, 1, 1)
applyUrlButton.Font = Enum.Font.Cartoon
applyUrlButton.TextSize = 20

Instance.new("UICorner", applyUrlButton)

local rejoinButton = Instance.new("TextButton", mainFrame)
rejoinButton.Text = "Rejoin"
rejoinButton.Size = UDim2.new(0, 320, 0, 40)
rejoinButton.Position = UDim2.new(0.05, 0, 0.78, 0)
rejoinButton.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
rejoinButton.BackgroundTransparency = 0.8
rejoinButton.TextColor3 = Color3.new(1, 1, 1)
rejoinButton.Font = Enum.Font.Cartoon
rejoinButton.TextSize = 20

Instance.new("UICorner", rejoinButton)

local editorFrame = Instance.new("Frame", screenGui)
editorFrame.Size = UDim2.new(0, 340, 0, 240)
editorFrame.AnchorPoint = Vector2.new(0.5, 0.5)
editorFrame.Position = UDim2.new(0.5, 0, 1.5, 0)
editorFrame.BackgroundColor3 = Color3.fromRGB(48, 25, 82)
editorFrame.BorderSizePixel = 0
editorFrame.ZIndex = 10

Instance.new("UICorner", editorFrame)

local editorStroke = Instance.new("UIStroke", editorFrame)
editorStroke.Color = Color3.fromRGB(138, 90, 224)

local editorPattern = Instance.new("ImageLabel", editorFrame)
editorPattern.Image = "rbxassetid://6803353442"
editorPattern.BackgroundTransparency = 1
editorPattern.ImageTransparency = 0.95
editorPattern.ScaleType = Enum.ScaleType.Tile
editorPattern.TileSize = UDim2.new(0, 10, 0, 10)
editorPattern.Size = UDim2.new(1, 0, 1, 0)
editorPattern.BorderSizePixel = 0
editorPattern.ZIndex = 10

local jsonScroll = Instance.new("ScrollingFrame", editorFrame)
jsonScroll.Size = UDim2.new(0, 310, 0, 140)
jsonScroll.Position = UDim2.new(0.05, 0, 0.15, 0)
jsonScroll.BackgroundTransparency = 0.8
jsonScroll.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
jsonScroll.CanvasSize = UDim2.new(0, 0, 5, 0)
jsonScroll.ScrollBarThickness = 4
jsonScroll.ZIndex = 11

Instance.new("UICorner", jsonScroll)

local jsonBox = Instance.new("TextBox", jsonScroll)
jsonBox.PlaceholderText = "Paste JSON here..."
jsonBox.Text = ""
jsonBox.Size = UDim2.new(1, 0, 1, 0)
jsonBox.BackgroundTransparency = 1
jsonBox.TextColor3 = Color3.new(1, 1, 1)
jsonBox.Font = Enum.Font.Cartoon
jsonBox.TextSize = 14
jsonBox.TextXAlignment = Enum.TextXAlignment.Left
jsonBox.TextYAlignment = Enum.TextYAlignment.Top
jsonBox.MultiLine = true
jsonBox.ZIndex = 12

local closeEditorButton = Instance.new("TextButton", editorFrame)
closeEditorButton.Text = "Close"
closeEditorButton.Size = UDim2.new(0, 145, 0, 35)
closeEditorButton.Position = UDim2.new(0.05, 0, 0.8, 0)
closeEditorButton.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
closeEditorButton.TextColor3 = Color3.new(1, 1, 1)
closeEditorButton.Font = Enum.Font.Cartoon
closeEditorButton.ZIndex = 11

Instance.new("UICorner", closeEditorButton)

local applyEditorButton = Instance.new("TextButton", editorFrame)
applyEditorButton.Text = "Apply FFlag"
applyEditorButton.Size = UDim2.new(0, 145, 0, 35)
applyEditorButton.Position = UDim2.new(0.51, 0, 0.8, 0)
applyEditorButton.BackgroundColor3 = Color3.fromRGB(93, 63, 168)
applyEditorButton.TextColor3 = Color3.new(1, 1, 1)
applyEditorButton.Font = Enum.Font.Cartoon
applyEditorButton.ZIndex = 11

Instance.new("UICorner", applyEditorButton)

local mainVisible = true

toggleButton.MouseButton1Click:Connect(function()
    mainVisible = not mainVisible

    if mainVisible then
        mainFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.5, true)
    else
        mainFrame:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), "Out", "Quad", 0.5, true)
        editorFrame:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), "In", "Quad", 0.5, true)
    end
end)

openEditorButton.MouseButton1Click:Connect(function()
    editorFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Back", 0.5, true)
end)

closeEditorButton.MouseButton1Click:Connect(function()
    editorFrame:TweenPosition(UDim2.new(0.5, 0, 1.5, 0), "In", "Back", 0.5, true)
end)

defaultFlagsButton.MouseButton1Click:Connect(function()
    applyJson(DEFAULT_FFLAGS)
end)

applyEditorButton.MouseButton1Click:Connect(function()
    applyJson(jsonBox.Text)
end)

applyUrlButton.MouseButton1Click:Connect(function()
    notify("Fetching", "Downloading...")

    local downloaded, content = pcall(function()
        return game:HttpGet(rawUrlBox.Text)
    end)

    if not downloaded then
        notify("Error", "Failed URL")
        return
    end

    applyJson(content)
end)

rejoinButton.MouseButton1Click:Connect(function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
end)

mainFrame:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Quad", 0.8, true)
