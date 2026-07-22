local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local terrain = Workspace:FindFirstChildOfClass("Terrain")

local oldFflagGui = playerGui:FindFirstChild("AVERAGE_FFLAG_UI")
if oldFflagGui then
	oldFflagGui:Destroy()
end

local oldStretchGui = playerGui:FindFirstChild("StretchController")
if oldStretchGui then
	oldStretchGui:Destroy()
end

RunService:UnbindFromRenderStep("StretchControllerRender")
RunService:UnbindFromRenderStep("TesteHubScreenStretch")

local existing = playerGui:FindFirstChild("TesteHub")
if existing then
	existing:Destroy()
end

local theme = {
	background = Color3.fromRGB(42, 29, 62),
	surface = Color3.fromRGB(82, 59, 118),
	surfaceAlt = Color3.fromRGB(98, 72, 140),
	elevated = Color3.fromRGB(114, 85, 160),
	hover = Color3.fromRGB(132, 101, 183),
	selection = Color3.fromRGB(148, 116, 204),
	input = Color3.fromRGB(58, 41, 84),
	active = Color3.fromRGB(218, 187, 255),
	accent = Color3.fromRGB(218, 187, 255),
	accentSoft = Color3.fromRGB(158, 123, 216),
	accentBright = Color3.fromRGB(252, 247, 255),
	text = Color3.fromRGB(255, 253, 255),
	subtext = Color3.fromRGB(246, 239, 252),
	dim = Color3.fromRGB(224, 211, 238),
	border = Color3.fromRGB(177, 145, 216),
	borderActive = Color3.fromRGB(231, 211, 255)
}

local function create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent
	return object
end

local function playTween(object, properties, duration, style, direction)
	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.2,
			style or Enum.EasingStyle.Quint,
			direction or Enum.EasingDirection.Out
		),
		properties
	)

	animation:Play()
	return animation
end

local function addCorner(object, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 6)
	}, object)
end

local function addStroke(object, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or theme.border,
		Thickness = thickness or 1.2,
		Transparency = transparency or 0
	}, object)
end


local executorEnvironment = _G

if typeof(getgenv) == "function" then
	local success, result = pcall(getgenv)

	if success and type(result) == "table" then
		executorEnvironment = result
	end
end

local function tryClipboardFunction(callback, owner)
	if typeof(callback) ~= "function" then
		return false, nil
	end

	local success, result = pcall(callback)

	if (not success or type(result) ~= "string") and owner then
		success, result = pcall(callback, owner)
	end

	if success and type(result) == "string" and result ~= "" then
		return true, result
	end

	return false, nil
end

local function readClipboard()
	local environments = {
		executorEnvironment,
		_G
	}

	local directNames = {
		"getclipboard",
		"readclipboard",
		"get_clipboard",
		"read_clipboard"
	}

	for _, environment in ipairs(environments) do
		if type(environment) == "table" then
			for _, functionName in ipairs(directNames) do
				local success, result = tryClipboardFunction(rawget(environment, functionName))

				if success then
					return true, result
				end
			end
		end
	end

	local clipboardTables = {
		type(executorEnvironment) == "table" and rawget(executorEnvironment, "Clipboard") or nil,
		type(executorEnvironment) == "table" and rawget(executorEnvironment, "clipboard") or nil,
		type(_G) == "table" and rawget(_G, "Clipboard") or nil,
		type(_G) == "table" and rawget(_G, "clipboard") or nil
	}

	local methodNames = {
		"get",
		"read",
		"Get",
		"Read",
		"getText",
		"GetText",
		"gettext"
	}

	for _, clipboardTable in ipairs(clipboardTables) do
		if type(clipboardTable) == "table" then
			for _, methodName in ipairs(methodNames) do
				local success, result = tryClipboardFunction(
					rawget(clipboardTable, methodName),
					clipboardTable
				)

				if success then
					return true, result
				end
			end
		end
	end

	return false, nil
end

local function trimText(value)
	return (tostring(value or ""):gsub("^%s*(.-)%s*$", "%1"))
end

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

