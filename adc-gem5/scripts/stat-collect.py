import sys

stat_names = [
    # cpu
    "simInsts",                                                 # Number of instructions simulated (Count)
    "system.cpu_cluster.cpus.numCycles",                        # Number of cpu cycles simulated (Cycle)

    # branch predictor
    "system.cpu_cluster.cpus.branchPred.lookups",               # Number of BP lookups (Count)
    "system.cpu_cluster.cpus.branchPred.condPredicted",         # Number of conditional branches predicted (Count)
    "system.cpu_cluster.cpus.branchPred.condIncorrect",         # Number of conditional branches incorrect (Count)
    "system.cpu_cluster.cpus.branchPred.BTBLookups",            # Number of BTB lookups (Count)
    "system.cpu_cluster.cpus.branchPred.BTBUpdates",            # Number of BTB updates (Count)
    "system.cpu_cluster.cpus.branchPred.BTBHits",               # Number of BTB hits (Count)

    # instruction classes
    "system.cpu_cluster.cpus.commitStats0.committedInstType::IntAlu",      # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::IntMult",     # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::IntDiv",      # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::FloatAdd",    # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::FloatCmp",    # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::FloatCvt",    # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::FloatMult",   # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::MemRead",     # Class of committed instruction. (Count)
    "system.cpu_cluster.cpus.commitStats0.committedInstType::MemWrite",    # Class of committed instruction. (Count)

    # dcache (l1)
    "system.cpu_cluster.cpus.dcache.overallHits::total",        # number of overall hits (Count)
    "system.cpu_cluster.cpus.dcache.overallMisses::total",      # number of overall misses (Count)
    "system.cpu_cluster.cpus.dcache.overallAccesses::total",    # number of overall (read+write) accesses (Count)
    "system.cpu_cluster.cpus.dcache.replacements",              # number of replacements (Count)
    "system.cpu_cluster.cpus.dcache.ReadReq.hits::total",       # number of ReadReq hits (Count)
    "system.cpu_cluster.cpus.dcache.ReadReq.accesses::total",   # number of ReadReq accesses(hits+misses) (Count)
    "system.cpu_cluster.cpus.dcache.WriteReq.hits::total",      # number of WriteReq hits (Count)
    "system.cpu_cluster.cpus.dcache.WriteReq.accesses::total",  # number of WriteReq accesses(hits+misses) (Count)
    
    # icache (l1)
    "system.cpu_cluster.cpus.icache.overallHits::total",        # number of overall hits (Count)
    "system.cpu_cluster.cpus.icache.overallMisses::total",      # number of overall misses (Count)
    "system.cpu_cluster.cpus.icache.overallAccesses::total",    # number of overall (read+write) accesses (Count)
    "system.cpu_cluster.cpus.icache.replacements",

    # l2
    "system.cpu_cluster.l2.overallMisses::total",               # number of overall misses (Count)
    "system.cpu_cluster.l2.overallAccesses::total",             # number of overall (read+write) accesses (Count)
    "system.cpu_cluster.l2.replacements",                       # number of replacements (Count)

    # other
    "system.cpu_cluster.cpus.idleCycles",                       # Total number of cycles that the object has spent stopped (Unspecified)
]

stats = { name: [] for name in stat_names }

def retrieve_stats(filename):
    stat_names_iterator = iter(stat_names + stat_names + [None])
    current_stat = next(stat_names_iterator)

    with open(filename) as f:
        for line in f:
            # out of order also writes the stats out of order :)
            if current_stat == stat_names[-1]:
                current_stat = next(stat_names_iterator)
                continue
            if current_stat and current_stat in line:
                value = float(line.split()[1])
                stats[current_stat].append(value)
                current_stat = next(stat_names_iterator)

        f.seek(0)
        for line in f:
            # out of order also writes the stats out of order :)
            if len(stats[stat_names[-1]]) >= 2:
                break
            if stat_names[-1] in line:
                value = float(line.split()[1])
                stats[stat_names[-1]].append(value)

retrieve_stats(sys.argv[1])
for key in stats:
    print(f"{key:70} {(stats[key][1] - stats[key][0])}")
    if key == "simInsts":
        numInst = stats[key][1] - stats[key][0]
    if key == "system.cpu_cluster.cpus.numCycles":
        numCycles = stats[key][1] - stats[key][0]
        key = "system.cpu_cluster.cpus.cpi" 
        print(f"{key:70} {numCycles/numInst:.2f}")
