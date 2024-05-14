# StyledApple.jl

[`Bad Apple!!`](https://www.youtube.com/watch?v=i41KoE0iMYU) rendered using [StyledStrings.jl](https://github.com/JuliaLang/StyledStrings.jl)

This isn't doing anything fancy, just displaying the raw `.webm` frames through `styled""`. It would probably be smarter to do more
preprocessing so that continuous runs can be colored at once.

When run in a terminal, this also attempts to play audio through `ffplay`. I have not taken too much care that everything is synced up
(the duration is off by about 0.2s on my machine), but the playback should (roughly) happen with 30 FPS :)

You can view a partial recording here:

[![asciicast](https://asciinema.org/a/QN7AZgyhQE0QtEeNBLqVGwiOs.svg)](https://asciinema.org/a/QN7AZgyhQE0QtEeNBLqVGwiOs)