local function stripFlagPrefix(flagName)
	local prefixes = {
		"DFFlag",
		"FFlag",
		"DFInt",
		"FInt",
		"DFString",
		"FString"
	}

	for _, prefix in ipairs(prefixes) do
		if flagName:sub(1, #prefix) == prefix then
			return flagName:sub(#prefix + 1)
		end
	end

	return flagName
end

local function getFlagSetter()
	local environments = {
		executorEnvironment,
		_G
	}

	for _, environment in ipairs(environments) do
		if type(environment) == "table" then
			local setter = rawget(environment, "setfflag")

			if typeof(setter) == "function" then
				return setter
			end
		end
	end

	local success, setter = pcall(function()
		return setfflag
	end)

	if success and typeof(setter) == "function" then
		return setter
	end

	return nil
end

local function applyFlagJson(jsonText)
	local decodedSuccessfully, decoded = pcall(function()
		return HttpService:JSONDecode(jsonText)
	end)

	if not decodedSuccessfully or type(decoded) ~= "table" then
		return false, 0, 0, "Invalid JSON format"
	end

	if #decoded == 1 and type(decoded[1]) == "table" then
		decoded = decoded[1]
	end

	local setter = getFlagSetter()
	if not setter then
		return false, 0, 0, "setfflag is unavailable"
	end

	local appliedCount = 0
	local failedCount = 0

	for flagName, value in pairs(decoded) do
		local success = pcall(
			setter,
			stripFlagPrefix(tostring(flagName)),
			tostring(value)
		)

		if success then
			appliedCount += 1
		else
			failedCount += 1
		end
	end

	if appliedCount == 0 then
		return false, appliedCount, failedCount, "No FFlags were applied"
	end

	return true, appliedCount, failedCount, nil
end


local destroyClasses = {
	ParticleEmitter = true,
	Trail = true,
	Beam = true,
	Smoke = true,
	Fire = true,
	Sparkles = true,
	Explosion = true,
	Highlight = true,
	ForceField = true,
	Atmosphere = true,
	Clouds = true,
	Sky = true,
	SelectionBox = true,
	SelectionSphere = true,
	SurfaceSelection = true,
	BoxHandleAdornment = true,
	SphereHandleAdornment = true,
	CylinderHandleAdornment = true,
	ConeHandleAdornment = true,
	LineHandleAdornment = true,
	WireframeHandleAdornment = true,
	Handles = true,
	ArcHandles = true
}

local noRender = {
	enabled = false,
	vfx = true,
	sfx = true,
	lighting = true,
	parts = true,
	terrain = true,
	descendantConnection = nil,
	propertyLocks = {},
	originalProperties = {},
	processed = 0,
	destroyed = 0
}

local screenStretch = {
	enabled = false,
	minimum = 0.1,
	maximum = 3,
	default = 1,
	factor = 1,
	bindName = "TesteHubScreenStretch",
	lastCamera = nil,
	lastBaseCFrame = nil,
	lastAppliedCFrame = nil
}

local function restoreCameraTransform()
	local camera = screenStretch.lastCamera
	local baseCFrame = screenStretch.lastBaseCFrame

	if camera and baseCFrame then
		pcall(function()
			if not screenStretch.lastAppliedCFrame or camera.CFrame == screenStretch.lastAppliedCFrame then
				camera.CFrame = baseCFrame
			end
		end)
	end

	screenStretch.lastCamera = nil
	screenStretch.lastBaseCFrame = nil
	screenStretch.lastAppliedCFrame = nil
end

local function applyScreenStretch()
	if not screenStretch.enabled or math.abs(screenStretch.factor - 1) < 0.0001 then
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	pcall(function()
		if screenStretch.lastCamera == camera
			and screenStretch.lastAppliedCFrame
			and screenStretch.lastBaseCFrame
			and camera.CFrame == screenStretch.lastAppliedCFrame then
			camera.CFrame = screenStretch.lastBaseCFrame
		end

		local baseCFrame = camera.CFrame
		local transform = CFrame.new(
			0, 0, 0,
			1, 0, 0,
			0, screenStretch.factor, 0,
			0, 0, 1
		)
		local appliedCFrame = baseCFrame * transform

		screenStretch.lastCamera = camera
		screenStretch.lastBaseCFrame = baseCFrame
		screenStretch.lastAppliedCFrame = appliedCFrame
		camera.CFrame = appliedCFrame
	end)
end

local function setScreenStretchEnabled(state)
	state = state == true

	if screenStretch.enabled == state then
		return
	end

	screenStretch.enabled = state
	RunService:UnbindFromRenderStep(screenStretch.bindName)

	if state then
		RunService:BindToRenderStep(
			screenStretch.bindName,
			Enum.RenderPriority.Camera.Value + 1,
			applyScreenStretch
		)
	else
		restoreCameraTransform()
	end
end

local function setScreenStretchFactor(value)
	screenStretch.factor = math.clamp(
		tonumber(value) or screenStretch.default,
		screenStretch.minimum,
		screenStretch.maximum
	)

	if math.abs(screenStretch.factor - 1) < 0.0001 then
		restoreCameraTransform()
	end
end

local function getPropertyBucket(container, instance, createBucket)
	local bucket = container[instance]

	if not bucket and createBucket then
		bucket = {}
		container[instance] = bucket
	end

	return bucket
end

local function safeDestroy(instance)
	if not instance or not instance.Parent then
		return false
	end

	local success = pcall(function()
		instance:Destroy()
	end)

	if success then
		noRender.destroyed += 1
	end

	return success
end

local function lockProperty(instance, property, value)
	if not instance then
		return
	end

	local locks = getPropertyBucket(noRender.propertyLocks, instance, true)
	if locks[property] then
		return
	end

	local success, originalValue = pcall(function()
		return instance[property]
	end)

	if not success then
		return
	end

	local originals = getPropertyBucket(noRender.originalProperties, instance, true)
	originals[property] = originalValue

	pcall(function()
		instance[property] = value
	end)

	locks[property] = instance:GetPropertyChangedSignal(property):Connect(function()
		if not noRender.enabled then
			return
		end

		pcall(function()
			if instance[property] ~= value then
				instance[property] = value
			end
		end)
	end)
end

local function unlockProperty(instance, property, restore)
	local locks = getPropertyBucket(noRender.propertyLocks, instance, false)
	local originals = getPropertyBucket(noRender.originalProperties, instance, false)

	if locks and locks[property] then
		locks[property]:Disconnect()
		locks[property] = nil
	end

	if restore and originals and originals[property] ~= nil then
		pcall(function()
			instance[property] = originals[property]
		end)
	end

	if originals then
		originals[property] = nil
	end

	if locks and next(locks) == nil then
		noRender.propertyLocks[instance] = nil
	end

	if originals and next(originals) == nil then
		noRender.originalProperties[instance] = nil
	end
end

local function unlockAllProperties(restore)
	for instance, locks in pairs(noRender.propertyLocks) do
		for property, connection in pairs(locks) do
			connection:Disconnect()
			locks[property] = nil
		end
		noRender.propertyLocks[instance] = nil
	end

	if restore then
		for instance, originals in pairs(noRender.originalProperties) do
			for property, value in pairs(originals) do
				pcall(function()
					instance[property] = value
				end)
				originals[property] = nil
			end
			noRender.originalProperties[instance] = nil
		end
	else
		table.clear(noRender.originalProperties)
	end
end

local function applyGlobalSettings()
	if noRender.sfx then
		lockProperty(SoundService, "Volume", 0)
	else
		unlockProperty(SoundService, "Volume", true)
	end

	if noRender.lighting then
		lockProperty(Lighting, "GlobalShadows", false)
		lockProperty(Lighting, "ShadowSoftness", 0)
		lockProperty(Lighting, "EnvironmentDiffuseScale", 0)
		lockProperty(Lighting, "EnvironmentSpecularScale", 0)
	else
		unlockProperty(Lighting, "GlobalShadows", true)
		unlockProperty(Lighting, "ShadowSoftness", true)
		unlockProperty(Lighting, "EnvironmentDiffuseScale", true)
		unlockProperty(Lighting, "EnvironmentSpecularScale", true)
	end

	if terrain then
		if noRender.terrain then
			lockProperty(terrain, "Decoration", false)
			lockProperty(terrain, "WaterWaveSize", 0)
			lockProperty(terrain, "WaterWaveSpeed", 0)
			lockProperty(terrain, "WaterReflectance", 0)
		else
			unlockProperty(terrain, "Decoration", true)
			unlockProperty(terrain, "WaterWaveSize", true)
			unlockProperty(terrain, "WaterWaveSpeed", true)
			unlockProperty(terrain, "WaterReflectance", true)
		end
	end
end

local function processInstance(instance)
	if not noRender.enabled or not instance or not instance.Parent then
		return
	end

	noRender.processed += 1

	if noRender.vfx and destroyClasses[instance.ClassName] then
		safeDestroy(instance)
		return
	end

	if noRender.sfx then
		if instance:IsA("Sound") then
			pcall(function()
				instance.Volume = 0
				instance.Playing = false
			end)
			safeDestroy(instance)
			return
		end

		if instance:IsA("SoundEffect") then
			safeDestroy(instance)
			return
		end
	end

	if noRender.lighting then
		if instance:IsA("PostEffect") or instance:IsA("Light") then
			safeDestroy(instance)
			return
		end
	end

	if noRender.parts and instance:IsA("BasePart") then
		pcall(function()
			instance.CastShadow = false
			instance.Reflectance = 0
		end)
	end
end

local function scanGame()
	if not noRender.enabled then
		return
	end

	noRender.processed = 0
	noRender.destroyed = 0

	local descendants = game:GetDescendants()

	for index, instance in ipairs(descendants) do
		processInstance(instance)

		if index % 500 == 0 then
			task.wait()
		end
	end
end

local function connectNoRender()
	if noRender.descendantConnection then
		noRender.descendantConnection:Disconnect()
	end

	noRender.descendantConnection = game.DescendantAdded:Connect(function(instance)
		task.defer(processInstance, instance)
	end)
end

local function setNoRenderEnabled(state)
	if noRender.enabled == state then
		return
	end

	noRender.enabled = state

	if state then
		applyGlobalSettings()
		connectNoRender()
		task.spawn(scanGame)
	else
		if noRender.descendantConnection then
			noRender.descendantConnection:Disconnect()
			noRender.descendantConnection = nil
		end

		unlockAllProperties(true)
	end
end

local function refreshNoRender()
	if not noRender.enabled then
		return
	end

	applyGlobalSettings()
	task.spawn(scanGame)
end

local KORBLOX_MESH_ID = "rbxassetid://902942096"
local KORBLOX_TEXTURE_ID = "rbxassetid://902843398"
local KORBLOX_NAME = "KorbloxVisual"

local appearance = {
	headless = false,
	korblox = false,
	version = 0,
	connections = {}
}

local headlessOriginals = setmetatable({}, { __mode = "k" })
local korbloxOriginals = setmetatable({}, { __mode = "k" })
local r6Backups = setmetatable({}, { __mode = "k" })

local oldAppearanceConnections = type(executorEnvironment) == "table"
	and rawget(executorEnvironment, "K27EAppearanceConnections")
	or nil

if type(oldAppearanceConnections) == "table" then
	for _, connection in pairs(oldAppearanceConnections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
end

local function clearExistingAppearance(character)
	local visual = character:FindFirstChild(KORBLOX_NAME)

	if visual then
		visual:Destroy()
	end

	local head = character:FindFirstChild("Head")

	if head and head:IsA("BasePart") then
		head.Transparency = 0
		head.LocalTransparencyModifier = 0

		for _, object in ipairs(head:GetDescendants()) do
			if object:IsA("Decal") or object:IsA("Texture") then
				object.Transparency = 0
			end
		end
	end

	for _, partName in ipairs({
		"Right Leg",
		"RightUpperLeg",
		"RightLowerLeg",
		"RightFoot"
	}) do
		local part = character:FindFirstChild(partName)

		if part and part:IsA("BasePart") then
			part.Transparency = 0
			part.LocalTransparencyModifier = 0

			local mesh = part:FindFirstChild("KorbloxMesh")

			if mesh then
				mesh:Destroy()
			end
		end
	end
end

if player.Character then
	pcall(clearExistingAppearance, player.Character)
end

local function storeProperty(storage, instance, property)
	local properties = storage[instance]

	if not properties then
		properties = {}
		storage[instance] = properties
	end

	if properties[property] == nil then
		local success, value = pcall(function()
			return instance[property]
		end)

		if success then
			properties[property] = value
		end
	end
end

local function setStoredProperty(storage, instance, property, value)
	if not instance then
		return
	end

	storeProperty(storage, instance, property)

	pcall(function()
		instance[property] = value
	end)
end

local function restoreProperties(storage, character)
	for instance, properties in pairs(storage) do
		local belongsToCharacter = false

		pcall(function()
			belongsToCharacter = instance == character or instance:IsDescendantOf(character)
		end)

		if belongsToCharacter then
			for property, value in pairs(properties) do
				pcall(function()
					instance[property] = value
				end)
			end

			storage[instance] = nil
		end
	end
end

local function setPartHidden(storage, part, hidden)
	if not part or not part:IsA("BasePart") then
		return
	end

	setStoredProperty(storage, part, "Transparency", hidden and 1 or 0)
	setStoredProperty(storage, part, "LocalTransparencyModifier", hidden and 1 or 0)
end

local function getKorbloxScale(part)
	return Vector3.new(part.Size.X, part.Size.Y / 2, part.Size.Z)
end

local function configureKorbloxMesh(mesh, part, offset)
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = KORBLOX_MESH_ID
	mesh.TextureId = KORBLOX_TEXTURE_ID
	mesh.Scale = getKorbloxScale(part)
	mesh.Offset = offset
end

local function applyHeadless(character)
	local head = character:FindFirstChild("Head")

	if not head or not head:IsA("BasePart") then
		return
	end

	setPartHidden(headlessOriginals, head, true)

	for _, object in ipairs(head:GetDescendants()) do
		if object:IsA("Decal") or object:IsA("Texture") then
			setStoredProperty(headlessOriginals, object, "Transparency", 1)
		end
	end
end

local function restoreHeadless(character)
	restoreProperties(headlessOriginals, character)
end

local function backupAndDestroyR6Meshes(character, rightLeg)
	local backups = r6Backups[character]

	if not backups then
		backups = {}
		r6Backups[character] = backups
	end

	local function backup(object, parent)
		local clone
		local success = pcall(function()
			clone = object:Clone()
		end)

		if success and clone then
			table.insert(backups, {
				clone = clone,
				parent = parent
			})
		end

		pcall(function()
			object:Destroy()
		end)
	end

	for _, object in ipairs(character:GetChildren()) do
		if object:IsA("CharacterMesh") and object.BodyPart == Enum.BodyPart.RightLeg then
			backup(object, character)
		end
	end

	for _, object in ipairs(rightLeg:GetChildren()) do
		if object:IsA("DataModelMesh") and object.Name ~= "KorbloxMesh" then
			backup(object, rightLeg)
		end
	end
end

local function applyKorbloxR6(character)
	local rightLeg = character:FindFirstChild("Right Leg")

	if not rightLeg or not rightLeg:IsA("BasePart") then
		return
	end

	local r15Visual = character:FindFirstChild(KORBLOX_NAME)

	if r15Visual then
		r15Visual:Destroy()
	end

	backupAndDestroyR6Meshes(character, rightLeg)
	setStoredProperty(korbloxOriginals, rightLeg, "Transparency", 0)
	setStoredProperty(korbloxOriginals, rightLeg, "LocalTransparencyModifier", 0)

	local mesh = rightLeg:FindFirstChild("KorbloxMesh")

	if mesh and not mesh:IsA("SpecialMesh") then
		mesh:Destroy()
		mesh = nil
	end

	if not mesh then
		mesh = Instance.new("SpecialMesh")
		mesh.Name = "KorbloxMesh"
		mesh.Parent = rightLeg
	end

	configureKorbloxMesh(mesh, rightLeg, Vector3.new(0, 0.7, 0))
end

local function applyKorbloxR15(character)
	local rightUpperLeg = character:FindFirstChild("RightUpperLeg")
	local rightLowerLeg = character:FindFirstChild("RightLowerLeg")
	local rightFoot = character:FindFirstChild("RightFoot")

	if not rightUpperLeg or not rightLowerLeg or not rightFoot then
		return
	end

	if not rightUpperLeg:IsA("BasePart")
		or not rightLowerLeg:IsA("BasePart")
		or not rightFoot:IsA("BasePart") then
		return
	end

	setPartHidden(korbloxOriginals, rightUpperLeg, true)
	setPartHidden(korbloxOriginals, rightLowerLeg, true)
	setPartHidden(korbloxOriginals, rightFoot, true)

	local visual = character:FindFirstChild(KORBLOX_NAME)

	if visual and not visual:IsA("Part") then
		visual:Destroy()
		visual = nil
	end

	if not visual then
		visual = Instance.new("Part")
		visual.Name = KORBLOX_NAME
		visual.Size = rightUpperLeg.Size
		visual.CFrame = rightUpperLeg.CFrame
		visual.Anchored = false
		visual.CanCollide = false
		visual.CanTouch = false
		visual.CanQuery = false
		visual.CastShadow = false
		visual.Massless = true
		visual.Transparency = 0
		visual.Parent = character

		local mesh = Instance.new("SpecialMesh")
		mesh.Name = "KorbloxMesh"
		mesh.Parent = visual

		local weld = Instance.new("WeldConstraint")
		weld.Name = "KorbloxWeld"
		weld.Part0 = rightUpperLeg
		weld.Part1 = visual
		weld.Parent = visual
	end

	visual.Size = rightUpperLeg.Size
	visual.Transparency = 0
	visual.LocalTransparencyModifier = 0

	local mesh = visual:FindFirstChild("KorbloxMesh")

	if mesh and not mesh:IsA("SpecialMesh") then
		mesh:Destroy()
		mesh = nil
	end

	if not mesh then
		mesh = Instance.new("SpecialMesh")
		mesh.Name = "KorbloxMesh"
		mesh.Parent = visual
	end

	local weld = visual:FindFirstChild("KorbloxWeld")

	if not weld or not weld:IsA("WeldConstraint") then
		if weld then
			weld:Destroy()
		end

		visual.CFrame = rightUpperLeg.CFrame

		weld = Instance.new("WeldConstraint")
		weld.Name = "KorbloxWeld"
		weld.Part0 = rightUpperLeg
		weld.Part1 = visual
		weld.Parent = visual
	else
		weld.Part0 = rightUpperLeg
		weld.Part1 = visual
	end

	configureKorbloxMesh(mesh, rightUpperLeg, Vector3.zero)
end

local function restoreR6Backups(character)
	local backups = r6Backups[character]

	if not backups then
		return
	end

	for _, backup in ipairs(backups) do
		local parent = backup.parent
		local clone = backup.clone

		if parent and parent.Parent and clone then
			local duplicate = false

			for _, child in ipairs(parent:GetChildren()) do
				if child.ClassName == clone.ClassName and child.Name == clone.Name then
					duplicate = true
					break
				end
			end

			if not duplicate then
				clone.Parent = parent
			end
		end
	end

	r6Backups[character] = nil
end

local function restoreKorblox(character)
	local visual = character:FindFirstChild(KORBLOX_NAME)

	if visual then
		visual:Destroy()
	end

	local rightLeg = character:FindFirstChild("Right Leg")

	if rightLeg then
		local mesh = rightLeg:FindFirstChild("KorbloxMesh")

		if mesh then
			mesh:Destroy()
		end
	end

	restoreProperties(korbloxOriginals, character)
	restoreR6Backups(character)
end

local function applyAppearance(character)
	if appearance.headless then
		applyHeadless(character)
	else
		restoreHeadless(character)
	end

	if appearance.korblox then
		if character:FindFirstChild("Right Leg") then
			applyKorbloxR6(character)
		else
			applyKorbloxR15(character)
		end
	else
		restoreKorblox(character)
	end
end

local function refreshAppearance()
	appearance.version += 1
	local version = appearance.version
	local character = player.Character

	if not character then
		return
	end

	pcall(applyAppearance, character)

	if not appearance.headless and not appearance.korblox then
		return
	end

	task.spawn(function()
		character:WaitForChild("Humanoid", 10)
		character:WaitForChild("Head", 10)
		task.wait()

		while version == appearance.version
			and player.Character == character
			and character.Parent do
			pcall(applyAppearance, character)
			task.wait(0.5)
		end
	end)
end

local function setHeadlessEnabled(value)
	appearance.headless = value == true
	refreshAppearance()
end

local function setKorbloxEnabled(value)
	appearance.korblox = value == true
	refreshAppearance()
end

appearance.connections.characterAdded = player.CharacterAdded:Connect(function()
	task.defer(refreshAppearance)
end)

appearance.connections.appearanceLoaded = player.CharacterAppearanceLoaded:Connect(function(character)
	if character == player.Character then
		task.defer(refreshAppearance)
	end
end)

if type(executorEnvironment) == "table" then
	rawset(executorEnvironment, "K27EAppearanceConnections", appearance.connections)
end


local gui = create("ScreenGui", {
	Name = "TesteHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	DisplayOrder = 1000,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local root = create("CanvasGroup", {
	Name = "Root",
	Size = UDim2.fromOffset(520, 334),
	Position = UDim2.new(0.5, -260, 0.5, -167),
	BackgroundColor3 = theme.background,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	ClipsDescendants = true
}, gui)

addCorner(root, 12)
addStroke(root, theme.borderActive, 1, 0.28)

create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.background),
		ColorSequenceKeypoint.new(0.52, Color3.fromRGB(82, 58, 119)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(116, 84, 162))
	}),
	Rotation = 125
}, root)

