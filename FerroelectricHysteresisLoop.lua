function FerroelectricEysteresisLoop(smuX, Vmax, Vmin, points, cycles, timesPercycles)
    -- local smuX= %s
    -- local Vmax = %f
    -- local Vmin = %f
    -- local points = %d
    -- local cycles = %d
    -- local timesPercycles = %f

    -- local timeStep = timesPercycles / points / 2-0.000008
    smuX.source.delay = 0
    smuX.measure.delay = timesPercycles / points / 2-0.000008
    smuX.measure.nplc=1
    smuX.measure.count=1

    smuX.measure.autozero=1 -- to zero once
    smuX.measure.filter.enable=smuX.FILTER_OFF
    
    smuX.nvbuffer1.timestampresolution = 0.000001
    smuX.nvbuffer1.clear()
    smuX.nvbuffer2.clear()
    smuX.nvbuffer1.appendmode = 1  
    smuX.nvbuffer2.appendmode = 1  
    smuX.nvbuffer1.collecttimestamps = 1
    smuX.nvbuffer2.collecttimestamps = 0
    smuX.nvbuffer1.collectsourcevalues = 0
    smuX.nvbuffer2.collectsourcevalues = 1
    
    smuX.source.limiti = 0.00001
    smuX.source.autorangev = smuX.AUTORANGE_ON
    smuX.source.autorangei = smuX.AUTORANGE_ON
    smuX.source.output = smuX.OUTPUT_ON
    smuX.measure.autorangev = smuX.AUTORANGE_ON
    
    local function sweep_voltage(startV, stopV, step)
        if startV < stopV then
            for v = startV, stopV, step do
                smuX.source.levelv = v
                -- delay(timeStep)  
                smuX.measure.iv(smuX.nvbuffer1,smuX.nvbuffer2)
            end
        else
            for v = startV, stopV, -step do
                smuX.source.levelv = v
                -- delay(timeStep)
                smuX.measure.iv(smuX.nvbuffer1,smuX.nvbuffer2)
            end
        end
    end

    local Vstep = (Vmax - Vmin) / points  
    sweep_voltage(0, Vmax, Vstep)
    for cycle = 1, cycles do
        sweep_voltage(Vmax, Vmin, Vstep)
        sweep_voltage(Vmin, Vmax, Vstep)

    end
    smuX.source.levelv = 0
    smuX.source.output = smuX.OUTPUT_OFF
    
    -- printbuffer(1, smuX.nvbuffer1.n, smuX.nvbuffer1.timestamps,smuX.nvbuffer1,smuX.nvbuffer2)  
    waitcomplete()
    delay(0.3)
    print("detectEnd")
    delay(0.3)
    printbuffer(1, smuX.nvbuffer1.n, smuX.nvbuffer1.timestamps)
    printbuffer(1,smuX.nvbuffer1.n,smuX.nvbuffer1)
    printbuffer(1,smuX.nvbuffer2.n,smuX.nvbuffer2.sourcevalues)
    printbuffer(1,smuX.nvbuffer2.n,smuX.nvbuffer2)
end
