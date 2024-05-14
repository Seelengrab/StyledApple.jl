#!/bin/env julia

import Pkg

Pkg.activate(@__DIR__)
Pkg.instantiate()

using VideoIO, StyledStrings
using StyledStrings: SimpleColor, Face, @styled_str
using FFplay_jll

function main(; stats=false, volume=80)
    video_file = joinpath(@__DIR__, "Bad Apple!! feat.nomico 40h.webm")
    badapple = VideoIO.openvideo(video_file)
    buf = Base.AnnotatedIOBuffer()

    # ffplay takes 0-100
    vol = round(Int, clamp(volume, 0, 100))
    audio = @async ffplay() do exe
        success(`$exe -autoexit -nodisp -volume $vol $video_file`)
    end

    # clear the screen
    print("\e[2J")

    # start running!
    old_time = time()
    for frame in badapple
        seekstart(buf)
        write(buf, "\e[H")
        for row in eachrow(frame)
            for pixel in row
                sc = SimpleColor(reinterpret(NTuple{3,UInt8}, pixel)...)
                f = Face(; background=sc)
                write(buf, styled"{$f:  }")
            end
            write(buf, '\n')
        end
        seekstart(buf)
        write(stdout, buf)
        flush(stdout)
        t = time() - old_time
        sleep_time = max(0, 1/30 - t)
        frametime = round(t; digits=5)
        stats && print(styled"""
        {grey:Frametime:     $frametime
        Sleep:         $(round(sleep_time; digits=5))}
        """)
        sleep(sleep_time)
        old_time = time()
    end
    wait(audio)
end

!isinteractive() && main()
