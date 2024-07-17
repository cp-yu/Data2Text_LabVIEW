--////////////////////////////////////////////////////////////////////////////
--
-- KISweep
--
-- This functions in this factory script are provided for backward
-- compatibility with the Series 2600.  The methods used in this factory
-- script can be used as examples of how to configure and run sweeps.
--
-- You are free to copy, modify, and use this script in any way.
--
--////////////////////////////////////////////////////////////////////////////

-- Tables of constants that are based on model number
local l_constants =
{
    ["2601"] =
        {
            min_amps    = 1e-12,
            min_volts   = 1e-6,
            max_amps    = 3,
            max_volts   = 40,
            volts_fmt   = "+00.0000"
        },
    ["2611"] =
        {
            min_amps    = 1e-12,
            min_volts   = 1e-6,
            max_amps    = 1.5,
            max_volts   = 200,
            volts_fmt   = "+000.000",
        },
    ["2634"] = 
        {
            min_amps    = 100e-15,
            min_volts   = 1e-6,
            max_amps    = 1.5,
            max_volts   = 200,
            volts_fmt   = "+000.000"
        },
    ["2635"] = 
        {
            min_amps    = 10e-15,
            min_volts   = 1e-6,
            max_amps    = 1.5,
            max_volts   = 200,
            volts_fmt   = "+000.000"
        },
}
l_constants["2602"]    = l_constants["2601"]
l_constants["2604"]    = l_constants["2601"]
l_constants["2612"]    = l_constants["2611"]
l_constants["2614"]    = l_constants["2611"]
l_constants["2636"]    = l_constants["2635"]

-- Choose the appropriate constants based on the model number
l_constants = l_constants[string.sub(localnode.model,1,4)]
if l_constants == nil then
    error("KISweep factory script is not designed to run on a Model " .. localnode.model)
    return
end
local l_min_amps    = l_constants.min_amps
local l_min_volts   = l_constants.min_volts
local l_max_amps    = l_constants.max_amps
local l_max_volts   = l_constants.max_volts
local l_volts_fmt   = l_constants.volts_fmt

--============================================================================
--
-- Helper functions
--
--============================================================================

------------------------------------------------------------------------------
--
-- AbortScript
--
-- Restore the display to the given screen, then terminate the running script.
--
------------------------------------------------------------------------------

local function AbortScript(screen)
    display.clear()
    display.settext("Script Aborted")
    delay(2)
    display.clear()
    display.screen = screen
    exit()
end

--============================================================================
--
-- Sweeping functions
--
--============================================================================

------------------------------------------------------------------------------
--
-- SweepILinMeasureV
--
------------------------------------------------------------------------------

