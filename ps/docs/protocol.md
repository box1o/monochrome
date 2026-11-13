# DPS-150 USB protocol

Primary reference: FNIRSI's [official communication protocol, listed as v1.6][protocol],
pages 1–4, checked on 13 November 2026. See also the [user manual][manual] and
[official downloads page][downloads].

No commands were sent to our device. Compatibility with its firmware is not yet verified.

## Packets

```text
Host → device: F1 CMD REG LEN DATA… CHECKSUM
Device → host: F0 CMD REG LEN DATA… CHECKSUM
CHECKSUM = (REG + LEN + sum(DATA)) & FF
```

`LEN` counts payload bytes. The checksum excludes header and command. Floats
occupy four bytes; flags occupy one. Read with `A1`, payload `00`; write with `B1`.

The [working Linux driver][driver] uses USB CDC `2e3c:5740`, 115200 baud, 8N1,
float32 little-endian and at least 50 ms between commands. These transport and
timing details come from implementations, not the official protocol sheet.

**Byte-order caveat:** the official input-voltage example lists `41 40 00 00`,
which resembles big-endian 12 V. The examined driver and upstream capture use
little-endian. Confirm read-only measurements on our unit before enabling writes.

## Registers

Official table, PDF pages 2–3. `RW` means readable/writable.

| Address | Value | Type | Access |
| --- | --- | --- | --- |
| `C0` | Input voltage | float | R |
| `C1`, `C2` | Voltage/current setpoints | float | RW |
| `C3` | Measured voltage, current, power | 3 floats | R |
| `C4` | Temperature, °C | float | R |
| `C5–D0` | Six preset voltage/current pairs | float | RW |
| `D1–D5` | OVP, OCP, OPP, OTP, undervoltage thresholds | float | RW |
| `D6`, `D7` | Brightness, volume | byte | RW |
| `D8` | Metering enabled | byte | RW |
| `D9`, `DA` | Capacity, energy | float | R |
| `DB` | Output enabled | byte | RW |
| `DC`, `DD` | Protection status, CC/CV mode | byte | R |
| `E1` | Device address | byte | R |
| `E2`, `E3` | Voltage/current setting ceilings | float | R |
| `E4–E8` | Corresponding protection-setting ceilings | float | R |

Manufacturer-defined values:

- Brightness: `1–14`; volume: `0–14`, with zero muted.
- Metering and output: `0 = off`, `1 = on`.
- Mode: `0 = CC`, `1 = CV`.
- Protection: `0 = OK`, `1 = OVP`, `2 = OCP`, `3 = OPP`, `4 = OTP`,
  `5 = UVP`. Preserve and display unknown codes; do not reinterpret them.

## Session and read examples

Calculated examples; not transmitted:

```text
Connect session:    F1 C1 00 01 01 02
Read input voltage: F1 A1 C0 01 00 C1
Read output state:  F1 A1 DB 01 00 DC
Disconnect session: F1 C1 00 01 00 01
```

After connecting, read the device state. Send session-disconnect before closing
the serial port. Session command `C1` is distinct from register `C1`.

**Command `C0` enters the bootloader.** It is unrelated to reading register `C0`.
Exclude it from the normal backend allowlist. Do not probe unknown commands.

## Implementation boundaries

Start with read-only monitoring. Before allowing writes, confirm model/firmware,
byte order, flags and live limits. Reject non-finite values and validate each
setting against its own ceiling; read back changes. Never enable output on
startup or reconnect, and never assume closing the connection turns output off.

Use Micro USB for data. The manual forbids simultaneous DC and USB-C power and
notes that PC connection locks the front panel. Test initially without a load.

Community drivers additionally use `DE–E0` for identity and `FF` for a packed
139-byte dump. **Their numeric addresses and dump offsets are not specified in
the official sheet.** Keep these as compatibility extensions. In particular,
the previously unknown dump tail may correspond to the newly documented ceilings,
but its offsets remain an inference until checked.

Sweeps and sequences use host timing with normal setpoint writes. Keep calibration
and firmware updates outside this integration.

[downloads]: https://fnirsi.com.cn/download.html
[protocol]: https://fnirsi.com.cn/uploads/file1/20261105/3cd44e35b2ea654f2b75786f3caaf0961793862437668.pdf
[manual]: https://fnirsi.com.cn/uploads/file1/20261009/31425d14baff9429137aaf1f5c302e241791539162370.pdf
[driver]: https://github.com/kaushikray2/fnirsi-dps150/blob/8c84f50a02d8a0d766b4b82c4e01dfb335b8b1df/fnirsi.py