local scale = create("UIScale", {
	Scale = 1
}, root)

local function updateScale()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local viewport = camera.ViewportSize
	local target = math.min(viewport.X / 620, viewport.Y / 430, 1)
	scale.Scale = math.clamp(target, 0.72, 1)
end

updateScale()

if Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local topbar = create("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 42),
	BackgroundColor3 = theme.surface,
	BorderSizePixel = 0
}, root)

create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.surfaceAlt),
		ColorSequenceKeypoint.new(1, theme.surface)
	}),
	Rotation = 0
}, topbar)

create("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = theme.accentSoft,
	BorderSizePixel = 0
}, topbar)

local brandAccent = create("Frame", {
	Size = UDim2.fromOffset(3, 22),
	Position = UDim2.fromOffset(14, 10),
	BackgroundColor3 = theme.accent,
	BorderSizePixel = 0
}, topbar)

addCorner(brandAccent, 2)

local brand = create("TextLabel", {
	Size = UDim2.fromOffset(180, 20),
	Position = UDim2.fromOffset(25, 4),
	BackgroundTransparency = 1,
	Text = "K27E",
	TextColor3 = theme.text,
	TextSize = 15,
	Font = Enum.Font.SourceSansBold,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local subtitle = create("TextLabel", {
	Size = UDim2.fromOffset(200, 12),
	Position = UDim2.fromOffset(25, 23),
	BackgroundTransparency = 1,
	Text = "performance control panel",
	TextColor3 = theme.subtext,
	TextSize = 11,
	Font = Enum.Font.SourceSans,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local minimizeButton = create("TextButton", {
	Size = UDim2.fromOffset(29, 28),
	Position = UDim2.new(1, -68, 0, 7),
	BackgroundColor3 = theme.surfaceAlt,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "-",
	TextColor3 = theme.subtext,
	TextSize = 15,
	Font = Enum.Font.SourceSans,
	AutoButtonColor = false
}, topbar)

addCorner(minimizeButton, 7)

local closeButton = create("TextButton", {
	Size = UDim2.fromOffset(29, 28),
	Position = UDim2.new(1, -35, 0, 7),
	BackgroundColor3 = theme.surfaceAlt,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "x",
	TextColor3 = theme.subtext,
	TextSize = 14,
	Font = Enum.Font.SourceSans,
	AutoButtonColor = false
}, topbar)

addCorner(closeButton, 7)

local restoreButton = create("TextButton", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	ZIndex = 10
}, topbar)

local sidebar = create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 146, 1, -42),
	Position = UDim2.fromOffset(0, 42),
	BackgroundColor3 = theme.surface,
	BorderSizePixel = 0
}, root)

