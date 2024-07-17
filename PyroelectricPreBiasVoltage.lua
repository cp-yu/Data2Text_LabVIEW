function PyroelectricPreBiasVoltage(Vmax,time2Vmax)

    -- function FerroelectricEysteresisLoop(smuX, Vmax, Vmin, points, cycles, timesPercycles)

        
        smuX.source.limiti = 0.00001
        smuX.source.autorangev = smuX.AUTORANGE_ON
        -- smuX.source.autorangei = smuX.AUTORANGE_ON
        smuX.source.output = smuX.OUTPUT_OFF
        smuX.source.levelv=0
        smuX.source.output = smuX.OUTPUT_ON
        -- smuX.measure.autorangev = smuX.AUTORANGE_ON
        
        stepTime=time2Vmax/100
        stepVoltage=Vmax/100
        for i=0,Vmax,stepVoltage do
            smuX.source.levelv=i
            delay(stepTime)
        end

        smuX.source.levelv=Vmax
    

end