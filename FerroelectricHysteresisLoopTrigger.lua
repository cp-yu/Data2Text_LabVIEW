function SweepVListMeasureI_yunxin(smu, vlist, stime, points)
    -- Save settings in temporary variables so they can be restored at the end.
    -- local l_d_screen = display.screen

    -- Clear the front panel display then prompt for input parameters if missing.
    -- display.clear()  

    -- -- Update display with test info.
    -- display.settext("SweepVListMeasureI")  -- Line 1 (20 characters max)

    ibuffer=smu.makebuffer(points)

    -- Configure source and measure settings.
    smu.source.output = smu.OUTPUT_OFF
    smu.source.func = smu.OUTPUT_DCVOLTS
    smu.source.autorangev = smu.AUTORANGE_ON
    smu.source.levelv = vlist[1]
    smu.measure.autozero = smu.AUTOZERO_ONCE

    ibuffer.clear()
    ibuffer.appendmode = 1
    ibuffer.collecttimestamps = 1
    ibuffer.collectsourcevalues = 1

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
    smu.trigger.measure.i(ibuffer)
    smu.trigger.measure.action = smu.ENABLE

    -- Configure the delay
    -- if (stime > 0) then
    --     trigger.timer[1].reset()
    --     trigger.timer[1].delay = stime
    --     smu.trigger.measure.stimulus = trigger.timer[1].EVENT_ID
    --     trigger.timer[1].stimulus = smu.trigger.SOURCE_COMPLETE_EVENT_ID
    -- end

    trigger.blender[1].clear()
    trigger.blender[1].reset()
    trigger.blender[1].orenable=true
    trigger.blender[1].stimulus[1]=trigger.timer[1].EVENT_ID
    trigger.blender[1].stimulus[2]=smu.trigger.ARMED_EVENT_ID
    if (stime > 0) then
        trigger.timer[1].reset()
        trigger.timer[1].delay = stime
        smu.trigger.source.stimulus = trigger.blender[1].EVENT_ID
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
    -- display.setcursor(2,1)             
    -- display.settext("Test complete.")      -- Line 2 (32 characters max)
    -- delay(2)
    -- display.clear()
    -- display.screen = l_d_screen
end

function FerroelectricEysteresisLoop(smuX, Vmax, Vmin, points, cycles, timesPercycles)
    -- local smuX= %s
    -- local Vmax = %f
    -- local Vmin = %f
    -- local points = %d
    -- local cycles = %d
    -- local timesPercycles = %f

    local timeStep = timesPercycles / points / 2-0.000008
    smuX.source.delay = 0
    smuX.measure.delay = 0
    smuX.measure.nplc=1
    smuX.measure.count=1

    smuX.measure.autozero=1 -- to zero once
    smuX.measure.filter.enable=smuX.FILTER_OFF
        
    smuX.source.autorangev = smuX.AUTORANGE_ON
    smuX.source.limiti = 0.00001
    -- smuX.measure.autorangev = smuX.AUTORANGE_ON
    
    -- 生成listv
    local listv = {}
    local step = 2*(Vmax-Vmin)/(points-1)
    
-- 第一段从0到Vmax
    local i = 0
    while i < Vmax do
        table.insert(listv, i)
        i = i + step
    end
    
    -- 第二段从Vmax到Vmin
    i = Vmax
    while i > Vmin do
        table.insert(listv, i)
        i = i - step
    end
    
    -- 第三段从Vmin到0
    i = Vmin
    while i < 0 do
        table.insert(listv, i)
        i = i + step
    end

    SweepVListMeasureI_yunxin(smuX, listv, timeStep, points * cycles + points / 4)

    waitcomplete()
    delay(0.3)
    print("detectEnd")
    delay(0.3)
    printbuffer(1, ibuffer.n, ibuffer.timestamps)
    printbuffer(1, ibuffer.n, ibuffer.sourcevalues)
    printbuffer(1, ibuffer.n, ibuffer)
end