create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, theme.surfaceAlt),
		ColorSequenceKeypoint.new(1, theme.surface)
	}),
	Rotation = 90
}, sidebar)

create("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = theme.accentSoft,
	BorderSizePixel = 0
}, sidebar)

create("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18),
	Position = UDim2.fromOffset(14, 13),
	BackgroundTransparency = 1,
	Text = "MENU",
	TextColor3 = theme.dim,
	TextSize = 10,
	Font = Enum.Font.SourceSansSemibold,
	TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)

local navigation = create("Frame", {
	Size = UDim2.new(1, -18, 0, 190),
	Position = UDim2.fromOffset(9, 38),
	BackgroundTransparency = 1
}, sidebar)

create("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, navigation)

local shortcut = create("Frame", {
	Size = UDim2.new(1, -18, 0, 44),
	Position = UDim2.new(0, 9, 1, -53),
	BackgroundColor3 = theme.surfaceAlt,
	BorderSizePixel = 0
}, sidebar)

addCorner(shortcut, 8)
addStroke(shortcut, theme.border, 1, 0.28)

local shortcutAccent = create("Frame", {
	Size = UDim2.fromOffset(3, 22),
	Position = UDim2.fromOffset(8, 11),
	BackgroundColor3 = theme.accent,
	BorderSizePixel = 0
}, shortcut)

addCorner(shortcutAccent, 2)

create("TextLabel", {
	Size = UDim2.new(1, -24, 0, 16),
	Position = UDim2.fromOffset(18, 6),
	BackgroundTransparency = 1,
	Text = "RIGHT SHIFT",
	TextColor3 = theme.text,
	TextSize = 10,
	Font = Enum.Font.SourceSansSemibold,
	TextXAlignment = Enum.TextXAlignment.Left
}, shortcut)

create("TextLabel", {
	Size = UDim2.new(1, -24, 0, 14),
	Position = UDim2.fromOffset(18, 22),
	BackgroundTransparency = 1,
	Text = "show / hide",
	TextColor3 = theme.subtext,
	TextSize = 10,
	Font = Enum.Font.SourceSans,
	TextXAlignment = Enum.TextXAlignment.Left
}, shortcut)

local content = create("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -146, 1, -42),
	Position = UDim2.fromOffset(146, 42),
	BackgroundColor3 = theme.background,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ClipsDescendants = true
}, root)

local pageContainer = create("Frame", {
	Size = UDim2.new(1, -28, 1, -22),
	Position = UDim2.fromOffset(14, 11),
	BackgroundTransparency = 1,
	ClipsDescendants = true
}, content)

local pages = {}
local tabs = {}
local activePage
local switching = false

local function createPage(name)
	local page = create("CanvasGroup", {
		Name = name,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false
	}, pageContainer)

	local scroll = create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.accentSoft,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	}, page)

	create("UIListLayout", {
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, scroll)

	create("UIPadding", {
		PaddingRight = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 8)
	}, scroll)

	pages[name] = {
		group = page,
		scroll = scroll
	}

	return scroll
end

local function setTabVisual(name, selected)
	local tab = tabs[name]
	if not tab then
		return
	end

	playTween(tab.button, {
		BackgroundColor3 = selected and theme.selection or theme.surface,
		BackgroundTransparency = selected and 0 or 0.18
	}, 0.22)

	playTween(tab.text, {
		TextColor3 = selected and theme.text or theme.subtext
	}, 0.22)

	playTween(tab.indicator, {
		BackgroundTransparency = selected and 0 or 0.18,
		Size = selected and UDim2.fromOffset(3, 18) or UDim2.fromOffset(3, 6)
	}, 0.22)

	playTween(tab.dot, {
		BackgroundColor3 = selected and theme.accentBright or theme.dim,
		BackgroundTransparency = selected and 0 or 0.15
	}, 0.22)
end

