
{
  config,
  lib,
  pkgs,
  ...
}:

{
  ###### Printers ######
  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [ hplip canon-cups-ufr2 cnijfilter2 ];
  # cups-browsed auto-creates duplicate implicitclass:// queues for the same printer
  services.printing.browsed.enable = false;
  
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Canon-TS3100-nixconfig";
        location = "Home";
        deviceUri = "ipp://10.0.0.233/ipp/print";
        model = "everywhere";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
    ensureDefaultPrinter = "Canon-TS3100-nixconfig";
  };

}