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
    cond = Condition()
    audio_start = Ref{Float64}()
    audio_end = Ref{Float64}()

    # ffplay takes 0-100
    vol = round(Int, clamp(volume, 0, 100))
    audio = @async ffplay() do exe
        wait(cond)
        audio_start[] = time()
        success(`$exe -autoexit -nodisp -volume $vol $video_file`)
        audio_end[] = time()
    end

    # clear the screen
    print("\e[2J")

    # start running!
    old_time = time()
    start_time = time()
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
        notify(cond)
        cur_time = time()
        render_time = cur_time - old_time
        if stats
            frametime = round(render_time; digits=5)
            print(styled"""
            {grey:Frametime:     $frametime}""")
        end
        while time() < (cur_time+(1/29.97-render_time))
            # busy wait, task yielding is expensive
        end
        old_time = time()
    end

    if stats
        total_time = time() - start_time
        mins, secs = divrem(total_time, 60)
        imins = round(Int, mins)
        secs = round(secs, sigdigits=3)
        println("\nVideo Duration: $(imins)m $(secs)s")
        wait(audio)
        audio_time = audio_end[] - audio_start[]
        mins, secs = divrem(audio_time, 60)
        imins = round(Int, mins)
        secs = round(secs, sigdigits=3)
        println("Audio Duration: $(imins)m $(secs)s")
    end
end

!isinteractive() && main(;stats=true)