local function switchPage(name)
	if switching or activePage == name or not pages[name] then
		return
	end

	switching = true

	local incoming = pages[name].group
	local outgoing = activePage and pages[activePage].group

	for tabName in pairs(tabs) do
		setTabVisual(tabName, tabName == name)
	end

	if outgoing then
		playTween(outgoing, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(-14, 0)
		}, 0.18, Enum.EasingStyle.Quad)

		task.wait(0.13)
		outgoing.Visible = false
	end

	incoming.Visible = true
	incoming.GroupTransparency = 1
	incoming.Position = UDim2.fromOffset(16, 0)

	playTween(incoming, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(0, 0)
	}, 0.24, Enum.EasingStyle.Quint)

	activePage = name
	task.wait(0.24)
	switching = false
end

local function createTab(name, label, index)
	local button = create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme.surface,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = index
	}, navigation)

	addCorner(button, 8)

	local indicator = create("Frame", {
		Size = UDim2.fromOffset(3, 6),
		Position = UDim2.new(0, 1, 0.5, -3),
		BackgroundColor3 = theme.accent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, button)

	addCorner(indicator, 2)

	local dot = create("Frame", {
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.fromOffset(13, 14),
		BackgroundColor3 = theme.dim,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0
	}, button)

	addCorner(dot, 3)

	local text = create("TextLabel", {
		Size = UDim2.new(1, -33, 1, 0),
		Position = UDim2.fromOffset(28, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = theme.text,
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, button)

	tabs[name] = {
		button = button,
		text = text,
		indicator = indicator,
		dot = dot
	}

	button.MouseEnter:Connect(function()
		if activePage ~= name then
			playTween(button, {
				BackgroundColor3 = theme.hover,
				BackgroundTransparency = 0.03
			}, 0.16)

			playTween(text, {
				TextColor3 = theme.text
			}, 0.16)
		end
	end)

	button.MouseLeave:Connect(function()
		if activePage ~= name then
			playTween(button, {
				BackgroundColor3 = theme.surface,
				BackgroundTransparency = 0.18
			}, 0.16)

			playTween(text, {
				TextColor3 = theme.subtext
			}, 0.16)
		end
	end)

	button.MouseButton1Click:Connect(function()
		switchPage(name)
	end)
end

local function createSection(parent, text)
	local section = create("Frame", {
		Size = UDim2.new(1, 0, 0, 21),
		BackgroundTransparency = 1
	}, parent)

	local accent = create("Frame", {
		Size = UDim2.fromOffset(3, 10),
		Position = UDim2.fromOffset(0, 6),
		BackgroundColor3 = theme.accent,
		BorderSizePixel = 0
	}, section)

	addCorner(accent, 2)

	create("TextLabel", {
		Size = UDim2.new(1, -12, 1, 0),
		Position = UDim2.fromOffset(11, 0),
		BackgroundTransparency = 1,
		Text = string.upper(text),
		TextColor3 = theme.subtext,
		TextSize = 10,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	}, section)

	return section
end

local function createCard(parent, height)
	local card = create("Frame", {
		Size = UDim2.new(1, -2, 0, height or 44),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0
	}, parent)

	addCorner(card, 9)
	local cardStroke = addStroke(card, theme.border, 1, 0.24)

	card.MouseEnter:Connect(function()
		playTween(card, {
			BackgroundColor3 = theme.elevated
		}, 0.18)

		playTween(cardStroke, {
			Color = theme.borderActive,
			Transparency = 0.04
		}, 0.18)
	end)

	card.MouseLeave:Connect(function()
		playTween(card, {
			BackgroundColor3 = theme.surface
		}, 0.18)

		playTween(cardStroke, {
			Color = theme.border,
			Transparency = 0.03
		}, 0.18)
	end)

	return card
end

local function createInfo(parent, titleText, description)
	local card = createCard(parent, 66)

	local marker = create("Frame", {
		Size = UDim2.fromOffset(4, 36),
		Position = UDim2.fromOffset(11, 15),
		BackgroundColor3 = theme.accentSoft,
		BorderSizePixel = 0
	}, card)

	addCorner(marker, 2)

	create("TextLabel", {
		Size = UDim2.new(1, -37, 0, 19),
		Position = UDim2.fromOffset(25, 8),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	create("TextLabel", {
		Size = UDim2.new(1, -37, 0, 31),
		Position = UDim2.fromOffset(25, 28),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = theme.text,
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	}, card)

	return card
end

local function createButton(parent, text, callback)
	local button = create("TextButton", {
		Size = UDim2.new(1, -2, 0, 41),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	}, parent)

	addCorner(button, 9)
	local buttonStroke = addStroke(button, theme.border, 1, 0.24)

	local buttonText = create("TextLabel", {
		Size = UDim2.new(1, -44, 1, 0),
		Position = UDim2.fromOffset(13, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, button)

	local arrow = create("TextLabel", {
		Size = UDim2.fromOffset(24, 24),
		Position = UDim2.new(1, -33, 0.5, -12),
		BackgroundColor3 = theme.surfaceAlt,
		BorderSizePixel = 0,
		Text = ">",
		TextColor3 = theme.subtext,
		TextSize = 12,
		Font = Enum.Font.SourceSansSemibold
	}, button)

	addCorner(arrow, 7)

	button.MouseEnter:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.hover
		}, 0.16)

		playTween(buttonStroke, {
			Color = theme.borderActive,
			Transparency = 0.03
		}, 0.16)

		playTween(arrow, {
			BackgroundColor3 = theme.accentSoft,
			TextColor3 = theme.text
		}, 0.16)
	end)

	button.MouseLeave:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.surface
		}, 0.16)

		playTween(buttonStroke, {
			Color = theme.border,
			Transparency = 0.03
		}, 0.16)

		playTween(arrow, {
			BackgroundColor3 = theme.surfaceAlt,
			TextColor3 = theme.subtext
		}, 0.16)
	end)

	button.MouseButton1Down:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.selection
		}, 0.08)

		playTween(buttonText, {
			TextColor3 = theme.accentBright
		}, 0.08)
	end)

	button.MouseButton1Up:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.hover
		}, 0.1)

		playTween(buttonText, {
			TextColor3 = theme.text
		}, 0.1)
	end)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return button
end

