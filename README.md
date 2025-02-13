# 🔌 PlugKit
A MacOS MenuBar app built with SwiftUI for controlling Philips Hue Smart Plugs via CoreBluetooth.

# Bluetooth Info
> The device advertises a vendor specific service 932c32bd-0000-47a2-835a-a8d455b859dd, and a power state characteristic 932c32bd-0002-47a2-835a-a8d455b859dd. The characteristic has the value 0x00 when the plug is turned off, and 0x01 when the plug is turned on.

Via [Kcede](https://github.com/kcede/plughub)

---
> [!IMPORTANT] 
> If you have already paired with you Smart Plug via the Hue App over Bluetooth, you may need to factory reset the plug via the app first before using this app. You can then pair again to your phone via the app.

> [!NOTE]
> [Other developers doing similar](https://github.com/alexhorn/libhueble), have found you may not need to factory reset and can instead just do the following:
> 
> *In the Hue BT app, go to Settings > Voice Assistants > Amazon Alexa and tap Make visible.*
> 
> I did not find that this worked, but you can always try.

# Credits 
The following repositories were very helpful in creating this app:
- [PlugHub](https://github.com/kcede/plughub)
- [Py-Hue](https://github.com/LucaDorinAnton/py-hue)
