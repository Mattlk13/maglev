# Class Maglev::Gprof is identically Smalltalk ProfMonitorTree
#

module Maglev
  Gprof = Object._resolve_smalltalk_global(:ProfMonitorTree)
  class Gprof

    class_primitive '__monitor&', 'monitorIntervalNs:block:'

    # Returns a String which is the gprof-style profiling analysis of
    # statistical sampling during execution of block.
    # The interval_ns argument should be adjusted to yield 50000 to 200000 
    # samples.  A sample interval too small may result in too many samples
    # and a NoMemoryError during the analysis of the samples.
    # The default value of interval_ns is suitable for profiling
    # an execution that takes 5 to 20 seconds of cpu time without
    # profiling enabled.  
    # A first estimate for interval_ns may be computed by
    #  ((cpu time without profiling in seconds) * 5 / 100000 / 1.0e-9).to_int
    # See also the method  compute_interval .
    #
    def self.monitor(interval_ns = 1000000, &block)
      self.__monitor(interval_ns) { block.call }   
    end

    # Return a profiling interval in nanoseconds, for an operation
    # which takes the specified number of cpu seconds without profiling.
    #
    def self.compute_interval(unprofiled_cputime_seconds)
      ns = (5.0 * unprofiled_cputime_seconds / 100000 / 1.0e-9).to_int
      if ns < 1000
        ns = 1000
      end
      ns
    end
  end
end