function SweepILinMeasureV(smu, starti, stopi, stime, points)
    -- Default to smua if no smu is specified.
    if smu == nil then
        smu = smua
    end

    -- Save settings in temporary variables so they can be restored at the end.
    local l_s_leveli = smu.source.leveli 
    local l_s_rangei = smu.source.rangei
    local l_s_autorangei = smu.source.autorangei 
    local l_s_func = smu.source.func
    local l_m_autozero = smu.measure.autozero
    local l_m_filter = smu.measure.filter.enable
    local l_d_screen = display.screen

    -- Clear the front panel display then prompt for input parameters if missing.
    display.clear()  
    if starti == nil then
        starti = display.prompt("+0.000E+00", " Amps", "Enter START current.", -100E-6, -l_max_amps, l_max_amps)
        if starti == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stopi == nil then
        stopi = display.prompt("+0.000E+00", " Amps", "Enter STOP current.", 100E-6, -l_max_amps, l_max_amps)
        if stopi == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stime == nil then
        stime = display.prompt("+0.000E+00", " Seconds", "Enter SETTLING time.", 0, 0, 10)
        if stime == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if points == nil then
        points = display.prompt("0000", " Points", "Enter number of sweep POINTS.", 10, 1, 1000)    
        if points == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    
    -- Update display with test info.
    display.settext("SweepILinMeasureV")  -- Line 1 (20 characters max)
    
    -- Configure source and measure settings.
    smu.source.output = smu.OUTPUT_OFF
    smu.source.func = smu.OUTPUT_DCAMPS
    smu.source.leveli = 0
    smu.source.rangei = math.max(math.abs(starti), math.abs(stopi))
    smu.measure.autozero = smu.AUTOZERO_OFF
    smu.measure.filter.enable = smu.FILTER_OFF
    
    -- Setup a buffer to store the result(s).
    smu.nvbuffer1.clear()
    smu.nvbuffer1.appendmode = 1
    smu.nvbuffer1.collecttimestamps = 1
    smu.nvbuffer1.collectsourcevalues = 1

    -- Reset trigger model
    smu.trigger.arm.stimulus = 0
    smu.trigger.source.stimulus = 0
    smu.trigger.measure.stimulus = 0
    smu.trigger.endpulse.stimulus = 0
    smu.trigger.arm.count = 1
    -- Configure the source action
    smu.trigger.source.lineari(starti, stopi, points)
    smu.trigger.source.action = smu.ENABLE
    smu.trigger.endpulse.action = smu.SOURCE_HOLD
    -- Configure the measure action
    smu.trigger.measure.v(smu.nvbuffer1)
    smu.trigger.measure.action = smu.ENABLE
    -- Configure the delay
    if (stime > 0) then
        trigger.timer[1].reset()
        trigger.timer[1].delay = stime
        smu.trigger.measure.stimulus = trigger.timer[1].EVENT_ID
        trigger.timer[1].stimulus = smu.trigger.SOURCE_COMPLETE_EVENT_ID
    end
    -- Configure the sweep count
    smu.trigger.count = points

    -- Run the sweep and then turn the output off.
    smu.source.output = smu.OUTPUT_ON
    smu.trigger.initiate()
    waitcomplete()
    smu.source.output = smu.OUTPUT_OFF

    -- Update the front panel display and restore modified settings.
    display.setcursor(2,1)             
    display.settext("Test complete.")     -- Line 2 (32 characters max)
    smu.source.leveli = 0
    smu.source.rangei = l_s_rangei
    smu.source.autorangei = l_s_autorangei 
    smu.source.func = l_s_func
    smu.source.leveli = l_s_leveli
    smu.measure.autozero = l_m_autozero
    smu.measure.filter.enable = l_m_filter
    delay(2)
    display.clear()
    display.screen = l_d_screen
end 

------------------------------------------------------------------------------
--
-- SweepVLinMeasureI
--
------------------------------------------------------------------------------

function SweepVLinMeasureI(smu, startv, stopv, stime, points)
    -- Default to smua if no smu is specified.
    if smu == nil then
        smu = smua
    end

    -- Save settings in temporary variables so they can be restored at the end.
    local l_s_levelv = smu.source.levelv 
    local l_s_rangev = smu.source.rangev
    local l_s_autorangev = smu.source.autorangev 
    local l_s_func = smu.source.func
    local l_m_autozero = smu.measure.autozero
    local l_d_screen = display.screen

    -- Clear the front panel display then prompt for input parameters if missing.
    display.clear()  
    if startv == nil then
        startv = display.prompt(l_volts_fmt, " Volts", "Enter START voltage.", -1, -l_max_volts, l_max_volts)
        if startv == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stopv == nil then
        stopv = display.prompt(l_volts_fmt, " Volts", "Enter STOP voltage.", 1, -l_max_volts, l_max_volts)
        if stopv == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stime == nil then
        stime = display.prompt("+0.000E+00", " Seconds", "Enter SETTLING time.", 0, 0, 10)
        if stime == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if points == nil then
        points = display.prompt("0000", " Points", "Enter number of sweep POINTS.", 10, 1, 1000)    
        if points == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    
    -- Update display with test info.
    display.settext("SweepVLinMeasureI")  -- Line 1 (20 characters max)
    
    -- Configure source and measure settings.
    smu.source.output = smu.OUTPUT_OFF
    smu.source.func = smu.OUTPUT_DCVOLTS
    smu.source.levelv = 0
    smu.source.rangev = math.max(math.abs(startv), math.abs(stopv))
    smu.measure.autozero = smu.AUTOZERO_OFF
    
    -- Setup a buffer to store the result(s) in and start testing.
    smu.nvbuffer1.clear()
    smu.nvbuffer1.appendmode = 1
    smu.nvbuffer1.collecttimestamps = 1
    smu.nvbuffer1.collectsourcevalues = 1

    -- Reset trigger model
    smu.trigger.arm.stimulus = 0
    smu.trigger.source.stimulus = 0
    smu.trigger.measure.stimulus = 0
    smu.trigger.endpulse.stimulus = 0
    smu.trigger.arm.count = 1
    -- Configure the source action
    smu.trigger.source.linearv(startv, stopv, points)
    smu.trigger.source.action = smu.ENABLE
    smu.trigger.endpulse.action = smu.SOURCE_HOLD
    -- Configure the measure action
    smu.trigger.measure.i(smu.nvbuffer1)
    smu.trigger.measure.action = smu.ENABLE
    -- Configure the delay
    if (stime > 0) then
        trigger.timer[1].reset()
        trigger.timer[1].delay = stime
        smu.trigger.measure.stimulus = trigger.timer[1].EVENT_ID
        trigger.timer[1].stimulus = smu.trigger.SOURCE_COMPLETE_EVENT_ID
    end
    -- Configure the sweep count
    smu.trigger.count = points

    -- Run the sweep and then turn the output off.
    smu.source.output = smu.OUTPUT_ON
    smu.trigger.initiate()
    waitcomplete()
    smu.source.output = smu.OUTPUT_OFF

    -- Update the front panel display and restore modified settings.
    display.setcursor(2,1)             
    display.settext("Test complete.")     -- Line 2 (32 characters max)
    smu.source.levelv = 0
    smu.source.rangev = l_s_rangev
    smu.source.autorangev = l_s_autorangev 
    smu.source.func = l_s_func
    smu.source.levelv = l_s_levelv
    smu.measure.autozero = l_m_autozero
    delay(2)
    display.clear()
    display.screen = l_d_screen
