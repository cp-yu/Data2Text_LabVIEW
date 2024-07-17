function SweepVListMeasureI_yunxin(smu, vlist, stime, points)
    ibuffer.clear()
    ibuffer.appendmode = 1
    ibuffer.collecttimestamps = 1
    ibuffer.collectsourcevalues = 1

    smu.source.levelv = vlist[1]

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
    trigger.blender[1].clear()
    trigger.blender[1].reset()
    trigger.blender[1].orenable = true
    trigger.blender[1].stimulus[1] = trigger.timer[1].EVENT_ID
    trigger.blender[1].stimulus[2] = smu.trigger.ARMED_EVENT_ID
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
end

function FerroelectricEysteresisLoop(smuX, Vmax, Vmin, points, cycles, timesPercycles, sourcev, measurei)
    -- local smuX= %s
    -- local Vmax = %f
    -- local Vmin = %f
    -- local points = %d
    -- local cycles = %d
    -- local timesPercycles = %f
    
    ibuffer = smuX.makebuffer(points * cycles + points / 4)
    ibuffer.clear()
    ibuffer.appendmode = 0

    smuX.reset()
    if (measurei == 0) then 
        smuX.source.levelv = abs_Vmax * 0.6
        smuX.measure.autorangei = smuX.AUTORANGE_ON
        smuX.measure.autozero = smuX.AUTOZERO_AUTO
        smuX.measure.count = 20
        smuX.source.output = smuX.OUTPUT_ON
        delay(0.3)
        smuX.measure.i(ibuffer)
        stats = smuX.buffer.getstats(ibuffer)
        smuX.source.levelv = 0
        delay(0.3)
    end

    smuX.source.delay = 0
    smuX.measure.delay = 0
    smuX.measure.nplc = 1
    smuX.measure.count = 1

    smuX.measure.autozero = smuX.AUTOZERO_OFF
    smuX.measure.autorangei = smuX.AUTORANGE_OFF

    if (measurei == 0) then
        smuX.measure.rangei = stats.max.reading * 3 -- if measurei==0, using this
    else
        smuX.measure.rangei = measurei -- else using measurei
    end

    smuX.measure.filter.enable = smuX.FILTER_OFF

    -- Configure source and measure settings.
    smuX.source.output = smuX.OUTPUT_OFF
    smuX.source.func = smuX.OUTPUT_DCVOLTS
    smuX.source.autorangev = smuX.AUTORANGE_OFF

    if (sourcev == 0) then
        smuX.source.rangev = abs_Vmax -- if sourcev==0, using this
    else
        smuX.source.rangev = sourcev -- else using sourcev
    end

    smuX.source.limiti = 0.00001 

    -- Generate listv
    local listv = {}
    local step = 2 * (Vmax - Vmin) / (points - 1)

    -- First segment from 0 to Vmax
    local i = 0
    while i < Vmax do
        table.insert(listv, i)
        i = i + step
    end

    -- Second segment from Vmax to Vmin
    i = Vmax
    while i > Vmin do
        table.insert(listv, i)
        i = i - step
    end

    -- Third segment from Vmin to 0
    i = Vmin
    while i < 0 do
        table.insert(listv, i)
        i = i + step
    end

    SweepVListMeasureI_yunxin(smuX, listv, timeStep, points * cycles + points / 4)

    waitcomplete()
    smuX.source.levelv = 0
    smuX.source.output = smuX.OUTPUT_ON
    delay(0.5)
    print("detectEnd")
    delay(0.8)
    smuX.reset()
end
