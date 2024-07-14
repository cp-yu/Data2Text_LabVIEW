function SweepVListMeasureI_yunxin(smu, vlist, stime, points)
    ibuffer=smuX.makebuffer(points)
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

end

function FerroelectricEysteresisLoop(smuX, Vmax, Vmin, points, cycles, timesPercycles)
    -- local smuX= %s
    -- local Vmax = %f
    -- local Vmin = %f
    -- local points = %d
    -- local cycles = %d
    -- local timesPercycles = %f
    
    local abs_Vmax=math.max(math.abs(Vmax), math.abs(Vmin))
    local timeStep = timesPercycles / points / 2-0.000008

    smuX.source.levelv=abs_Vmax
    smuX.measure.autorangei=smuX.AUTORANGE_ON
    smuX.measure.autozero = smuX.AUTOZERO_ON
    smuX.measure.count=6
    smuX.source.output=smuX.OUTPUT_ON
    local current_i=smuX.measure.i()
    currnet_i= current_i*1.2

    smuX.source.delay = 0
    smuX.measure.delay = 0
    smuX.measure.nplc=1
    smuX.measure.count=1




    -- smuX.source.rangev=math.max(math.abs(starti), math.abs(stopi))
    smuX.measure.autozero = smuX.AUTOZERO_OFF
    smuX.measure.autorangei=smuX.AUTORANGE_OFF
    smuX.measure.rangei=current_i
    smuX.measure.filter.enable=smuX.FILTER_OFF
    
    -- Configure source and measure settings.
    smuX.source.output = smuX.OUTPUT_OFF
    smuX.source.func = smuX.OUTPUT_DCVOLTS
    smuX.source.autorangev = smuX.AUTORANGE_OFF
    smuX.source.rangev= abs_Vmax
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