end

------------------------------------------------------------------------------
--
-- SweepILogMeasureV
--
------------------------------------------------------------------------------

function SweepILogMeasureV(smu, starti, stopi, stime, points)
    -- Default to smua if no smu is specified.
    if smu == nil then
        smu = smua
    end

    -- Save settings in temporary variables so they can be restored at the end.
    local l_s_leveli = smu.source.leveli 
    local l_s_rangei = smu.source.rangei
    local l_s_autorangei = smu.source.autorangei 
    local l_s_func = smu.source.func
    local l_m_autozero = smu.measure.autozero
    local l_d_screen = display.screen

    -- Clear the front panel display then prompt for input parameters if missing.
    display.clear()  
    if starti == nil then
        starti = display.prompt("+0.000E+00", " Amps", "Enter START current.", 1E-9, l_min_amps, l_max_amps)
        if starti == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stopi == nil then
        stopi = display.prompt("+0.000E+00", " Amps", "Enter STOP current.", 100E-6, l_min_amps, l_max_amps)
        if stopi == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stime == nil then
        stime = display.prompt("+0.000E+00", " Seconds", "Enter SETTLING time.", 0, 0, 10)
        if stime == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if points == nil then
        points = display.prompt("0000", " Points", "Enter number of sweep POINTS.", 10, 1, 1000)    
        if points == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end

    -- Update display with test info.
    display.settext("SweepILogMeasureV")  -- Line 1 (20 characters max)

    -- Configure source and measure settings.
    smu.source.output = smu.OUTPUT_OFF
    smu.source.func = smu.OUTPUT_DCAMPS
    smu.source.leveli = 0
    smu.source.rangei = math.max(starti, stopi)
    smu.measure.autozero = smu.AUTOZERO_OFF

    -- Setup a buffer to store the result(s) in and start testing.
    smu.nvbuffer1.clear()
    smu.nvbuffer1.appendmode = 1
    smu.nvbuffer1.collecttimestamps = 1
    smu.nvbuffer1.collectsourcevalues = 1

    -- Reset trigger model
    smu.trigger.arm.stimulus = 0
    smu.trigger.source.stimulus = 0
    smu.trigger.measure.stimulus = 0
    smu.trigger.endpulse.stimulus = 0
    smu.trigger.arm.count = 1
    -- Configure the source action
    smu.trigger.source.logi(starti, stopi, points, 0)
    smu.trigger.source.action = smu.ENABLE
    smu.trigger.endpulse.action = smu.SOURCE_HOLD
    -- Configure the measure action
    smu.trigger.measure.v(smu.nvbuffer1)
    smu.trigger.measure.action = smu.ENABLE
    -- Configure the delay
    if (stime > 0) then
        trigger.timer[1].reset()
        trigger.timer[1].delay = stime
        smu.trigger.measure.stimulus = trigger.timer[1].EVENT_ID
        trigger.timer[1].stimulus = smu.trigger.SOURCE_COMPLETE_EVENT_ID
    end
    -- Configure the sweep count
    smu.trigger.count = points

    -- Run the sweep and then turn the output off.
    smu.source.output = smu.OUTPUT_ON
    smu.trigger.initiate()
    waitcomplete()
    smu.source.output = smu.OUTPUT_OFF

    -- Update the front panel display and restore modified settings.
    display.setcursor(2,1)             
    display.settext("Test complete.")     -- Line 2 (32 characters max)
    smu.source.leveli = 0
    smu.source.rangei = l_s_rangei
    smu.source.autorangei = l_s_autorangei 
    smu.source.func = l_s_func
    smu.source.leveli = l_s_leveli
    smu.measure.autozero = l_m_autozero
    delay(2)
    display.clear()
    display.screen = l_d_screen