local function createTextInput(parent, titleText, placeholder)
	local card = createCard(parent, 67)

	create("TextLabel", {
		Size = UDim2.new(1, -24, 0, 16),
		Position = UDim2.fromOffset(12, 7),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = theme.text,
		TextSize = 10,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local inputFrame = create("Frame", {
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.fromOffset(12, 28),
		BackgroundColor3 = theme.input,
		BorderSizePixel = 0
	}, card)

	addCorner(inputFrame, 7)
	local inputStroke = addStroke(inputFrame, theme.border, 1, 0.16)

	local input = create("TextBox", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = theme.dim,
		TextColor3 = theme.text,
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		MultiLine = false
	}, inputFrame)

	input.Focused:Connect(function()
		playTween(inputFrame, {
			BackgroundColor3 = theme.surfaceAlt
		}, 0.18)

		playTween(inputStroke, {
			Color = theme.accent,
			Transparency = 0.04
		}, 0.18)
	end)

	input.FocusLost:Connect(function()
		playTween(inputFrame, {
			BackgroundColor3 = theme.input
		}, 0.18)

		playTween(inputStroke, {
			Color = theme.border,
			Transparency = 0.16
		}, 0.18)
	end)

	return input
end

local function createTextArea(parent, titleText, placeholder, height)
	local areaHeight = math.max(110, height or 150)
	local card = createCard(parent, areaHeight + 38)

	create("TextLabel", {
		Size = UDim2.new(1, -24, 0, 16),
		Position = UDim2.fromOffset(12, 7),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = theme.text,
		TextSize = 10,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local inputFrame = create("Frame", {
		Size = UDim2.new(1, -24, 0, areaHeight),
		Position = UDim2.fromOffset(12, 29),
		BackgroundColor3 = theme.input,
		BorderSizePixel = 0,
		ClipsDescendants = true
	}, card)

	addCorner(inputFrame, 7)
	local inputStroke = addStroke(inputFrame, theme.border, 1, 0.16)

	local input = create("TextBox", {
		Size = UDim2.new(1, -20, 1, -16),
		Position = UDim2.fromOffset(10, 8),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = theme.dim,
		TextColor3 = theme.text,
		TextSize = 11,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ClearTextOnFocus = false,
		MultiLine = true,
		TextWrapped = false
	}, inputFrame)

	input.Focused:Connect(function()
		playTween(inputFrame, {
			BackgroundColor3 = theme.surfaceAlt
		}, 0.18)

		playTween(inputStroke, {
			Color = theme.accent,
			Transparency = 0.04
		}, 0.18)
	end)

	input.FocusLost:Connect(function()
		playTween(inputFrame, {
			BackgroundColor3 = theme.input
		}, 0.18)

		playTween(inputStroke, {
			Color = theme.border,
			Transparency = 0.16
		}, 0.18)
	end)

	return input
end

local function createToggle(parent, text, defaultValue, callback)
	local enabled = defaultValue == true
	local card = createCard(parent, 46)

	local label = create("TextLabel", {
		Size = UDim2.new(1, -78, 1, 0),
		Position = UDim2.fromOffset(13, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local toggle = create("TextButton", {
		Size = UDim2.fromOffset(38, 20),
		Position = UDim2.new(1, -51, 0.5, -10),
		BackgroundColor3 = enabled and theme.accent or theme.surfaceAlt,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	}, card)

	addCorner(toggle, 10)
	local toggleStroke = addStroke(toggle, enabled and theme.accentBright or theme.borderActive, 1, 0.25)

	local knob = create("Frame", {
		Size = UDim2.fromOffset(14, 14),
		Position = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3),
		BackgroundColor3 = enabled and theme.text or theme.subtext,
		BorderSizePixel = 0
	}, toggle)

	addCorner(knob, 7)

	local function update(runCallback)
		playTween(toggle, {
			BackgroundColor3 = enabled and theme.accent or theme.surfaceAlt
		}, 0.2)

		playTween(toggleStroke, {
			Color = enabled and theme.accentBright or theme.borderActive,
			Transparency = enabled and 0.12 or 0.25
		}, 0.2)

		playTween(knob, {
			Position = enabled and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = enabled and theme.text or theme.subtext
		}, 0.2)

		playTween(label, {
			TextColor3 = enabled and theme.text or theme.subtext
		}, 0.2)

		if runCallback and callback then
			callback(enabled)
		end
	end

	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		update(true)
	end)

	return {
		card = card,
		set = function(value, runCallback)
			enabled = value == true
			update(runCallback == true)
		end,
		get = function()
			return enabled
		end
	}
end

local function createSlider(parent, text, minimum, maximum, defaultValue, precision, callback)
	local decimals = math.max(0, precision or 0)
	local increment = 10 ^ -decimals
	local value = math.clamp(defaultValue or minimum, minimum, maximum)
	local dragging = false
	local activeTouch = nil
	local card = createCard(parent, 64)

	create("TextLabel", {
		Size = UDim2.new(1, -92, 0, 21),
		Position = UDim2.fromOffset(13, 7),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local valueBadge = create("Frame", {
		Size = UDim2.fromOffset(58, 22),
		Position = UDim2.new(1, -70, 0, 6),
		BackgroundColor3 = theme.surfaceAlt,
		BorderSizePixel = 0
	}, card)

	addCorner(valueBadge, 7)
	addStroke(valueBadge, theme.border, 1, 0.3)

	local valueLabel = create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = theme.accentBright,
		TextSize = 10,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Center
	}, valueBadge)

	local track = create("Frame", {
		Size = UDim2.new(1, -26, 0, 4),
		Position = UDim2.fromOffset(13, 47),
		BackgroundColor3 = theme.accentSoft,
		BorderSizePixel = 0
	}, card)

	addCorner(track, 2)

	local fill = create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = theme.accent,
		BorderSizePixel = 0
	}, track)

	addCorner(fill, 2)

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, theme.accentSoft),
			ColorSequenceKeypoint.new(1, theme.accentBright)
		}),
		Rotation = 0
	}, fill)

	local knob = create("Frame", {
		Size = UDim2.fromOffset(11, 11),
		Position = UDim2.new(0, -5, 0.5, -5),
		BackgroundColor3 = theme.text,
		BorderSizePixel = 0
	}, track)

	addCorner(knob, 6)
	addStroke(knob, theme.accentBright, 2, 0.05)

	local hitbox = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.new(0, 0, 0.5, -11),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false
	}, track)

	local function formatValue(number)
		return string.format("%." .. tostring(decimals) .. "f", number)
	end

	local function getRatio(number)
		return math.clamp((number - minimum) / (maximum - minimum), 0, 1)
	end

	local function render(animated)
		local ratio = getRatio(value)
		local fillSize = UDim2.new(ratio, 0, 1, 0)
		local knobPosition = UDim2.new(ratio, -5, 0.5, -5)

		valueLabel.Text = formatValue(value) .. "x"

		if animated then
			playTween(fill, {Size = fillSize}, 0.13, Enum.EasingStyle.Quad)
			playTween(knob, {Position = knobPosition}, 0.13, Enum.EasingStyle.Quad)
		else
			fill.Size = fillSize
			knob.Position = knobPosition
		end
	end

	local function setValue(nextValue, runCallback, animated)
		nextValue = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
		nextValue = math.floor((nextValue / increment) + 0.5) * increment
		value = math.clamp(nextValue, minimum, maximum)
		render(animated == true)

		if runCallback and callback then
			callback(value)
		end
	end

	local function setFromX(positionX)
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return
		end

		local ratio = math.clamp(
			(positionX - track.AbsolutePosition.X) / width,
			0,
			1
		)

		setValue(minimum + ((maximum - minimum) * ratio), true, false)
	end

	local function beginDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			activeTouch = nil
			setFromX(input.Position.X)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeTouch = input
			setFromX(input.Position.X)
		end

		if dragging then
			playTween(knob, {
				Size = UDim2.fromOffset(13, 13),
				Position = UDim2.new(getRatio(value), -6, 0.5, -6)
			}, 0.1)
		end
	end

	hitbox.InputBegan:Connect(beginDrag)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if activeTouch then
			if input == activeTouch then
				setFromX(input.Position.X)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not activeTouch then
			dragging = false
		elseif activeTouch and input == activeTouch then
			dragging = false
			activeTouch = nil
		end

		if not dragging then
			playTween(knob, {
				Size = UDim2.fromOffset(11, 11),
				Position = UDim2.new(getRatio(value), -5, 0.5, -5)
			}, 0.1)
		end
	end)

	render(false)

	return {
		set = function(nextValue, runCallback)
			setValue(nextValue, runCallback == true, true)
		end,
		get = function()
			return value
		end
	}
end

