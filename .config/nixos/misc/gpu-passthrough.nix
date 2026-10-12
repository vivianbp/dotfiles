##
## GPU passthrough (kerrigan): RTX 3050 -> WinApps Windows guest (see winapps-host.nix)
## Stage A: IOMMU only. VT-d must also be enabled in the BIOS.
##

{ ... }:
{
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
  ];
}
