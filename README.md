# spice-gtk-autologin

> **Retired project.** It is no longer developed. The scripts are kept here as
> they were last packaged, and the package stays available on the openSUSE
> Build Service for existing installations.

Turns a machine into a thin client for a virtual machine: at boot it starts X
with a minimal window manager and the SPICE client `spicy` in full screen,
connected to the SPICE display of the VM. There is no login screen.

- Audio is forwarded through PulseAudio, the keyboard to the VM.
- A USB device can be redirected when connecting (`--spice-usbredir-redirect-on-connect`).
- USB redirection costs CPU even while idle, so `spicy` is stopped after a
  period without mouse input and the display is switched off. It is started
  again on the next input.
- Plymouth is told to quit, so the boot splash does not keep the screen.

## Files

| File | Installed as | Purpose |
|---|---|---|
| `spice-xinit.service` | `/usr/lib/systemd/system/spice-gtk-autologin.service` | runs `startx` with the wrapper, restarts it if it ends |
| `spicy_xinit_wrapper.sh` | `/usr/bin/spicy_xinit_wrapper.sh` | runs as root in X: quits Plymouth, prepares permissions, starts the session as user `spicy` |
| `spicy_xinit.sh` | `/usr/bin/spicy_xinit.sh` | the session: icewm-lite, PulseAudio, `spicy`, idle handling |

The package creates the system user `spicy` (groups `audio`, `video`).

## Configuration

Environment variables of `spicy_xinit.sh`, set with
`systemctl edit spice-gtk-autologin.service`:

```ini
[Service]
Environment=SPICY_HOST=vmhost.example.org SPICY_PORT=5900
```

| Variable | Default | Meaning |
|---|---|---|
| `SPICY_HOST` | `localhost` | host of the SPICE display |
| `SPICY_PORT` | `5900` | port of the SPICE display |
| `SPICY_EXTRA_ARG` | redirect USB device `0x413c:0x2107` | further arguments of `spicy` |
| `SPICY_IDLE_COUNTER_MS` | `100000` | stop `spicy` after this many ms without mouse input |
| `SPICY_SLEEP_DURATION` | `30` | seconds between two checks |
| `SPICY_ERR_FILE` | `/tmp/spicy.log` | output of `spicy` |
| `SPICY_DEBUG` | | if set, trace the script and play a test sound |

USB redirection may ask for a password; allow the polkit action
`org.spice-space.lowlevelusbaccess` for the user `spicy`.

## Requirements

bash, X with `startx` and `xset`, spice-gtk (`spicy`,
`spice-client-glib-usb-acl-helper`), icewm-lite, xprintidle, PulseAudio,
ALSA, sudo, and optionally Plymouth.

## Packages

openSUSE packages are built on the
[openSUSE Build Service](https://build.opensuse.org/package/show/home:Aikhjarto/spice-gtk-autologin).

## License

GPL-2.0-or-later. See [LICENSE](LICENSE).
