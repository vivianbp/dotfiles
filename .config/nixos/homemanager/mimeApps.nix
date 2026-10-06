{ ... }:

{
  xdg.desktopEntries = {
    fontforge = {
      name = "FontForge";
      genericName = "Font Editor";
      exec = "fontforge %F";
      terminal = false;
      type = "Application";
      icon = "fontforge";
      categories = [ "Graphics" "X-FontEditor" ];
      mimeType = [
        "font/otf" "font/ttf" "font/woff" "font/woff2"
        "application/x-font-ttf" "application/x-font-otf"
        "application/vnd.ms-fontobject" "application/x-font-type1"
      ];
    };

    feh = {
      name = "Feh";
      genericName = "Image viewer";
      comment = "Image viewer and cataloguer";
      exec = "feh -F.Z --start-at %u";
      terminal = false;
      type = "Application";
      icon = "feh";
      categories = [ "Graphics" "2DGraphics" "Viewer" ];
      mimeType = [
        "image/bmp" "image/gif" "image/jpeg" "image/jpg" "image/pjpeg"
        "image/png" "image/tiff" "image/webp" "image/x-bmp" "image/x-pcx"
        "image/x-png" "image/x-portable-anymap" "image/x-portable-bitmap"
        "image/x-portable-graymap" "image/x-portable-pixmap" "image/x-tga"
        "image/x-xbitmap" "image/heic"
      ];
      noDisplay = true;
    };
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # browser
      "text/html"                       = "app.zen_browser.zen.desktop";
      "x-scheme-handler/http"           = "app.zen_browser.zen.desktop";
      "x-scheme-handler/https"          = "app.zen_browser.zen.desktop";
      "x-scheme-handler/about"          = "app.zen_browser.zen.desktop";
      "x-scheme-handler/unknown"        = "app.zen_browser.zen.desktop";
      "x-scheme-handler/chrome"         = "app.zen_browser.zen.desktop";
      "application/x-extension-htm"     = "app.zen_browser.zen.desktop";
      "application/x-extension-html"    = "app.zen_browser.zen.desktop";
      "application/x-extension-shtml"   = "app.zen_browser.zen.desktop";
      "application/xhtml+xml"           = "app.zen_browser.zen.desktop";
      "application/x-extension-xhtml"   = "app.zen_browser.zen.desktop";
      "application/x-extension-xht"     = "app.zen_browser.zen.desktop";
      "x-scheme-handler/webcal"         = "app.zen_browser.zen.desktop";
      "x-scheme-handler/mailto"         = "app.zen_browser.zen.desktop";
      "application/pdf"                 = "app.zen_browser.zen.desktop";

      # text / editor
      "text/plain"                      = "org.kde.kate.desktop";

      # code / markup → kwrite
      "text/markdown"                   = "org.kde.kate.desktop";
      "text/xml"                        = "org.kde.kate.desktop";
      "text/css"                        = "org.kde.kate.desktop";
      "text/javascript"                 = "org.kde.kate.desktop";
      "application/json"                = "org.kde.kate.desktop";
      "application/x-sh"                = "org.kde.kate.desktop";
      "application/x-shellscript"       = "org.kde.kate.desktop";

      # messaging
      "x-scheme-handler/tg"             = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite"        = "org.telegram.desktop.desktop";
      "x-scheme-handler/sgnl"           = "signal.desktop";
      "x-scheme-handler/signalcaptcha"  = "signal.desktop";

      # images
      "image/jpeg"                      = "feh.desktop";
      "image/png"                       = "feh.desktop";
      "image/gif"                       = "feh.desktop";
      "image/svg+xml"                   = "feh.desktop";
      "image/tiff"                      = "feh.desktop";
      "image/avif"                      = "feh.desktop";
      "image/webp"                      = "feh.desktop";
      "image/jp2"                       = "feh.desktop";

      # video
      "video/1d-interleaved-parityfec"              = "vlc.desktop";
      "video/3gpp"                                  = "vlc.desktop";
      "video/3gpp2"                                 = "vlc.desktop";
      "video/3gpp-tt"                               = "vlc.desktop";
      "video/AV1"                                   = "vlc.desktop";
      "video/BMPEG"                                 = "vlc.desktop";
      "video/BT656"                                 = "vlc.desktop";
      "video/CelB"                                  = "vlc.desktop";
      "video/DV"                                    = "vlc.desktop";
      "video/encaprtp"                              = "vlc.desktop";
      "video/evc"                                   = "vlc.desktop";
      "video/example"                               = "vlc.desktop";
      "video/FFV1"                                  = "vlc.desktop";
      "video/flexfec"                               = "vlc.desktop";
      "video/H261"                                  = "vlc.desktop";
      "video/H263"                                  = "vlc.desktop";
      "video/H263-1998"                             = "vlc.desktop";
      "video/H263-2000"                             = "vlc.desktop";
      "video/H264"                                  = "vlc.desktop";
      "video/H264-RCDO"                             = "vlc.desktop";
      "video/H264-SVC"                              = "vlc.desktop";
      "video/H265"                                  = "vlc.desktop";
      "video/H266"                                  = "vlc.desktop";
      "video/iso.segment"                           = "vlc.desktop";
      "video/JPEG"                                  = "vlc.desktop";
      "video/jpeg2000"                              = "vlc.desktop";
      "video/jpeg2000-scl"                          = "vlc.desktop";
      "video/jxsv"                                  = "vlc.desktop";
      "video/lottie+json"                           = "vlc.desktop";
      "video/matroska"                              = "vlc.desktop";
      "video/matroska-3d"                           = "vlc.desktop";
      "video/mj2"                                   = "vlc.desktop";
      "video/MP1S"                                  = "vlc.desktop";
      "video/MP2P"                                  = "vlc.desktop";
      "video/MP2T"                                  = "vlc.desktop";
      "video/mp4"                                   = "vlc.desktop";
      "video/MP4V-ES"                               = "vlc.desktop";
      "video/MPV"                                   = "vlc.desktop";
      "video/mpeg"                                  = "vlc.desktop";
      "video/mpeg4-generic"                         = "vlc.desktop";
      "video/nv"                                    = "vlc.desktop";
      "video/ogg"                                   = "vlc.desktop";
      "video/parityfec"                             = "vlc.desktop";
      "video/pointer"                               = "vlc.desktop";
      "video/quicktime"                             = "vlc.desktop";
      "video/raptorfec"                             = "vlc.desktop";
      "video/raw"                                   = "vlc.desktop";
      "video/rtp-enc-aescm128"                      = "vlc.desktop";
      "video/rtploopback"                           = "vlc.desktop";
      "video/rtx"                                   = "vlc.desktop";
      "video/scip"                                  = "vlc.desktop";
      "video/smpte291"                              = "vlc.desktop";
      "video/SMPTE292M"                             = "vlc.desktop";
      "video/ulpfec"                                = "vlc.desktop";
      "video/vc1"                                   = "vlc.desktop";
      "video/vc2"                                   = "vlc.desktop";
      "video/vnd.blockfact.factv"                   = "vlc.desktop";
      "video/vnd.CCTV"                              = "vlc.desktop";
      "video/vnd.dece.hd"                           = "vlc.desktop";
      "video/vnd.dece.mobile"                       = "vlc.desktop";
      "video/vnd.dece.mp4"                          = "vlc.desktop";
      "video/vnd.dece.pd"                           = "vlc.desktop";
      "video/vnd.dece.sd"                           = "vlc.desktop";
      "video/vnd.dece.video"                        = "vlc.desktop";
      "video/vnd.directv.mpeg"                      = "vlc.desktop";
      "video/vnd.directv.mpeg-tts"                  = "vlc.desktop";
      "video/vnd.dlna.mpeg-tts"                     = "vlc.desktop";
      "video/vnd.dvb.file"                          = "vlc.desktop";
      "video/vnd.fvt"                               = "vlc.desktop";
      "video/vnd.hns.video"                         = "vlc.desktop";
      "video/vnd.iptvforum.1dparityfec-1010"        = "vlc.desktop";
      "video/vnd.iptvforum.1dparityfec-2005"        = "vlc.desktop";
      "video/vnd.iptvforum.2dparityfec-1010"        = "vlc.desktop";
      "video/vnd.iptvforum.2dparityfec-2005"        = "vlc.desktop";
      "video/vnd.iptvforum.ttsavc"                  = "vlc.desktop";
      "video/vnd.iptvforum.ttsmpeg2"                = "vlc.desktop";
      "video/vnd.motorola.video"                    = "vlc.desktop";
      "video/vnd.motorola.videop"                   = "vlc.desktop";
      "video/vnd.mpegurl"                           = "vlc.desktop";
      "video/vnd.ms-playready.media.pyv"            = "vlc.desktop";
      "video/vnd.nokia.interleaved-multimedia"      = "vlc.desktop";
      "video/vnd.nokia.mp4vr"                       = "vlc.desktop";
      "video/vnd.nokia.videovoip"                   = "vlc.desktop";
      "video/vnd.objectvideo"                       = "vlc.desktop";
      "video/vnd.planar"                            = "vlc.desktop";
      "video/vnd.radgamettools.bink"                = "vlc.desktop";
      "video/vnd.radgamettools.smacker"             = "vlc.desktop";
      "video/vnd.sealed.mpeg1"                      = "vlc.desktop";
      "video/vnd.sealed.mpeg4"                      = "vlc.desktop";
      "video/vnd.sealed.swf"                        = "vlc.desktop";
      "video/vnd.sealedmedia.softseal.mov"          = "vlc.desktop";
      "video/vnd.uvvu.mp4"                          = "vlc.desktop";
      "video/vnd.youtube.yt"                        = "vlc.desktop";
      "video/vnd.vivo"                              = "vlc.desktop";
      "video/VP8"                                   = "vlc.desktop";
      "video/VP9"                                   = "vlc.desktop";

      # audio
      "audio/mpeg"                                  = "vlc.desktop";
      "audio/ogg"                                   = "vlc.desktop";
      "audio/flac"                                  = "vlc.desktop";
      "audio/wav"                                   = "vlc.desktop";
      "audio/x-wav"                                 = "vlc.desktop";
      "audio/aac"                                   = "vlc.desktop";
      "audio/mp4"                                   = "vlc.desktop";
      "audio/x-m4a"                                 = "vlc.desktop";
      "audio/opus"                                  = "vlc.desktop";
      "audio/webm"                                  = "vlc.desktop";
      "audio/x-flac"                                = "vlc.desktop";

      # fonts → fontforge
      "font/otf"                                    = "org.fontforge.FontForge.desktop";
      "font/ttf"                                    = "org.fontforge.FontForge.desktop";
      "font/woff"                                   = "org.fontforge.FontForge.desktop";
      "font/woff2"                                  = "org.fontforge.FontForge.desktop";
      "application/x-font-ttf"                      = "org.fontforge.FontForge.desktop";
      "application/x-font-otf"                      = "org.fontforge.FontForge.desktop";
      "application/vnd.ms-fontobject"               = "org.fontforge.FontForge.desktop";
      "application/x-font-type1"                    = "org.fontforge.FontForge.desktop";

      # torrents → transmission
      "application/x-bittorrent"                    = "transmission-qt.desktop";
      "x-scheme-handler/magnet"                     = "transmission-qt.desktop";

      # office documents → libreoffice
      "application/vnd.oasis.opendocument.text"                        = "writer.desktop";
      "application/vnd.oasis.opendocument.text-template"               = "writer.desktop";
      "application/vnd.oasis.opendocument.spreadsheet"                 = "calc.desktop";
      "application/vnd.oasis.opendocument.spreadsheet-template"        = "calc.desktop";
      "application/vnd.oasis.opendocument.presentation"                = "impress.desktop";
      "application/vnd.oasis.opendocument.presentation-template"       = "impress.desktop";
      "application/vnd.oasis.opendocument.graphics"                    = "draw.desktop";
      "application/msword"                                             = "writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"   = "writer.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.template"   = "writer.desktop";
      "application/vnd.ms-excel"                                       = "calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"         = "calc.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.template"      = "calc.desktop";
      "application/vnd.ms-powerpoint"                                  = "impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.template"     = "impress.desktop";
      "text/csv"                                                       = "calc.desktop";

      # scheme handlers
      "x-scheme-handler/zoom"                       = "Zoom.desktop";
      "x-scheme-handler/zoommtg"                    = "Zoom.desktop";
      "x-scheme-handler/zoomus"                     = "Zoom.desktop";
      "x-scheme-handler/slack"                      = "slack.desktop";
    };
  };
}