local function createStatus(parent)
	local card = createCard(parent, 70)

	local statusDot = create("Frame", {
		Size = UDim2.fromOffset(9, 9),
		Position = UDim2.fromOffset(13, 15),
		BackgroundColor3 = theme.dim,
		BorderSizePixel = 0
	}, card)

	addCorner(statusDot, 5)

	local statusTitle = create("TextLabel", {
		Size = UDim2.new(1, -42, 0, 19),
		Position = UDim2.fromOffset(30, 10),
		BackgroundTransparency = 1,
		Text = "STATUS: DISABLED",
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local statusText = create("TextLabel", {
		Size = UDim2.new(1, -26, 0, 31),
		Position = UDim2.fromOffset(13, 33),
		BackgroundTransparency = 1,
		Text = "Waiting for activation.",
		TextColor3 = theme.text,
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	}, card)

	return function()
		statusTitle.Text = noRender.enabled and "STATUS: ENABLED" or "STATUS: DISABLED"
		playTween(statusDot, {
			BackgroundColor3 = noRender.enabled and theme.accentBright or theme.dim
		}, 0.2)

		if noRender.enabled then
			statusText.Text = string.format(
				"Processed %d instances. Removed %d effects.",
				noRender.processed,
				noRender.destroyed
			)
		else
			statusText.Text = "Future cleanup stopped. Removed instances cannot be restored."
		end
	end
end

local notifications = create("Frame", {
	Size = UDim2.fromOffset(300, 260),
	Position = UDim2.new(1, -304, 1, -262),
	BackgroundTransparency = 1
}, gui)

create("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 9),
	SortOrder = Enum.SortOrder.LayoutOrder
}, notifications)

local function notify(text)
	local notification = create("CanvasGroup", {
		Size = UDim2.fromOffset(292, 72),
		BackgroundColor3 = theme.elevated,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		ClipsDescendants = true
	}, notifications)

	addCorner(notification, 10)
	addStroke(notification, theme.accentBright, 1, 0.18)

	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(92, 62, 136)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(67, 45, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 35, 79))
		}),
		Rotation = 0
	}, notification)

	local accent = create("Frame", {
		Size = UDim2.fromOffset(3, 44),
		Position = UDim2.fromOffset(8, 11),
		BackgroundColor3 = theme.accent,
		BorderSizePixel = 0
	}, notification)

	addCorner(accent, 2)

	local icon = create("Frame", {
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.fromOffset(18, 13),
		BackgroundColor3 = theme.accentSoft,
		BorderSizePixel = 0
	}, notification)

	addCorner(icon, 9)
	addStroke(icon, theme.accentBright, 1, 0.3)

	create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "27",
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center
	}, icon)

	create("TextLabel", {
		Size = UDim2.new(1, -76, 0, 18),
		Position = UDim2.fromOffset(65, 10),
		BackgroundTransparency = 1,
		Text = "K27E",
		TextColor3 = theme.accentBright,
		TextSize = 13,
		Font = Enum.Font.SourceSansSemibold,
		TextXAlignment = Enum.TextXAlignment.Left
	}, notification)

	create("TextLabel", {
		Size = UDim2.new(1, -76, 0, 30),
		Position = UDim2.fromOffset(65, 28),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	}, notification)

	local progressTrack = create("Frame", {
		Size = UDim2.new(1, -20, 0, 2),
		Position = UDim2.new(0, 10, 1, -6),
		BackgroundColor3 = theme.accentSoft,
		BorderSizePixel = 0
	}, notification)

	addCorner(progressTrack, 1)

	local progress = create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = theme.accentBright,
		BorderSizePixel = 0
	}, progressTrack)

	addCorner(progress, 1)

	notification.Position = UDim2.fromOffset(28, 10)

	playTween(notification, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(0, 0)
	}, 0.46, Enum.EasingStyle.Quint)

	playTween(progress, {
		Size = UDim2.new(0, 0, 1, 0)
	}, 4.1, Enum.EasingStyle.Linear)

	task.delay(3.45, function()
		playTween(notification, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(28, 10)
		}, 0.52, Enum.EasingStyle.Quint)

		task.wait(0.56)
		if notification.Parent then
			notification:Destroy()
		end
	end)
end

local homePage = createPage("Home")
local controlsPage = createPage("Controls")
local fflagsPage = createPage("FFlags")
local miscPage = createPage("Misc")
local settingsPage = createPage("Settings")

createTab("Home", "Home", 1)
createTab("Controls", "Controls", 2)
createTab("FFlags", "FFlags", 3)
createTab("Misc", "Misc", 4)
createTab("Settings", "Settings", 5)

createSection(homePage, "Overview")
createInfo(homePage, "K27E", "Compact no render, anti lag and display adjustment panel.")

createSection(homePage, "Status")
local updateStatus = createStatus(homePage)

createSection(homePage, "Actions")
createButton(homePage, "Run cleanup scan", function()
	if not noRender.enabled then
		notify("Enable No Render first")
		return
	end

	task.spawn(function()
		scanGame()
		updateStatus()
		notify("Cleanup scan completed")
	end)
end)

createButton(homePage, "Refresh status", function()
	updateStatus()
	notify("Status refreshed")
end)

createSection(controlsPage, "Main")

local mainToggle
mainToggle = createToggle(controlsPage, "No Render", false, function(value)
	setNoRenderEnabled(value)

	if value then
		notify("No Render enabled")
		task.delay(0.5, updateStatus)
	else
		notify("No Render disabled")
		updateStatus()
	end
end)

createSection(controlsPage, "Cleanup")

createToggle(controlsPage, "Visual effects", true, function(value)
	noRender.vfx = value
	refreshNoRender()
end)

createToggle(controlsPage, "Sounds and effects", true, function(value)
	noRender.sfx = value
	refreshNoRender()
end)

createToggle(controlsPage, "Lighting and post effects", true, function(value)
	noRender.lighting = value
	refreshNoRender()
end)

createToggle(controlsPage, "Part shadows and reflectance", true, function(value)
	noRender.parts = value
	refreshNoRender()
end)

createToggle(controlsPage, "Terrain decoration and water", true, function(value)
	noRender.terrain = value
	refreshNoRender()
end)

createSection(controlsPage, "Display")

local stretchToggle
local stretchSlider

stretchToggle = createToggle(controlsPage, "Screen stretch", false, function(value)
	setScreenStretchEnabled(value)
	notify(value and "Screen stretch enabled" or "Screen stretch disabled")
end)

stretchSlider = createSlider(
	controlsPage,
	"Stretch factor",
	screenStretch.minimum,
	screenStretch.maximum,
	screenStretch.default,
	2,
	function(value)
		setScreenStretchFactor(value)
	end
)

createButton(controlsPage, "Reset screen stretch", function()
	stretchSlider.set(screenStretch.default, true)
	notify("Screen stretch reset")
end)


createSection(fflagsPage, "Raw source")

local rawUrlInput = createTextInput(
	fflagsPage,
	"RAW URL",
	"https://raw.githubusercontent.com/..."
)

createButton(fflagsPage, "Paste URL", function()
	local success, clipboardText = readClipboard()

	if not success then
		notify("Clipboard is unavailable")
		return
	end

	rawUrlInput.Text = trimText(clipboardText)
	rawUrlInput:ReleaseFocus()
	notify("URL pasted")
end)

createButton(fflagsPage, "Apply URL", function()
	local url = trimText(rawUrlInput.Text)

	if url == "" then
		notify("Enter a raw URL first")
		return
	end

	rawUrlInput:ReleaseFocus()
	notify("Downloading FFlags")

	task.spawn(function()
		local downloaded, content = pcall(function()
			return game:HttpGet(url)
		end)

		if not downloaded or type(content) ~= "string" then
			notify("Failed to download URL")
			return
		end

		local success, appliedCount, failedCount, errorMessage = applyFlagJson(content)

		if not success then
			notify(errorMessage or "Failed to apply FFlags")
			return
		end

		if failedCount > 0 then
			notify(string.format("Applied %d, failed %d", appliedCount, failedCount))
		else
			notify(string.format("Applied %d FFlags", appliedCount))
		end
	end)
end)

createSection(fflagsPage, "JSON editor")

local jsonEditor = createTextArea(
	fflagsPage,
	"FFLAG JSON",
	"Paste JSON here...",
	150
)

createButton(fflagsPage, "Paste JSON", function()
	local success, clipboardText = readClipboard()

	if not success then
		notify("Clipboard is unavailable")
		return
	end

	jsonEditor.Text = clipboardText
	jsonEditor:ReleaseFocus()
	notify("JSON pasted")
end)

createButton(fflagsPage, "Apply JSON", function()
	jsonEditor:ReleaseFocus()

	local success, appliedCount, failedCount, errorMessage = applyFlagJson(jsonEditor.Text)

	if not success then
		notify(errorMessage or "Failed to apply FFlags")
		return
	end

	if failedCount > 0 then
		notify(string.format("Applied %d, failed %d", appliedCount, failedCount))
	else
		notify(string.format("Applied %d FFlags", appliedCount))
	end
end)

createSection(fflagsPage, "Presets")

createButton(fflagsPage, "Load default JSON", function()
	jsonEditor.Text = DEFAULT_FFLAGS
	notify("Default JSON loaded")
end)

createButton(fflagsPage, "Apply default FFlags", function()
	local success, appliedCount, failedCount, errorMessage = applyFlagJson(DEFAULT_FFLAGS)

	if not success then
		notify(errorMessage or "Failed to apply default FFlags")
		return
	end

	if failedCount > 0 then
		notify(string.format("Applied %d, failed %d", appliedCount, failedCount))
	else
		notify(string.format("Applied %d default FFlags", appliedCount))
	end
end)

