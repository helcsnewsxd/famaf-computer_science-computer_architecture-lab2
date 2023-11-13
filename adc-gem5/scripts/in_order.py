import m5
from m5.objects import *
from common.cores.arm import HPI
 

class BP_local(LocalBP):
    localPredictorSize = 1024
    localCtrBits = 2

class BP_tournament(TournamentBP):
    localPredictorSize = 64
    localCtrBits = 2
    localHistoryTableSize = 64
    globalPredictorSize = 1024
    globalCtrBits = 2
    choicePredictorSize = 1024
    choiceCtrBits = 2
    BTBEntries = 128
    BTBTagSize = 18
    RASSize = 8
    instShiftAmt = 2

class ICache(Cache):
    data_latency = 1
    tag_latency = 1
    response_latency = 1
    mshrs = 2
    tgts_per_mshr = 8
    size = "32kB"
    assoc = 2

class DCache(Cache):
    data_latency = 1
    tag_latency = 1
    response_latency = 1
    mshrs = 4
    tgts_per_mshr = 8
    size = "32kB"
    assoc = 2
    write_buffers = 4
    prefetcher = StridePrefetcher(queue_size=4, degree=4)

class L2(Cache):
    data_latency = 13
    tag_latency = 13
    response_latency = 5
    mshrs = 4
    tgts_per_mshr = 8
    size = "1024kB"
    assoc = 16
    write_buffers = 16

cpu_name = __name__
cpu_spec = (HPI.HPI, ICache, DCache, L2, BP_local)