end

------------------------------------------------------------------------------
--
-- SweepVLogMeasureI
--
------------------------------------------------------------------------------

function SweepVLogMeasureI(smu, startv, stopv, stime, points)
    -- Default to smua if no smu is specified.
    if smu == nil then
        smu = smua
    end

    -- Save settings in temporary variables so they can be restored at the end.
    local l_s_levelv = smu.source.levelv 
    local l_s_rangev = smu.source.rangev
    local l_s_autorangev = smu.source.autorangev 
    local l_s_func = smu.source.func
    local l_m_autozero = smu.measure.autozero
    local l_d_screen = display.screen

    -- Clear the front panel display then prompt for input parameters if missing.
    display.clear()  
    if startv == nil then
        startv = display.prompt(l_volts_fmt, " Volts", "Enter START voltage.", 1, l_min_volts, l_max_volts)
        if startv == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stopv == nil then
        stopv = display.prompt(l_volts_fmt, " Volts", "Enter STOP voltage.", 10, l_min_volts, l_max_volts)
        if stopv == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stime == nil then
        stime = display.prompt("+0.000E+00", " Seconds", "Enter SETTLING time.", 0, 0, 10)
        if stime == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if points == nil then
        points = display.prompt("0000", " Points", "Enter number of sweep POINTS.", 10, 1, 1000)    
        if points == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    
    -- Update display with test info.
    display.settext("SweepVLogMeasureI")  -- Line 1 (20 characters max)
    
    -- Configure source and measure settings.
    smu.source.output = smu.OUTPUT_OFF
    smu.source.func = smu.OUTPUT_DCVOLTS
    smu.source.levelv = 0
    smu.source.rangev = math.max(startv, stopv)
    smu.measure.autozero = smu.AUTOZERO_OFF
    
    -- Setup a buffer to store the result(s) in and start testing.
    smu.nvbuffer1.clear()
    smu.nvbuffer1.appendmode = 1
    smu.nvbuffer1.collecttimestamps = 1
    smu.nvbuffer1.collectsourcevalues = 1

    -- Reset trigger model
    smu.trigger.arm.stimulus = 0
    smu.trigger.source.stimulus = 0
    smu.trigger.measure.stimulus = 0
    smu.trigger.endpulse.stimulus = 0
    smu.trigger.arm.count = 1
    -- Configure the source action
    smu.trigger.source.logv(startv, stopv, points, 0)
    smu.trigger.source.action = smu.ENABLE
    smu.trigger.endpulse.action = smu.SOURCE_HOLD
    -- Configure the measure action
    smu.trigger.measure.i(smu.nvbuffer1)
    smu.trigger.measure.action = smu.ENABLE
    -- Configure the delay
    if (stime > 0) then
        trigger.timer[1].reset()
        trigger.timer[1].delay = stime
        smu.trigger.measure.stimulus = trigger.timer[1].EVENT_ID
        trigger.timer[1].stimulus = smu.trigger.SOURCE_COMPLETE_EVENT_ID
    end
    -- Configure the sweep count
    smu.trigger.count = points

    -- Run the sweep and then turn the output off.
    smu.source.output = smu.OUTPUT_ON
    smu.trigger.initiate()
    waitcomplete()
    smu.source.output = smu.OUTPUT_OFF

    -- Update the front panel display and restore modified settings.
    display.setcursor(2,1)             
    display.settext("Test complete.")     -- Line 2 (32 characters max)
    smu.source.levelv = 0
    smu.source.rangev = l_s_rangev
    smu.source.autorangev = l_s_autorangev 
    smu.source.func = l_s_func
    smu.source.levelv = l_s_levelv
    smu.measure.autozero = l_m_autozero
    delay(2)
    display.clear()
    display.screen = l_d_screen