createButton(fflagsPage, "Rejoin server", function()
	local success = pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
	end)

	if not success then
		notify("Failed to rejoin server")
	end
end)

createInfo(
	fflagsPage,
	"FFLAGS",
	"Apply flags from a raw URL, pasted JSON or the included default preset."
)


createSection(miscPage, "Avatar")

local headlessToggle = createToggle(miscPage, "Headless", false, function(value)
	setHeadlessEnabled(value)
	notify(value and "Headless enabled" or "Headless disabled")
end)

local korbloxToggle = createToggle(miscPage, "Korblox", false, function(value)
	setKorbloxEnabled(value)
	notify(value and "Korblox enabled" or "Korblox disabled")
end)

createButton(miscPage, "Reapply appearance", function()
	refreshAppearance()
	notify("Appearance reapplied")
end)

createInfo(
	miscPage,
	"AVATAR VISUALS",
	"Applies Headless and Korblox locally and reapplies them after character reloads."
)

createSection(settingsPage, "Interface")

createButton(settingsPage, "Reset interface position", function()
	playTween(root, {
		Position = UDim2.new(0.5, -260, 0.5, -167)
	}, 0.3)

	notify("Position reset")
end)

createButton(settingsPage, "Disable and close", function()
	setNoRenderEnabled(false)
	setScreenStretchEnabled(false)
	setHeadlessEnabled(false)
	setKorbloxEnabled(false)

	playTween(root, {
		GroupTransparency = 1,
		Size = UDim2.fromOffset(520, 20)
	}, 0.2)

	task.wait(0.22)
	gui:Destroy()
end)

createInfo(settingsPage, "KEYBIND", "Press RightShift to fade the interface in or out.")

local visible = true
local minimized = false
local normalSize = UDim2.fromOffset(520, 334)

local function setVisible(state)
	if visible == state then
		return
	end

	visible = state

	if state then
		root.Visible = true
		root.GroupTransparency = 1
		root.Position = UDim2.new(
			root.Position.X.Scale,
			root.Position.X.Offset,
			root.Position.Y.Scale,
			root.Position.Y.Offset + 8
		)

		playTween(root, {
			GroupTransparency = 0,
			Position = UDim2.new(
				root.Position.X.Scale,
				root.Position.X.Offset,
				root.Position.Y.Scale,
				root.Position.Y.Offset - 8
			)
		}, 0.22)
	else
		playTween(root, {
			GroupTransparency = 1,
			Position = UDim2.new(
				root.Position.X.Scale,
				root.Position.X.Offset,
				root.Position.Y.Scale,
				root.Position.Y.Offset + 8
			)
		}, 0.18)

		task.delay(0.18, function()
			if not visible then
				root.Visible = false
			end
		end)
	end
end

local function buttonHover(button, hovering)
	playTween(button, {
		BackgroundTransparency = hovering and 0 or 1,
		BackgroundColor3 = theme.hover,
		TextColor3 = hovering and theme.text or theme.subtext
	}, 0.14)
end

minimizeButton.MouseEnter:Connect(function()
	buttonHover(minimizeButton, true)
end)

minimizeButton.MouseLeave:Connect(function()
	buttonHover(minimizeButton, false)
end)

closeButton.MouseEnter:Connect(function()
	buttonHover(closeButton, true)
end)

closeButton.MouseLeave:Connect(function()
	buttonHover(closeButton, false)
end)

local function setMinimized(state)
	state = state == true

	if minimized == state then
		return
	end

	minimized = state

	if state then
		sidebar.Visible = false
		content.Visible = false
		subtitle.Visible = false
		minimizeButton.Visible = false
		closeButton.Visible = false
		restoreButton.Visible = true

		brandAccent.Visible = false
		brand.Text = "27"
		brand.Size = UDim2.new(1, 0, 1, 0)
		brand.Position = UDim2.fromOffset(0, 0)
		brand.TextXAlignment = Enum.TextXAlignment.Center

		playTween(root, {
			Size = UDim2.fromOffset(78, 42)
		}, 0.28)
	else
		restoreButton.Visible = false

		playTween(root, {
			Size = normalSize
		}, 0.28)

		task.delay(0.15, function()
			if not minimized and root.Parent then
				brandAccent.Visible = true
				brand.Text = "K27E"
				brand.Size = UDim2.fromOffset(180, 20)
				brand.Position = UDim2.fromOffset(25, 4)
				brand.TextXAlignment = Enum.TextXAlignment.Left
				subtitle.Visible = true
				minimizeButton.Visible = true
				closeButton.Visible = true
				sidebar.Visible = true
				content.Visible = true
			end
		end)
	end
end

minimizeButton.MouseButton1Click:Connect(function()
	setMinimized(true)
end)


closeButton.MouseButton1Click:Connect(function()
	setNoRenderEnabled(false)
	setScreenStretchEnabled(false)
	setHeadlessEnabled(false)
	setKorbloxEnabled(false)

	playTween(root, {
		GroupTransparency = 1,
		Size = UDim2.fromOffset(520, 20)
	}, 0.2)

	task.wait(0.22)
	gui:Destroy()
end)

local dragging = false
local dragStart
local startPosition
local activeDragInput

local minimizedDragging = false
local minimizedDragStart
local minimizedStartPosition
local minimizedDragInput
local minimizedMoved = false

topbar.InputBegan:Connect(function(input)
	if minimized then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = root.Position
		activeDragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
	end
end)

restoreButton.InputBegan:Connect(function(input)
	if not minimized then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		minimizedDragging = true
		minimizedDragStart = input.Position
		minimizedStartPosition = root.Position
		minimizedDragInput = input.UserInputType == Enum.UserInputType.Touch and input or nil
		minimizedMoved = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if minimizedDragging then
		local validInput = minimizedDragInput and input == minimizedDragInput
			or not minimizedDragInput and input.UserInputType == Enum.UserInputType.MouseMovement

		if validInput then
			local delta = input.Position - minimizedDragStart

			if delta.Magnitude >= 6 then
				minimizedMoved = true
			end

			root.Position = UDim2.new(
				minimizedStartPosition.X.Scale,
				minimizedStartPosition.X.Offset + delta.X,
				minimizedStartPosition.Y.Scale,
				minimizedStartPosition.Y.Offset + delta.Y
			)
		end

		return
	end

	if dragging then
		local validInput = activeDragInput and input == activeDragInput
			or not activeDragInput and input.UserInputType == Enum.UserInputType.MouseMovement

		if validInput then
			local delta = input.Position - dragStart

			root.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if minimizedDragging then
		local ended = minimizedDragInput and input == minimizedDragInput
			or not minimizedDragInput and input.UserInputType == Enum.UserInputType.MouseButton1

		if ended then
			minimizedDragging = false
			minimizedDragInput = nil

			if not minimizedMoved and minimized then
				setMinimized(false)
			end
		end

		return
	end

	local ended = activeDragInput and input == activeDragInput
		or not activeDragInput and input.UserInputType == Enum.UserInputType.MouseButton1

	if ended then
		dragging = false
		activeDragInput = nil
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		setVisible(not visible)
	end
end)

for name, page in pairs(pages) do
	page.group.Visible = name == "Home"
	page.group.GroupTransparency = name == "Home" and 0 or 1
	page.group.Position = UDim2.fromOffset(0, 0)
end

activePage = "Home"

for name in pairs(tabs) do
	setTabVisual(name, name == "Home")
end

updateStatus()

root.Size = UDim2.fromOffset(520, 30)
root.Position = UDim2.new(0.5, -260, 0.5, -152)

playTween(root, {
	GroupTransparency = 0,
	Size = normalSize,
	Position = UDim2.new(0.5, -260, 0.5, -167)
}, 0.35)

gui.Destroying:Connect(function()
	setScreenStretchEnabled(false)
	appearance.version += 1

	if player.Character then
		pcall(restoreHeadless, player.Character)
		pcall(restoreKorblox, player.Character)
	end

	for _, connection in pairs(appearance.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end

	if type(executorEnvironment) == "table" then
		rawset(executorEnvironment, "K27EAppearanceConnections", nil)
	end
end)

task.delay(0.4, function()
	notify("K27E loaded")
end)
