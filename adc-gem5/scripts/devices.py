# Copyright (c) 2016-2017, 2019, 2021-2023 Arm Limited
# All rights reserved.
#
# The license below extends only to copyright in the software and shall
# not be construed as granting a license to any other intellectual
# property including but not limited to intellectual property relating
# to a hardware implementation of the functionality of the software
# licensed hereunder.  You may use the software subject to the license
# terms below provided that you ensure that this notice is replicated
# unmodified and in its entirety in all distributions of the software,
# modified or unmodified, in source code or in binary form.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# System components used by the bigLITTLE.py configuration script

import m5
from m5.objects import *

m5.util.addToPath("/opt/gem5/configs")
from common.Caches import *

class ArmCpuCluster(CpuCluster):
    def __init__(
        self,
        system,
        num_cpus,
        cpu_clock,
        cpu_voltage,
        cpu_type,
        l1i_type,
        l1d_type,
        l2_type,
        bp_type,
        tarmac_gen=False,
        tarmac_dest=None,
    ):
        super().__init__()
        self._cpu_type = cpu_type
        self._l1i_type = l1i_type
        self._l1d_type = l1d_type
        self._l2_type = l2_type
        self._bp_type = bp_type

        assert num_cpus > 0

        self.voltage_domain = VoltageDomain(voltage=cpu_voltage)
        self.clk_domain = SrcClockDomain(
            clock=cpu_clock, voltage_domain=self.voltage_domain
        )

        self.generate_cpus(cpu_type, num_cpus)

        for cpu in self.cpus:
            if tarmac_gen:
                cpu.tracer = TarmacTracer()
                if tarmac_dest is not None:
                    cpu.tracer.outfile = tarmac_dest

        system.addCpuCluster(self)

    def addBP(self):
        for cpu in self.cpus:
            bp = None if self._bp_type is None else self._bp_type()
        cpu.branchPred = bp

    def addL1(self):
        for cpu in self.cpus:
            l1i = None if self._l1i_type is None else self._l1i_type()
            l1d = None if self._l1d_type is None else self._l1d_type()
            cpu.addPrivateSplitL1Caches(l1i, l1d)

    def addL2(self, clk_domain):
        if self._l2_type is None:
            return
        self.toL2Bus = L2XBar(width=64, clk_domain=clk_domain)
        self.l2 = self._l2_type()
        for cpu in self.cpus:
            cpu.connectCachedPorts(self.toL2Bus.cpu_side_ports)
        self.toL2Bus.mem_side_ports = self.l2.cpu_side

    def addPMUs(
        self,
        ints,
        events=[],
        exit_sim_on_control=False,
        exit_sim_on_interrupt=False,
    ):
        """
        Instantiates 1 ArmPMU per PE. The method is accepting a list of
        interrupt numbers (ints) used by the PMU and a list of events to
        register in it.

        :param ints: List of interrupt numbers. The code will iterate over
            the cpu list in order and will assign to every cpu in the cluster
            a PMU with the matching interrupt.
        :type ints: List[int]
        :param events: Additional events to be measured by the PMUs
        :type events: List[Union[ProbeEvent, SoftwareIncrement]]
        :param exit_sim_on_control: If true, exit the sim loop when the PMU is
            enabled, disabled, or reset.
        :type exit_on_control: bool
        :param exit_sim_on_interrupt: If true, exit the sim loop when the PMU
            triggers an interrupt.
        :type exit_on_control: bool

        """
        assert len(ints) == len(self.cpus)
        for cpu, pint in zip(self.cpus, ints):
            int_cls = ArmPPI if pint < 32 else ArmSPI
            for isa in cpu.isa:
                isa.pmu = ArmPMU(interrupt=int_cls(num=pint))
                isa.pmu.exitOnPMUControl = exit_sim_on_control
                isa.pmu.exitOnPMUInterrupt = exit_sim_on_interrupt
                isa.pmu.addArchEvents(
                    cpu=cpu,
                    itb=cpu.mmu.itb,
                    dtb=cpu.mmu.dtb,
                    icache=getattr(cpu, "icache", None),
                    dcache=getattr(cpu, "dcache", None),
                    l2cache=getattr(self, "l2", None),
                )
                for ev in events:
                    isa.pmu.addEvent(ev)

    def connectMemSide(self, bus):
        try:
            self.l2.mem_side = bus.cpu_side_ports
        except AttributeError:
            for cpu in self.cpus:
                cpu.connectCachedPorts(bus.cpu_side_ports)

