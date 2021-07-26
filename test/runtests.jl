using PosteriorPlots
using Test

import Logging

#------------- Build some demo models ---------------



#------------- Run package tests --------------------

# Silence all warnings

level = Logging.min_enabled_level(Logging.current_logger())
Logging.disable_logging(Logging.Warn)

@testset "PosteriorPlots.jl" begin
    # Write your tests here.
end

# Reset log level

Logging.disable_logging(level)
