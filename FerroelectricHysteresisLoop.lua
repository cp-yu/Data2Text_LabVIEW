function FerroelectricEysteresisLoop(smuX, Vmax, Vmin, points, cycles, timesPercycles)
    -- local smuX= %s
    -- local Vmax = %f
    -- local Vmin = %f
    -- local points = %d
    -- local cycles = %d
    -- local timesPercycles = %f
    local timeStep = timesPercycles / points / 2-0.000008
    smuX.nvbuffer1.timestampresolution = 0.000001
    -- smuX.nvbuffer2.timestampresolution = 0.000001
    smuX.nvbuffer1.clear()
    smuX.nvbuffer2.clear()
    smuX.nvbuffer1.appendmode = 1  
    smuX.nvbuffer2.appendmode = 1  
    smuX.nvbuffer1.collecttimestamps = 1
    smuX.nvbuffer2.collecttimestamps = 0
    smuX.source.limiti = 0.1
    smuX.source.autorangev = smuX.AUTORANGE_ON
    smuX.source.autorangei = smuX.AUTORANGE_ON
    smuX.source.output = smuX.OUTPUT_ON
    smuX.measure.delay = 0.001
    smuX.measure.count=1
    
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
    print("detectEnd")
    delay(0.9)
    printbuffer(1, smuX.nvbuffer1.n, smuX.nvbuffer1.timestamps)
    printbuffer(1,smuX.nvbuffer1.n,smuX.nvbuffer1)
    printbuffer(1,smuX.nvbuffer2.n,smuX.nvbuffer2)
end