end

------------------------------------------------------------------------------
--
-- SweepIListMeasureV
--
------------------------------------------------------------------------------

function SweepIListMeasureV(smu, ilist, stime, points)
    -- Default to smua if no smu is specified.
    if smu == nil then
        smu = smua
    end

    -- Save settings in temporary variables so they can be restored at the end.
    local l_s_leveli = smu.source.leveli 
    local l_s_rangei = smu.source.rangei
    local l_s_autorangei = smu.source.autorangei 
    local l_s_func = smu.source.func
    local l_m_autozero = smu.measure.autozero
    local l_d_screen = display.screen

    -- Temporary variables used by this function.
    local l_j

    -- Clear the front panel display then prompt for input parameters if missing.
    display.clear()  
    if points == nil then
        points = display.prompt("0000", " Points", "Enter number of sweep POINTS.", 10, 1, 1000)    
        if points == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stime == nil then
        stime = display.prompt("+0.000E+00", " Seconds", "Enter SETTLING time.", 0, 0, 10)
        if stime == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end 
    if ilist == nil then
        ilist = {}
        for l_j = 1,points do
            ilist[l_j] = display.prompt("+0.000E+00", " Amps", "Enter current "..string.format("%d",l_j), 100E-6, -l_max_amps, l_max_amps)        
            if ilist[l_j] == nil then
                -- Abort if Exit key pressed
                AbortScript(l_d_screen)
            end
        end
    end
    
    -- Update display with test info.
    display.settext("SweepIListMeasureV")  -- Line 1 (20 characters max)
    
    -- Configure source and measure settings.
    smu.source.output = smu.OUTPUT_OFF
    smu.source.func = smu.OUTPUT_DCAMPS
    smu.source.autorangei = smu.AUTORANGE_ON
    smu.source.leveli = ilist[1]
    smu.measure.autozero = smu.AUTOZERO_OFF
    
    -- Setup a buffer to store the result(s) in and start testing.
    smu.nvbuffer1.clear()
    smu.nvbuffer1.appendmode = 1
    smu.nvbuffer1.collecttimestamps = 1
    smu.nvbuffer1.collectsourcevalues = 1

    -- Reset trigger model
    smu.trigger.arm.stimulus = 0
    smu.trigger.source.stimulus = 0
    smu.trigger.measure.stimulus = 0
    smu.trigger.endpulse.stimulus = 0
    smu.trigger.arm.count = 1
    -- Configure the source action
    smu.trigger.source.listi(ilist)
    smu.trigger.source.action = smu.ENABLE
    smu.trigger.endpulse.action = smu.SOURCE_HOLD
    -- Configure the measure action
    smu.trigger.measure.v(smu.nvbuffer1)
    smu.trigger.measure.action = smu.ENABLE
    -- Configure the delay
    if (stime > 0) then
        trigger.timer[1].reset()
        trigger.timer[1].delay = stime
        smu.trigger.measure.stimulus = trigger.timer[1].EVENT_ID
        trigger.timer[1].stimulus = smu.trigger.SOURCE_COMPLETE_EVENT_ID
    end
    -- Configure the sweep count
    smu.trigger.count = points

    -- Run the sweep and then turn the output off.
    smu.source.output = smu.OUTPUT_ON
    smu.trigger.initiate()
    waitcomplete()
    smu.source.output = smu.OUTPUT_OFF

    -- Update the front panel display and restore modified settings.
    display.setcursor(2,1)             
    display.settext("Test complete.")      -- Line 2 (32 characters max)
    smu.source.leveli     = l_s_leveli
    smu.source.func       = l_s_func
    smu.source.autorangei = l_s_autorangei
    smu.measure.autozero  = l_m_autozero
    delay(2)
    display.clear()
    display.screen = l_d_screen
end

------------------------------------------------------------------------------
--
-- SweepVListMeasureI
--
------------------------------------------------------------------------------

