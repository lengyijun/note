2020年 12月 20日 星期日 10:22:13 CST
sgx explain 4.10

Ascend and Phantom
The Ascend [52] and Phantom [132] secure processors
introduced practical implementations of Oblivious RAM
[65] techniques in the CPU’s memory controller. These
processors are resilient to attackers who can probe the
DRAM address bus and attempt to learn a container’s
private information from its DRAM memory access pat-
tern.
Implementing an ORAM scheme in a memory con-
troller is largely orthogonal to the other secure archi-
tectures described above. It follows, for example, that
Ascend’s ORAM implementation can be combined with
Aegis’ memory encryption and authentication, and with
Sanctum’s hardware extensions and security monitor,
yielding a secure processor that can withstand both soft-
ware attacks and physical DRAM attacks.