function SweepVListMeasureI(smu, vlist, stime, points)
    -- Default to smua if no smu is specified.
    if smu == nil then
        smu = smua
    end

    -- Save settings in temporary variables so they can be restored at the end.
    local l_s_levelv = smu.source.levelv 
    local l_s_rangev = smu.source.rangev
    local l_s_autorangev = smu.source.autorangev 
    local l_s_func = smu.source.func
    local l_m_autozero = smu.measure.autozero
    local l_d_screen = display.screen

    -- Temporary variables used by this function.
    local l_j

    -- Clear the front panel display then prompt for input parameters if missing.
    display.clear()  
    if points == nil then
        points = display.prompt("0000", " Points", "Enter number of sweep POINTS.", 10, 1, 1000)    
        if points == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if stime == nil then
        stime = display.prompt("+0.000E+00", " Seconds", "Enter SETTLING time.", 0, 0, 10)
        if stime == nil then
            -- Abort if Exit key pressed
            AbortScript(l_d_screen)
        end
    end
    if vlist == nil then
        vlist = {}
        for l_j = 1, points do
            vlist[l_j] = display.prompt(l_volts_fmt, " Volts", "Enter voltage "..string.format("%d",l_j), -1, -l_max_volts, l_max_volts)        
            if  vlist[l_j] == nil then
                -- Abort if Exit key pressed
                AbortScript(l_d_screen)
            end
        end
    end

    -- Update display with test info.
    display.settext("SweepVListMeasureI")  -- Line 1 (20 characters max)

    -- Configure source and measure settings.
    smu.source.output = smu.OUTPUT_OFF
    smu.source.func = smu.OUTPUT_DCVOLTS
    smu.source.autorangev = smu.AUTORANGE_ON
    smu.source.levelv = vlist[1]
    smu.measure.autozero = smu.AUTOZERO_OFF

    -- Setup a buffer to store the result(s) in and start testing.
    smu.nvbuffer1.clear()
    smu.nvbuffer1.appendmode = 1
    smu.nvbuffer1.collecttimestamps = 1
    smu.nvbuffer1.collectsourcevalues = 1

    -- Reset trigger model
    smu.trigger.arm.stimulus = 0
    smu.trigger.source.stimulus = 0
    smu.trigger.measure.stimulus = 0
    smu.trigger.endpulse.stimulus = 0
    smu.trigger.arm.count = 1
    -- Configure the source action
    smu.trigger.source.listv(vlist)
    smu.trigger.source.action = smu.ENABLE
    smu.trigger.endpulse.action = smu.SOURCE_HOLD
    -- Configure the measure action
    smu.trigger.measure.i(smu.nvbuffer1)
    smu.trigger.measure.action = smu.ENABLE
    -- Configure the delay
    if (stime > 0) then
        trigger.timer[1].reset()
        trigger.timer[1].delay = stime
        smu.trigger.measure.stimulus = trigger.timer[1].EVENT_ID
        trigger.timer[1].stimulus = smu.trigger.SOURCE_COMPLETE_EVENT_ID
    end
    -- Configure the sweep count
    smu.trigger.count = points

    -- Run the sweep and then turn the output off.
    smu.source.output = smu.OUTPUT_ON
    smu.trigger.initiate()
    waitcomplete()
    smu.source.output = smu.OUTPUT_OFF

    -- Update the front panel display and restore modified settings.
    display.setcursor(2,1)             
    display.settext("Test complete.")      -- Line 2 (32 characters max)
    smu.source.levelv = l_s_levelv
    smu.source.func = l_s_func
    smu.source.autorangev = l_s_autorangev
    smu.measure.autozero = l_m_autozero
    delay(2)
    display.clear()
    display.screen = l_d_screen
end

--============================================================================
--
-- Add entries to the display menu
--
--============================================================================

display.loadmenu.add("Factory/SweepILinMeasureV", "SweepILinMeasureV()",    0)
display.loadmenu.add("Factory/SweepVLinMeasureI", "SweepVLinMeasureI()",    0)
display.loadmenu.add("Factory/SweepILogMeasureV", "SweepILogMeasureV()",    0)
display.loadmenu.add("Factory/SweepVLogMeasureI", "SweepVLogMeasureI()",    0)
display.loadmenu.add("Factory/SweepIListMeasureV","SweepIListMeasureV()",   0)
display.loadmenu.add("Factory/SweepVListMeasureI","SweepVListMeasureI()",   0)

